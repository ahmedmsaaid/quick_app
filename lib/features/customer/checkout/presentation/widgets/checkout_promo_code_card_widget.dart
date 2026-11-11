import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/profile/data/models/invitation_code_model.dart';

class CheckoutPromoCodeCardWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isApplying;
  final DiscountCodeDto? appliedDiscount;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const CheckoutPromoCodeCardWidget({
    super.key,
    required this.controller,
    required this.isApplying,
    required this.appliedDiscount,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: appliedDiscount != null
              ? colors.success.withValues(alpha: 0.5)
              : colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (appliedDiscount != null)
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: colors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    appliedDiscount!.isFreeDelivery
                        ? Icons.delivery_dining_rounded
                        : Icons.local_offer_rounded,
                    color: colors.success,
                    size: 18.sp,
                  ),
                ),
                10.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appliedDiscount!.isFreeDelivery
                            ? '${appliedDiscount!.name} (${AppStrings.freeDeliveryTitle})'
                            : '${appliedDiscount!.name} (-${appliedDiscount!.percentage.toStringAsFixed(0)}%)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.text14w700(color: colors.success),
                      ),
                      if (appliedDiscount!.description != null &&
                          appliedDiscount!.description!.trim().isNotEmpty) ...[
                        2.verticalSpace,
                        Text(
                          appliedDiscount!.description!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.text11w400(
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                8.horizontalSpace,
                TextButton(
                  onPressed: onRemove,
                  style: TextButton.styleFrom(
                    foregroundColor: colors.error,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                  ),
                  child: Text(
                    AppStrings.removePromoCodeBtn,
                    style: AppTextStyles.text12w700(color: colors.error),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: AppTextStyles.text14w600(color: colors.textPrimary),
                    decoration: InputDecoration(
                      hintText: AppStrings.enterPromoCodeHint,
                      hintStyle: AppTextStyles.text12w400(
                        color: colors.textHint,
                      ),
                      prefixIcon: Icon(
                        Icons.confirmation_number_outlined,
                        color: colors.primary,
                        size: 20.sp,
                      ),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 12.h,
                      ),
                      filled: true,
                      fillColor: colors.containerBackground,
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
                ),
                10.horizontalSpace,
                SizedBox(
                  height: 44.h,
                  child: ElevatedButton(
                    onPressed: isApplying ? null : onApply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isApplying
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            AppStrings.applyPromoCodeBtn,
                            style: AppTextStyles.text13w700(
                              color: Colors.white,
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
}

