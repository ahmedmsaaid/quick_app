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
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  static const double _deliveryFee = 2500;
  static const double _serviceFee = 500;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final cart = ref.watch(cartProvider);
    final notifier = ref.read(cartProvider.notifier);
    final total = cart.subtotal + _deliveryFee + _serviceFee;

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
            TextButton.icon(
              onPressed: () => _confirmClear(context, notifier),
              icon: Icon(Icons.delete_sweep_outlined, size: 18.sp, color: colors.error),
              label: Text('مسح', style: AppTextStyles.text14w600(color: colors.error)),
            ),
          8.horizontalSpace,
        ],
      ),
      body: cart.items.isEmpty
          ? _EmptyCart(colors: colors)
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                    itemCount: cart.items.length,
                    itemBuilder: (_, i) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _Dismissible(
                        key: ValueKey(cart.items[i].product.id),
                        onDismissed: () => notifier.removeItem(cart.items[i].product.id),
                        child: _CartItemCard(item: cart.items[i], notifier: notifier, colors: colors),
                      ),
                    ),
                  ),
                ),
                _SummaryCard(
                  subtotal: cart.subtotal,
                  deliveryFee: _deliveryFee,
                  serviceFee: _serviceFee,
                  total: total,
                  colors: colors,
                ),
              ],
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 36.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: colors.border, borderRadius: BorderRadius.circular(2.r))),
            16.verticalSpace,
            Icon(Icons.delete_outline, size: 44.sp, color: colors.error),
            12.verticalSpace,
            Text('تفريغ العربة؟', style: AppTextStyles.text18w700(color: colors.textPrimary)),
            8.verticalSpace,
            Text('سيتم حذف جميع المنتجات', style: AppTextStyles.text14w400(color: colors.textSecondary)),
            24.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.border),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('إلغاء', style: AppTextStyles.text16w600(color: colors.textSecondary)),
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
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('تفريغ', style: AppTextStyles.text16w700(color: Colors.white)),
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
  const _Dismissible({required super.key, required this.child, required this.onDismissed});
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
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: colors.error,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24.sp),
            4.verticalSpace,
            Text('حذف', style: AppTextStyles.text10w500(color: Colors.white)),
          ],
        ),
      ),
      child: child,
    );
  }
}

// ── Cart item card ─────────────────────────────────────────────
class _CartItemCard extends StatelessWidget {
  const _CartItemCard({required this.item, required this.notifier, required this.colors});

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
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          // ─ Image ─
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              bottomLeft: Radius.circular(16.r),
            ),
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 90.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(width: 90.w, height: 100.h, color: colors.shimmerBase),
                    errorWidget: (_, __, ___) => _fallback(colors),
                  )
                : _fallback(colors),
          ),
          // ─ Info ─
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  5.verticalSpace,
                  Row(
                    children: [
                      Text(
                        '${item.effectivePrice.toStringAsFixed(0)} ${AppStrings.currency}',
                        style: AppTextStyles.text13w700(color: colors.primary),
                      ),
                      if (product.hasDiscount) ...[
                        8.horizontalSpace,
                        Text(
                          '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                          style: AppTextStyles.text10w500(color: colors.textHint).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    ],
                  ),
                  12.verticalSpace,
                  // Quantity + delete
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Qty controls
                      Container(
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: colors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QtyIconBtn(
                              icon: Icons.remove,
                              onTap: () => notifier.decreaseQuantity(product.id),
                              color: colors.textSecondary,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              child: Text('${item.quantity}', style: AppTextStyles.text14w700(color: colors.textPrimary)),
                            ),
                            _QtyIconBtn(
                              icon: Icons.add,
                              onTap: () => notifier.increaseQuantity(product.id),
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                      // Total price
                      Text(
                        '${item.totalPrice.toStringAsFixed(0)} ${AppStrings.currency}',
                        style: AppTextStyles.text14w700(color: colors.textPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(AppColors colors) {
    return Container(
      width: 90.w,
      height: 100.h,
      color: colors.shimmerBase,
      child: Icon(Icons.fastfood, color: colors.textHint, size: 28.sp),
    );
  }
}

class _QtyIconBtn extends StatelessWidget {
  const _QtyIconBtn({required this.icon, required this.onTap, required this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.all(7.r),
        child: Icon(icon, color: color, size: 18.sp),
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
  });

  final double subtotal, deliveryFee, serviceFee, total;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, -3))],
      ),
      child: Column(
        children: [
          _row(AppStrings.subtotalLabel, '${subtotal.toStringAsFixed(0)} ${AppStrings.currency}'),
          10.verticalSpace,
          _row(AppStrings.deliveryFeesLabel, '${deliveryFee.toStringAsFixed(0)} ${AppStrings.currency}'),
          10.verticalSpace,
          _row(AppStrings.serviceFeesLabel, '${serviceFee.toStringAsFixed(0)} ${AppStrings.currency}'),
          12.verticalSpace,
          Divider(color: colors.divider, height: 1),
          12.verticalSpace,
          _row(
            AppStrings.finalTotalLabel,
            '${total.toStringAsFixed(0)} ${AppStrings.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: isTotal
                ? AppTextStyles.text16w700(color: colors.textPrimary)
                : AppTextStyles.text14w400(color: colors.textSecondary)),
        Text(value,
            style: isTotal
                ? AppTextStyles.text16w700(color: colors.primary)
                : AppTextStyles.text14w600(color: colors.textPrimary)),
      ],
    );
  }
}

// ── Checkout bar ───────────────────────────────────────────────
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({required this.colors, required this.total, required this.context});
  final AppColors colors;
  final double total;
  final BuildContext context;

  @override
  Widget build(BuildContext ctx) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 28.h),
      color: colors.surface,
      child: CustomAppButton(
        text: '${AppStrings.confirmOrder} — ${total.toStringAsFixed(0)} ${AppStrings.currency}',
        onPressed: () => context.pushNamed(AppRoutes.cart),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: colors.tealLight,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.shopping_cart_outlined, size: 56.sp, color: colors.primary),
          ),
          24.verticalSpace,
          Text('عربتك فارغة', style: AppTextStyles.text20w700(color: colors.textPrimary)),
          10.verticalSpace,
          Text('أضف منتجات لتبدأ طلبك', style: AppTextStyles.text14w400(color: colors.textHint)),
          30.verticalSpace,
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              elevation: 0,
            ),
            child: Text('تصفح المنتجات', style: AppTextStyles.text16w600(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
