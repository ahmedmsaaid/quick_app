import 'package:base_app/core/network/api_result.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/favorites/data/favorites_api_service.dart';

class FavoritesNotifier extends Notifier<List<ProductDetailDto>> {
  @override
  List<ProductDetailDto> build() {
    Future.microtask(() => fetchFavorites());
    return [];
  }

  Future<void> fetchFavorites() async {
    final apiService = ref.read(favoritesApiServiceProvider);
    final result = await apiService.getFavoriteProducts();
    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = response.result!;
        }
      },
      failure: (error) {
        // Soft fail
      },
    );
  }

  Future<void> toggleFavorite(ProductDetailDto product) async {
    final originallyFav = state.any((p) => p.id == product.id);
    
    // Optimistic UI Update
    if (originallyFav) {
      state = state.where((p) => p.id != product.id).toList();
    } else {
      state = [...state, product];
    }

    // Call API
    final apiService = ref.read(favoritesApiServiceProvider);
    final result = await apiService.toggleFavoriteProduct(product.id);
    
    result.when(
      success: (response) {
        if (!response.success) {
          _revertToggle(product, originallyFav);
        }
      },
      failure: (error) {
        _revertToggle(product, originallyFav);
      },
    );
  }

  void _revertToggle(ProductDetailDto product, bool originallyFav) {
    final currentlyFav = state.any((p) => p.id == product.id);
    if (originallyFav && !currentlyFav) {
      state = [...state, product];
    } else if (!originallyFav && currentlyFav) {
      state = state.where((p) => p.id != product.id).toList();
    }
  }

  bool isFavorite(int productId) {
    return state.any((p) => p.id == productId);
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<ProductDetailDto>>(() {
  return FavoritesNotifier();
});


