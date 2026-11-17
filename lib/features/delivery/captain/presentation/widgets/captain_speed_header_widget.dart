import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_nav_provider.dart';
import 'package:base_app/features/shared/notifications/presentation/riverpod/notifications_provider.dart';

class CaptainSpeedHeaderWidget extends ConsumerWidget {
  final ProfileState profileState;
  final bool isOnline;

  const CaptainSpeedHeaderWidget({
    super.key,
    required this.profileState,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final user = profileState.user;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.primary, colors.primary.withValues(alpha: 0.92)],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        border: Border(
          bottom: BorderSide(
            color: colors.secondary,
            width: 2.5.h,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Visual Speed Lines in the background
          Positioned(
            right: -30.w,
            top: 25.h,
            child: Container(
              width: 160.w,
              height: 1.5.h,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            left: -40.w,
            top: 65.h,
            child: Container(
              width: 220.w,
              height: 2.h,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            right: 40.w,
            bottom: 45.h,
            child: Container(
              width: 120.w,
              height: 1.h,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Positioned(
            left: 20.w,
            bottom: 95.h,
            child: Container(
              width: 100.w,
              height: 1.5.h,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),

          // Header Content
          Padding(
            padding: EdgeInsets.fromLTRB(
              20.w,
              MediaQuery.of(context).padding.top + 8.h,
              20.w,
              14.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delivery_dining_rounded,
                              color: colors.secondary,
                              size: 16.sp,
                            ),
                            4.horizontalSpace,
                            Text(
                              AppStrings.controlPanelTitle,
                              style: AppTextStyles.text14w700(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        4.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: isOnline
                                  ? colors.success
                                  : colors.warning,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 7.w,
                                height: 7.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isOnline
                                      ? colors.success
                                      : colors.warning,
                                ),
                              ),
                              4.horizontalSpace,
                              Text(
                                isOnline
                                    ? AppStrings.onlineNowStatus
                                    : AppStrings.breakLabel,
                                style: AppTextStyles.text11w700(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Center Logo
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Image.asset(
                          'assets/image/quick_panner.png',
                          height: 46.h,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.shrink(),
                        ),
                      ),
                    ),

                    // Right: Schedule Icon + Notification Bell + Profile Avatar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.captainScheduleScreen),
                          child: Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.calendar_month_rounded,
                              color: Colors.white,
                              size: 17.sp,
                            ),
                          ),
                        ),
                        6.horizontalSpace,
                        const _CaptainNotificationBell(),
                        6.horizontalSpace,
                        GestureDetector(
                          onTap: () {
                            ref.read(captainNavIndexProvider.notifier).state = 3;
                          },
                          child: Container(
                            width: 34.w,
                            height: 34.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.15),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4),
                                width: 1.2,
                              ),
                            ),
                            child: ClipOval(
                              child:
                                  (user?.photo != null &&
                                      user!.photo!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: user.photo!.startsWith('http')
                                          ? user.photo!
                                          : '${ApiConstants.streamUrl}${user.photo}',
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) =>
                                          Container(color: colors.shimmerBase),
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.person,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptainNotificationBell extends ConsumerWidget {
  const _CaptainNotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(
      notificationsProvider.select((s) => s.unreadCount),
    );

    return GestureDetector(
      onTap: () async {
        await Navigator.of(context).pushNamed(AppRoutes.notifications);
        ref.read(notificationsProvider.notifier).fetchUnreadCount();
      },
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: Colors.white,
                size: 18.sp,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -4,
                right: -4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Container(
                    key: ValueKey(unreadCount),
                    constraints: BoxConstraints(
                      minWidth: 18.w,
                      minHeight: 18.w,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: AppTextStyles.text10w700(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
