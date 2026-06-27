import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';

part 'home_provider.g.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState {
  final HomeStatus status;
  final HomeStatus restaurantsStatus;
  final HomeStatus categoriesStatus;
  final HomeStatus recommendedStoresStatus;
  final HomeStatus popularProductsStatus;
  final List<OfferDto> offers;
  final List<UserDto> featuredRestaurants;
  final List<MainCategoryDto> categories;
  final List<UserDto> recommendedStores;
  final List<ProductDetailDto> popularProducts;
  final MainCategoryDto? selectedCategory;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.restaurantsStatus = HomeStatus.initial,
    this.categoriesStatus = HomeStatus.initial,
    this.recommendedStoresStatus = HomeStatus.initial,
    this.popularProductsStatus = HomeStatus.initial,
    this.offers = const [],
    this.featuredRestaurants = const [],
    this.categories = const [],
    this.recommendedStores = const [],
    this.popularProducts = const [],
    this.selectedCategory,
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    HomeStatus? restaurantsStatus,
    HomeStatus? categoriesStatus,
    HomeStatus? recommendedStoresStatus,
    HomeStatus? popularProductsStatus,
    List<OfferDto>? offers,
    List<UserDto>? featuredRestaurants,
    List<MainCategoryDto>? categories,
    List<UserDto>? recommendedStores,
    List<ProductDetailDto>? popularProducts,
    MainCategoryDto? selectedCategory,
    bool clearSelectedCategory = false,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      restaurantsStatus: restaurantsStatus ?? this.restaurantsStatus,
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      recommendedStoresStatus: recommendedStoresStatus ?? this.recommendedStoresStatus,
      popularProductsStatus: popularProductsStatus ?? this.popularProductsStatus,
      offers: offers ?? this.offers,
      featuredRestaurants: featuredRestaurants ?? this.featuredRestaurants,
      categories: categories ?? this.categories,
      recommendedStores: recommendedStores ?? this.recommendedStores,
      popularProducts: popularProducts ?? this.popularProducts,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class HomeNotifier extends _$HomeNotifier {
  @override
  HomeState build() {
    // Automatically load offers, restaurants, categories, recommended stores, and popular products when provider is constructed
    Future.microtask(() {
      loadOffers();
      loadFeaturedRestaurants();
      loadCategories();
      loadRecommendedStores();
      loadPopularProducts();
    });
    return const HomeState();
  }

  Future<void> loadPopularProducts() async {
    state = state.copyWith(popularProductsStatus: HomeStatus.loading);

    final result = await ref.read(homeApiServiceProvider).getPopularProducts();

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            popularProductsStatus: HomeStatus.loaded,
            popularProducts: response.result!,
          );
        } else {
          state = state.copyWith(
            popularProductsStatus: HomeStatus.error,
            errorMessage: response.message ?? 'فشل تحميل المنتجات الأكثر طلباً',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          popularProductsStatus: HomeStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadOffers() async {
    state = state.copyWith(status: HomeStatus.loading);

    final result = await ref.read(homeApiServiceProvider).getOffers();

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            status: HomeStatus.loaded,
            offers: response.result!,
          );
        } else {
          state = state.copyWith(
            status: HomeStatus.error,
            errorMessage: response.message ?? 'فشل تحميل العروض',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: HomeStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadFeaturedRestaurants() async {
    state = state.copyWith(restaurantsStatus: HomeStatus.loading);

    final result = await ref.read(homeApiServiceProvider).getUsersPaginate(
      role: 0,
      orderByRate: true,
      pageSize: 10,
    );

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            restaurantsStatus: HomeStatus.loaded,
            featuredRestaurants: response.result!,
          );
        } else {
          state = state.copyWith(
            restaurantsStatus: HomeStatus.error,
            errorMessage: response.message ?? 'فشل تحميل المطاعم',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          restaurantsStatus: HomeStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadCategories() async {
    state = state.copyWith(categoriesStatus: HomeStatus.loading);

    final result = await ref.read(homeApiServiceProvider).getMainCategories();

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            categoriesStatus: HomeStatus.loaded,
            categories: response.result!,
          );
        } else {
          state = state.copyWith(
            categoriesStatus: HomeStatus.error,
            errorMessage: response.message ?? 'فشل تحميل الأقسام الرئيسية',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          categoriesStatus: HomeStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadRecommendedStores({int? categoryId, int? role}) async {
    state = state.copyWith(recommendedStoresStatus: HomeStatus.loading);

    // Default role is 0 (Restaurants) if null
    final activeRole = role ?? 0;

    final result = await ref.read(homeApiServiceProvider).getUsersPaginate(
      role: activeRole,
      categoryId: categoryId,
      pageSize: 20,
    );

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            recommendedStoresStatus: HomeStatus.loaded,
            recommendedStores: response.result!,
          );
        } else {
          state = state.copyWith(
            recommendedStoresStatus: HomeStatus.error,
            errorMessage: response.message ?? 'فشل تحميل المحلات الموصى بها',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          recommendedStoresStatus: HomeStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  void selectCategory(MainCategoryDto? category) {
    if (state.selectedCategory?.id == category?.id) return;
    state = state.copyWith(
      selectedCategory: category,
      clearSelectedCategory: category == null,
    );
    if (category == null) {
      loadRecommendedStores(categoryId: null, role: 0);
    } else {
      loadRecommendedStores(categoryId: category.id, role: category.userRole);
    }
  }
}

@riverpod
Future<OfferDto> getOfferDetails(Ref ref, int id) async {
  final apiService = ref.watch(homeApiServiceProvider);
  final result = await apiService.getOfferById(id);
  
  return await result.when(
    success: (response) async {
      if (response.success && response.result != null) {
        final offer = response.result!;
        
        // If the offer has products, fetch full details for each product by ID if not already included
        if (offer.products != null && offer.products!.isNotEmpty) {
          final List<ProductDto> fullProducts = [];
          for (final prod in offer.products!) {
            if (prod.name != null && prod.name!.isNotEmpty) {
              fullProducts.add(prod);
              continue;
            }
            final prodResult = await apiService.getProductById(prod.id);
            prodResult.when(
              success: (prodResponse) {
                if (prodResponse.success && prodResponse.result != null) {
                  final fullProd = prodResponse.result!;
                  fullProducts.add(ProductDto(
                    id: fullProd.id,
                    name: fullProd.name,
                    photo: fullProd.photo,
                    description: fullProd.description,
                    price: fullProd.price,
                    categoryId: fullProd.categoryId,
                    creatorId: offer.creatorId,
                  ));
                } else {
                  fullProducts.add(prod);
                }
              },
              failure: (error) {
                fullProducts.add(prod);
              },
            );
          }
          
          return OfferDto(
            id: offer.id,
            name: offer.name,
            price: offer.price,
            featuredPhoto: offer.featuredPhoto,
            otherPhotos: offer.otherPhotos,
            description: offer.description,
            type: offer.type,
            active: offer.active,
            approved: offer.approved,
            numberOfClicks: offer.numberOfClicks,
            numberOfWatches: offer.numberOfWatches,
            numberOfBooking: offer.numberOfBooking,
            numberOfAsks: offer.numberOfAsks,
            createdOn: offer.createdOn,
            creatorId: offer.creatorId,
            creator: offer.creator,
            products: fullProducts,
          );
        }
        
        return offer;
      }
      throw Exception(response.message ?? 'فشل تحميل تفاصيل العرض');
    },
    failure: (error) {
      throw Exception(error.message);
    },
  );
}
