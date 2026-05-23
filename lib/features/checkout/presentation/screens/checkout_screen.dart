import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/utils/extensions.dart';
import '../../../../core/routes/app_routes.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _selectedPayment = 0; // 0 for Cash, 1 for Online

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.confirmBooking,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, AppStrings.whereToDeliverLabel),
            10.verticalSpace,
            _buildAddressCard(context),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.howToPayLabel),
            10.verticalSpace,
            _buildPaymentMethods(context),
            25.verticalSpace,
            _buildSectionTitle(context, AppStrings.billSummaryLabel),
            10.verticalSpace,
            _buildOrderSummary(context),
            30.verticalSpace,
          ],
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(context),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: AppTextStyles.text16w700(color: AppColors(context).textPrimary),
    );
  }

  Widget _buildAddressCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: AppColors(context).surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors(context).border),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: AppColors(context).primary, size: 24.sp),
          15.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.homeLabel, style: AppTextStyles.text14w600(color: AppColors(context).textPrimary)),
                Text(AppStrings.mansourAddressMsg, style: AppTextStyles.text12w400(color: AppColors(context).textSecondary)),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushNamed(AppRoutes.address);
            },
            child: Text(AppStrings.changeBtn, style: AppTextStyles.text12w600(color: AppColors(context).primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      children: [
        _buildPaymentItem(context, 0, Icons.money, AppStrings.cashOnDeliveryLabel),
        10.verticalSpace,
        _buildPaymentItem(context, 1, Icons.credit_card, AppStrings.onlinePaymentLabel),
      ],
    );
  }

  Widget _buildPaymentItem(BuildContext context, int index, IconData icon, String title) {
    bool isSelected = _selectedPayment == index;
    return InkWell(
      onTap: () => setState(() => _selectedPayment = index),
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: AppColors(context).surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors(context).primary : AppColors(context).border,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors(context).primary : AppColors(context).textHint),
            15.horizontalSpace,
            Text(title, style: AppTextStyles.text14w500(color: AppColors(context).textPrimary)),
            const Spacer(),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors(context).primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: AppColors(context).surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: AppColors(context).border),
      ),
      child: Column(
        children: [
          _buildSummaryRow(context, AppStrings.productsPriceLabel, '17,000 ${AppStrings.currency}'),
          10.verticalSpace,
          _buildSummaryRow(context, AppStrings.deliveryFeesLabelMsg, '2,500 ${AppStrings.currency}'),
          10.verticalSpace,
          _buildSummaryRow(context, AppStrings.serviceFeesLabel, '500 ${AppStrings.iqdCurrency}'),
          10.verticalSpace,
          const Divider(),
          10.verticalSpace,
          _buildSummaryRow(context, AppStrings.totalRequiredLabel, '20,000 ${AppStrings.currency}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: isTotal ? AppTextStyles.text16w700(color: AppColors(context).textPrimary) : AppTextStyles.text14w400(color: AppColors(context).textSecondary)),
        Text(value, style: isTotal ? AppTextStyles.text16w700(color: AppColors(context).primary) : AppTextStyles.text14w600(color: AppColors(context).textPrimary)),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      color: AppColors(context).surface,
      child: CustomAppButton(
        text: AppStrings.confirmBooking,
        onPressed: () {
           context.pushNamed(AppRoutes.orderDetailsScreen);
        },
      ),
    );
  }
}
