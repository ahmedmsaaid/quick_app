import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/utils/format_price.dart';

final _cartVendorProvider =
    FutureProvider.family<UserDto?, int?>((ref, vendorId) async {
  if (vendorId == null || vendorId <= 0) return null;
  final result = await ref.read(homeApiServiceProvider).getUserById(vendorId);
  return result.when(
    success: (res) => res.result,
    failure: (_) => null,
  );
});

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final settingsAsync = ref.watch(settingsProvider);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    // Customer Location
    LocationDto? userLocation;
    if (profileState.locations.isNotEmpty) {
      userLocation = profileState.locations.firstWhere(
        (loc) => loc.base,
        orElse: () => profileState.locations.first,
      );
    }
    final double userLat =
        userLocation?.latitude ?? user?.location?.latitude ?? 0.0;
    final double userLng =
        userLocation?.longitude ?? user?.location?.longitude ?? 0.0;

    // Vendor Location
    final vendorLocsAsync = ref.watch(vendorLocationsProvider(cart.vendorId));
    final vendorLocs = vendorLocsAsync.asData?.value ?? [];
    LocationDto? vendorLocation;
    if (vendorLocs.isNotEmpty) {
      vendorLocation = vendorLocs.firstWhere(
        (l) => l.base,
        orElse: () => vendorLocs.first,
      );
    }
    final double storeLat = vendorLocation?.latitude ?? 0.0;
    final double storeLng = vendorLocation?.longitude ?? 0.0;

    // Calculate exact distance
    final double distanceKm =
        calculateDistanceKm(userLat, userLng, storeLat, storeLng);

    // Calculate fees dynamically
    final settings = settingsAsync.asData?.value ?? defaultAppSettings;
    final deliveryFee = calcDeliveryFee(distanceKm, settings);
    final serviceFee = calcOrderFee(cart.subtotal, settings);
    final total = cart.subtotal + deliveryFee + serviceFee;

    // Vendor info
    final vendorAsync = ref.watch(_cartVendorProvider(cart.vendorId));
    final vendor = vendorAsync.asData?.value;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.shoppingCartTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (cart.items.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
              child: InkWell(
                onTap: () => _confirmClear(context, notifier),
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.delete_sweep_outlined,
                        size: 16.sp,
                        color: colors.error,
                      ),
                      4.horizontalSpace,
                      Text(
                        'مسح',
                        style: AppTextStyles.text12w700(color: colors.error),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          6.horizontalSpace,
        ],
      ),
      body: cart.items.isEmpty
          ? _EmptyCart(colors: colors)
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Vendor Header Card (if available)
                  if (vendor != null) ...[
                    _VendorCartHeader(vendor: vendor, colors: colors),
                    16.verticalSpace,
                  ],

                  // 2. Section Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'المنتجات (${cart.totalQuantity})',
                        style:
                            AppTextStyles.text15w700(color: colors.textPrimary),
                      ),
                      Text(
                        'اسحب لليسار للحذف',
                        style: AppTextStyles.text11w400(color: colors.textHint),
                      ),
                    ],
                  ),
                  12.verticalSpace,

                  // 3. Cart Items List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => 12.verticalSpace,
                    itemBuilder: (_, i) => _Dismissible(
                      key: ValueKey(cart.items[i].product.id),
                      onDismissed: () =>
                          notifier.removeItem(cart.items[i].product.id),
                      child: _CartItemCard(
                        item: cart.items[i],
                        notifier: notifier,
                        colors: colors,
                      ),
                    ),
                  ),
                  20.verticalSpace,

                  // 4. Summary Card
                  _SummaryCard(
                    subtotal: cart.subtotal,
                    deliveryFee: deliveryFee,
                    serviceFee: serviceFee,
                    total: total,
                    isLoadingFees: settingsAsync.isLoading,
                    colors: colors,
                  ),
                ],
              ),
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : _CheckoutBar(colors: colors, total: total, context: context),
    );
  }

  void _confirmClear(BuildContext context, CartNotifier notifier) {
    final colors = AppColors(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            18.verticalSpace,
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_sweep_rounded,
                size: 36.sp,
                color: colors.error,
              ),
            ),
            14.verticalSpace,
            Text(
              'تفريغ السلة بالكامل؟',
              style: AppTextStyles.text18w700(color: colors.textPrimary),
            ),
            8.verticalSpace,
            Text(
              'سيتم حذف جميع المنتجات المضافة من السلة',
              style: AppTextStyles.text14w400(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            22.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border),
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'إلغاء',
                      style:
                          AppTextStyles.text16w600(color: colors.textSecondary),
                    ),
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      notifier.clearCart();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.error,
                      padding: EdgeInsets.symmetric(vertical: 13.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'تفريغ السلة',
                      style: AppTextStyles.text15w700(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dismissible wrapper ───────────────────────────────────────
class _Dismissible extends StatelessWidget {
  const _Dismissible({
    required super.key,
    required this.child,
    required this.onDismissed,
  });
  final Widget child;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20.w),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline_rounded,
                color: Colors.white, size: 24.sp),
            4.verticalSpace,
            Text(
              'حذف',
              style: AppTextStyles.text11w700(color: Colors.white),
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}

// ── Vendor Header Card ─────────────────────────────────────────
class _VendorCartHeader extends StatelessWidget {
  const _VendorCartHeader({required this.vendor, required this.colors});
  final UserDto vendor;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final String? photo = vendor.photo ?? vendor.avatar;
    final String logoUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              width: 38.w,
              height: 38.w,
              color: colors.background,
              child: logoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: logoUrl,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.storefront_rounded,
                        color: colors.primary,
                        size: 20.sp,
                      ),
                    )
                  : Icon(
                      Icons.storefront_rounded,
                      color: colors.primary,
                      size: 20.sp,
                    ),
            ),
          ),
          10.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vendor.name ?? 'المتجر',
                        style:
                            AppTextStyles.text13w700(color: colors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                2.verticalSpace,
                Text(
                  'طلبك من هذا المتجر',
                  style: AppTextStyles.text11w400(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '+ إضافة أصناف',
              style: AppTextStyles.text11w700(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Cart item card ─────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.notifier,
    required this.colors,
  });

  final CartItem item;
  final CartNotifier notifier;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final String? photo = product.photo;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.7),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ─ Product Image ─
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 76.w,
              height: 76.w,
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.5),
                ),
              ),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 76.w,
                        height: 76.w,
                        color: colors.shimmerBase,
                      ),
                      errorWidget: (_, __, ___) => _fallback(colors),
                    )
                  : _fallback(colors),
            ),
          ),
          12.horizontalSpace,

          // ─ Details Column ─
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title and delete button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name ?? '',
                        style:
                            AppTextStyles.text14w700(color: colors.textPrimary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    8.horizontalSpace,
                    GestureDetector(
                      onTap: () => notifier.removeItem(product.id),
                      child: Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.sp,
                          color: colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                4.verticalSpace,

                // Unit Price & Discount
                Row(
                  children: [
                    Text(
                      '${item.effectivePrice.toStringAsFixed(0)} ${AppStrings.currency}',
                      style:
                          AppTextStyles.text11w500(color: colors.textSecondary),
                    ),
                    if (product.hasDiscount) ...[
                      6.horizontalSpace,
                      Text(
                        '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                        style: AppTextStyles.text10w500(color: colors.textHint)
                            .copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
                10.verticalSpace,

                // Bottom row: Total Price and Quantity Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total item price
                    Text(
                      '${item.totalPrice.toStringAsFixed(0)} ${AppStrings.currency}',
                      style: AppTextStyles.text15w700(color: colors.primary),
                    ),

                    // Quantity Controls Pill
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.8),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        textDirection: TextDirection.ltr,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _QtyIconBtn(
                            icon: item.quantity > 1
                                ? Icons.remove_rounded
                                : Icons.delete_outline_rounded,
                            onTap: () {
                              if (item.quantity > 1) {
                                notifier.decreaseQuantity(product.id);
                              } else {
                                notifier.removeItem(product.id);
                              }
                            },
                            color: item.quantity > 1
                                ? colors.textSecondary
                                : colors.error,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Text(
                              '${item.quantity}',
                              style: AppTextStyles.text13w700(
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          _QtyIconBtn(
                            icon: Icons.add_rounded,
                            onTap: () => notifier.increaseQuantity(product.id),
                            color: colors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(AppColors colors) {
    return Container(
      color: colors.shimmerBase,
      child: Icon(Icons.fastfood_rounded, color: colors.textHint, size: 28.sp),
    );
  }
}

class _QtyIconBtn extends StatelessWidget {
  const _QtyIconBtn({
    required this.icon,
    required this.onTap,
    required this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.all(5.r),
        child: Icon(icon, color: color, size: 16.sp),
      ),
    );
  }
}

// ── Summary card ───────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.colors,
    this.isLoadingFees = false,
  });

  final double subtotal, deliveryFee, serviceFee, total;
  final AppColors colors;
  final bool isLoadingFees;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 18.sp,
                color: colors.primary,
              ),
              8.horizontalSpace,
              Text(
                'ملخص الفاتورة',
                style: AppTextStyles.text15w700(color: colors.textPrimary),
              ),
            ],
          ),
          14.verticalSpace,
          _row(
            AppStrings.subtotalLabel,
            '${formatPrice(subtotal)} ${AppStrings.currency}',
          ),
          10.verticalSpace,
          isLoadingFees
              ? _loadingRow(AppStrings.deliveryFeesLabel)
              : _row(
                  AppStrings.deliveryFeesLabel,
                  '${formatPrice(deliveryFee)} ${AppStrings.currency}',
                ),
          10.verticalSpace,
          isLoadingFees
              ? _loadingRow(AppStrings.serviceFeesLabel)
              : _row(
                  AppStrings.serviceFeesLabel,
                  '${formatPrice(serviceFee)} ${AppStrings.currency}',
                ),
          14.verticalSpace,
          Divider(color: colors.border.withValues(alpha: 0.6), height: 1),
          14.verticalSpace,
          _row(
            AppStrings.finalTotalLabel,
            '${formatPrice(total)} ${AppStrings.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _loadingRow(String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.text14w400(color: colors.textSecondary),
        ),
        SizedBox(
          width: 60,
          height: 12,
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(4),
            color: colors.primary,
            backgroundColor: colors.shimmerBase,
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.text15w700(color: colors.textPrimary)
              : AppTextStyles.text14w400(color: colors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.text18w700(color: colors.primary)
              : AppTextStyles.text14w600(color: colors.textPrimary),
        ),
      ],
    );
  }
}

// ── Checkout bar ───────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    required this.colors,
    required this.total,
    required this.context,
  });
  final AppColors colors;
  final double total;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16.w,
        12.h,
        16.w,
        MediaQuery.of(context).padding.bottom + 12.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.border.withValues(alpha: 0.6),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () => context.pushNamed(AppRoutes.cart),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: AppColors.gradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    8.horizontalSpace,
                    Text(
                      AppStrings.confirmOrder,
                      style: AppTextStyles.text15w700(color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${formatPrice(total)} ${AppStrings.currency}',
                    style: AppTextStyles.text13w700(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Empty cart ─────────────────────────────────────────────────
class _EmptyCart extends StatelessWidget {
  const _EmptyCart({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 50.sp,
                color: colors.primary,
              ),
            ),
            24.verticalSpace,
            Text(
              'سلتك فارغة حالياً',
              style: AppTextStyles.text18w700(color: colors.textPrimary),
            ),
            8.verticalSpace,
            Text(
              'لم تقم بإضافة أي منتجات إلى سلتك بعد، تصفح المتاجر والمطاعم وابدأ بالتسوق الآن!',
              style: AppTextStyles.text14w400(color: colors.textHint),
              textAlign: TextAlign.center,
            ),
            28.verticalSpace,
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding:
                    EdgeInsets.symmetric(horizontal: 28.w, vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              icon: Icon(
                Icons.explore_outlined,
                color: Colors.white,
                size: 18.sp,
              ),
              label: Text(
                'تصفح المتاجر',
                style: AppTextStyles.text15w700(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
