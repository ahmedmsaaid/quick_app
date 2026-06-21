import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';

part 'home_api_service.g.dart';

@riverpod
HomeApiService homeApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return HomeApiService(dio);
}

class HomeApiService {
  final Dio _dio;

  HomeApiService(this._dio);

  /// Fetch active offers from backend.
  Future<ApiResult<ApiResponse<List<OfferDto>>>> getOffers({
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.offers,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          'includesPath': ['OfferProducts.Product']
        },
      );
      final apiResponse = ApiResponse<List<OfferDto>>.fromJson(
          response.data, (json,) {
        if (json is List) {
          return json
              .map((e) => OfferDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch a single offer details by ID.
  Future<ApiResult<ApiResponse<OfferDto>>> getOfferById(int id) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.offers}/$id',
        data: {
          'includesPath': ['OfferProducts.Product'],
        },
      );
      final apiResponse = ApiResponse<OfferDto>.fromJson(
        response.data,
            (json) => OfferDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Search/paginate products from backend.
  Future<ApiResult<ApiResponse<List<ProductDetailDto>>>> searchProducts({
    required String query,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.productsPaginate,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          'search': query,
        },
      );
      final apiResponse = ApiResponse<List<ProductDetailDto>>.fromJson(
        response.data,
            (json) {
          if (json is List) {
            return json
                .map(
                  (e) => ProductDetailDto.fromJson(e as Map<String, dynamic>),
            )
                .toList();
          }
          return [];
        },
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch users (vendors) list by role and filters.
  Future<ApiResult<ApiResponse<List<UserDto>>>> getUsersPaginate({
    required int role,
    bool? orderByRate,
    int? categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final queryParams = {
        'role': role,
        'userStatus': 1,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'enablePagination': true,
      };
      if (orderByRate != null) {
        queryParams['orderByRate'] = orderByRate;
      }
      if (categoryId != null) {
        queryParams['categoryId'] = categoryId;
      }

      final response = await _dio.get(
        ApiConstants.usersPaginate,
        queryParameters: queryParams,
      );
      final apiResponse = ApiResponse<List<UserDto>>.fromJson(
          response.data, (json,) {
        if (json is List) {
          return json
              .map((e) => UserDto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return [];
      });
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch categories.
  Future<ApiResult<ApiResponse<List<CategoryDto>>>> getCategories({
    int? creatorId,
  }) async {
    try {
      final Map<String, dynamic> filters = {};
      if (creatorId != null) {
        filters['creatorId'] = creatorId;
      }
      final response = await _dio.patch(
        ApiConstants.categories,
        data: {
          'enablePagination': false,
          'filters': filters,
        },
      );
      final apiResponse = ApiResponse<List<CategoryDto>>.fromJson(
        response.data,
            (json) {
          if (json is List) {
            return json.map((e) =>
                CategoryDto.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch main categories.
  Future<ApiResult<ApiResponse<List<MainCategoryDto>>>> getMainCategories() async {
    try {
      final response = await _dio.patch(
        ApiConstants.mainCategories,
        data: {
          'enablePagination': false,
        },
      );
      final apiResponse = ApiResponse<List<MainCategoryDto>>.fromJson(
        response.data,
            (json) {
          if (json is List) {
            return json.map((e) =>
                MainCategoryDto.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch products by vendor (creatorId) and optional categoryId.
  Future<ApiResult<ApiResponse<List<ProductDetailDto>>>> getVendorProducts({
    required int creatorId,
    int? categoryId,
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    try {
      final Map<String, dynamic> filters = {
        'creatorId': creatorId,
      };
      if (categoryId != null) {
        filters['categoryId'] = categoryId;
      }

      final response = await _dio.patch(
        ApiConstants.productsPaginate,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          'filters': filters,
        },
      );
      final apiResponse = ApiResponse<List<ProductDetailDto>>.fromJson(
        response.data,
            (json) {
          if (json is List) {
            return json.map((e) =>
                ProductDetailDto.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch a single product details by ID.
  Future<ApiResult<ApiResponse<ProductDetailDto>>> getProductById(
      int id) async {
    try {
      final response = await _dio.get('products/$id');
      final apiResponse = ApiResponse<ProductDetailDto>.fromJson(
        response.data,
            (json) => ProductDetailDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch products by categoryId.
  Future<ApiResult<ApiResponse<List<ProductDetailDto>>>> getProductsByCategory({
    required int categoryId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.productsPaginate,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          'filters': {
            'categoryId': categoryId,
          },
        },
      );
      final apiResponse = ApiResponse<List<ProductDetailDto>>.fromJson(
        response.data,
            (json) {
          if (json is List) {
            return json.map((e) =>
                ProductDetailDto.fromJson(e as Map<String, dynamic>)).toList();
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
