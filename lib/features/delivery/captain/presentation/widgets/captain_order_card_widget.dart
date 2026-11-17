import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/shared/finance/data/models/payment_method.dart';

class CaptainOrderCardWidget extends StatelessWidget {
  final OrderDto order;
  final bool isActive;

  const CaptainOrderCardWidget({
    super.key,
    required this.order,
    required this.isActive,
  });

  Widget _buildLocationRow(
    BuildContext context,
    IconData icon,
    String text,
    Color iconColor,
  ) {
    final colors = AppColors(context);
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        10.horizontalSpace,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.text13w600(color: colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final storeName = (order.user?.name != null && order.user!.name!.isNotEmpty)
        ? order.user!.name!
        : (order.userLocation?.name != null &&
                  order.userLocation!.name!.isNotEmpty
              ? order.userLocation!.name!
              : AppStrings.unknownStore);
    final customerName =
        (order.creator?.name != null && order.creator!.name!.isNotEmpty)
        ? order.creator!.name!
        : AppStrings.unknownCustomer;

    String statusLabelText =
        isActive ? AppStrings.onWayLabel : AppStrings.arrivedDoneLabel;
    if (isActive && (order.status == 2 || order.status == 5)) {
      statusLabelText = AppStrings.waitingForPickup;
    }

    return InkWell(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.captainOrderDetails, arguments: order);
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.6),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    order.type == 0
                        ? Icons.restaurant_rounded
                        : Icons.shopping_bag_rounded,
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
                        '${AppStrings.order} #${order.id}',
                        style: AppTextStyles.text15w700(color: colors.textPrimary),
                      ),
                      3.verticalSpace,
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.warning.withValues(alpha: 0.12)
                        : colors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusLabelText,
                    style: AppTextStyles.text11w700(
                      color: isActive ? colors.warning : colors.success,
                    ),
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            _buildLocationRow(
              context,
              Icons.store_rounded,
              '${AppStrings.pickupFromLabel}: $storeName',
              colors.primary,
            ),
            if (order.status >= 6) ...[
              10.verticalSpace,
              _buildLocationRow(
                context,
                Icons.location_on_rounded,
                '${AppStrings.deliverToLabel}: $customerName',
                colors.secondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
