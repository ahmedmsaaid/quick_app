import 'package:flutter/foundation.dart';
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
    int pageSize = 10,
    List<String>? includesPath = const ["OrderProducts.Product", "User", "UserLocation"],
  }) async {
    try {
      final response = await _dio.patch(
        'orders',
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          'orderDirection': 1,
          if (includesPath != null && includesPath.isNotEmpty)
            "includesPath": includesPath,
          "filters": {"CreatorId": userId},
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
      debugPrint("ERROR IN getOrders: $e");
      debugPrint(stack.toString());
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
          'orderDirection': 1,
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
      debugPrint("ERROR IN getOrdersWithFilters: $e");
      debugPrint(stack.toString());
      return ApiResult.failure(handleError(e));
    }
  }

  /// Update the status of an order.
  Future<ApiResult<ApiResponse<bool>>> updateOrderStatus({
    required int orderId,
    required int status,
    int? deliveryId,
    String? rowVersion,
  }) async {
    Future<ApiResponse<bool>> sendPut(String? currentRowVersion) async {
      final parsedRowVersion = currentRowVersion != null
          ? (int.tryParse(currentRowVersion) ?? currentRowVersion)
          : null;
      final response = await _dio.put(
        'orders/status',
        data: {
          'id': orderId,
          'status': status,
          if (deliveryId != null) 'deliveryId': deliveryId,
          if (parsedRowVersion != null) 'rowVersion': parsedRowVersion,
        },
      );
      return ApiResponse<bool>.fromJson(response.data, (json) {
        return json is bool ? json : (json == true);
      });
    }

    try {
      final apiResponse = await sendPut(rowVersion);
      if (apiResponse.success) {
        // Verify that the backend actually transitioned the order to the target status.
        // If the first PUT only assigned the driver or advanced to an intermediate state,
        // send a second PUT with the fresh rowVersion automatically so one user action suffices.
        final verifyRes = await getOrderById(
          orderId: orderId,
          includesPath: const [],
        );
        if (verifyRes is Success<ApiResponse<OrderDto>>) {
          final latestOrder = verifyRes.data.result;
          if (latestOrder != null && latestOrder.status != status) {
            final secondAttempt = await sendPut(latestOrder.rowVersion);
            return ApiResult.success(secondAttempt);
          }
        }
        return ApiResult.success(apiResponse);
      }
    } catch (_) {
      // Fall through to retry with fresh rowVersion
    }

    // Retry after fetching latest rowVersion (handles stale rowVersion after acceptOrder or vendor status updates)
    try {
      final latestOrderRes = await getOrderById(
        orderId: orderId,
        includesPath: const [],
      );
      String? freshRowVersion = rowVersion;
      if (latestOrderRes is Success<ApiResponse<OrderDto>>) {
        freshRowVersion =
            latestOrderRes.data.result?.rowVersion ?? freshRowVersion;
      }
      final retryResponse = await sendPut(freshRowVersion);
      if (retryResponse.success) {
        final verifyRes = await getOrderById(
          orderId: orderId,
          includesPath: const [],
        );
        if (verifyRes is Success<ApiResponse<OrderDto>>) {
          final latestOrder = verifyRes.data.result;
          if (latestOrder != null && latestOrder.status != status) {
            final secondAttempt = await sendPut(latestOrder.rowVersion);
            return ApiResult.success(secondAttempt);
          }
        }
      }
      return ApiResult.success(retryResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Retrieve a single order by ID with specific include paths (User, Creator, OrderProducts.Product).
  Future<ApiResult<ApiResponse<OrderDto>>> getOrderById({
    required int orderId,
    List<String>? includesPath,
  }) async {
    try {
      final response = await _dio.patch(
        'orders/$orderId',
        data: {
          'orderDirection': 1,
          "includesPath": includesPath ?? const ["User", "Creator", "OrderProducts.Product", "Delivery", "UserLocation"],
        },
      );
      final apiResponse = ApiResponse<OrderDto>.fromJson(response.data, (json) {
        return OrderDto.fromJson(json as Map<String, dynamic>);
      });
      return ApiResult.success(apiResponse);
    } catch (e, stack) {
      debugPrint("ERROR IN getOrderById: $e");
      debugPrint(stack.toString());
      return ApiResult.failure(handleError(e));
    }
  }
}
