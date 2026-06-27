import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';

part 'vendor_details_provider.g.dart';

enum VendorDetailsStatus { initial, loading, loaded, error }

class VendorDetailsState {
  final VendorDetailsStatus categoriesStatus;
  final VendorDetailsStatus productsStatus;
  final List<CategoryDto> categories;
  final List<ProductDetailDto> products;
  final CategoryDto? selectedCategory;
  final String? errorMessage;

  const VendorDetailsState({
    this.categoriesStatus = VendorDetailsStatus.initial,
    this.productsStatus = VendorDetailsStatus.initial,
    this.categories = const [],
    this.products = const [],
    this.selectedCategory,
    this.errorMessage,
  });

  VendorDetailsState copyWith({
    VendorDetailsStatus? categoriesStatus,
    VendorDetailsStatus? productsStatus,
    List<CategoryDto>? categories,
    List<ProductDetailDto>? products,
    CategoryDto? selectedCategory,
    bool clearSelectedCategory = false,
    String? errorMessage,
  }) {
    return VendorDetailsState(
      categoriesStatus: categoriesStatus ?? this.categoriesStatus,
      productsStatus: productsStatus ?? this.productsStatus,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@riverpod
class VendorDetailsNotifier extends _$VendorDetailsNotifier {
  CategoryDto? _preSelectedCategory;

  void setPreSelectedCategory(CategoryDto category) {
    _preSelectedCategory = category;
  }

  @override
  VendorDetailsState build(int vendorId) {
    Future.microtask(() => loadVendorData());
    return const VendorDetailsState();
  }

  Future<void> loadVendorData() async {
    state = state.copyWith(
      categoriesStatus: VendorDetailsStatus.loading,
      productsStatus: VendorDetailsStatus.loading,
    );

    final categoriesResult = await ref.read(homeApiServiceProvider).getCategories(
      creatorId: vendorId,
    );

    categoriesResult.when(
      success: (response) async {
        final List<CategoryDto> categories = response.result ?? [];
        CategoryDto? initialCategory = _preSelectedCategory;

        if (initialCategory == null && categories.isNotEmpty) {
          initialCategory = categories.first;
        } else if (initialCategory != null) {
          initialCategory = categories.firstWhere(
            (c) => c.id == initialCategory!.id,
            orElse: () => initialCategory!,
          );
        }

        state = state.copyWith(
          categoriesStatus: VendorDetailsStatus.loaded,
          categories: categories,
          selectedCategory: initialCategory,
        );

        await loadProducts(categoryId: initialCategory?.id);
      },
      failure: (error) {
        state = state.copyWith(
          categoriesStatus: VendorDetailsStatus.error,
          productsStatus: VendorDetailsStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  Future<void> loadProducts({int? categoryId}) async {
    state = state.copyWith(productsStatus: VendorDetailsStatus.loading);

    final result = await ref.read(homeApiServiceProvider).getVendorProducts(
      creatorId: vendorId,
      categoryId: categoryId,
      pageSize: 50,
    );

    result.when(
      success: (response) {
        state = state.copyWith(
          productsStatus: VendorDetailsStatus.loaded,
          products: response.result ?? [],
        );
      },
      failure: (error) {
        state = state.copyWith(
          productsStatus: VendorDetailsStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  void selectCategory(CategoryDto? category) {
    if (state.selectedCategory?.id == category?.id) return;
    state = state.copyWith(
      selectedCategory: category,
      clearSelectedCategory: category == null,
    );
    loadProducts(categoryId: category?.id);
  }
}
