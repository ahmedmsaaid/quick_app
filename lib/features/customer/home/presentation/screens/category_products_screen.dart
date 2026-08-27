import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/presentation/screens/all_categories_screen.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  const CategoryProductsScreen({
    super.key,
    required this.category,
    this.categoriesList,
  });

  final CategoryDto category;
  final List<CategoryDto>? categoriesList;

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  late CategoryDto _selectedCategory;
  bool _isLoading = true;
  String? _errorMessage;
  List<ProductDetailDto> _products = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.category;
    _loadProductsForCategory(_selectedCategory.id);
  }

  Future<void> _loadProductsForCategory(int categoryId) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await ref.read(homeApiServiceProvider).getProductsByCategory(
      categoryId: categoryId,
    );

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          setState(() {
            _products = response.result!;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = response.message ?? 'فشل تحميل المنتجات';
            _isLoading = false;
          });
        }
      },
      failure: (error) {
        setState(() {
          _errorMessage = error.message;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          _selectedCategory.name ?? '',
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildCategoriesBar(colors),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildCategoriesBar(AppColors colors) {
    if (widget.categoriesList != null && widget.categoriesList!.isNotEmpty) {
      return _buildCategoriesListView(widget.categoriesList!, colors);
    }

    final subCategoriesAsync = ref.watch(subCategoriesProvider);

    return subCategoriesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        return _buildCategoriesListView(categories, colors);
      },
    );
  }

  Widget _buildCategoriesListView(List<CategoryDto> categories, AppColors colors) {
    return Container(
      height: 52.h,
      color: colors.surface,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => 10.horizontalSpace,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final bool isSelected = cat.id == _selectedCategory.id;
          final String? photoKey = cat.photo;
          final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
              ? (photoKey.startsWith('http') ? photoKey : '${ApiConstants.streamUrl}$photoKey')
              : '';

          return GestureDetector(
            onTap: () {
              if (cat.id != _selectedCategory.id) {
                setState(() {
                  _selectedCategory = cat;
                });
                _loadProductsForCategory(cat.id);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white24 : colors.containerBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: photoUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: photoUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: colors.shimmerBase),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.fastfood_rounded,
                                size: 12.sp,
                                color: isSelected ? Colors.white : colors.textSecondary,
                              ),
                            )
                          : Icon(
                              Icons.fastfood_rounded,
                              size: 12.sp,
                              color: isSelected ? Colors.white : colors.textSecondary,
                            ),
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    cat.name ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? Colors.white : colors.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    final colors = AppColors(context);

    if (_isLoading) {
      return const LoadingButton();
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: colors.error),
              10.verticalSpace,
              Text(
                _errorMessage!,
                style: AppTextStyles.text14w500(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              15.verticalSpace,
              ElevatedButton(
                onPressed: () => _loadProductsForCategory(_selectedCategory.id),
                child: Text(AppStrings.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_basket_outlined, size: 64.sp, color: colors.textHint),
            10.verticalSpace,
            Text(
              'لا توجد منتجات في هذا القسم حالياً',
              style: AppTextStyles.text16w600(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(12.r),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.86,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return _buildProductCard(context, product);
      },
    );
  }

  Widget _buildProductCard(BuildContext context, ProductDetailDto product) {
    final colors = AppColors(context);
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String? photo = product.photo;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    final double price = product.hasDiscount
        ? product.price * (1 - product.discountPercentage / 100)
        : product.price;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: colors.border.withValues(alpha: 0.8), width: 1.0),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => context.pushNamed(
            AppRoutes.storeProductDetailsScreen,
            arguments: {
              'product': product,
              'vendorId': _selectedCategory.creatorId,
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Image Container with discount badge
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(color: colors.shimmerBase),
                              errorWidget: (context, url, error) => Image.asset('assets/image/logo.png', fit: BoxFit.cover),
                            )
                          : Image.asset('assets/image/logo.png', fit: BoxFit.cover),
                      if (product.hasDiscount)
                        Positioned(
                          top: 6.r,
                          right: 6.r,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: colors.error,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 8.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom Compact Info
              Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        fontFamily: 'Cairo',
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                                  style: TextStyle(
                                    fontSize: 8.5.sp,
                                    color: colors.textHint,
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              Text(
                                '${price.toStringAsFixed(0)} ${AppStrings.currency}',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w900,
                                  color: colors.primary,
                                  fontFamily: 'Cairo',
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.5.h),
                          decoration: BoxDecoration(
                            gradient: AppColors.gradient,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            isArabic ? 'التفاصيل' : 'Details',
                            style: TextStyle(
                              fontSize: 8.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
