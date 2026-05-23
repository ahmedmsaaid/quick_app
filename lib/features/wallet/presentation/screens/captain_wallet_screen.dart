import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

class CaptainWalletScreen extends StatelessWidget {
  const CaptainWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          AppStrings.myCaptainWalletTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildBalanceCard(context),
            20.verticalSpace,
            _buildStatsRow(context),
            20.verticalSpace,
            _buildTransactionsHeader(context),
            _buildTransactionsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(20.w),
      padding: EdgeInsets.all(30.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: colors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Text(AppStrings.withdrawableBalanceLabel, style: AppTextStyles.text14w400(color: Colors.white.withOpacity(0.9))),
          10.verticalSpace,
          Text('125,750 ${AppStrings.currency}', style: AppTextStyles.text24w700(color: Colors.white)),
          25.verticalSpace,
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: colors.primary,
              minimumSize: Size(150.w, 45.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(AppStrings.withdrawRequestBtn, style: AppTextStyles.text14w700()),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final colors = AppColors(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          _buildStatBox(context, AppStrings.netProfitLabel, '85,000 ${AppStrings.currency}', colors.success),
          15.horizontalSpace,
          _buildStatBox(context, AppStrings.companyFeesLabel, '12,500 ${AppStrings.currency}', colors.error),
        ],
      ),
    );
  }

  Widget _buildStatBox(BuildContext context, String title, String value, Color color) {
    final colors = AppColors(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10)],
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Text(title, style: AppTextStyles.text12w400(color: colors.textSecondary)),
            5.verticalSpace,
            Text(value, style: AppTextStyles.text14w700(color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsHeader(BuildContext context) {
    final colors = AppColors(context);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(AppStrings.lastTransactionsLabel, style: AppTextStyles.text16w700(color: colors.textPrimary)),
          TextButton(onPressed: () {}, child: Text(AppStrings.seeAll, style: TextStyle(color: colors.primary))),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context) {
    final colors = AppColors(context);
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 6,
      separatorBuilder: (context, index) => 10.verticalSpace,
      itemBuilder: (context, index) {
        bool isProfit = index % 3 == 0;
        return Container(
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            color: colors.surface, 
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isProfit ? Colors.blue.withOpacity(0.1) : colors.success.withOpacity(0.1),
                child: Icon(
                  isProfit ? Icons.delivery_dining : Icons.add_circle_outline, 
                  color: isProfit ? Colors.blue : colors.success,
                ),
              ),
              15.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isProfit ? '${AppStrings.profitFromOrderLabel} #123' : AppStrings.performanceBonusLabel, style: AppTextStyles.text14w600(color: colors.textPrimary)),
                    Text(AppStrings.mockDate, style: AppTextStyles.text12w400(color: colors.textSecondary)),
                  ],
                ),
              ),
              Text('+3,500 ${AppStrings.iqdCurrency}', style: AppTextStyles.text14w700(color: colors.success)),
            ],
          ),
        );
      },
    );
  }
}
