import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/utils/format_price.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

class OrderTrackingDetailsCardWidget extends StatefulWidget {
  final OrderDto order;

  const OrderTrackingDetailsCardWidget({super.key, required this.order});

  @override
  State<OrderTrackingDetailsCardWidget> createState() => _OrderTrackingDetailsCardWidgetState();
}

class _OrderTrackingDetailsCardWidgetState extends State<OrderTrackingDetailsCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final order = widget.order;
    final products = order.products;
    final subTotal = products.fold(0.0, (sum, p) => sum + (p.price * p.quantity));

    return Container(
      decoration: BoxDecoration(
        color: colors.containerBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          // Header button to click and toggle details
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: colors.primary,
                      size: 20.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.orderDetailsAndItems,
                          style: AppTextStyles.text14w700(color: colors.textPrimary),
                        ),
                        4.verticalSpace,
                        Text(
                          products.isNotEmpty
                              ? '${products.length} ${AppStrings.itemsCount} • ${formatPrice(order.effectiveFinalPrice)} ${AppStrings.currency}'
                              : AppStrings.clickToViewBillAndItems,
                          style: AppTextStyles.text12w400(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.textSecondary,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          // Expanded items details & breakdown
          if (_isExpanded) ...[
            Divider(color: colors.divider, height: 1),
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                children: [
                  if (products.isNotEmpty)
                    ...products.map((item) {
                      final rawPhoto = item.photo;
                      final photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
                          ? (rawPhoto.startsWith('http')
                              ? rawPhoto
                              : '${ApiConstants.streamUrl}$rawPhoto')
                          : '';

                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: photoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      width: 40.w,
                                      height: 40.w,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: colors.shimmerBase,
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: colors.shimmerBase,
                                        child: Icon(
                                          Icons.fastfood_rounded,
                                          size: 20.sp,
                                          color: colors.textHint,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 40.w,
                                      height: 40.w,
                                      color: colors.shimmerBase,
                                      child: Icon(
                                        Icons.fastfood_rounded,
                                        size: 20.sp,
                                        color: colors.textHint,
                                      ),
                                    ),
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName ?? AppStrings.singleItem,
                                    style: AppTextStyles.text13w600(
                                      color: colors.textPrimary,
                                    ),
                                  ),
                                  2.verticalSpace,
                                  Text(
                                    '${AppStrings.quantityLabel}: ${item.quantity}',
                                    style: AppTextStyles.text11w400(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${formatPrice(item.price * item.quantity)} ${AppStrings.currency}',
                              style: AppTextStyles.text13w700(
                                color: colors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                  else if (order.offerId != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Text(
                        AppStrings.specialOfferFullOrder,
                        style: AppTextStyles.text13w600(color: colors.textPrimary),
                      ),
                    ),

                  10.verticalSpace,
                  Divider(color: colors.divider),
                  8.verticalSpace,

                  // Summary breakdown
                  _priceRow(AppStrings.subtotalLabel, '${formatPrice(subTotal)} ${AppStrings.currency}', colors),
                  if (order.hasPromoDiscount) ...[
                    6.verticalSpace,
                    _priceRow(
                      '${AppStrings.discountLabel} (${order.promoCodeName ?? "-${order.promoDiscountPercentage!.toStringAsFixed(0)}%"})',
                      '-${formatPrice(order.originalTotalPrice - order.effectiveFinalPrice)} ${AppStrings.currency}',
                      colors,
                      valueColor: colors.success,
                    ),
                  ],
                  6.verticalSpace,
                  _priceRow(
                    AppStrings.deliveryFeesLabel,
                    order.hasFreeDeliveryPromo
                        ? AppStrings.freeDeliveryTitle
                        : '${formatPrice(order.deliveryFee)} ${AppStrings.currency}',
                    colors,
                    valueColor: order.hasFreeDeliveryPromo ? colors.success : null,
                  ),
                  8.verticalSpace,
                  Divider(color: colors.divider),
                  8.verticalSpace,
                  _priceRow(AppStrings.finalTotalLabel, '${formatPrice(order.effectiveFinalPrice)} ${AppStrings.currency}', colors, isTotal: true),
                  if (order.notes != null && order.notes!.trim().isNotEmpty) ...[
                    10.verticalSpace,
                    Divider(color: colors.divider),
                    8.verticalSpace,
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: colors.primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.notes_rounded,
                            color: colors.primary,
                            size: 18.sp,
                          ),
                          8.horizontalSpace,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStrings.customerNotesLabel,
                                  style: AppTextStyles.text11w700(
                                    color: colors.primary,
                                  ),
                                ),
                                4.verticalSpace,
                                Text(
                                  order.notes!.trim(),
                                  style: AppTextStyles.text12w500(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, AppColors colors, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.text14w700(color: colors.textPrimary)
              : AppTextStyles.text12w400(color: colors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.text15w700(color: colors.primary)
              : AppTextStyles.text13w600(color: colors.textPrimary),
        ),
      ],
    );
  }
}
