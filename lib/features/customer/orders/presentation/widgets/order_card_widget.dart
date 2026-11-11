import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/format_price.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/orders/presentation/widgets/order_status_helper.dart';
import 'package:base_app/features/customer/orders/presentation/widgets/order_reorder_button_widget.dart';
import 'package:base_app/features/customer/orders/presentation/widgets/order_cancel_button_widget.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderDto order;

  const OrderCardWidget({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    // Dynamic Title & Image from products or offer
    String orderTitle = AppStrings.newOrder;
    String photoUrl = '';

    if (order.offerId != null) {
      orderTitle = '${AppStrings.specialOfferOrder} #${order.offerId}';
    } else if (order.products.isNotEmpty) {
      final firstProd = order.products.first;
      orderTitle = firstProd.productName ?? AppStrings.newOrder;
      if (order.products.length > 1) {
        orderTitle += ' و ${order.products.length - 1} ${AppStrings.otherProducts}';
      }
      final String? photo = firstProd.photo;
      photoUrl = (photo != null && photo.isNotEmpty)
          ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
          : '';
    }

    final String dateStr = order.createdOn != null && order.createdOn!.isNotEmpty
        ? order.createdOn!.split('T').first
        : '';

    final isCurrent = order.status < 7;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.orderDetailsScreen,
          arguments: order,
        );
      },
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: photoUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: photoUrl,
                          width: 50.w,
                          height: 50.h,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 50.w,
                            height: 50.h,
                            color: colors.shimmerBase,
                          ),
                          errorWidget: (_, __, ___) => Image.asset(
                            'assets/image/logo.png',
                            width: 50.w,
                            height: 50.h,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Image.asset(
                          'assets/image/logo.png',
                          width: 50.w,
                          height: 50.h,
                          fit: BoxFit.cover,
                        ),
                ),
                15.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderTitle,
                        style: AppTextStyles.text14w600(color: colors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      5.verticalSpace,
                      Text(
                        '${AppStrings.uniqueNumber}: #${order.id}',
                        style: AppTextStyles.text12w400(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: OrderStatusHelper.getStatusColor(order.status, colors).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    OrderStatusHelper.getStatusText(order.status),
                    style: AppTextStyles.text10w500(
                      color: OrderStatusHelper.getStatusColor(order.status, colors),
                    ),
                  ),
                ),
              ],
            ),
            15.verticalSpace,
            Divider(color: colors.divider),
            15.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dateStr,
                  style: AppTextStyles.text12w400(color: colors.textSecondary),
                ),
                if (order.hasPromoDiscount)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${formatPrice(order.originalTotalPrice)} ${AppStrings.currency}',
                        style: AppTextStyles.text12w400(
                          color: colors.textHint,
                        ).copyWith(
                          decoration: TextDecoration.lineThrough,
                          decorationColor: colors.textHint,
                        ),
                      ),
                      8.horizontalSpace,
                      Text(
                        '${formatPrice(order.effectiveFinalPrice)} ${AppStrings.currency}',
                        style: AppTextStyles.text14w700(color: colors.success),
                      ),
                    ],
                  )
                else
                  Text(
                    '${formatPrice(order.effectiveFinalPrice)} ${AppStrings.currency}',
                    style: AppTextStyles.text14w700(color: colors.primary),
                  ),
              ],
            ),
            if (isCurrent) ...[
              15.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.orderDetailsScreen,
                          arguments: order,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text(
                        AppStrings.trackOrderBtn,
                        style: AppTextStyles.text12w600(color: colors.primary),
                      ),
                    ),
                  ),
                  15.horizontalSpace,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.chatDetailsScreen,
                          arguments: AppStrings.technicalSupportTitle,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text(
                        AppStrings.helpBtn,
                        style: AppTextStyles.text12w600(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              if (order.status == 0) ...[
                10.verticalSpace,
                OrderCancelButtonWidget(order: order),
              ],
            ] else ...[
              15.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: OrderReorderButtonWidget(order: order),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
