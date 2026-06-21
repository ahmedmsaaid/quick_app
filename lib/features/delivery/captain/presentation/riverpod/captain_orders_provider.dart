import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';

part 'captain_orders_provider.g.dart';

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
    ref.listen(profileProvider, (previous, next) {
      if (next.status == ProfileStatus.loaded && next.user != null) {
        loadAll();
      }
    });

    final profile = ref.read(profileProvider);
    if (profile.status == ProfileStatus.loaded && profile.user != null) {
      Future.microtask(() => loadAll());
    }
    return const CaptainOrdersState();
  }

  Future<void> loadAll() async {
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

    // 1. Fetch available orders (cannot filter by status due to backend Enum filter limitation)
    // We fetch recent orders and filter locally for status == 2 (ready_for_pickup)
    final recentResult = await apiService.getOrdersWithFilters(
      includesPath: ["User","Creator"],
      pageSize: 100,
    );

    // 2. Fetch captain's orders (updated by this captain)
    // We filter by updatorId = user.id and include related data.
    final captainResult = await apiService.getOrdersWithFilters(

      includesPath: ["User", "Creator"],
      pageSize: 100,
    );

    List<OrderDto> available = [];
    List<OrderDto> active = [];
    List<OrderDto> finished = [];
    String? error;

    recentResult.when(
      success: (response) {
        final list = response.result ?? [];
        // In production: only o.status == 2 (Ready for Pickup) should be shown.
        // For testing, we also allow o.status == 0 (Pending) to let you see and test accepting orders.
        available = list.where((o) => o.status == 2 || o.status == 0).toList();
      },
      failure: (e) => error = e.message,
    );

    captainResult.when(
      success: (response) {
        final list = response.result ?? [];
        active = list.where((o) => o.status == 3).toList();
        finished = list.where((o) => o.status == 4).toList();
      },
      failure: (e) => error = error ?? e.message,
    );

    // Calculate today's stats from finished orders
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

    final todayEarningsSum = todayCompleted.fold<double>(
      0.0,
      (sum, item) => sum + item.deliveryFee,
    );

    if (error != null) {
      state = state.copyWith(
        status: CaptainOrdersStatus.error,
        errorMessage: error,
      );
    } else {
      state = CaptainOrdersState(
        status: CaptainOrdersStatus.loaded,
        availableOrders: available,
        activeOrders: active,
        finishedOrders: finished,
        todayOrdersCount: todayCompleted.length,
        todayEarnings: todayEarningsSum,
      );
    }
  }

  /// Accept an available order (update status from 2 to 3)
  Future<bool> acceptOrder(OrderDto order) async {
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: 3,
      rowVersion: order.rowVersion,
    );

    return result.when(
      success: (response) {
        if (response.success) {
          loadAll();
          return true;
        }
        return false;
      },
      failure: (_) => false,
    );
  }

  /// Update active order status
  Future<bool> updateStatus(OrderDto order, int newStatus) async {
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: newStatus,
      rowVersion: order.rowVersion,
    );

    return result.when(
      success: (response) {
        if (response.success) {
          loadAll();
          return true;
        }
        return false;
      },
      failure: (_) => false,
    );
  }
}
