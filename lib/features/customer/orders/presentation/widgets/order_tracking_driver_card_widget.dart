import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/constans/role_type_enum.dart';
import 'package:base_app/core/models/app_chat_argument.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/customer/orders/presentation/widgets/order_driver_action_button_widget.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

class OrderTrackingDriverCardWidget extends StatelessWidget {
  final OrderDto order;

  const OrderTrackingDriverCardWidget({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    // Only display the captain once the order has been accepted by a captain (status 3..7)
    if (order.status < 3 || order.status > 7) return const SizedBox.shrink();
    final driver = order.delivery;
    if (driver == null) return const SizedBox.shrink();

    final String? photoKey = driver.photo ?? driver.avatar;
    final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
        ? (photoKey.startsWith('http')
            ? photoKey
            : '${ApiConstants.streamUrl}$photoKey')
        : '';

    return Column(
      children: [
        16.verticalSpace,
        Divider(color: colors.divider),
        16.verticalSpace,
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
                    driver.name ?? AppStrings.driverNameFallback,
                    style: AppTextStyles.text14w700(color: colors.textPrimary),
                  ),
                  4.verticalSpace,
                  Text(
                    AppStrings.deliveryCaptain,
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            // Chat & Call Captain
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (driver.phone != null && driver.phone!.isNotEmpty)
                  OrderDriverActionButtonWidget(
                    icon: Icons.call_rounded,
                    color: colors.success,
                    onTap: () => _launchCall(context, driver.phone!),
                  ),
                if (driver.phone != null && driver.phone!.isNotEmpty)
                  6.horizontalSpace,
                OrderDriverActionButtonWidget(
                  icon: Icons.chat_bubble_outline_rounded,
                  color: colors.primary,
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.chatDetailsScreen,
                    arguments: AppChatArgument(
                      chatId: null,
                      recipientId: order.deliveryId ?? driver.id,
                      profileId: 0,
                      typeEnum: RoleTypeEnum.captain,
                      recipientName: driver.name ?? AppStrings.driverNameFallback,
                      recipientImage: photoUrl,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _fallbackAvatar(AppColors colors) {
    return Container(
      width: 48.w,
      height: 48.w,
      color: colors.shimmerBase,
      child: Icon(
        Icons.delivery_dining_rounded,
        color: colors.textHint,
        size: 22.sp,
      ),
    );
  }

  Future<void> _launchCall(BuildContext context, String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          CustomToast.error(context, '${AppStrings.cannotCallNumber} $phone');
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomToast.error(context, '${AppStrings.callError}: $e');
      }
    }
  }
}
