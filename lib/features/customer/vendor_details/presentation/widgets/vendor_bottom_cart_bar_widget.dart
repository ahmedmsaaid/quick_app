import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';

class VendorBottomCartBarWidget extends ConsumerWidget {
  const VendorBottomCartBarWidget({
    super.key,
    required this.colors,
    required this.outerContext,
  });

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
                  child: Text(
                    AppStrings.viewCartBtn,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text16w700(color: Colors.white),
                  ),
                ),
                Text(
                  '${cart.subtotal.toStringAsFixed(0)} ${AppStrings.currency}',
                  style: AppTextStyles.text14w700(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
