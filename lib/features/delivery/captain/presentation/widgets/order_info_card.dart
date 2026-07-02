import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

class OrderInfoCard extends StatelessWidget {
  final OrderDto order;

  const OrderInfoCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final paymentMethod = order.paymentMethod == 0 ? AppStrings.cashLabel : "إلكتروني";
    final earnings = order.deliveryFee;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "طلب #${order.id}",
                    style: AppTextStyles.text16w700(color: colors.textPrimary),
                  ),
                  5.verticalSpace,
                  Text(
                    order.createdOn != null
                        ? _formatOrderDate(order.createdOn!)
                        : "تاريخ غير متوفر",
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: _getStatusColor(context, order.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: AppTextStyles.text12w600(
                    color: _getStatusColor(context, order.status),
                  ),
                ),
              ),
            ],
          ),
          20.verticalSpace,
          Divider(color: colors.divider.withValues(alpha: 0.5)),
          15.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                AppStrings.netProfitLabel,
                "${earnings.toStringAsFixed(0)} ${AppStrings.currency}",
                colors.success,
                Icons.account_balance_wallet_outlined,
              ),
              _buildInfoItem(
                context,
                AppStrings.paymentMethodLabel,
                paymentMethod,
                Colors.orange,
                order.paymentMethod == 0 ? Icons.money : Icons.credit_card,
              ),
              _buildInfoItem(
                context,
                "نوع الطلب",
                order.type == 0 ? "مطعم" : "متجر",
                Colors.blue,
                order.type == 0 ? Icons.restaurant : Icons.shopping_bag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final colors = AppColors(context);
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 20.sp),
        8.verticalSpace,
        Text(
          label,
          style: AppTextStyles.text11w400(color: colors.textSecondary),
        ),
        4.verticalSpace,
        Text(
          value,
          style: AppTextStyles.text14w700(color: color),
        ),
      ],
    );
  }

  String _formatOrderDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.year}/${date.month}/${date.day}";
    } catch (_) {
      return dateStr;
    }
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return "قيد الانتظار";
      case 1:
        return "في انتظار الدفع";
      case 2:
        return "بانتظار سائق";
      case 3:
        return "مقبول";
      case 4:
        return "جاري التحضير";
      case 5:
        return "جاهز للاستلام";
      case 6:
        return "قيد التوصيل";
      case 7:
        return "تم التوصيل";
      case 8:
        return "ملغي";
      case 9:
        return "مرفوض";
      default:
        return "غير معروف";
    }
  }

  Color _getStatusColor(BuildContext context, int status) {
    final colors = AppColors(context);
    switch (status) {
      case 7:
        return colors.success;
      case 8:
      case 9:
        return colors.error;
      default:
        return colors.primary;
    }
  }
}
