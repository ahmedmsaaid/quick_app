import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/customer/home/data/models/rating_models.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

part 'rating_api_service.g.dart';

@riverpod
RatingApiService ratingApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return RatingApiService(dio);
}

class RatingApiService {
  final Dio _dio;

  RatingApiService(this._dio);

  /// Submit product rating.
  Future<ApiResult<ApiResponse<ProductRatingDto>>> createProductRating({
    required int productId,
    required int value,
    required String note,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.productRating,
        data: CreateProductRatingRequest(
          productId: productId,
          value: value,
          note: note,
        ).toJson(),
      );
      final apiResponse = ApiResponse<ProductRatingDto>.fromJson(
        response.data,
        (json) => ProductRatingDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Submit vendor/user rating.
  Future<ApiResult<ApiResponse<RatingDto>>> createUserRating({
    required int userId,
    required int value,
    required String note,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.userRating,
        data: CreateRatingRequest(
          userId: userId,
          value: value,
          note: note,
        ).toJson(),
      );
      final apiResponse = ApiResponse<RatingDto>.fromJson(
        response.data,
        (json) => RatingDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch product ratings.
  Future<ApiResult<ApiResponse<List<ProductRatingDto>>>> getProductRatings({
    required int productId,
    int pageNumber = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.productRating,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': false,
          'includesPath': ['Creator'],
          'filters': {
            'productId': productId,
          }
        },
      );
      final apiResponse = ApiResponse<List<ProductRatingDto>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => ProductRatingDto.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch user/vendor ratings.
  Future<ApiResult<ApiResponse<List<RatingDto>>>> getUserRatings({
    required int userId,
    int pageNumber = 1,
    int pageSize = 100,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.userRating,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': false,
          'includesPath': ['Creator'],
          'filters': {
            'userId': userId,
          }
        },
      );
      final apiResponse = ApiResponse<List<RatingDto>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => RatingDto.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
