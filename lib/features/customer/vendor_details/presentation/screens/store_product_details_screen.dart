// ignore_for_file: unused_element, unused_import
import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/favorites/presentation/riverpod/favorites_provider.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/rating_provider.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:shimmer/shimmer.dart';
import 'package:base_app/features/customer/home/data/rating_api_service.dart';
import 'package:base_app/features/customer/home/data/models/rating_models.dart';
import 'package:base_app/core/network/api_result.dart';

class StoreProductDetailsScreen extends ConsumerStatefulWidget {
  const StoreProductDetailsScreen({
    super.key,
    required this.product,
    this.vendorId,
    this.isClosed,
    this.isBusy,
    this.vendor,
  });

  final ProductDetailDto product;
  final int? vendorId;
  final bool? isClosed;
  final bool? isBusy;
  final UserDto? vendor;

  @override
  ConsumerState<StoreProductDetailsScreen> createState() =>
      _StoreProductDetailsScreenState();
}

class _StoreProductDetailsScreenState
    extends ConsumerState<StoreProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _addController;
  late Animation<double> _scaleAnim;

  UserDto? _vendor;
  List<ProductDetailDto> _sameRestaurantProducts = [];
  bool _isLoadingSameProducts = true;

  ProductDetailDto get product => widget.product;

  int? get resolvedVendorId => widget.vendorId ?? product.creatorId ?? _vendor?.id;

  double get effectivePrice => product.hasDiscount
      ? product.price * (1 - product.discountPercentage / 100)
      : product.price;

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendor;
    _addController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _addController, curve: Curves.easeInOut),
    );

    final int? vId = resolvedVendorId;
    if (vId != null && vId > 0) {
      if (_vendor == null) {
        _loadVendor(vId);
      }
      _loadSameRestaurantProducts(vId);
    } else {
      _isLoadingSameProducts = false;
    }
  }

  Future<void> _loadVendor(int vId) async {
    final result = await ref.read(homeApiServiceProvider).getUserById(vId);
    if (!mounted) return;
    result.when(
      success: (res) {
        if (res.success && res.result != null) {
          setState(() => _vendor = res.result);
        }
      },
      failure: (_) {},
    );
  }

  Future<void> _loadSameRestaurantProducts(int vId) async {
    setState(() => _isLoadingSameProducts = true);
    final result = await ref.read(homeApiServiceProvider).getVendorProducts(
          creatorId: vId,
          pageSize: 20,
        );
    if (!mounted) return;
    result.when(
      success: (res) {
        if (res.success && res.result != null) {
          setState(() {
            _sameRestaurantProducts =
                res.result!.where((p) => p.id != widget.product.id).toList();
            _isLoadingSameProducts = false;
          });
        } else {
          setState(() => _isLoadingSameProducts = false);
        }
      },
      failure: (_) {
        if (mounted) setState(() => _isLoadingSameProducts = false);
      },
    );
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _addToCart() async {
    if (widget.isBusy == true || _vendor?.busy == true) {
      CustomToast.error(
          context, 'المتجر مشغول حالياً، لا يمكن إضافة طلبات الآن');
      return;
    }
    if (widget.isClosed == true ||
        (_vendor != null && (!(_vendor!.active ?? true) || _vendor!.status == 0))) {
      CustomToast.error(
          context, 'المتجر مغلق مؤقتاً، لا يمكن إضافة طلبات الآن');
      return;
    }
    await _addController.forward();
    await _addController.reverse();
    ref.read(cartProvider.notifier).addItem(
          product,
          quantity: _quantity,
          vendorId: resolvedVendorId,
        );
    if (mounted) {
      CustomToast.success(context, AppStrings.addedToCartSuccessMsg);
    }
  }

  void _openVendorScreen() {
    if (_vendor != null) {
      context.pushNamed(AppRoutes.providerStoreScreen, arguments: _vendor);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final String? photo = product.photo;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    final String? vendorPhoto = _vendor?.photo ?? _vendor?.avatar;
    final String vendorLogoUrl = (vendorPhoto != null && vendorPhoto.isNotEmpty)
        ? (vendorPhoto.startsWith('http')
            ? vendorPhoto
            : '${ApiConstants.streamUrl}$vendorPhoto')
        : '';

    final cartState = ref.watch(cartProvider);
    final totalCartQty = cartState.totalQuantity;

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          // ─── 1. Scrollable Page Content ───
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Hero Product Image with Dots ───
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: screenH * 0.38,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.shimmerBase,
                        ),
                        child: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: colors.shimmerBase,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: colors.shimmerBase,
                                  child: Icon(
                                    Icons.fastfood,
                                    size: 80.sp,
                                    color: colors.textHint,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.fastfood,
                                size: 80.sp,
                                color: colors.textHint,
                              ),
                      ),
                      // Subtle gradient overlay at the top for button contrast
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 100.h,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.4),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom Dots Indicator
                      Positioned(
                        bottom: 24.h,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final bool isActive = index == 0;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.symmetric(horizontal: 3.w),
                              width: isActive ? 16.w : 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? Colors.white
                                    : Colors.white.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),

                  // ─── Content Sheet (Overlapping with Rounded Top) ───
                  Transform.translate(
                    offset: Offset(0, -16.h),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(28.r)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ─── Restaurant / Vendor Card ───
                          _buildVendorCard(colors, vendorLogoUrl),
                          16.verticalSpace,

                          // ─── Product Title and Price Row ───
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  product.name ?? '',
                                  style: AppTextStyles.text20w700(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ),
                              12.horizontalSpace,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (product.hasDiscount) ...[
                                    Text(
                                      '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                                      style: AppTextStyles.text12w400(
                                        color: colors.textHint,
                                      ).copyWith(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    2.verticalSpace,
                                  ],
                                  Text(
                                    '${effectivePrice.toStringAsFixed(0)} ${AppStrings.currency}',
                                    style: AppTextStyles.text20w700(
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // ─── Product Description ───
                          if (product.description != null &&
                              product.description!.trim().isNotEmpty) ...[
                            8.verticalSpace,
                            Text(
                              product.description!.trim(),
                              style: AppTextStyles.text14w400(
                                color: colors.textSecondary,
                              ).copyWith(height: 1.55),
                            ),
                          ],
                          20.verticalSpace,

                          // ─── Quantity & Availability Row ───
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Quantity pill container
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: colors.surface,
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: colors.border.withValues(alpha: 0.8),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          colors.shadow.withValues(alpha: 0.03),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _QtyCircleBtn(
                                      icon: Icons.remove_rounded,
                                      enabled: _quantity > 1,
                                      colors: colors,
                                      onTap: () {
                                        if (_quantity > 1) {
                                          setState(() => _quantity--);
                                        }
                                      },
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16.w),
                                      child: Text(
                                        '$_quantity',
                                        style: AppTextStyles.text16w700(
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    _QtyCircleBtn(
                                      icon: Icons.add_rounded,
                                      enabled: true,
                                      colors: colors,
                                      onTap: () => setState(() => _quantity++),
                                    ),
                                  ],
                                ),
                              ),

                              // Availability badge
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    product.isAvailable ? 'متوفر' : 'غير متوفر',
                                    style: AppTextStyles.text13w700(
                                      color: product.isAvailable
                                          ? colors.primary
                                          : colors.error,
                                    ),
                                  ),
                                  6.horizontalSpace,
                                  Icon(
                                    product.isAvailable
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_rounded,
                                    color: product.isAvailable
                                        ? colors.primary
                                        : colors.error,
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // ─── Products from the same restaurant (منتجات من نفس المطعم) ───
                          _buildSameRestaurantSection(colors),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── 2. Top Action Buttons (AppBar overlay) ───
          Positioned(
            top: MediaQuery.of(context).padding.top + 8.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back Button
                _buildCircularActionBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.of(context).pop(),
                  colors: colors,
                ),
                // Favorite Button
                Consumer(
                  builder: (context, ref, child) {
                    final bool isFavorite = ref
                        .watch(favoritesProvider)
                        .any((p) => p.id == product.id);
                    return _buildCircularActionBtn(
                      icon: isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor:
                          isFavorite ? Colors.redAccent : Colors.black87,
                      onTap: () => ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(product),
                      colors: colors,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomAddToCartBar(colors, cartState, totalCartQty),
    );
  }

  // ─── Fixed Bottom Add to Cart Bar (تحت خالص) ───
  Widget _buildBottomAddToCartBar(
    AppColors colors,
    CartState cartState,
    int totalCartQty,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        10.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 10.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.7),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (totalCartQty > 0) ...[
            GestureDetector(
              onTap: () => context.pushNamed(AppRoutes.cartScreen),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_cart_rounded,
                      color: colors.primary,
                      size: 16.sp,
                    ),
                    6.horizontalSpace,
                    Text(
                      'سلتك تحتوي على $totalCartQty منتجات',
                      style: AppTextStyles.text11w700(color: colors.primary),
                    ),
                    const Spacer(),
                    Text(
                      '${cartState.subtotal.toStringAsFixed(0)} ${AppStrings.currency}',
                      style: AppTextStyles.text12w700(color: colors.primary),
                    ),
                    4.horizontalSpace,
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: colors.primary,
                      size: 10.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
          Row(
            children: [
              if (totalCartQty > 0) ...[
                InkWell(
                  borderRadius: BorderRadius.circular(14.r),
                  onTap: () => context.pushNamed(AppRoutes.cartScreen),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      Icons.shopping_cart_rounded,
                      color: colors.primary,
                      size: 22.sp,
                    ),
                  ),
                ),
                10.horizontalSpace,
              ],
              Expanded(
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16.r),
                      onTap: product.isAvailable ? _addToCart : null,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        decoration: BoxDecoration(
                          gradient: product.isAvailable
                              ? AppColors.gradient
                              : null,
                          color: product.isAvailable ? null : colors.border,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: product.isAvailable
                              ? [
                                  BoxShadow(
                                    color: colors.primary
                                        .withValues(alpha: 0.35),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                            8.horizontalSpace,
                            Text(
                              product.isAvailable
                                  ? 'أضف إلى السلة — ${(effectivePrice * _quantity).toStringAsFixed(0)} ${AppStrings.currency}'
                                  : 'غير متوفر',
                              style: AppTextStyles.text15w700(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Circular Header Action Button ───
  Widget _buildCircularActionBtn({
    required IconData icon,
    required VoidCallback onTap,
    required AppColors colors,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? Colors.black87,
          size: 19.sp,
        ),
      ),
    );
  }

  // ─── Vendor Info Card ───
  Widget _buildVendorCard(AppColors colors, String vendorLogoUrl) {
    final vendorName = _vendor?.name ?? 'المطعم';
    final String categoryName = (_vendor?.description != null &&
            _vendor!.description!.trim().isNotEmpty)
        ? _vendor!.description!.trim()
        : 'Fast Food';
    final double ratingVal = _vendor?.rating ?? 4.5;

    return InkWell(
      onTap: _vendor != null ? _openVendorScreen : null,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: colors.border.withValues(alpha: 0.7),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Vendor Logo
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                ),
                child: vendorLogoUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: vendorLogoUrl,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.storefront_rounded,
                          color: colors.primary,
                          size: 22.sp,
                        ),
                      )
                    : Icon(
                        Icons.storefront_rounded,
                        color: colors.primary,
                        size: 22.sp,
                      ),
              ),
            ),
            10.horizontalSpace,

            // Vendor Name, category & rating
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    vendorName,
                    style: AppTextStyles.text14w700(
                      color: colors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalSpace,
                  Row(
                    children: [
                      Icon(
                        Icons.storefront_outlined,
                        size: 13.sp,
                        color: colors.textHint,
                      ),
                      3.horizontalSpace,
                      Flexible(
                        child: Text(
                          categoryName,
                          style: AppTextStyles.text11w400(
                            color: colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      6.horizontalSpace,
                      Icon(Icons.star_rounded, size: 14.sp, color: Colors.amber),
                      2.horizontalSpace,
                      Text(
                        '${ratingVal.toStringAsFixed(1)} (1.2k)',
                        style: AppTextStyles.text11w700(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            8.horizontalSpace,
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.sp,
              color: colors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Same Restaurant Section (منتجات من نفس المطعم) ───
  Widget _buildSameRestaurantSection(AppColors colors) {
    if (!_isLoadingSameProducts && _sameRestaurantProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        24.verticalSpace,
        Row(
          children: [
            Text(
              'منتجات من نفس المطعم',
              style: AppTextStyles.text15w700(color: colors.textPrimary),
            ),
            6.horizontalSpace,
            Text('🔥', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
        12.verticalSpace,
        SizedBox(
          height: 175.h,
          child: _isLoadingSameProducts
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 3,
                  itemBuilder: (_, __) => _buildShimmerProductCard(colors),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _sameRestaurantProducts.length,
                  itemBuilder: (context, index) {
                    final item = _sameRestaurantProducts[index];
                    return _buildSameRestaurantProductCard(item, colors);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildSameRestaurantProductCard(
    ProductDetailDto item,
    AppColors colors,
  ) {
    final String? itemPhoto = item.photo;
    final String itemImgUrl = (itemPhoto != null && itemPhoto.isNotEmpty)
        ? (itemPhoto.startsWith('http')
            ? itemPhoto
            : '${ApiConstants.streamUrl}$itemPhoto')
        : '';
    final double itemPrice = item.hasDiscount
        ? item.price * (1 - item.discountPercentage / 100)
        : item.price;

    return Container(
      width: 130.w,
      margin: EdgeInsets.only(left: 10.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StoreProductDetailsScreen(
                product: item,
                vendorId: resolvedVendorId,
                vendor: _vendor,
                isClosed: widget.isClosed,
                isBusy: widget.isBusy,
              ),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.all(6.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with heart button
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.r),
                        child: itemImgUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: itemImgUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: colors.shimmerBase,
                                ),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.fastfood_rounded,
                                  color: colors.textHint,
                                  size: 28.sp,
                                ),
                              )
                            : Icon(
                                Icons.fastfood_rounded,
                                color: colors.textHint,
                                size: 28.sp,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 4.h,
                      right: 4.w,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isFav = ref
                              .watch(favoritesProvider)
                              .any((p) => p.id == item.id);
                          return GestureDetector(
                            onTap: () => ref
                                .read(favoritesProvider.notifier)
                                .toggleFavorite(item),
                            child: Container(
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color:
                                    isFav ? Colors.redAccent : Colors.white,
                                size: 13.sp,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              6.verticalSpace,
              // Title
              Text(
                item.name ?? '',
                style: AppTextStyles.text12w700(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              3.verticalSpace,
              // Price
              Text(
                '${itemPrice.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTextStyles.text12w700(color: colors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProductCard(AppColors colors) {
    return Container(
      width: 130.w,
      margin: EdgeInsets.only(left: 10.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
      ),
      child: Shimmer.fromColors(
        baseColor: colors.shimmerBase,
        highlightColor: colors.shimmerHighlight,
        child: Padding(
          padding: EdgeInsets.all(6.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              6.verticalSpace,
              Container(
                width: 80.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              4.verticalSpace,
              Container(
                width: 50.w,
                height: 12.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Quantity button ───────────────────────────────────────────
class _QtyCircleBtn extends StatelessWidget {
  const _QtyCircleBtn({
    required this.icon,
    required this.onTap,
    required this.colors,
    required this.enabled,
  });

  final IconData icon;
  final VoidCallback onTap;
  final AppColors colors;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: enabled
              ? colors.primary.withValues(alpha: 0.1)
              : colors.border.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: enabled ? colors.primary : colors.textHint,
          size: 16.sp,
        ),
      ),
    );
  }
}

class _ProductRatingBottomSheet extends ConsumerStatefulWidget {
  final int productId;
  final VoidCallback? onSuccess;
  const _ProductRatingBottomSheet({required this.productId, this.onSuccess});

  @override
  ConsumerState<_ProductRatingBottomSheet> createState() =>
      _ProductRatingBottomSheetState();
}

class _ProductRatingBottomSheetState
    extends ConsumerState<_ProductRatingBottomSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _commentController.text.trim();
    final success = await ref.read(ratingProvider.notifier).submitProductRating(
          productId: widget.productId,
          value: _rating,
          note: note.isEmpty ? "منتج جيد جداً" : note,
        );

    if (!mounted) return;

    if (success) {
      CustomToast.success(context, AppStrings.thanksForRatingMsg);
      Navigator.pop(context);
      if (widget.onSuccess != null) widget.onSuccess!();
    } else {
      final errorMsg = ref.read(ratingProvider).errorMessage;
      CustomToast.error(context, errorMsg ?? AppStrings.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final ratingState = ref.watch(ratingProvider);
    final isLoading = ratingState.status == RatingStatus.loading;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        left: 20.w,
        right: 20.w,
        top: 20.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          20.verticalSpace,
          Text(
            'تقييم المنتج',
            style: AppTextStyles.text18w700(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          15.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= _rating;
              return IconButton(
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 40.sp,
                ),
                onPressed:
                    isLoading ? null : () => setState(() => _rating = starIndex),
              );
            }),
          ),
          15.verticalSpace,
          CustomTextField(
            controller: _commentController,
            hintText: 'اكتب رأيك حول جودة ومذاق المنتج هنا...',
            maxLines: 3,
            enabled: !isLoading,
          ),
          24.verticalSpace,
          isLoading
              ? const LoadingButton()
              : CustomAppButton(
                  text: 'إرسال التقييم',
                  onPressed: _submit,
                ),
        ],
      ),
    );
  }
}

class _ProductRatingsListBottomSheet extends ConsumerStatefulWidget {
  final ProductDetailDto product;
  const _ProductRatingsListBottomSheet({required this.product});

  @override
  ConsumerState<_ProductRatingsListBottomSheet> createState() =>
      _ProductRatingsListBottomSheetState();
}

class _ProductRatingsListBottomSheetState
    extends ConsumerState<_ProductRatingsListBottomSheet> {
  List<ProductRatingDto>? _ratings;
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
    final result = await ref
        .read(ratingApiServiceProvider)
        .getProductRatings(productId: widget.product.id);
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
    final double avg = widget.product.rating;
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
                        : (starVal - 0.5 <= avg
                            ? Icons.star_half_rounded
                            : Icons.star_border_rounded),
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
              Icons.shopping_bag_rounded,
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
            Text(_error!,
                style: AppTextStyles.text12w500(color: colors.textSecondary)),
            12.verticalSpace,
            TextButton(
              onPressed: _loadRatings,
              child: Text("إعادة المحاولة",
                  style: AppTextStyles.text13w700(color: colors.primary)),
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
              Icon(Icons.rate_review_outlined,
                  color: colors.textHint, size: 50.sp),
              16.verticalSpace,
              Text(
                "لا توجد تقييمات بعد",
                style: AppTextStyles.text14w700(color: colors.textPrimary),
              ),
              6.verticalSpace,
              Text(
                "كن أول من يشارك تجربته مع هذا المنتج!",
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
            ? (photo.startsWith('http')
                ? photo
                : '${ApiConstants.streamUrl}$photo')
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
                            placeholder: (_, __) =>
                                Container(color: colors.shimmerBase),
                            errorWidget: (_, __, ___) =>
                                _avatarFallback(colors, name),
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
                          style: AppTextStyles.text13w700(
                              color: colors.textPrimary),
                        ),
                        4.verticalSpace,
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < review.value
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
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
                    style: AppTextStyles.text12w500(color: colors.textSecondary)
                        .copyWith(height: 1.5),
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
        bottom: MediaQuery.of(context).padding.bottom +
            MediaQuery.of(context).viewInsets.bottom +
            16.h,
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
            widget.product.name ?? "",
            style: AppTextStyles.text12w400(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,
          if (!_isLoading &&
              _error == null &&
              _ratings != null &&
              _ratings!.isNotEmpty) ...[
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
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return _ProductRatingBottomSheet(
                      productId: widget.product.id,
                      onSuccess: () {
                        _loadRatings();
                      },
                    );
                  },
                );
              },
              icon: Icon(Icons.star_rate_rounded,
                  color: Colors.white, size: 20.sp),
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
