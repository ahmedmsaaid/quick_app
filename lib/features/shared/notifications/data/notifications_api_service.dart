// lib/features/shared/notifications/data/notifications_api_service.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/shared/notifications/data/notification_model.dart';

part 'notifications_api_service.g.dart';

@riverpod
NotificationsApiService notificationsApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsApiService(dio);
}

class NotificationsApiService {
  final Dio _dio;
  const NotificationsApiService(this._dio);

  /// GET /api/v1/users/notifications?pageNumber=1&pageSize=20
  Future<ApiResult<ApiResponse<List<NotificationDto>>>> getNotifications({
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getNotifications,
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      final parsed = ApiResponse<List<NotificationDto>>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => (json as List<dynamic>)
            .map((e) => NotificationDto.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// GET /api/v1/users/count-notifications → returns int (unread count)
  Future<ApiResult<ApiResponse<int>>> countNotifications() async {
    try {
      final response = await _dio.get(ApiConstants.countNotifications);
      final parsed = ApiResponse<int>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as int,
      );
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// GET /api/v1/users/read-notifications/{auditId}
  Future<ApiResult<ApiResponse<bool>>> readNotification(int auditId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.readNotification}/$auditId',
      );
      final parsed = ApiResponse<bool>.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as bool? ?? true,
      );
      return ApiResult.success(parsed);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
