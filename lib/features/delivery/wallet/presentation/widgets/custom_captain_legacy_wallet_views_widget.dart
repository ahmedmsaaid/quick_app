import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/shared/finance/data/models/delivery_dashboard_model.dart';
import 'package:base_app/core/routes/app_routes.dart';

/// Legacy Wallet Section Widget preserved for reference per user request.
/// Keep inactive/commented out unless requested.
class CustomCaptainLegacyWalletViewsWidget extends StatelessWidget {
  final DeliveryDashboardModel data;

  const CustomCaptainLegacyWalletViewsWidget({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    // Preserved for future reference
    return const SizedBox.shrink();
  }

  /*
  ==============================================================================
  ARCHIVED LEGACY COMPONENTS (PRESERVED PER USER SPECIFICATION)
  ==============================================================================

  Widget buildLegacyHeroCard(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [colors.primary, const Color(0xFF1E3A8A), const Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.currentWalletBalanceLabel, style: AppTextStyles.text12w500(color: Colors.white70)),
          4.verticalSpace,
          Text('${data.currentWalletBalance.toStringAsFixed(2)} ${AppStrings.currency}', style: AppTextStyles.text24w700(color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildDuePayoutBanner(BuildContext context) {
    final colors = AppColors(context);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.mySettlements),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.account_balance_wallet_rounded, color: colors.primary, size: 20.sp),
            12.horizontalSpace,
            Expanded(
              child: Text('${data.duePayout.toStringAsFixed(2)} ${AppStrings.currency}', style: AppTextStyles.text16w700(color: colors.primary)),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: colors.textSecondary),
          ],
        ),
      ),
    );
  }
  ==============================================================================
  */
}
