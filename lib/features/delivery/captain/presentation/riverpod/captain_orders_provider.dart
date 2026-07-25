import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';

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

  const CaptainOrdersState({
    this.status = CaptainOrdersStatus.initial,
    this.availableOrders = const [],
    this.activeOrders = const [],
    this.finishedOrders = const [],
    this.todayOrdersCount = 0,
    this.todayEarnings = 0.0,
    this.errorMessage,
  });

  CaptainOrdersState copyWith({
    CaptainOrdersStatus? status,
    List<OrderDto>? availableOrders,
    List<OrderDto>? activeOrders,
    List<OrderDto>? finishedOrders,
    int? todayOrdersCount,
    double? todayEarnings,
    String? errorMessage,
  }) {
    return CaptainOrdersState(
      status: status ?? this.status,
      availableOrders: availableOrders ?? this.availableOrders,
      activeOrders: activeOrders ?? this.activeOrders,
      finishedOrders: finishedOrders ?? this.finishedOrders,
      todayOrdersCount: todayOrdersCount ?? this.todayOrdersCount,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class CaptainOrders extends _$CaptainOrders {
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
        if (currentStatus != CaptainOrdersStatus.loaded || userChanged) {
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

  Future<void> loadAll() async {
    if (state.status == CaptainOrdersStatus.loading) return;
    state = state.copyWith(status: CaptainOrdersStatus.loading);

    final profileState = ref.read(profileProvider);
    final user = profileState.user;
    if (user == null) {
      if (profileState.status == ProfileStatus.loading ||
          profileState.status == ProfileStatus.initial) {
        return;
      }
      state = state.copyWith(
        status: CaptainOrdersStatus.error,
        errorMessage: 'الرجاء تسجيل الدخول أولاً لرؤية الطلبات',
      );
      return;
    }

    final apiService = ref.read(ordersApiServiceProvider);

    // ✅ call واحدة بس — بفلتر DeliveryId وعناصر أساسية فقط لتقليل حجم الريسبونس في الهوم
    final result = await apiService.getOrdersWithFilters(
      includesPath: const ['Creator'],
      filters: {'DeliveryId': user?.id},
      pageSize: 100,
    );

    if (!ref.mounted) return;

    result.when(
      success: (response) {
        final list = response.result ?? [];

        // ✅ تقسيم النتيجة هنا
        final available = list
            .where((o) => o.status == 2 )
            .toList();

        final active = list
            .where(
              (o) => o.deliveryId == user.id && o.status >= 2 && o.status <= 6,
            )
            .toList();

        final finished = list
            .where((o) => o.deliveryId == user.id && o.status == 7)
            .toList();

        // إحصائيات اليوم
        final now = DateTime.now();
        final todayStart = DateTime(now.year, now.month, now.day);
        final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

        final todayCompleted = finished.where((o) {
          if (o.createdOn == null) return false;
          try {
            final date = DateTime.parse(o.createdOn!);
            return date.isAfter(todayStart) && date.isBefore(todayEnd);
          } catch (_) {
            return false;
          }
        }).toList();

        state = CaptainOrdersState(
          status: CaptainOrdersStatus.loaded,
          availableOrders: available,
          activeOrders: active,
          finishedOrders: finished,
          todayOrdersCount: todayCompleted.length,
          todayEarnings: todayCompleted.fold(0.0, (sum, o) => sum + o.deliveryFee),
        );
      },
      failure: (e) => state = state.copyWith(
        status: CaptainOrdersStatus.error,
        errorMessage: e.message,
      ),
    );
  }

  /// قبول طلب متاح (update status من 2 إلى 3)
  Future<bool> acceptOrder(OrderDto order) async {
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: 3,
      rowVersion: order.rowVersion,
    );
    if (!ref.mounted) return false;

    return result.when(
      success: (response) {
        if (response.success) {
          loadAll();
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
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: newStatus,
      rowVersion: order.rowVersion,
    );
    if (!ref.mounted) return false;

    return result.when(
      success: (response) {
        if (response.success) {
          loadAll();
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
      includesPath: const ['Creator'],
      pageSize: 100,
    );
    if (!ref.mounted) return;

    List<OrderDto> active = [];
    List<OrderDto> finished = [];
    String? error;

    result.when(
      success: (response) {
        final list = response.result ?? [];
        final filteredList = list.where((o) => o.deliveryId == user.id).toList();
        active = filteredList.where((o) => o.status >= 2 && o.status <= 6).toList();
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
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: newStatus,
      rowVersion: order.rowVersion,
    );
    if (!ref.mounted) return false;

    return result.when(
      success: (response) {
        if (response.success) {
          loadOrders();
          // Refresh general provider to update stats
          ref.read(captainOrdersProvider.notifier).loadAll();
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
