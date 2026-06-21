import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';

part 'product_search_provider.g.dart';

enum ProductSearchStatus { initial, loading, loaded, error }

class ProductSearchState {
  final ProductSearchStatus status;
  final List<ProductDetailDto> products;
  final String? errorMessage;

  const ProductSearchState({
    this.status = ProductSearchStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  ProductSearchState copyWith({
    ProductSearchStatus? status,
    List<ProductDetailDto>? products,
    String? errorMessage,
  }) {
    return ProductSearchState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class ProductSearchNotifier extends _$ProductSearchNotifier {
  @override
  ProductSearchState build() => const ProductSearchState();

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const ProductSearchState();
      return;
    }

    state = state.copyWith(status: ProductSearchStatus.loading);

    final result = await ref.read(homeApiServiceProvider).searchProducts(query: query);

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = ProductSearchState(
            status: ProductSearchStatus.loaded,
            products: response.result!,
          );
        } else {
          state = state.copyWith(
            status: ProductSearchStatus.error,
            errorMessage: response.message ?? 'فشل تحميل نتائج البحث',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: ProductSearchStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }
}
