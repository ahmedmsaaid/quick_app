import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_dashboard_provider.dart';
import 'package:base_app/core/services/audio/order_sound_service.dart';

part 'captain_orders_provider.g.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CaptainOrders — الطلبات المتاحة + إحصائيات الكابتن
// ─────────────────────────────────────────────────────────────────────────────

enum CaptainOrdersStatus { initial, loading, loaded, error }

class CaptainOrdersState {
  final CaptainOrdersStatus status;
  final List<OrderDto> availableOrders;
  final List<OrderDto> activeOrders;
  final List<OrderDto> finishedOrders;
  final int todayOrdersCount;
  final double todayEarnings;
  final String? errorMessage;
  final int availablePage;
  final bool hasMoreAvailable;
  final bool isLoadingMoreAvailable;

  const CaptainOrdersState({
    this.status = CaptainOrdersStatus.initial,
    this.availableOrders = const [],
    this.activeOrders = const [],
    this.finishedOrders = const [],
    this.todayOrdersCount = 0,
    this.todayEarnings = 0.0,
    this.errorMessage,
    this.availablePage = 1,
    this.hasMoreAvailable = true,
    this.isLoadingMoreAvailable = false,
  });

  CaptainOrdersState copyWith({
    CaptainOrdersStatus? status,
    List<OrderDto>? availableOrders,
    List<OrderDto>? activeOrders,
    List<OrderDto>? finishedOrders,
    int? todayOrdersCount,
    double? todayEarnings,
    String? errorMessage,
    int? availablePage,
    bool? hasMoreAvailable,
    bool? isLoadingMoreAvailable,
  }) {
    return CaptainOrdersState(
      status: status ?? this.status,
      availableOrders: availableOrders ?? this.availableOrders,
      activeOrders: activeOrders ?? this.activeOrders,
      finishedOrders: finishedOrders ?? this.finishedOrders,
      todayOrdersCount: todayOrdersCount ?? this.todayOrdersCount,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      errorMessage: errorMessage ?? this.errorMessage,
      availablePage: availablePage ?? this.availablePage,
      hasMoreAvailable: hasMoreAvailable ?? this.hasMoreAvailable,
      isLoadingMoreAvailable:
          isLoadingMoreAvailable ?? this.isLoadingMoreAvailable,
    );
  }
}

@Riverpod(keepAlive: true)
class CaptainOrders extends _$CaptainOrders {
  static const int _pageSize = 20;

  @override
  CaptainOrdersState build() {
    // Listener: نادي loadAll لما يتحمل الـ profile للمرة الأولى أو يتغير المستخدم
    ref.listen(profileProvider, (previous, next) {
      final wasLoaded = previous?.status == ProfileStatus.loaded;
      final isNowLoaded =
          next.status == ProfileStatus.loaded && next.user != null;
      if (!wasLoaded && isNowLoaded) {
        final currentStatus = state.status;
        final userChanged = previous?.user?.id != next.user?.id;
        if (currentStatus == CaptainOrdersStatus.initial || userChanged) {
          loadAll();
        }
      }
    });

    // لو الـ profile اتحمل قبل ما الـ provider يتبني (عند الرجوع للشاشة مثلاً)
    final profile = ref.read(profileProvider);
    if (profile.status == ProfileStatus.loaded && profile.user != null) {
      Future.microtask(() => loadAll());
    }
    return const CaptainOrdersState();
  }

  Future<void> loadAll({bool forceRefresh = false}) async {
    if (state.status == CaptainOrdersStatus.loading && !forceRefresh) return;
    state = state.copyWith(
      status: CaptainOrdersStatus.loading,
      errorMessage: null,
      availablePage: 1,
      hasMoreAvailable: true,
      isLoadingMoreAvailable: false,
    );

    try {
      final profileState = ref.read(profileProvider);
      final user = profileState.user;
      if (user == null) {
        state = state.copyWith(
          status: CaptainOrdersStatus.error,
          errorMessage: 'الرجاء تسجيل الدخول أولاً لرؤية الطلبات',
        );
        return;
      }

      final apiService = ref.read(ordersApiServiceProvider);

      final availableFuture = apiService.getOrdersWithFilters(
        pageNumber: 1,
        pageSize: _pageSize,
        includesPath: const ['User', 'Creator', 'UserLocation'],
        filters: {'DeliveryId': user.id},
      );

      final myOrdersFuture = apiService.getOrdersWithFilters(
        pageNumber: 1,
        pageSize: 100,
        includesPath: const ['User', 'Creator', 'UserLocation'],
        filters: {'DeliveryId': user.id},
      );

      final results = await Future.wait([availableFuture, myOrdersFuture]);
      if (!ref.mounted) return;

      final availableResult = results[0];
      final myOrdersResult = results[1];

      List<OrderDto> availableOrders = [];
      bool hasMore = true;

      availableResult.when(
        success: (response) {
          final list = response.result ?? [];
          availableOrders = list.where((o) {
            final hasNoDelivery = (o.deliveryId == null || o.deliveryId == 0);
            final isAvailableStatus = (o.status == 2 || o.status == 0 || o.status == 1 || o.status == 5);
            final isAssignedToMePending =
                (o.deliveryId == user.id && (o.status == 2 || o.status == 0 || o.status == 1 || o.status == 5));
            return (hasNoDelivery && isAvailableStatus) || isAssignedToMePending;
          }).toList();
          hasMore = list.length >= _pageSize;
        },
        failure: (_) {
          hasMore = false;
        },
      );

      List<OrderDto> activeOrders = [];
      List<OrderDto> finishedOrders = [];
      double todayEarnings = 0.0;
      int todayOrdersCount = 0;

      myOrdersResult.when(
        success: (response) {
          final list = response.result ?? [];
          activeOrders = list
              .where((o) =>
                  o.deliveryId == user.id &&
                  o.status >= 3 &&
                  o.status <= 6)
              .toList();
          finishedOrders = list
              .where((o) => o.deliveryId == user.id && o.status == 7)
              .toList();

          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd =
              DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

          final todayCompleted = finishedOrders.where((o) {
            if (o.createdOn == null) return false;
            try {
              final raw = o.createdOn!.trim();
              final hasZone = raw.endsWith('Z') ||
                  RegExp(r'[+-]\d{2}:?\d{2}$').hasMatch(raw);
              final parsed = DateTime.parse(hasZone ? raw : '${raw}Z').toLocal();
              return !parsed.isBefore(todayStart) && !parsed.isAfter(todayEnd);
            } catch (_) {
              return false;
            }
          }).toList();

          todayOrdersCount = todayCompleted.length;
          todayEarnings = todayCompleted.fold(0.0, (sum, o) => sum + o.deliveryFee);
        },
        failure: (_) {},
      );

      state = state.copyWith(
        status: CaptainOrdersStatus.loaded,
        availableOrders: availableOrders,
        activeOrders: activeOrders,
        finishedOrders: finishedOrders,
        todayOrdersCount: todayOrdersCount,
        todayEarnings: todayEarnings,
        availablePage: 1,
        hasMoreAvailable: hasMore,
        isLoadingMoreAvailable: false,
      );
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(
          status: CaptainOrdersStatus.error,
          errorMessage: 'حدث خطأ أثناء جلب الطلبات',
        );
      }
    }
  }

  /// تحميل المزيد من الطلبات المتاحة (Infinite Scroll)
  Future<void> loadMoreAvailableOrders() async {
    if (!state.hasMoreAvailable ||
        state.isLoadingMoreAvailable ||
        state.status != CaptainOrdersStatus.loaded) {
      return;
    }

    final user = ref.read(profileProvider).user;
    if (user == null) return;

    state = state.copyWith(isLoadingMoreAvailable: true);

    try {
      final nextPage = state.availablePage + 1;
      final apiService = ref.read(ordersApiServiceProvider);

      final result = await apiService.getOrdersWithFilters(
        pageNumber: nextPage,
        pageSize: _pageSize,
        includesPath: const ['User', 'Creator', 'UserLocation'],
        filters: {'DeliveryId': user.id},
      );

      if (!ref.mounted) return;

      result.when(
        success: (response) {
          final list = response.result ?? [];
          final newAvailable = list.where((o) {
            final hasNoDelivery = (o.deliveryId == null || o.deliveryId == 0);
            final isAvailableStatus = (o.status == 2 || o.status == 0 || o.status == 1 || o.status == 5);
            final isAssignedToMePending =
                (o.deliveryId == user.id && (o.status == 2 || o.status == 0 || o.status == 1 || o.status == 5));
            return (hasNoDelivery && isAvailableStatus) || isAssignedToMePending;
          }).toList();

          final existingIds = state.availableOrders.map((o) => o.id).toSet();
          final uniqueNew =
              newAvailable.where((o) => !existingIds.contains(o.id)).toList();

          state = state.copyWith(
            availableOrders: [...state.availableOrders, ...uniqueNew],
            availablePage: nextPage,
            hasMoreAvailable: list.length >= _pageSize,
            isLoadingMoreAvailable: false,
          );
        },
        failure: (_) {
          state = state.copyWith(
            isLoadingMoreAvailable: false,
            hasMoreAvailable: false,
          );
        },
      );
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isLoadingMoreAvailable: false);
      }
    }
  }

  /// قبول طلب متاح (update status من 2 إلى 3)
  Future<bool> acceptOrder(OrderDto order) async {
    OrderSoundService.stopRingtone();
    final profileState = ref.read(profileProvider);
    final user = profileState.user;
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: 3,
      deliveryId: user?.id,
      rowVersion: order.rowVersion,
    );
    if (!ref.mounted) return false;

    return result.when(
      success: (response) {
        if (response.success) {
          OrderSoundService.stopRingtone();
          loadAll(forceRefresh: true);
          ref.read(captainMyOrdersProvider.notifier).loadOrders();
          return true;
        }
        return false;
      },
      failure: (_) => false,
    );
  }

  /// تحديث status الطلب النشط
  Future<bool> updateStatus(OrderDto order, int newStatus) async {
    OrderSoundService.stopRingtone();
    final profileState = ref.read(profileProvider);
    final user = profileState.user;
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: newStatus,
      deliveryId: user?.id,
      rowVersion: order.rowVersion,
    );
    if (!ref.mounted) return false;

    return result.when(
      success: (response) {
        if (response.success) {
          ref.invalidate(captainDashboardProvider);
          ref.invalidate(captainWalletDashboardProvider);
          ref.invalidate(captainWalletSummaryProvider);
          loadAll(forceRefresh: true);
          ref.read(captainMyOrdersProvider.notifier).loadOrders();
          return true;
        }
        return false;
      },
      failure: (_) => false,
    );
  }
  /// ميثود خاصة للتفاصيل — بتجيب كل البيانات في الـ includesPath
  Future<OrderDto?> getOrderDetails(int orderId) async {
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.getOrderById(
      orderId: orderId,
      includesPath: const [
        'User',
        'Creator',
        'OrderProducts.Product',
        'UserLocation',
        'Delivery',
      ],
    );
    return result.when(
      success: (response) =>
          response.success && response.result != null ? response.result : null,
      failure: (_) => null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CaptainMyOrders — مشاوير الكابتن (تاب "مشاواري")
// ─────────────────────────────────────────────────────────────────────────────

enum MyOrdersStatus { initial, loading, loaded, error }

class MyOrdersState {
  final MyOrdersStatus status;
  final List<OrderDto> activeOrders;
  final List<OrderDto> finishedOrders;
  final String? errorMessage;

  const MyOrdersState({
    this.status = MyOrdersStatus.initial,
    this.activeOrders = const [],
    this.finishedOrders = const [],
    this.errorMessage,
  });

  MyOrdersState copyWith({
    MyOrdersStatus? status,
    List<OrderDto>? activeOrders,
    List<OrderDto>? finishedOrders,
    String? errorMessage,
  }) {
    return MyOrdersState(
      status: status ?? this.status,
      activeOrders: activeOrders ?? this.activeOrders,
      finishedOrders: finishedOrders ?? this.finishedOrders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class CaptainMyOrders extends _$CaptainMyOrders {
  @override
  MyOrdersState build() {
    // لا تعمل microtask هنا — الـ CaptainOrders provider بيتولى التحميل عند الفتح
    // loadOrders بيتعمل manually لما الكابتن يدخل تاب "مشاواري"
    return const MyOrdersState();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(status: MyOrdersStatus.loading);

    final profileState = ref.read(profileProvider);
    final user = profileState.user;
    if (user == null) {
      state = state.copyWith(
        status: MyOrdersStatus.error,
        errorMessage: 'الرجاء تسجيل الدخول أولاً لرؤية الطلبات',
      );
      return;
    }

    final apiService = ref.read(ordersApiServiceProvider);

    // جيب طلبات الكابتن بفلتر deliveryId والبيانات الأساسية فقط لتقليل حجم الريسبونس
    final result = await apiService.getOrdersWithFilters(
      filters: {'DeliveryId': user.id},
      includesPath: const ['User', 'Creator', 'UserLocation'],
      pageSize: 100,
    );
    if (!ref.mounted) return;

    List<OrderDto> active = [];
    List<OrderDto> finished = [];
    String? error;

    result.when(
      success: (response) {
        final list = response.result ?? [];
        final filteredList = list.where((o) => o.deliveryId == user.id || o.deliveryId == null).toList();
        active = filteredList.where((o) => o.status >= 3 && o.status <= 6).toList();
        finished = filteredList.where((o) => o.status == 7).toList();
      },
      failure: (e) => error = e.message,
    );

    if (error != null) {
      state = state.copyWith(status: MyOrdersStatus.error, errorMessage: error);
    } else {
      state = MyOrdersState(
        status: MyOrdersStatus.loaded,
        activeOrders: active,
        finishedOrders: finished,
      );
    }
  }

  /// تحديث status الطلب النشط
  Future<bool> updateStatus(OrderDto order, int newStatus) async {
    final profileState = ref.read(profileProvider);
    final user = profileState.user;
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: newStatus,
      deliveryId: user?.id,
      rowVersion: order.rowVersion,
    );
    if (!ref.mounted) return false;

    return result.when(
      success: (response) {
        if (response.success) {
          ref.invalidate(captainDashboardProvider);
          loadOrders();
          // Refresh general provider to update stats
          ref.read(captainOrdersProvider.notifier).loadAll(forceRefresh: true);
          return true;
        }
        return false;
      },
      failure: (_) => false,
    );
  }
  /// ميثود خاصة للتفاصيل — بتجيب كل البيانات في الـ includesPath
  Future<OrderDto?> getOrderDetails(int orderId) async {
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.getOrderById(
      orderId: orderId,
      includesPath: const [
        'User',
        'Creator',
        'OrderProducts.Product',
        'UserLocation',
        'Delivery',
      ],
    );
    return result.when(
      success: (response) =>
          response.success && response.result != null ? response.result : null,
      failure: (_) => null,
    );
  }
}
