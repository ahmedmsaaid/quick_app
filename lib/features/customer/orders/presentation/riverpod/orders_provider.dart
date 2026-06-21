import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';

part 'orders_provider.g.dart';

enum OrdersStatus { initial, loading, loaded, error }

class OrdersState {
  final OrdersStatus status;
  final List<OrderDto> orders;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderDto>? orders,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  @override
  OrdersState build() {
    // Automatically load orders on initialization
    Future.microtask(() => loadOrders());
    return const OrdersState();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(status: OrdersStatus.loading);

    final profileState = ref.read(profileProvider);
    final user = profileState.user;
    if (user == null) {
      state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: 'الرجاء تسجيل الدخول أولاً لرؤية الطلبات',
      );
      return;
    }

    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.getOrders(userId: user.id);

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            status: OrdersStatus.loaded,
            orders: response.result!,
          );
        } else {
          state = state.copyWith(
            status: OrdersStatus.error,
            errorMessage: response.message ?? 'فشل تحميل الطلبات',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: OrdersStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }
}
