import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

part 'orders_api_service.g.dart';

@riverpod
OrdersApiService ordersApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return OrdersApiService(dio);
}

class OrdersApiService {
  final Dio _dio;

  OrdersApiService(this._dio);

  /// Fetch orders list with creatorId filter.
  Future<ApiResult<ApiResponse<List<OrderDto>>>> getOrders({
    required int userId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.patch(
        'orders',
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          "includesPath": ["User"],
          "filters": {"userId": userId},
        },
      );
      final apiResponse = ApiResponse<List<OrderDto>>.fromJson(response.data, (
        json,
      ) {
        if (json is List) {
          return json
              .map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
      return ApiResult.success(apiResponse);
    } catch (e, stack) {
      print("ERROR IN getOrders: $e");
      print(stack);
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch orders with flexible filters and optional include paths.
  Future<ApiResult<ApiResponse<List<OrderDto>>>> getOrdersWithFilters({
    Map<String, dynamic>? filters,
    List<String>? includesPath,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.patch(
        'orders',
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          if (includesPath != null && includesPath.isNotEmpty) "includesPath": includesPath,
          if (filters != null && filters.isNotEmpty) "filters": filters,
        },
      );
      final apiResponse = ApiResponse<List<OrderDto>>.fromJson(response.data, (
        json,
      ) {
        if (json is List) {
          return json
              .map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
      return ApiResult.success(apiResponse);
    } catch (e, stack) {
      print("ERROR IN getOrdersWithFilters: $e");
      print(stack);
      return ApiResult.failure(handleError(e));
    }
  }

  /// Update the status of an order.
  Future<ApiResult<ApiResponse<bool>>> updateOrderStatus({
    required int orderId,
    required int status,
    String? rowVersion,
  }) async {
    try {
      final response = await _dio.put(
        'orders/status',
        data: {
          'id': orderId,
          'status': status,
          if (rowVersion != null) 'rowVersion': rowVersion,
        },
      );
      final apiResponse = ApiResponse<bool>.fromJson(response.data, (json) {
        return json is bool ? json : (json == true);
      });
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Retrieve a single order by ID with specific include paths.
  Future<ApiResult<ApiResponse<OrderDto>>> getOrderById({
    required int orderId,
    required List<String> includesPath,
  }) async {
    try {
      final response = await _dio.patch(
        'orders/$orderId',
        data: {
          "includesPath": includesPath,
        },
      );
      final apiResponse = ApiResponse<OrderDto>.fromJson(response.data, (json) {
        return OrderDto.fromJson(json as Map<String, dynamic>);
      });
      return ApiResult.success(apiResponse);
    } catch (e, stack) {
      print("ERROR IN getOrderById: $e");
      print(stack);
      return ApiResult.failure(handleError(e));
    }
  }
}
