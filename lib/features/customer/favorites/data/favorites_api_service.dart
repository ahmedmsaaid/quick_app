import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';

part 'favorites_api_service.g.dart';

@riverpod
FavoritesApiService favoritesApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return FavoritesApiService(dio);
}

class FavoritesApiService {
  final Dio _dio;

  FavoritesApiService(this._dio);

  /// Fetch favorite products list.
  Future<ApiResult<ApiResponse<List<ProductDetailDto>>>> getFavoriteProducts({
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.get(
        'products/favorites',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );
      final apiResponse = ApiResponse<List<ProductDetailDto>>.fromJson(response.data, (
        json,
      ) {
        if (json is List) {
          return json
              .map((e) => ProductDetailDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Toggle product favorite status.
  Future<ApiResult<ApiResponse<bool>>> toggleFavoriteProduct(int productId) async {
    try {
      final response = await _dio.patch(
        'favorites',
        queryParameters: {
          'productId': productId,
        },
      );
      final apiResponse = ApiResponse<bool>.fromJson(response.data, (json) {
        if (json is Map && json.containsKey('result')) {
          return json['result'] as bool? ?? false;
        }
        return json as bool? ?? false;
      });
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
