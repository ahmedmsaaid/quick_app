import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/utils/format_price.dart';

class CheckoutBillSummaryWidget extends StatelessWidget {
  final double productsPrice;
  final double deliveryFee;
  final double serviceFee;
  final double discountAmount;
  final double totalRequired;

  const CheckoutBillSummaryWidget({
    super.key,
    required this.productsPrice,
    required this.deliveryFee,
    required this.serviceFee,
    this.discountAmount = 0.0,
    required this.totalRequired,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            context,
            AppStrings.productsPriceLabel,
            '${formatPrice(productsPrice)} ${AppStrings.currency}',
          ),
          if (discountAmount > 0) ...[
            10.verticalSpace,
            _buildSummaryRow(
              context,
              AppStrings.discountAmountLabel,
              '-${formatPrice(discountAmount)} ${AppStrings.currency}',
              valueColor: colors.success,
            ),
          ],
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.deliveryFeesLabelMsg,
            '${formatPrice(deliveryFee)} ${AppStrings.currency}',
          ),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.serviceFeesLabel,
            '${formatPrice(serviceFee)} ${AppStrings.currency}',
          ),
          10.verticalSpace,
          Divider(color: colors.border),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.totalRequiredLabel,
            '${formatPrice(totalRequired)} ${AppStrings.currency}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String title,
    String value, {
    bool isTotal = false,
    Color? valueColor,
  }) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: isTotal
                ? AppTextStyles.text16w700(color: colors.textPrimary)
                : AppTextStyles.text14w400(color: colors.textSecondary),
          ),
        ),
        8.horizontalSpace,
        Text(
          value,
          style: isTotal
              ? AppTextStyles.text16w700(color: colors.primary)
              : AppTextStyles.text14w600(
                  color: valueColor ?? colors.textPrimary,
                ),
        ),
      ],
    );
  }
}
