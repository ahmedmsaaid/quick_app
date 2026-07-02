import 'dart:async';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/shared/auth/presentation/riverpod/auth_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:base_app/features/shared/notifications/presentation/riverpod/notifications_provider.dart';

class CaptainHomeScreen extends ConsumerStatefulWidget {
  const CaptainHomeScreen({super.key});

  @override
  ConsumerState<CaptainHomeScreen> createState() => _CaptainHomeScreenState();
}

class _CaptainHomeScreenState extends ConsumerState<CaptainHomeScreen> with WidgetsBindingObserver {
  bool _isOnline = true;
  Timer? _breakTimer;
  int _breakSecondsRemaining = 1800; // 30 minutes

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Load the user profile to check activation status
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
    });
  }

  Future<int?> _showBreakDurationDialog() async {
    final colors = AppColors(context);
    return showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          title: Text(
            'اختر مدة الاستراحة',
            style: AppTextStyles.text16w700(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDurationOption(context, '10 دقائق', 10),
              10.verticalSpace,
              _buildDurationOption(context, '20 دقيقة', 20),
              10.verticalSpace,
              _buildDurationOption(context, '30 دقيقة', 30),
              10.verticalSpace,
              _buildDurationOption(context, '45 دقيقة', 45),
              10.verticalSpace,
              _buildDurationOption(context, 'ساعة واحدة', 60),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text(
                'إلغاء',
                style: AppTextStyles.text14w600(color: colors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDurationOption(BuildContext context, String title, int minutes) {
    final colors = AppColors(context);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary.withValues(alpha: 0.1),
          foregroundColor: colors.primary,
          elevation: 0,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
            side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
          ),
        ),
        onPressed: () => Navigator.of(context).pop(minutes),
        child: Text(
          title,
          style: AppTextStyles.text14w700(color: colors.primary),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(bool val) async {
    if (!val) {
      // Going offline (Break) -> Show duration dialog
      final minutes = await _showBreakDurationDialog();
      if (minutes == null) {
        // User cancelled, do not update backend or local switch state
        return;
      }
      setState(() {
        _breakSecondsRemaining = minutes * 60;
      });
    }

    final success = await ref.read(profileProvider.notifier).toggleActivity();
    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل تحديث حالة النشاط، يرجى المحاولة لاحقاً')),
        );
      }
    }
  }

  void _startBreakTimer() {
    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_breakSecondsRemaining > 0) {
        setState(() {
          _breakSecondsRemaining--;
        });
      } else {
        timer.cancel();
        ref.read(profileProvider.notifier).toggleActivity();
      }
    });
  }

  String _formatTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh captain orders and unread notification badge count when app comes back to foreground
      ref.read(captainOrdersProvider.notifier).loadAll();
      ref.read(notificationsProvider.notifier).fetchUnreadCount();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _breakTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final ordersState = ref.watch(captainOrdersProvider);

    // Synchronize initial loaded active status
    if (profileState.status == ProfileStatus.loaded && profileState.user != null) {
      final nextActive = profileState.user!.active ?? false;
      if (_isOnline != nextActive && _breakTimer == null) {
        Future.microtask(() {
          if (mounted) {
            setState(() {
              _isOnline = nextActive;
              if (!_isOnline) {
                _startBreakTimer();
              }
            });
          }
        });
      }
    }

    // Listen to live profile status changes to update break/online status dynamically
    ref.listen(profileProvider, (previous, next) {
      if (next.status == ProfileStatus.loaded && next.user != null) {
        final nextActive = next.user!.active ?? false;
        if (_isOnline != nextActive) {
          setState(() {
            _isOnline = nextActive;
            if (!_isOnline) {
              _startBreakTimer();
            } else {
              _breakTimer?.cancel();
              _breakSecondsRemaining = 1800;
            }
          });
        }
      }
    });

    // Show loading while profile is being fetched
    if (profileState.status == ProfileStatus.loading ||
        profileState.status == ProfileStatus.initial) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: LoadingButton(color: colors.primary),
        ),
      );
    }

    // Check user activation status (status == 0 means pending, status == 2 means rejected/blocked)
    final userStatus = profileState.user?.status ?? 0;
    if (userStatus == 0) {
      return _buildPendingApprovalScreen(colors);
    } else if (userStatus == 2) {
      return _buildRejectedScreen(colors);
    }

    // Normal home screen
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const _NotificationBell(),
        title: Text(
          AppStrings.controlPanelTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Text(
                _isOnline ? AppStrings.onlineNowStatus : AppStrings.breakLabel.split(' ')[0],
                style: AppTextStyles.text12w600(color: _isOnline ? AppColors(context).success : AppColors(context).warning),
              ),
              Switch(
                value: _isOnline,
                onChanged: _toggleStatus,
                activeThumbColor: AppColors(context).success,
                inactiveThumbColor: AppColors(context).warning,
                inactiveTrackColor: AppColors(context).warning.withOpacity(0.3),
              ),
            ],
          ),
          10.horizontalSpace,
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(captainOrdersProvider.notifier).loadAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildStatusCard(context),
              20.verticalSpace,
              _buildStatsGrid(context, ordersState),
              20.verticalSpace,
              _buildSectionHeader(context, AppStrings.availableOrdersNow, ref),
              10.verticalSpace,
              if (_isOnline) ...[
                if (ordersState.status == CaptainOrdersStatus.loading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(child: LoadingButton(color: colors.primary)),
                  )
                else if (ordersState.status == CaptainOrdersStatus.error)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            ordersState.errorMessage ?? 'حدث خطأ ما',
                            style: AppTextStyles.text14w600(color: colors.error),
                          ),
                          10.verticalSpace,
                          ElevatedButton(
                            onPressed: () => ref.read(captainOrdersProvider.notifier).loadAll(),
                            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
                            child: Text('إعادة المحاولة', style: AppTextStyles.text12w600(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _buildAvailableOrdersList(context, ordersState.activeOrders)
              ] else
                _buildBreakMessage(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Pending Approval Screen ──────────────────────────────────────────────

  Widget _buildPendingApprovalScreen(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated icon container
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: colors.warning.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.warning.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 56.sp,
                    color: colors.warning,
                  ),
                ),
                32.verticalSpace,

                Text(
                  'في انتظار الموافقة',
                  style: AppTextStyles.text22w700(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                12.verticalSpace,

                Text(
                  'تم إنشاء حسابك بنجاح!\nحسابك قيد المراجعة حالياً من قبل الإدارة.\nسيتم تفعيل حسابك في أقرب وقت.',
                  style: AppTextStyles.text14w400(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                32.verticalSpace,

                // Status info card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: colors.warning.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: colors.warning.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: colors.warning.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: colors.warning,
                          size: 22.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حالة الحساب',
                              style: AppTextStyles.text12w600(color: colors.textPrimary),
                            ),
                            4.verticalSpace,
                            Text(
                              'غير مفعّل — في انتظار موافقة الأدمن',
                              style: AppTextStyles.text12w400(color: colors.warning),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                40.verticalSpace,

                // Refresh button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ref.read(profileProvider.notifier).loadProfile();
                    },
                    icon: Icon(Icons.refresh_rounded, color: colors.primary),
                    label: Text(
                      'تحقق من حالة الحساب',
                      style: AppTextStyles.text14w600(color: colors.primary),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRejectedScreen(AppColors colors) {
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error/Blocked icon container
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.block_flipped,
                    size: 56.sp,
                    color: colors.error,
                  ),
                ),
                32.verticalSpace,

                Text(
                  'تم رفض الحساب',
                  style: AppTextStyles.text22w700(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                12.verticalSpace,

                Text(
                  'لقد تم رفض طلب انضمامك أو حظر حسابك من قبل الإدارة.\nيرجى التواصل مع الدعم الفني لمزيد من التفاصيل.',
                  style: AppTextStyles.text14w400(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                32.verticalSpace,

                // Status info card
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: colors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: colors.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: colors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          Icons.info_outline_rounded,
                          color: colors.error,
                          size: 22.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'حالة الحساب',
                              style: AppTextStyles.text12w600(color: colors.textPrimary),
                            ),
                            4.verticalSpace,
                            Text(
                              'مرفوض / محظور — تواصل مع الدعم الفني',
                              style: AppTextStyles.text12w400(color: colors.error),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                40.verticalSpace,

                // Support button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.contactUs);
                    },
                    icon: const Icon(Icons.support_agent_rounded, color: Colors.white),
                    label: Text(
                      'تواصل مع الدعم الفني',
                      style: AppTextStyles.text14w600(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
                16.verticalSpace,

                // Logout button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          AppRoutes.chooseUserTypeScreen,
                          (route) => false,
                        );
                      }
                    },
                    icon: Icon(Icons.logout_rounded, color: colors.error),
                    label: Text(
                      'تسجيل الخروج',
                      style: AppTextStyles.text14w600(color: colors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: colors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Normal Home Widgets ──────────────────────────────────────────────────

  Widget _buildStatusCard(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: _isOnline ? colors.success.withOpacity(0.1) : colors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: _isOnline ? colors.success : colors.warning, width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.check_circle : Icons.timer_outlined,
            color: _isOnline ? colors.success : colors.warning,
          ),
          15.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isOnline ? AppStrings.onlineReadyToWorkMsg : AppStrings.breakLabel,
                  style: AppTextStyles.text14w600(color: _isOnline ? colors.success : colors.warning),
                ),
                if (!_isOnline)
                  Text(
                    '${AppStrings.timeLeftLabel}: ${_formatTime(_breakSecondsRemaining)}',
                    style: AppTextStyles.text12w400(color: colors.warning),
                  ),
              ],
            ),
          ),
          if (!_isOnline)
            TextButton(
              onPressed: () => _toggleStatus(true),
              child: Text(AppStrings.endBreakBtn, style: TextStyle(color: colors.primary)),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, CaptainOrdersState state) {
    return Row(
      children: [
        _buildStatItem(context, AppStrings.todayOrders, '${state.todayOrdersCount}', Icons.shopping_bag_outlined, Colors.blue),
        15.horizontalSpace,
        _buildStatItem(context, AppStrings.todayEarnings, '${state.todayEarnings.toStringAsFixed(0)} ${AppStrings.currency}', Icons.account_balance_wallet_outlined, Colors.orange),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String title, String value, IconData icon, Color color) {
    final colors = AppColors(context);
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24.sp),
            10.verticalSpace,
            Text(title, style: AppTextStyles.text12w400(color: colors.textSecondary)),
            5.verticalSpace,
            Text(value, style: AppTextStyles.text16w700(color: colors.textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, WidgetRef ref) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.text16w700(color: colors.textPrimary)),
        TextButton(
          onPressed: () => ref.read(captainOrdersProvider.notifier).loadAll(),
          child: Text(AppStrings.refresh, style: TextStyle(color: colors.primary)),
        ),
      ],
    );
  }

  Widget _buildAvailableOrdersList(BuildContext context, List<OrderDto> orders) {
    if (orders.isEmpty) {
      final colors = AppColors(context);
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: Center(
          child: Text(
            'لا توجد طلبات متاحة حالياً',
            style: AppTextStyles.text14w600(color: colors.textHint),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderDto order) {
    final colors = AppColors(context);
    final storeName = order.creator?.name ?? 'متجر غير معروف';
    final storeAddress = order.creator?.address ?? 'عنوان غير متوفر';
    final earnings = order.deliveryFee;

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: colors.primary.withOpacity(0.1),
                child: Icon(
                  order.type == 0 ? Icons.restaurant : Icons.shopping_bag,
                  color: colors.primary,
                  size: 20.sp,
                ),
              ),
              15.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(storeName, style: AppTextStyles.text14w700(color: colors.textPrimary)),
                    Text(storeAddress, style: AppTextStyles.text12w400(color: colors.textSecondary)),
                  ],
                ),
              ),
              Text(
                '${earnings.toStringAsFixed(0)} ${AppStrings.currency}',
                style: AppTextStyles.text14w700(color: colors.primary),
              ),
            ],
          ),
          20.verticalSpace,
          Row(
            children: [
              Icon(Icons.location_on, color: colors.error, size: 18.sp),
              10.horizontalSpace,
              Expanded(
                child: Text(
                  'العنوان: ${order.address ?? 'عنوان الزبون غير متوفر'}',
                  style: AppTextStyles.text12w400(color: colors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              10.horizontalSpace,
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.captainOrderDetails,
                  arguments: order,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text(AppStrings.viewDetailsBtn, style: AppTextStyles.text12w600(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakMessage(BuildContext context) {
    final colors = AppColors(context);
    return Column(
      children: [
        40.verticalSpace,
        Icon(Icons.coffee_outlined, size: 80.sp, color: colors.warning),
        20.verticalSpace,
        Text(AppStrings.breakLabel, style: AppTextStyles.text14w600(color: colors.textSecondary)),
        Text(AppStrings.openOnlineToReceiveOrdersMsg, style: AppTextStyles.text12w400(color: colors.textHint)),
        30.verticalSpace,
        ElevatedButton(
          onPressed: () => _toggleStatus(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
          child: Text(AppStrings.endBreakBtn, style: AppTextStyles.text12w600(color: Colors.white)),
        ),
      ],
    );
  }
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final unreadCount =
        ref.watch(notificationsProvider.select((s) => s.unreadCount));

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
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surface,
                border: Border.all(
                  color: colors.border,
                  width: 1.2,
                ),
              ),
              child: Icon(
                Icons.notifications_rounded,
                color: colors.textPrimary,
                size: 20.sp,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: Container(
                    key: ValueKey(unreadCount),
                    constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.w),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: colors.surface, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(
                        fontSize: 8.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1,
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

