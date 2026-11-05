import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/shared/finance/data/models/delivery_dashboard_model.dart';

/// Modern Captain Remittance Hero Card displaying total cash to remit to Quick.
class CustomCaptainRemittanceCardWidget extends StatelessWidget {
  final DeliveryDashboardModel data;

  const CustomCaptainRemittanceCardWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1B4B),
            const Color(0xFF1E293B),
            colors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Decorative background glowing circles
            Positioned(
              top: -30.r,
              right: -30.r,
              child: Container(
                width: 140.r,
                height: 140.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40.r,
              left: -20.r,
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Card Body
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand & Verified Badge (Fully flex-constrained to prevent RenderFlex overflow)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(
                                Icons.delivery_dining_rounded,
                                color: Colors.white,
                                size: 22.sp,
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
                                          'QUICK CAPTAIN',
                                          style: AppTextStyles.text11w500(
                                            color: Colors.white.withValues(alpha: 0.75),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (data.deliveryId > 0) ...[
                                        6.horizontalSpace,
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 1.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text(
                                            '#${data.deliveryId}',
                                            style: AppTextStyles.text10w700(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  Text(
                                    data.deliveryName?.isNotEmpty == true
                                        ? data.deliveryName!
                                        : AppStrings.captainNameLabel,
                                    style: AppTextStyles.text14w700(
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      8.horizontalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: colors.success.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.r,
                              height: 7.r,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            6.horizontalSpace,
                            Text(
                              AppStrings.verifiedCaptainBadge,
                              style: AppTextStyles.text11w600(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  18.verticalSpace,

                  // 1. الرصيد المطلوب توريده لكويك (Cash Balance to Remit to Quick)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.payments_rounded,
                              color: const Color(0xFFFBBF24),
                              size: 18.sp,
                            ),
                            8.horizontalSpace,
                            Expanded(
                              child: Text(
                                AppStrings.totalCashToRemitTitle,
                                style: AppTextStyles.text13w600(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        8.verticalSpace,
                        Text(
                          '${data.totalCashToRemit.toStringAsFixed(2)} ${AppStrings.currency}',
                          style: AppTextStyles.text28w700(
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                        4.verticalSpace,
                        Text(
                          AppStrings.totalCashToRemitSubtitle,
                          style: AppTextStyles.text11w500(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
