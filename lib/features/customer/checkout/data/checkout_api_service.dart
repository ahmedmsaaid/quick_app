import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

part 'checkout_api_service.g.dart';

@riverpod
CheckoutApiService checkoutApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return CheckoutApiService(dio);
}

class CheckoutApiService {
  final Dio _dio;

  CheckoutApiService(this._dio);

  /// Create a new order (normal product order or special offer order).
  Future<ApiResult<ApiResponse<OrderDto>>> createOrder(CreateOrderRequest request) async {
    try {
      final response = await _dio.post(
        'orders',
        data: request.toJson(),
      );
      final apiResponse = ApiResponse<OrderDto>.fromJson(
        response.data,
        (json) => OrderDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
