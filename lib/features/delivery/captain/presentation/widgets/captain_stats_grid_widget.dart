import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_dashboard_provider.dart';

class CaptainStatsGridWidget extends ConsumerWidget {
  const CaptainStatsGridWidget({super.key});

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final colors = AppColors(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          14.horizontalSpace,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.text12w600(color: colors.textSecondary),
              ),
              4.verticalSpace,
              Text(
                value,
                style: AppTextStyles.text16w700(color: colors.textPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final dashboard = ref.watch(captainDashboardProvider);

    return dashboard.when(
      skipLoadingOnRefresh: true,
      loading: () => _buildStatCard(
        context,
        title: AppStrings.todayOrders,
        value: '...',
        icon: Icons.shopping_bag_rounded,
        iconColor: colors.primary,
        bgColor: colors.primary.withValues(alpha: 0.08),
      ),
      error: (_, __) => InkWell(
        onTap: () => ref.invalidate(captainDashboardProvider),
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: colors.border.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh_rounded, color: colors.primary, size: 18.sp),
              8.horizontalSpace,
              Text(
                '${AppStrings.serverError} - ${AppStrings.retry}',
                style: AppTextStyles.text12w600(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      ),
      data: (data) => _buildStatCard(
        context,
        title: AppStrings.todayOrders,
        value: '${data.deliveredOrdersCount}',
        icon: Icons.shopping_bag_rounded,
        iconColor: colors.primary,
        bgColor: colors.primary.withValues(alpha: 0.08),
      ),
    );
  }
}
