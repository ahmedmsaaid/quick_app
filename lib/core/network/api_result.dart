import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:base_app/core/error/app_error.dart';

part 'api_result.freezed.dart';

@Freezed()
abstract class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.failure(AppError appError) = Failure<T>;
}
