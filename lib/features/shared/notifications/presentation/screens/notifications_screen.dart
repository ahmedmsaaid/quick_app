import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/shared/notifications/data/notification_model.dart';
import 'package:base_app/features/shared/notifications/presentation/riverpod/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationsProvider.notifier).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.notifications,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          if (state.unreadCount > 0)
            Padding(
              padding: EdgeInsets.only(right: 16.w),
              child: Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${state.unreadCount}',
                    style: AppTextStyles.text12w700(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Builder(
        builder: (_) {
          // Loading state
          if (state.status == NotificationsStatus.loading) {
            return Center(
              child: LoadingButton(color: colors.primary),
            );
          }

          // Error state
          if (state.status == NotificationsStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded,
                      size: 48.sp, color: colors.textHint),
                  16.verticalSpace,
                  Text(
                    state.errorMessage ?? 'حدث خطأ، يرجى المحاولة مجددًا',
                    style: AppTextStyles.text14w400(color: colors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  16.verticalSpace,
                  TextButton(
                    onPressed: () => ref
                        .read(notificationsProvider.notifier)
                        .fetchNotifications(),
                    child: Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (state.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined,
                      size: 64.sp, color: colors.textHint),
                  16.verticalSpace,
                  Text(
                    AppStrings.noNotifications,
                    style: AppTextStyles.text16w600(color: colors.textSecondary),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: colors.primary,
            onRefresh: () => ref
                .read(notificationsProvider.notifier)
                .fetchNotifications(),
            child: ListView.separated(
              padding: EdgeInsets.all(20.w),
              itemCount: state.notifications.length,
              separatorBuilder: (_, __) => 10.verticalSpace,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationCard(
                  notification: notification,
                  onTap: () {
                    if (!notification.isRead) {
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(notification.id);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationDto notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final isRead = notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: isRead
              ? colors.surface
              : colors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isRead
                ? colors.border
                : colors.primary.withValues(alpha: 0.35),
            width: isRead ? 1.0 : 1.5,
          ),
          boxShadow: isRead
              ? null
              : [
                  BoxShadow(
                    color: colors.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image / icon area
            _buildIcon(notification, colors),
            14.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          // Use body as headline if no separate title exists
                          notification.title ?? notification.body ?? '',
                          style: AppTextStyles.text14w600(
                            color: colors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.primary,
                          ),
                        ),
                    ],
                  ),
                  if (notification.title != null && notification.body != null) ...[  
                    6.verticalSpace,
                    Text(
                      notification.body!,
                      style: AppTextStyles.text12w400(
                        color: colors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  8.verticalSpace,
                  Text(
                    _formatDate(notification.createdOn),
                    style: AppTextStyles.text10w400(color: colors.textHint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(NotificationDto notification, AppColors colors) {
    if (notification.imageUrl != null && notification.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Image.network(
          notification.imageUrl!,
          width: 48.w,
          height: 48.w,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultIcon(colors),
        ),
      );
    }
    return _defaultIcon(colors);
  }

  Widget _defaultIcon(AppColors colors) => Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_rounded,
          color: colors.primary,
          size: 22.sp,
        ),
      );

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} د';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} س';
    if (diff.inDays == 1) return 'أمس';
    return '${date.day}/${date.month}/${date.year}';
  }
}
