import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

class WalletScreen extends StatelessWidget {
  final bool isFromNav;
  const WalletScreen({super.key, this.isFromNav = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: isFromNav ? null : const CustomArrowBack(),
        automaticallyImplyLeading: !isFromNav,
        title: Text(
          AppStrings.wallet,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(20.w),
            padding: EdgeInsets.all(25.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.primary, colors.primary.withValues(alpha: 0.7)],
              ),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Column(
              children: [
                Text(AppStrings.currentBalanceLabel,
                    style: AppTextStyles.text14w400(color: Colors.white)),
                5.verticalSpace,
                Text('25,000 ${AppStrings.currency}',
                    style: AppTextStyles.text24w700(color: Colors.white)),
                20.verticalSpace,
                ElevatedButton(
                  onPressed: () => _showChargeBottomSheet(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colors.primary,
                    minimumSize: Size(150.w, 45.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text(AppStrings.chargeBalanceLabel,
                      style: AppTextStyles.text14w700()),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(AppStrings.lastOperationsLabel,
                    style: AppTextStyles.text16w700(color: colors.textPrimary)),
              ],
            ),
          ),
          15.verticalSpace,
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: 4,
              separatorBuilder: (context, index) => 10.verticalSpace,
              itemBuilder: (context, index) {
                bool isAddition = index % 2 == 0;
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
                        backgroundColor: isAddition
                            ? colors.success.withValues(alpha: 0.1)
                            : colors.error.withValues(alpha: 0.1),
                        child: Icon(
                          isAddition ? Icons.add : Icons.remove,
                          color: isAddition ? colors.success : colors.error,
                        ),
                      ),
                      15.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                isAddition
                                    ? AppStrings.chargeBalanceLabel
                                    : '${AppStrings.payForOrderLabel} #123',
                                style: AppTextStyles.text14w600(
                                    color: colors.textPrimary)),
                            Text(AppStrings.mockDate,
                                style: AppTextStyles.text12w400(
                                    color: colors.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        isAddition ? '+10,000' : '-5,000',
                        style: AppTextStyles.text14w700(
                            color: isAddition ? colors.success : colors.error),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showChargeBottomSheet(BuildContext context) {
    final colors = AppColors(context);
    int selectedMethod = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            padding: EdgeInsets.fromLTRB(
                20.w,
                20.h,
                20.w,
                MediaQuery.of(context).viewInsets.bottom + 30.h),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                25.verticalSpace,
                Text(AppStrings.chargeBalanceLabel,
                    style: AppTextStyles.text18w700(color: colors.textPrimary)),
                20.verticalSpace,
                CustomTextField(
                  hintText: AppStrings.enterAmountHint,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined,
                      color: colors.primary),
                ),
                20.verticalSpace,
                Text(AppStrings.selectPaymentMethod,
                    style:
                        AppTextStyles.text14w600(color: colors.textPrimary)),
                15.verticalSpace,
                _PaymentMethodItem(
                  title: AppStrings.vodafoneCash,
                  icon: Icons.phone_android,
                  isSelected: selectedMethod == 0,
                  onTap: () => setModalState(() => selectedMethod = 0),
                ),
                10.verticalSpace,
                _PaymentMethodItem(
                  title: AppStrings.instapay,
                  icon: Icons.account_balance,
                  isSelected: selectedMethod == 1,
                  onTap: () => setModalState(() => selectedMethod = 1),
                ),
                10.verticalSpace,
                _PaymentMethodItem(
                  title: AppStrings.creditCard,
                  icon: Icons.credit_card,
                  isSelected: selectedMethod == 2,
                  onTap: () => setModalState(() => selectedMethod = 2),
                ),
                30.verticalSpace,
                CustomAppButton(
                  text: AppStrings.confirmCharge,
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white),
                            10.horizontalSpace,
                            Text(AppStrings.chargeSuccessMsg),
                          ],
                        ),
                        backgroundColor: colors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                        margin: EdgeInsets.all(20.w),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaymentMethodItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color:
              isSelected ? colors.primary.withValues(alpha: 0.05) : colors.background,
          borderRadius: BorderRadius.circular(12.r),
          border:
              Border.all(color: isSelected ? colors.primary : colors.border),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? colors.primary : colors.textSecondary),
            15.horizontalSpace,
            Text(title,
                style: AppTextStyles.text14w500(color: colors.textPrimary)),
            const Spacer(),
            Radio(
              value: true,
              groupValue: isSelected,
              onChanged: (v) => onTap(),
              activeColor: colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
