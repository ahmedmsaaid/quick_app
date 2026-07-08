import 'package:base_app/core/network/api_result.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/vendor_details/presentation/riverpod/vendor_details_provider.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/favorites/presentation/riverpod/favorites_provider.dart';
import 'package:base_app/features/customer/home/data/rating_api_service.dart';
import 'package:base_app/features/customer/home/data/models/rating_models.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';

class VendorDetailsScreen extends ConsumerStatefulWidget {
  const VendorDetailsScreen({super.key, required this.vendor, this.initialCategory});

  final UserDto vendor;
  final CategoryDto? initialCategory;

  @override
  ConsumerState<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends ConsumerState<VendorDetailsScreen> {
  UserDto? _vendor;
  bool _isLoadingVendor = false;

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendor;
    
    // If the photo/avatar is missing or empty, load it from backend
    if (_vendor!.photo == null || _vendor!.photo!.isEmpty) {
      _loadVendorDetails();
    }

    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(vendorDetailsProvider(widget.vendor.id).notifier)
            .setPreSelectedCategory(widget.initialCategory!);
      });
    }
  }

  Future<void> _loadVendorDetails() async {
    if (!mounted) return;
    setState(() {
      _isLoadingVendor = true;
    });

    final result = await ref.read(homeApiServiceProvider).getUserById(widget.vendor.id);

    if (!mounted) return;
    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          setState(() {
            _vendor = response.result;
            _isLoadingVendor = false;
          });
        } else {
          setState(() {
            _isLoadingVendor = false;
          });
        }
      },
      failure: (error) {
        setState(() {
          _isLoadingVendor = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendor = _vendor ?? widget.vendor;
    final bool isMarket = vendor.role == 1;
    final state = ref.watch(vendorDetailsProvider(vendor.id));
    final notifier = ref.read(vendorDetailsProvider(vendor.id).notifier);
    final colors = AppColors(context);

    final String? vendorPhoto = vendor.photo ?? vendor.avatar;
    final String vendorImageUrl = (vendorPhoto != null && vendorPhoto.isNotEmpty)
        ? (vendorPhoto.startsWith('http') ? vendorPhoto : '${ApiConstants.streamUrl}$vendorPhoto')
        : '';

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Hero AppBar ───
          SliverAppBar(
            expandedHeight: 240.h,
            pinned: true,
            backgroundColor: colors.primary,
            leading: Padding(
              padding: EdgeInsets.all(8.r),
              child: CustomArrowBack(
                color: Colors.black26,
                iconColor: Colors.white,
                isCircular: true,
                margin: EdgeInsets.zero,
                padding: EdgeInsets.all(8.r),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              title: Text(
                vendor.name ?? (isMarket ? 'السوق' : 'المطعم'),
                style: AppTextStyles.text16w700(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  vendorImageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: vendorImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: colors.shimmerBase),
                          errorWidget: (_, __, ___) => _placeholderBg(colors, isMarket),
                        )
                      : _placeholderBg(colors, isMarket),
                  // Gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                  ),
                  // Vendor info at bottom
                  Positioned(
                    bottom: 50.h,
                    left: 16.w,
                    right: 16.w,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: (vendor.active ?? false) ? Colors.green : Colors.red,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            (vendor.active ?? false) ? 'مفتوح' : 'مغلق',
                            style: AppTextStyles.text10w500(color: Colors.white),
                          ),
                        ),
                        8.horizontalSpace,
                        GestureDetector(
                          onTap: () => _showRatingDialog(context, ref, vendor, colors),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.star_rounded, color: Colors.amber, size: 14.sp),
                                3.horizontalSpace,
                                Text(
                                  vendor.rating.toStringAsFixed(1),
                                  style: AppTextStyles.text12w700(color: Colors.white),
                                ),
                                4.horizontalSpace,
                                Text(
                                  "(قيّم)",
                                  style: AppTextStyles.text10w500(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                        ),
                        8.horizontalSpace,
                        Icon(Icons.access_time_rounded, color: Colors.white70, size: 13.sp),
                        3.horizontalSpace,
                        Text('15-25 د', style: AppTextStyles.text10w500(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: InkWell(
                onTap: () => _showVendorRatingsListBottomSheet(context, ref, vendor, colors),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colors.primary.withValues(alpha: 0.1)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.star_rounded, color: Colors.amber, size: 18.sp),
                      8.horizontalSpace,
                      Text(
                        '${vendor.rating.toStringAsFixed(1)}  •  تقييمات وآراء العملاء',
                        style: AppTextStyles.text13w600(color: colors.textPrimary),
                      ),
                      const Spacer(),
                      Text(
                        'عرض الكل',
                        style: AppTextStyles.text12w600(color: colors.primary),
                      ),
                      4.horizontalSpace,
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: colors.primary,
                        size: 11.sp,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ─── Categories filter ───
          if (state.categories.isNotEmpty || state.categoriesStatus == VendorDetailsStatus.loading)
            if (isMarket)
              SliverPersistentHeader(
                pinned: true,
                delegate: _QuickMarketCategoriesHeaderDelegate(
                  child: _QuickMarketCategoriesFilter(state: state, notifier: notifier, colors: colors),
                ),
              )
            else
              SliverPersistentHeader(
                pinned: true,
                delegate: _CategoriesHeaderDelegate(
                  child: _CategoriesFilter(state: state, notifier: notifier, colors: colors),
                ),
              ),

          // ─── Content body (Categories or Products) ───
          if (isMarket) ...[
            if (state.productsStatus == VendorDetailsStatus.loading)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: _marketShimmerGrid(),
              )
            else if (state.productsStatus == VendorDetailsStatus.error)
              SliverFillRemaining(
                child: _ErrorWidget(
                  message: state.errorMessage,
                  onRetry: () => notifier.loadProducts(categoryId: state.selectedCategory?.id),
                ),
              )
            else if (state.products.isEmpty)
              SliverFillRemaining(
                child: _EmptyProducts(colors: colors),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => _MarketProductCard(product: state.products[i], colors: colors, ref: ref, vendorId: vendor.id),
                    childCount: state.products.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12.w,
                    mainAxisSpacing: 12.h,
                  ),
                ),
              )
          ] else ...[
            if (state.productsStatus == VendorDetailsStatus.loading)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: _restaurantShimmerList(colors),
              )
            else if (state.productsStatus == VendorDetailsStatus.error)
              SliverFillRemaining(
                child: _ErrorWidget(
                  message: state.errorMessage,
                  onRetry: notifier.loadVendorData,
                ),
              )
            else if (state.products.isEmpty)
              SliverFillRemaining(
                child: _EmptyProducts(colors: colors),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _RestaurantProductCard(product: state.products[i], colors: colors, ref: ref, vendorId: vendor.id),
                    ),
                    childCount: state.products.length,
                  ),
                ),
              )
          ],

          SliverToBoxAdapter(child: 90.verticalSpace),
        ],
      ),
      bottomNavigationBar: _BottomCartBar(colors: colors, outerContext: context),
    );
  }



  Widget _placeholderBg(AppColors colors, bool isMarket) => Container(
    color: colors.primary,
    child: Icon(isMarket ? Icons.store : Icons.restaurant, size: 60.sp, color: Colors.white30),
  );

  SliverList _restaurantShimmerList(AppColors colors) => SliverList(
    delegate: SliverChildBuilderDelegate(
      (_, __) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Shimmer.fromColors(
          baseColor: colors.shimmerBase,
          highlightColor: colors.shimmerHighlight,
          child: Container(
            height: 110.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
      childCount: 5,
    ),
  );

  SliverGrid _marketShimmerGrid() => SliverGrid(
    delegate: SliverChildBuilderDelegate(
      (context, _) => Shimmer.fromColors(
        baseColor: AppColors(context).shimmerBase,
        highlightColor: AppColors(context).shimmerHighlight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
      ),
      childCount: 6,
    ),
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: 0.68,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
    ),
  );
}

// ── Categories pinned header ─────────────────────────────────
class _CategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CategoriesHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      color: AppColors(context).surface,
      child: child,
    );
  }

  @override double get minExtent => 52.h;
  @override double get maxExtent => 52.h;
  @override bool shouldRebuild(covariant _CategoriesHeaderDelegate old) => old.child != child;
}

// ── Categories filter ─────────────────────────────────────────
class _CategoriesFilter extends StatelessWidget {
  const _CategoriesFilter({required this.state, required this.notifier, required this.colors});

  final VendorDetailsState state;
  final VendorDetailsNotifier notifier;
  final AppColors colors;

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${ApiConstants.streamUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    if (state.categoriesStatus == VendorDetailsStatus.loading) {
      return SizedBox(
        height: 52.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => 10.horizontalSpace,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ),
      );
    }

    if (state.categories.isEmpty) return const SizedBox(height: 52.0);

    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => 10.horizontalSpace,
        itemBuilder: (_, i) {
          final CategoryDto cat = state.categories[i];
          final bool selected = state.selectedCategory?.id == cat.id;
          final String imageUrl = _imageUrl(cat.photo);

          return GestureDetector(
            onTap: () => notifier.selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: selected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: selected ? colors.primary : colors.border.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: selected
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
                      color: selected ? Colors.white24 : colors.containerBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: colors.shimmerBase),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.fastfood_rounded,
                                size: 12.sp,
                                color: selected ? Colors.white : colors.textSecondary,
                              ),
                            )
                          : Icon(
                              Icons.fastfood_rounded,
                              size: 12.sp,
                              color: selected ? Colors.white : colors.textSecondary,
                            ),
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    cat.name ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: selected ? Colors.white : colors.textSecondary,
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
}

// ── Restaurant product card ───────────────────────────────────
class _RestaurantProductCard extends ConsumerWidget {
  const _RestaurantProductCard({required this.product, required this.colors, required this.ref, required this.vendorId});

  final ProductDetailDto product;
  final AppColors colors;
  final WidgetRef ref;
  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String imageUrl = _imageUrl(product.photo);
    final double price = product.hasDiscount
        ? product.price * (1 - product.discountPercentage / 100)
        : product.price;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => context.pushNamed(
          AppRoutes.storeProductDetailsScreen,
          arguments: {
            'product': product,
            'vendorId': vendorId,
          },
        ),
        child: Container(
          height: 125.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 115.w,
                            height: 125.h,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(width: 115.w, height: 125.h, color: colors.shimmerBase),
                            errorWidget: (_, __, ___) => _imgFallback(colors, 115.w, 125.h, Icons.fastfood),
                          )
                        : _imgFallback(colors, 115.w, 125.h, Icons.fastfood),
                    // Favorite Button
                    Positioned(
                      top: 6.r, right: 6.r,
                      child: _FavoriteToggle(product: product),
                    ),
                    if (product.hasDiscount)
                      Positioned(
                        top: 6.r, left: 6.r,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: colors.error,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            '-${product.discountPercentage.toStringAsFixed(0)}%',
                            style: AppTextStyles.text10w500(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name ?? '',
                        style: AppTextStyles.text14w700(color: colors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      3.verticalSpace,
                      if (product.description != null && product.description!.isNotEmpty)
                        Expanded(
                          child: Text(
                            product.description!,
                            style: AppTextStyles.text12w400(color: colors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (product.hasDiscount)
                                Text(
                                  '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                                  style: AppTextStyles.text10w500(color: colors.textHint).copyWith(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                '${price.toStringAsFixed(0)} ${AppStrings.currency}',
                                style: AppTextStyles.text14w700(color: colors.primary),
                              ),
                            ],
                          ),
                          _AddBtn(
                            onTap: () {
                              ref.read(cartProvider.notifier).addItem(product, vendorId: vendorId);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppStrings.addedToCartSuccessMsg),
                                backgroundColor: colors.primary,
                                duration: const Duration(seconds: 1),
                              ));
                            },
                            colors: colors,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Market product card ───────────────────────────────────────
class _MarketProductCard extends ConsumerWidget {
  const _MarketProductCard({required this.product, required this.colors, required this.ref, required this.vendorId});

  final ProductDetailDto product;
  final AppColors colors;
  final WidgetRef ref;
  final int vendorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String imageUrl = _imageUrl(product.photo);
    final double price = product.hasDiscount
        ? product.price * (1 - product.discountPercentage / 100)
        : product.price;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: colors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: () => context.pushNamed(
            AppRoutes.storeProductDetailsScreen,
            arguments: {
              'product': product,
              'vendorId': vendorId,
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: colors.shimmerBase),
                              errorWidget: (_, __, ___) => _imgFallback(colors, double.infinity, double.infinity, Icons.shopping_basket),
                            )
                          : _imgFallback(colors, double.infinity, double.infinity, Icons.shopping_basket),
                      // Favorite Button
                      Positioned(
                        top: 8.r, left: 8.r,
                        child: _FavoriteToggle(product: product),
                      ),
                      // Discount badge
                      if (product.hasDiscount)
                        Positioned(
                          top: 8.r, right: 8.r,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: colors.error,
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.error.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '-${product.discountPercentage.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10.sp,
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
              // Info
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              fontFamily: 'Cairo',
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.hasDiscount) ...[
                            4.verticalSpace,
                            Text(
                              '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: colors.textHint,
                                decoration: TextDecoration.lineThrough,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${price.toStringAsFixed(0)} ${AppStrings.currency}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w900,
                                color: colors.primary,
                                fontFamily: 'Cairo',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Premium Pill Add Button
                          GestureDetector(
                            onTap: () {
                              ref.read(cartProvider.notifier).addItem(product, vendorId: vendorId);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(
                                  AppStrings.addedToCartSuccessMsg,
                                  style: const TextStyle(fontFamily: 'Cairo'),
                                ),
                                backgroundColor: colors.primary,
                                duration: const Duration(seconds: 1),
                              ));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                gradient: AppColors.gradient,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: colors.primary.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add, color: Colors.white, size: 12.sp),
                                  2.horizontalSpace,
                                  Text(
                                    'أضف',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add button ─────────────────────────────────────────────────
class _AddBtn extends StatelessWidget {
  const _AddBtn({required this.onTap, required this.colors, this.size = 34});

  final VoidCallback onTap;
  final AppColors colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          gradient: AppColors.gradient,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Icon(Icons.add, color: Colors.white, size: (size * 0.55).sp),
      ),
    );
  }
}

class _FavoriteToggle extends ConsumerWidget {
  const _FavoriteToggle({required this.product});
  final ProductDetailDto product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFavorite = ref.watch(favoritesProvider).any((p) => p.id == product.id);
    return GestureDetector(
      onDoubleTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: Colors.black26,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? Colors.redAccent : Colors.white,
          size: 18.sp,
        ),
      ),
    );
  }
}

// ── Error / Empty widgets ──────────────────────────────────────
class _ErrorWidget extends StatelessWidget {
  const _ErrorWidget({required this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56.sp, color: colors.textHint),
          16.verticalSpace,
          Text(message ?? 'حدث خطأ', style: AppTextStyles.text14w600(color: colors.textSecondary), textAlign: TextAlign.center),
          20.verticalSpace,
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
          ),
        ],
      ),
    );
  }
}

class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56.sp, color: colors.textHint),
          12.verticalSpace,
          Text('لا توجد منتجات في هذه الفئة', style: AppTextStyles.text14w600(color: colors.textSecondary)),
        ],
      ),
    );
  }
}

// ── Bottom cart bar ────────────────────────────────────────────
class _BottomCartBar extends ConsumerWidget {
  const _BottomCartBar({required this.colors, required this.outerContext});

  final AppColors colors;
  final BuildContext outerContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    if (cart.totalQuantity == 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => outerContext.pushNamed(AppRoutes.cartScreen),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [BoxShadow(color: colors.primary.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text('${cart.totalQuantity}', style: AppTextStyles.text14w700(color: Colors.white)),
                ),
                Expanded(
                  child: Text(AppStrings.viewCartBtn, textAlign: TextAlign.center, style: AppTextStyles.text16w700(color: Colors.white)),
                ),
                Text('${cart.subtotal.toStringAsFixed(0)} ${AppStrings.currency}', style: AppTextStyles.text14w700(color: Colors.white)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────
String _imageUrl(String? photo) {
  if (photo == null || photo.isEmpty) return '';
  return photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo';
}

Widget _imgFallback(AppColors colors, double w, double h, IconData icon) {
  return Container(
    width: w,
    height: h,
    color: colors.shimmerBase,
    child: Icon(icon, color: colors.textHint, size: 36),
  );
}

void _showRatingDialog(BuildContext context, WidgetRef ref, UserDto vendor, AppColors colors, {VoidCallback? onSuccess}) {
  int selectedStars = 5;
  final noteController = TextEditingController();
  bool isSubmitting = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: colors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            title: Text(
              "تقييم المطعم",
              style: AppTextStyles.text16w700(color: colors.textPrimary),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "ما هو تقييمك لـ ${vendor.name}؟",
                  style: AppTextStyles.text12w400(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                16.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        starIndex <= selectedStars ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 32.sp,
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setState(() {
                                selectedStars = starIndex;
                              });
                            },
                    );
                  }),
                ),
                16.verticalSpace,
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  enabled: !isSubmitting,
                  style: AppTextStyles.text12w500(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: "اكتب تعليقك أو ملاحظاتك هنا (اختياري)...",
                    hintStyle: AppTextStyles.text12w400(color: colors.textHint),
                    filled: true,
                    fillColor: colors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: colors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: colors.primary),
                    ),
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.only(bottom: 16.h, left: 16.w, right: 16.w),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          side: BorderSide(color: colors.border),
                        ),
                      ),
                      onPressed: isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(
                        "إلغاء",
                        style: AppTextStyles.text14w600(color: colors.textSecondary),
                      ),
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: isSubmitting
                          ? null
                          : () async {
                              setState(() {
                                isSubmitting = true;
                              });
                              
                              final ratingService = ref.read(ratingApiServiceProvider);
                              final result = await ratingService.createUserRating(
                                userId: vendor.id,
                                value: selectedStars,
                                note: noteController.text.trim(),
                              );

                              result.when(
                                success: (response) {
                                  Navigator.pop(context);
                                  if (onSuccess != null) onSuccess();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        response.message ?? "تم تقديم تقييمك بنجاح. شكراً لك!",
                                        style: AppTextStyles.text12w500(color: Colors.white),
                                      ),
                                      backgroundColor: colors.primary,
                                    ),
                                  );
                                },
                                failure: (error) {
                                  setState(() {
                                    isSubmitting = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        error.message,
                                        style: AppTextStyles.text12w500(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                },
                              );
                            },
                      child: isSubmitting
                          ? SizedBox(
                              width: 16.w,
                              height: 16.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "تقييم",
                              style: AppTextStyles.text14w600(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

void _showVendorRatingsListBottomSheet(BuildContext context, WidgetRef ref, UserDto vendor, AppColors colors) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _VendorRatingsListBottomSheet(vendor: vendor);
    },
  );
}

class _VendorRatingsListBottomSheet extends ConsumerStatefulWidget {
  final UserDto vendor;
  const _VendorRatingsListBottomSheet({required this.vendor});

  @override
  ConsumerState<_VendorRatingsListBottomSheet> createState() => _VendorRatingsListBottomSheetState();
}

class _VendorRatingsListBottomSheetState extends ConsumerState<_VendorRatingsListBottomSheet> {
  List<RatingDto>? _ratings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref.read(ratingApiServiceProvider).getUserRatings(userId: widget.vendor.id);
    if (!mounted) return;
    result.when(
      success: (response) {
        setState(() {
          _ratings = response.result;
          _isLoading = false;
        });
      },
      failure: (error) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      },
    );
  }

  Widget _avatarFallback(AppColors colors, String name) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Container(
      width: 36.r,
      height: 36.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppTextStyles.text13w700(color: colors.primary),
      ),
    );
  }

  Widget _buildSummaryHeader(AppColors colors) {
    final double avg = widget.vendor.rating;
    final int totalCount = _ratings?.length ?? 0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: AppTextStyles.text32w700(color: colors.textPrimary),
                  ),
                  4.horizontalSpace,
                  Text(
                    "/ 5.0",
                    style: AppTextStyles.text14w500(color: colors.textHint),
                  ),
                ],
              ),
              8.verticalSpace,
              Row(
                children: List.generate(5, (index) {
                  final double starVal = index + 1;
                  return Icon(
                    starVal <= avg
                        ? Icons.star_rounded
                        : (starVal - 0.5 <= avg ? Icons.star_half_rounded : Icons.star_border_rounded),
                    color: Colors.amber,
                    size: 18.sp,
                  );
                }),
              ),
              6.verticalSpace,
              Text(
                "بناءً على $totalCount تقييم",
                style: AppTextStyles.text11w400(color: colors.textSecondary),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.reviews_rounded,
              color: colors.primary,
              size: 40.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(AppColors colors) {
    if (_isLoading) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => 12.verticalSpace,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Container(
              height: 90.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        },
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 40.sp),
            12.verticalSpace,
            Text(_error!, style: AppTextStyles.text12w500(color: colors.textSecondary)),
            12.verticalSpace,
            TextButton(
              onPressed: _loadRatings,
              child: Text("إعادة المحاولة", style: AppTextStyles.text13w700(color: colors.primary)),
            ),
          ],
        ),
      );
    }

    if (_ratings == null || _ratings!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chat_bubble_outline_rounded, color: colors.textHint, size: 50.sp),
              16.verticalSpace,
              Text(
                "لا توجد تقييمات بعد",
                style: AppTextStyles.text14w700(color: colors.textPrimary),
              ),
              6.verticalSpace,
              Text(
                "كن أول من يشارك تجربته مع هذا المطعم!",
                style: AppTextStyles.text12w400(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _ratings!.length,
      separatorBuilder: (_, __) => 12.verticalSpace,
      itemBuilder: (context, index) {
        final review = _ratings![index];
        final creator = review.creator;
        final name = creator?.name ?? "مستخدم";
        final photo = creator?.photo ?? creator?.avatar;
        final String imgUrl = (photo != null && photo.isNotEmpty)
            ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
            : '';

        return Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: 36.r,
                            height: 36.r,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: colors.shimmerBase),
                            errorWidget: (_, __, ___) => _avatarFallback(colors, name),
                          )
                        : _avatarFallback(colors, name),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.text13w700(color: colors.textPrimary),
                        ),
                        4.verticalSpace,
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < review.value ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 14.sp,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (review.note != null && review.note!.trim().isNotEmpty) ...[
                10.verticalSpace,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    review.note!,
                    style: AppTextStyles.text12w500(color: colors.textSecondary).copyWith(height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          16.verticalSpace,
          Text(
            "تقييمات وآراء العملاء",
            style: AppTextStyles.text18w700(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          4.verticalSpace,
          Text(
            widget.vendor.name ?? "",
            style: AppTextStyles.text12w400(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,

          if (!_isLoading && _error == null && _ratings != null && _ratings!.isNotEmpty) ...[
            _buildSummaryHeader(colors),
            16.verticalSpace,
          ],

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildMainContent(colors),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                _showRatingDialog(
                  context,
                  ref,
                  widget.vendor,
                  colors,
                  onSuccess: () {
                    _loadRatings();
                  },
                );
              },
              icon: Icon(Icons.star_rate_rounded, color: Colors.white, size: 20.sp),
              label: Text(
                "أضف تقييمك الآن",
                style: AppTextStyles.text14w700(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Market categories pinned header delegate ────────────────────────────
class _QuickMarketCategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _QuickMarketCategoriesHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 3 : 0,
      color: AppColors(context).surface,
      child: child,
    );
  }

  @override double get minExtent => 52.h;
  @override double get maxExtent => 52.h;
  @override bool shouldRebuild(covariant _QuickMarketCategoriesHeaderDelegate old) => old.child != child;
}

// ── Quick Market custom category selector ─────────────────────────────────────
class _QuickMarketCategoriesFilter extends StatelessWidget {
  const _QuickMarketCategoriesFilter({required this.state, required this.notifier, required this.colors});

  final VendorDetailsState state;
  final VendorDetailsNotifier notifier;
  final AppColors colors;

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${ApiConstants.streamUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    if (state.categoriesStatus == VendorDetailsStatus.loading) {
      return SizedBox(
        height: 52.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => 10.horizontalSpace,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ),
      );
    }

    if (state.categories.isEmpty) return const SizedBox(height: 52.0);

    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => 10.horizontalSpace,
        itemBuilder: (_, i) {
          final CategoryDto cat = state.categories[i];
          final bool selected = state.selectedCategory?.id == cat.id;
          final String imageUrl = _imageUrl(cat.photo);

          return GestureDetector(
            onTap: () => notifier.selectCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: selected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: selected ? colors.primary : colors.border.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: selected
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
                      color: selected ? Colors.white24 : colors.containerBackground,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: colors.shimmerBase),
                              errorWidget: (_, __, ___) => Icon(
                                Icons.category_rounded,
                                size: 12.sp,
                                color: selected ? Colors.white : colors.textSecondary,
                              ),
                            )
                          : Icon(
                              Icons.category_rounded,
                              size: 12.sp,
                              color: selected ? Colors.white : colors.textSecondary,
                            ),
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    cat.name ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: selected ? Colors.white : colors.textSecondary,
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
}

