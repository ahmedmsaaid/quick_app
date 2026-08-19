import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';

part 'product_search_provider.g.dart';

enum ProductSearchStatus { initial, loading, loaded, error }

class ProductSearchState {
  final ProductSearchStatus status;
  final List<ProductDetailDto> products;
  final List<UserDto> vendors;
  final String? errorMessage;

  const ProductSearchState({
    this.status = ProductSearchStatus.initial,
    this.products = const [],
    this.vendors = const [],
    this.errorMessage,
  });

  ProductSearchState copyWith({
    ProductSearchStatus? status,
    List<ProductDetailDto>? products,
    List<UserDto>? vendors,
    String? errorMessage,
  }) {
    return ProductSearchState(
      status: status ?? this.status,
      products: products ?? this.products,
      vendors: vendors ?? this.vendors,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class ProductSearchNotifier extends _$ProductSearchNotifier {
  @override
  ProductSearchState build() => const ProductSearchState();

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const ProductSearchState();
      return;
    }

    state = state.copyWith(status: ProductSearchStatus.loading);

    final apiService = ref.read(homeApiServiceProvider);

    // Run parallel API requests for Products and Vendors (Restaurants role 0, Markets role 1)
    final results = await Future.wait([
      apiService.searchProducts(query: query.trim()),
      apiService.getUsersPaginate(role: 0, search: query.trim(), pageSize: 20),
      apiService.getUsersPaginate(role: 1, search: query.trim(), pageSize: 20),
    ]);

    final productsResult = results[0] as ApiResult<ApiResponse<List<ProductDetailDto>>>;
    final restaurantsResult = results[1] as ApiResult<ApiResponse<List<UserDto>>>;
    final marketsResult = results[2] as ApiResult<ApiResponse<List<UserDto>>>;

    List<ProductDetailDto> fetchedProducts = [];
    List<UserDto> fetchedVendors = [];
    String? errorMsg;

    productsResult.when(
      success: (response) {
        if (response.success && response.result != null) {
          fetchedProducts = response.result!;
        }
      },
      failure: (error) => errorMsg = error.message,
    );

    restaurantsResult.when(
      success: (response) {
        if (response.success && response.result != null) {
          fetchedVendors.addAll(response.result!);
        }
      },
      failure: (_) {},
    );

    marketsResult.when(
      success: (response) {
        if (response.success && response.result != null) {
          fetchedVendors.addAll(response.result!);
        }
      },
      failure: (_) {},
    );

    // Remove potential duplicate vendors by ID
    final uniqueVendorsMap = <int, UserDto>{};
    for (final v in fetchedVendors) {
      uniqueVendorsMap[v.id] = v;
    }
    final finalVendors = uniqueVendorsMap.values.toList();

    if (fetchedProducts.isNotEmpty || finalVendors.isNotEmpty) {
      state = ProductSearchState(
        status: ProductSearchStatus.loaded,
        products: fetchedProducts,
        vendors: finalVendors,
      );
    } else {
      state = state.copyWith(
        status: ProductSearchStatus.error,
        errorMessage: errorMsg ?? 'لم يتم العثور على أي نتائج للمتاجر أو المنتجات',
      );
    }
  }
}
