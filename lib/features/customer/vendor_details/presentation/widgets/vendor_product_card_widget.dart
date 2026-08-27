import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/favorites/presentation/riverpod/favorites_provider.dart';

import 'package:base_app/core/widgets/custom_toast.dart';

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

class VendorFavoriteToggleWidget extends ConsumerWidget {
  const VendorFavoriteToggleWidget({super.key, required this.product});
  final ProductDetailDto product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isFavorite = ref.watch(favoritesProvider).any((p) => p.id == product.id);
    return GestureDetector(
      onDoubleTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: const BoxDecoration(
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

class VendorAddButtonWidget extends StatelessWidget {
  const VendorAddButtonWidget({super.key, required this.onTap, required this.colors, this.size = 34});

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

class VendorRestaurantProductCardWidget extends ConsumerWidget {
  const VendorRestaurantProductCardWidget({
    super.key,
    required this.product,
    required this.colors,
    required this.vendorId,
    this.isClosed = false,
    this.isBusy = false,
  });

  final ProductDetailDto product;
  final AppColors colors;
  final int vendorId;
  final bool isClosed;
  final bool isBusy;

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
            'isClosed': isClosed,
            'isBusy': isBusy,
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
              ClipRRect(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
                child: SizedBox(
                  width: 120.w,
                  height: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: colors.shimmerBase),
                    errorWidget: (_, __, ___) => Container(
                      color: colors.primary.withValues(alpha: 0.1),
                      child: Icon(Icons.fastfood, size: 40.sp, color: colors.primary.withValues(alpha: 0.5)),
                    ),
                  ),
                ),
              ),
              Expanded(
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
                            style: AppTextStyles.text14w700(color: colors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (product.description != null && product.description!.isNotEmpty) ...[
                            4.verticalSpace,
                            Text(
                              product.description!,
                              style: AppTextStyles.text12w400(color: colors.textSecondary),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (product.hasDiscount) ...[
                                Text(
                                  '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: colors.textSecondary,
                                    decoration: TextDecoration.lineThrough,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                6.horizontalSpace,
                              ],
                              Text(
                                '${price.toStringAsFixed(0)} ${AppStrings.currency}',
                                style: AppTextStyles.text14w700(color: colors.primary),
                              ),
                            ],
                          ),
                          VendorAddButtonWidget(
                            onTap: () {
                              if (isBusy) {
                                CustomToast.error(context, 'المتجر مشغول حالياً، لا يمكن إضافة طلبات الآن');
                                return;
                              }
                              if (isClosed) {
                                CustomToast.error(context, 'المتجر مغلق مؤقتاً، لا يمكن إضافة طلبات الآن');
                                return;
                              }
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

class VendorMarketProductCardWidget extends ConsumerWidget {
  const VendorMarketProductCardWidget({
    super.key,
    required this.product,
    required this.colors,
    required this.vendorId,
    this.isClosed = false,
    this.isBusy = false,
  });

  final ProductDetailDto product;
  final AppColors colors;
  final int vendorId;
  final bool isClosed;
  final bool isBusy;

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
              'isClosed': isClosed,
              'isBusy': isBusy,
            },
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                      Positioned(
                        top: 8.r,
                        left: 8.r,
                        child: VendorFavoriteToggleWidget(product: product),
                      ),
                      if (product.hasDiscount)
                        Positioned(
                          top: 8.r,
                          right: 8.r,
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
                          GestureDetector(
                            onTap: () {
                              if (isBusy) {
                                CustomToast.error(context, 'المتجر مشغول حالياً، لا يمكن إضافة طلبات الآن');
                                return;
                              }
                              if (isClosed) {
                                CustomToast.error(context, 'المتجر مغلق مؤقتاً، لا يمكن إضافة طلبات الآن');
                                return;
                              }
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
