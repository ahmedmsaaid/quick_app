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
    int? creatorId,
  }) async {
    try {
      final Map<String, dynamic> filters = {
        'Active': true,
      };
      if (creatorId != null) {
        filters['creatorId'] = creatorId;
      } else {
        filters['Creator.Role'] = 4;
      }
      final response = await _dio.patch(
        ApiConstants.offers,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          'includesPath': ['OfferProducts.Product'],
          'filters': filters,
        },
      );
      final apiResponse = ApiResponse<List<OfferDto>>.fromJson(response.data, (
        json,
      ) {
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

  /// Fetch a single user details by ID.
  Future<ApiResult<ApiResponse<UserDto>>> getUserById(int id) async {
    try {
      final response = await _dio.get('${ApiConstants.getById}/$id');
      final apiResponse = ApiResponse<UserDto>.fromJson(
        response.data,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Search/paginate products from backend with searchFilter strings.
  Future<ApiResult<ApiResponse<List<ProductDetailDto>>>> searchProducts({
    required String query,
    List<String>? searchFilter,
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
          'sortDirection': 1,
          'search': query,
          'searchFilter': searchFilter ?? const [
            "name",
            "description",
            "Name",
            "Description"
          ],
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

  /// Fetch popular products (all products paginated) from backend.
  Future<ApiResult<ApiResponse<List<ProductDetailDto>>>> getPopularProducts({
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
          'sortDirection': 1,
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

  /// Fetch users (vendors) list by role, search query, and searchFilter.
  Future<ApiResult<ApiResponse<List<UserDto>>>> getUsersPaginate({
    required int role,
    String? search,
    List<String>? searchFilter,
    bool? orderByRate,
    int? categoryId,
    int pageNumber = 1,
    int pageSize = 10,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'role': role,
        'userStatus': 1,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
        'enablePagination': true,
        'sortDirection': 1,
      };

      if (categoryId != null && categoryId > 0) {
        queryParams['categoryId'] = categoryId;
      }

      if (orderByRate != null) {
        queryParams['orderByRate'] = orderByRate;
      }

      // Only attach search & searchFilter parameters when text search is actually performed
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
        queryParams['searchFilter'] = searchFilter ?? const [
          "name",
          "phone",
          "email",
          "description"
        ];
      }

      final response = await _dio.get(
        ApiConstants.usersPaginate,
        queryParameters: queryParams,
      );
      final apiResponse = ApiResponse<List<UserDto>>.fromJson(response.data, (
        json,
      ) {
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
        data: {'enablePagination': false, 'filters': filters},
      );
      final apiResponse = ApiResponse<List<CategoryDto>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((e) => CategoryDto.fromJson(e as Map<String, dynamic>))
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

  /// Fetch main categories.
  Future<ApiResult<ApiResponse<List<MainCategoryDto>>>> getMainCategories({
    int? role,
  }) async {
    try {
      final Map<String, dynamic> filters = {};
      if (role != null) {
        // filters['type'] = role;
      }
      final response = await _dio.patch(
        ApiConstants.mainCategories,
        data: {
          'enablePagination': false,
          if (filters.isNotEmpty) 'filters': filters,
        },
      );
      final apiResponse = ApiResponse<List<MainCategoryDto>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json
                .map((e) => MainCategoryDto.fromJson(e as Map<String, dynamic>))
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

  /// Fetch products by optional vendor (creatorId) and optional categoryId.
  Future<ApiResult<ApiResponse<List<ProductDetailDto>>>> getVendorProducts({
    int? creatorId,
    int? categoryId,
    int pageNumber = 1,
    int pageSize = 50,
  }) async {
    try {
      final Map<String, dynamic> filters = {};
      if (creatorId != null) {
        filters['creatorId'] = creatorId;
      }
      if (categoryId != null) {
        filters['categoryId'] = categoryId;
      }

      final response = await _dio.patch(
        ApiConstants.productsPaginate,
        data: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
          'enablePagination': true,
          'sortDirection': 1,
          if (categoryId != null) 'categoryId': categoryId,
          if (filters.isNotEmpty) 'filters': filters,
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

  /// Fetch a single product details by ID.
  Future<ApiResult<ApiResponse<ProductDetailDto>>> getProductById(
    int id,
  ) async {
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
          'filters': {'categoryId': categoryId},
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
}
