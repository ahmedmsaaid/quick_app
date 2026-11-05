import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/shared/finance/data/models/delivery_dashboard_model.dart';

/// Modern Orders Count Card displaying total completed orders for the captain.
class CustomCaptainOrdersCountCardWidget extends StatelessWidget {
  final DeliveryDashboardModel data;

  const CustomCaptainOrdersCountCardWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: colors.primary,
              size: 26.sp,
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.completedOrdersCountLabel,
                  style: AppTextStyles.text13w600(
                    color: colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.verticalSpace,
                Text(
                  AppStrings.completedOrdersCountSubtitle,
                  style: AppTextStyles.text11w500(
                    color: colors.textHint,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          10.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${data.ordersCount}',
                style: AppTextStyles.text26w700(
                  color: colors.primary,
                ),
              ),
              Text(
                AppStrings.ordersUnitLabel,
                style: AppTextStyles.text11w600(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
