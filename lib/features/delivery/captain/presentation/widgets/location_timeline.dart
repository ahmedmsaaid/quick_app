import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/core/constans/role_type_enum.dart';
import 'package:base_app/core/models/app_chat_argument.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class LocationTimeline extends StatelessWidget {
  final OrderDto order;
  final LocationDto? vendorLocation;

  const LocationTimeline({
    super.key,
    required this.order,
    this.vendorLocation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final storeLat = vendorLocation?.latitude ?? order.userLocation?.latitude ?? order.user?.location?.latitude;
    final storeLng = vendorLocation?.longitude ?? order.userLocation?.longitude ?? order.user?.location?.longitude;
    final destLat = order.latitude != 0 ? order.latitude : (order.creator?.location?.latitude ?? 0.0);
    final destLng = order.longitude != 0 ? order.longitude : (order.creator?.location?.longitude ?? 0.0);

    final storeName = order.user?.name ?? "متجر غير معروف";
    final storeAddress = (vendorLocation?.address != null && vendorLocation!.address!.isNotEmpty)
        ? vendorLocation!.address!
        : (order.userLocation?.address != null && order.userLocation!.address!.isNotEmpty)
            ? order.userLocation!.address!
            : (order.user?.address != null && order.user!.address!.isNotEmpty)
                ? order.user!.address!
                : (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0)
                    ? "الموقع: ${storeLat.toStringAsFixed(5)}, ${storeLng.toStringAsFixed(5)}"
                    : "عنوان غير متوفر";

    final customerName = order.creator?.name ?? "زبون غير معروف";
    final customerAddress = (order.address != null && order.address!.isNotEmpty)
        ? order.address!
        : (order.creator?.address != null && order.creator!.address!.isNotEmpty)
            ? order.creator!.address!
            : (destLat != 0 && destLng != 0)
                ? "الموقع: ${destLat.toStringAsFixed(5)}, ${destLng.toStringAsFixed(5)}"
                : "عنوان غير متوفر";

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
          _buildTimelineItem(
            context,
            Icons.store,
            AppStrings.pickupPointLabel,
            storeName,
            storeAddress,
            Colors.blue,
            avatarUrl: null,
            phone: order.user?.phone,
            recipientId: order.userLocation?.creatorId ?? order.userId,
            roleType: order.type == 0 ? RoleTypeEnum.restaurant : RoleTypeEnum.market,
            showChat: true,
          ),
          25.verticalSpace,
          _buildTimelineItem(
            context,
            Icons.location_on,
            AppStrings.deliveryPointLabel,
            customerName,
            customerAddress,
            colors.error,
            isLast: true,
            avatarUrl: _getImageUrl(order.creator?.photo ?? order.creator?.avatar),
            phone: order.creator?.phone,
            recipientId: order.creatorId ?? order.userId,
            roleType: RoleTypeEnum.customer,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    IconData icon,
    String type,
    String title,
    String subtitle,
    Color color, {
    bool isLast = false,
    String? phone,
    String? avatarUrl,
    int? recipientId,
    RoleTypeEnum? roleType,
    bool showChat = true,
  }) {
    final colors = AppColors(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), 
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
              ),
              child: ClipOval(
                child: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 20.sp),
                      )
                    : Icon(icon, color: color, size: 20.sp),
              ),
            ),
            if (!isLast)
              Container(width: 2.w, height: 45.h, color: colors.divider),
          ],
        ),
        15.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: AppTextStyles.text10w500(color: color)),
              Text(title, style: AppTextStyles.text14w700(color: colors.textPrimary)),
              Text(subtitle, style: AppTextStyles.text12w400(color: colors.textSecondary)),
            ],
          ),
        ),
        if (phone != null && phone.isNotEmpty)
          Row(
            children: [
              IconButton(
                onPressed: () async {
                  final Uri phoneUri = Uri(scheme: 'tel', path: phone);
                  try {
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("لا يمكن الاتصال بالرقم $phone")),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("خطأ أثناء محاولة الاتصال: $e")),
                      );
                    }
                  }
                },
                icon: Icon(Icons.call, color: colors.success, size: 22.sp),
              ),
              if (showChat)
                IconButton(
                  onPressed: () {
                    if (recipientId != null && roleType != null) {
                      Navigator.of(context).pushNamed(
                        AppRoutes.chatDetailsScreen,
                        arguments: AppChatArgument(
                          chatId: null,
                          recipientId: recipientId,
                          profileId: 0,
                          typeEnum: roleType,
                          recipientName: title,
                          recipientImage: avatarUrl ?? '',
                        ),
                      );
                    } else {
                      Navigator.of(context).pushNamed(
                        AppRoutes.chatDetailsScreen,
                        arguments: title,
                      );
                    }
                  }, 
                  icon: Icon(Icons.chat, color: colors.primary, size: 22.sp),
                ),
            ],
          ),
      ],
    );
  }

  String _getImageUrl(String? photo) {
    if (photo == null || photo.isEmpty) return "";
    if (photo.startsWith("http")) return photo;
    return "${ApiConstants.streamUrl}$photo";
  }
}
