import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/utils/format_price.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

class OrderTrackingVendorCardWidget extends StatelessWidget {
  final OrderDto order;

  const OrderTrackingVendorCardWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final String storeName = order.user?.name ?? order.userLocation?.name ?? AppStrings.storeNameFallback;
    final String? rawPhoto = order.user?.photo ?? order.user?.avatar;
    final String photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
        ? (rawPhoto.startsWith('http')
            ? rawPhoto
            : '${ApiConstants.streamUrl}$rawPhoto')
        : '';

    String productSummary = '';
    if (order.products.isNotEmpty) {
      productSummary = order.products
          .map((p) => '${p.productName ?? ''} ×${p.quantity}')
          .join('  •  ');
    } else if (order.offerId != null) {
      productSummary = AppStrings.specialOfferOrder;
    }

    return Column(
      children: [
        Row(
          children: [
            ClipOval(
              child: photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      width: 48.w,
                      height: 48.w,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        width: 48.w,
                        height: 48.w,
                        color: colors.shimmerBase,
                      ),
                      errorWidget: (_, __, ___) => _fallbackAvatar(colors),
                    )
                  : _fallbackAvatar(colors),
            ),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    storeName,
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                  ),
                  4.verticalSpace,
                  Text(
                    '${formatPrice(order.effectiveFinalPrice)} ${AppStrings.currency}',
                    style: AppTextStyles.text13w600(color: colors.primary),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (productSummary.isNotEmpty) ...[
          12.verticalSpace,
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: colors.containerBackground,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              productSummary,
              style: AppTextStyles.text11w400(color: colors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  Widget _fallbackAvatar(AppColors colors) {
    return Container(
      width: 48.w,
      height: 48.w,
      color: colors.shimmerBase,
      child: Icon(
        Icons.storefront_rounded,
        color: colors.textHint,
        size: 22.sp,
      ),
    );
  }
}
