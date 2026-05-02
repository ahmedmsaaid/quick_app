import 'package:dio/dio.dart';
import '../../core/error/error_handler.dart';
import '../../core/network/api_result.dart';

/// Extension على Future<T> لتبسيط معالجة الأخطاء في الـ Repository
extension RepositoryExecutor<T> on Future<T> {
  /// تنفيذ عملية Repository مع معالجة الأخطاء التلقائية
  Future<ApiResult<R>> execute<R>({
    required R Function(T data) onSuccess,
  }) async {
    try {
      final result = await this;
      return ApiResult.success(onSuccess(result));
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// تنفيذ عملية Repository وإرجاع البيانات مباشرة (للحالات البسيطة)
  Future<ApiResult<T>> executeSimple() async {
    try {
      final result = await this;
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}

/// Helper class لتنفيذ عمليات Repository
class RepositoryHelper {
  /// تنفيذ عملية Repository مع mapper function
  static Future<ApiResult<R>> execute<T, R>({
    required Future<T> Function() call,
    required R Function(T data) mapper,
  }) async {
    try {
      final result = await call();
      return ApiResult.success(mapper(result));
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// تنفيذ عملية Repository بدون mapper
  static Future<ApiResult<T>> executeSimple<T>({
    required Future<T> Function() call,
  }) async {
    try {
      final result = await call();
      return ApiResult.success(result);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// تنفيذ عملية Repository مع List mapper
  static Future<ApiResult<List<R>>> executeList<T, R>({
    required Future<List<T>> Function() call,
    required R Function(T item) mapper,
  }) async {
    try {
      final result = await call();
      final mappedResult = result.map(mapper).toList();
      return ApiResult.success(mappedResult);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// تنفيذ عملية Repository مع pagination
  static Future<ApiResult<PaginatedResult<R>>> executePaginated<T, R>({
    required Future<PaginatedData<T>> Function() call,
    required R Function(T item) mapper,
  }) async {
    try {
      final result = await call();
      final mappedItems = result.items.map(mapper).toList();
      return ApiResult.success(
        PaginatedResult<R>(
          items: mappedItems,
          total: result.total,
          skip: result.skip,
          limit: result.limit,
        ),
      );
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}

/// Data class for paginated data from API
class PaginatedData<T> {
  final List<T> items;
  final int total;
  final int skip;
  final int limit;

  PaginatedData({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });
}

/// Data class for paginated result (Entity)
class PaginatedResult<T> {
  final List<T> items;
  final int total;
  final int skip;
  final int limit;

  PaginatedResult({
    required this.items,
    required this.total,
    required this.skip,
    required this.limit,
  });
}
