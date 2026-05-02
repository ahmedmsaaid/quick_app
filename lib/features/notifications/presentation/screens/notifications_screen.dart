import 'package:base_app/core/extintions/extintios.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_app_bar.dart';

import '../../../../core/exports/exports.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(
        title: AppStrings.notifications.trans,
        showTrailing: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        itemCount: notificationsList.length,
        separatorBuilder: (context, index) => Container(
          height: 1,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          color: colors.divider,
        ),
        itemBuilder: (context, index) =>
            NotificationItem(notification: notificationsList[index]),
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const NotificationItem({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: NetworkImage(notification.imageUrl),
          ),
          12.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: AppTextStyles.text16w600(color: colors.textPrimary),
                ),
                4.verticalSpace,
                Text(
                  notification.description,
                  style: AppTextStyles.text14w400(color: colors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                8.verticalSpace,
              ],
            ),
          ),
          12.horizontalSpace,

          Column(
            children: [
              Text(
                notification.time,
                style: AppTextStyles.text12w400(color: colors.textHint),
              ),
              Container(
                width: 8.w,
                height: 8.h,
                margin: EdgeInsets.only(top: 6.h),
                decoration: BoxDecoration(
                  color: colors.success,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NotificationModel {
  final String title;
  final String description;
  final String time;
  final String imageUrl;

  NotificationModel({
    required this.title,
    required this.description,
    required this.time,
    required this.imageUrl,
  });
}

final List<NotificationModel> notificationsList = [
  NotificationModel(
    title: 'هدا البند غير متاح',
    description: 'هذا البند غير متاح حتي الان يمكنك الحصول علي استشارتي',
    time: '10 m',
    imageUrl: '',
  ),
  NotificationModel(
    title: 'هدا البند غير متاح',
    description: 'هذا البند غير متاح حتي الان يمكنك الحصول علي استشارتي',
    time: '10 m',
    imageUrl: '',
  ),
  NotificationModel(
    title: 'هدا البند غير متاح',
    description: 'هذا البند غير متاح حتي الان يمكنك الحصول علي استشارتي',
    time: '10 m',
    imageUrl: '',
  ),
  NotificationModel(
    title: 'هدا البند غير متاح',
    description: 'هذا البند غير متاح حتي الان يمكنك الحصول علي استشارتي',
    time: '10 m',
    imageUrl: '',
  ),
];
