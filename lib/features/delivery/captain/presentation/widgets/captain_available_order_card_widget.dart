import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/core/services/audio/order_sound_service.dart';
import 'package:base_app/features/shared/finance/data/models/payment_method.dart';

class CaptainAvailableOrderCardWidget extends StatelessWidget {
  final OrderDto order;

  const CaptainAvailableOrderCardWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final creatorName =
        (order.creator?.name != null && order.creator!.name!.isNotEmpty)
        ? order.creator!.name!
        : AppStrings.unknownCustomer;
    final storeName = (order.user?.name != null && order.user!.name!.isNotEmpty)
        ? order.user!.name!
        : (order.userLocation?.name != null &&
                  order.userLocation!.name!.isNotEmpty
              ? order.userLocation!.name!
              : AppStrings.unknownStore);
    final earnings = order.deliveryFee;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.6),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(
                  order.type == 0
                      ? Icons.restaurant_rounded
                      : Icons.shopping_bag_rounded,
                  color: colors.primary,
                  size: 24.sp,
                ),
              ),
              14.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      creatorName,
                      style: AppTextStyles.text15w700(color: colors.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    4.verticalSpace,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PaymentMethod.fromValue(order.paymentMethod).icon,
                          size: 13.sp,
                          color: order.isPaidOnline ? colors.success : Colors.orange,
                        ),
                        4.horizontalSpace,
                        Flexible(
                          child: Text(
                            PaymentMethod.fromValue(order.paymentMethod).shortLabel,
                            style: AppTextStyles.text11w600(
                              color: order.isPaidOnline ? colors.success : Colors.orange,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${earnings.toStringAsFixed(0)} ${AppStrings.currency}',
                  style: AppTextStyles.text13w700(color: colors.primary),
                ),
              ),
            ],
          ),
          14.verticalSpace,
          Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
          14.verticalSpace,
          Row(
            children: [
              Icon(Icons.store_rounded, color: colors.primary, size: 20.sp),
              8.horizontalSpace,
              Expanded(
                child: Text(
                  '${AppStrings.pickupFromLabel}: $storeName',
                  style: AppTextStyles.text12w600(color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              12.horizontalSpace,
              ElevatedButton(
                onPressed: () {
                  OrderSoundService.stopRingtone();
                  Navigator.pushNamed(
                    context,
                    AppRoutes.captainOrderDetails,
                    arguments: order,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  AppStrings.viewDetailsBtn,
                  style: AppTextStyles.text12w700(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
