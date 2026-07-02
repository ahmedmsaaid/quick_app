import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

class OrderSummaryCard extends StatelessWidget {
  final OrderDto order;
  final bool isFetchingDetails;

  const OrderSummaryCard({
    super.key,
    required this.order,
    required this.isFetchingDetails,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final subtotal = order.totalPrice - order.deliveryFee - order.orderFee;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.orderDetails, style: AppTextStyles.text14w700(color: colors.textPrimary)),
          15.verticalSpace,
          if (isFetchingDetails)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(color: colors.primary, strokeWidth: 2),
                ),
              ),
            )
          else if (order.products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Text(
                "لا توجد منتجات في هذا الطلب",
                style: AppTextStyles.text12w400(color: colors.textHint),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.products.length,
              separatorBuilder: (context, index) => Divider(color: colors.divider.withValues(alpha: 0.5)),
              itemBuilder: (context, index) {
                final product = order.products[index];
                final name = product.productName ?? "منتج غير معروف";
                final quantity = product.quantity;
                final price = product.price;
                final totalPrice = product.totalPrice;
                final productPhotoUrl = _getImageUrl(product.photo);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: colors.surface,
                          border: Border.all(color: colors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: productPhotoUrl.isNotEmpty
                              ? Image.network(
                                  productPhotoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag_outlined, color: colors.textHint, size: 24.sp),
                                )
                              : Icon(Icons.shopping_bag_outlined, color: colors.textHint, size: 24.sp),
                        ),
                      ),
                      15.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.text14w700(color: colors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            5.verticalSpace,
                            Text(
                              "$quantity x ${price.toStringAsFixed(0)} ${AppStrings.currency}",
                              style: AppTextStyles.text12w400(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      10.horizontalSpace,
                      Text(
                        "${totalPrice.toStringAsFixed(0)} ${AppStrings.currency}",
                        style: AppTextStyles.text14w700(color: colors.textPrimary),
                      ),
                    ],
                  ),
                );
              },
            ),
          15.verticalSpace,
          Divider(color: colors.divider),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            "إجمالي المنتجات",
            "${subtotal.toStringAsFixed(0)} ${AppStrings.currency}",
          ),
          8.verticalSpace,
          _buildSummaryRow(
            context,
            "رسوم التوصيل",
            "${order.deliveryFee.toStringAsFixed(0)} ${AppStrings.currency}",
          ),
          8.verticalSpace,
          _buildSummaryRow(
            context,
            "رسوم الخدمة",
            "${order.orderFee.toStringAsFixed(0)} ${AppStrings.currency}",
          ),
          10.verticalSpace,
          Divider(color: colors.divider),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.requiredFromCustomerLabel,
            "${order.totalPrice.toStringAsFixed(0)} ${AppStrings.currency}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, {bool isTotal = false}) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: isTotal ? AppTextStyles.text14w700(color: colors.textPrimary) : AppTextStyles.text14w400(color: colors.textSecondary)),
        Text(value, style: isTotal ? AppTextStyles.text16w700(color: colors.primary) : AppTextStyles.text14w600(color: colors.textPrimary)),
      ],
    );
  }

  String _getImageUrl(String? photo) {
    if (photo == null || photo.isEmpty) return "";
    if (photo.startsWith("http")) return photo;
    return "${ApiConstants.streamUrl}$photo";
  }
}
