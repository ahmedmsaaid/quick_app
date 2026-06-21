import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/checkout/data/checkout_api_service.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

part 'checkout_provider.g.dart';

enum CheckoutStatus { initial, loading, success, error }

class CheckoutState {
  final CheckoutStatus status;
  final String? errorMessage;
  final OrderDto? createdOrder;

  const CheckoutState({
    this.status = CheckoutStatus.initial,
    this.errorMessage,
    this.createdOrder,
  });

  CheckoutState copyWith({
    CheckoutStatus? status,
    String? errorMessage,
    OrderDto? createdOrder,
  }) {
    return CheckoutState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdOrder: createdOrder ?? this.createdOrder,
    );
  }
}

@riverpod
class CheckoutNotifier extends _$CheckoutNotifier {
  @override
  CheckoutState build() => const CheckoutState();

  Future<bool> submitOrder(CreateOrderRequest request) async {
    state = state.copyWith(status: CheckoutStatus.loading);

    final apiService = ref.read(checkoutApiServiceProvider);
    final result = await apiService.createOrder(request);

    return result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            status: CheckoutStatus.success,
            createdOrder: response.result,
          );
          return true;
        } else {
          state = state.copyWith(
            status: CheckoutStatus.error,
            errorMessage: response.message ?? 'فشل تقديم الطلب',
          );
          return false;
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: CheckoutStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }
}
