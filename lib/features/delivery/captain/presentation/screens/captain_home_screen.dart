import 'dart:async';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
      ref.read(profileProvider.notifier).loadProfile(clearOld: true);
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

    if (profileState.status == ProfileStatus.loading ||
        profileState.status == ProfileStatus.initial) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(
          child: LoadingButton(color: colors.primary),
        ),
      );
    }

    final userStatus = profileState.user?.status ?? 0;
    if (userStatus == 0) {
      return _buildPendingApprovalScreen(colors);
    } else if (userStatus == 2) {
      return _buildRejectedScreen(colors);
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.secondary,
        backgroundColor: colors.cardBackground,
        strokeWidth: 2.5,
        onRefresh: () async {
          await ref.read(captainOrdersProvider.notifier).loadAll();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpeedHeader(context, profileState),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatsGrid(context, ordersState),
                    24.verticalSpace,
                    _buildSectionHeader(context, AppStrings.availableOrdersNow, ref),
                    14.verticalSpace,
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
                    40.verticalSpace,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpeedHeader(BuildContext context, ProfileState profileState) {
    final colors = AppColors(context);
    final user = profileState.user;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.primary,
            colors.primary.withValues(alpha: 0.92),
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        border: Border(
          bottom: BorderSide(
            color: colors.secondary, // Bright orange speed trail bottom line
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
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                        4.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: _isOnline ? colors.success : colors.warning,
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
                                  color: _isOnline ? colors.success : colors.warning,
                                ),
                              ),
                              4.horizontalSpace,
                              Text(
                                _isOnline
                                    ? AppStrings.onlineNowStatus
                                    : AppStrings.breakLabel.split(' ')[0],
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Center Logo
                    Image.asset(
                      'assets/image/quick_panner.png',
                      height: 52.h,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox.shrink(),
                    ),

                    // Right: Notification Bell + Profile Avatar
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _NotificationBell(),
                        10.horizontalSpace,
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.profileScreen),
                          child: Container(
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
                            child: ClipOval(
                              child: (user?.photo != null &&
                                      user!.photo!.isNotEmpty)
                                  ? CachedNetworkImage(
                                      imageUrl: user.photo!.startsWith('http')
                                          ? user.photo!
                                          : '${ApiConstants.streamUrl}${user.photo}',
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                          color: colors.shimmerBase),
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
                14.verticalSpace,

                // Status Card nested inside the header
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: (_isOnline ? colors.success : colors.warning).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isOnline ? Icons.check_circle_rounded : Icons.timer_outlined,
                          color: _isOnline ? colors.success : colors.warning,
                          size: 22.sp,
                        ),
                      ),
                      12.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isOnline ? AppStrings.onlineReadyToWorkMsg : AppStrings.breakLabel,
                              style: AppTextStyles.text13w700(
                                color: _isOnline ? colors.success : colors.warning,
                              ),
                            ),
                            if (!_isOnline) ...[
                              2.verticalSpace,
                              Text(
                                '${AppStrings.timeLeftLabel}: ${_formatTime(_breakSecondsRemaining)}',
                                style: AppTextStyles.text11w600(color: colors.warning),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!_isOnline)
                        ElevatedButton(
                          onPressed: () => _toggleStatus(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                          ),
                          child: Text(AppStrings.endBreakBtn, style: AppTextStyles.text11w700(color: Colors.white)),
                        )
                      else
                        Switch(
                          value: _isOnline,
                          onChanged: _toggleStatus,
                          activeThumbColor: colors.success,
                          inactiveThumbColor: colors.warning,
                          inactiveTrackColor: colors.warning.withValues(alpha: 0.3),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context, CaptainOrdersState state) {
    final colors = AppColors(context);
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            title: AppStrings.todayOrders,
            value: '${state.todayOrdersCount}',
            icon: Icons.shopping_bag_rounded,
            iconColor: colors.primary,
            bgColor: colors.primary.withValues(alpha: 0.08),
          ),
        ),
        16.horizontalSpace,
        Expanded(
          child: _buildStatCard(
            context,
            title: AppStrings.todayEarnings,
            value: '${state.todayEarnings.toStringAsFixed(0)} ${AppStrings.currency}',
            icon: Icons.account_balance_wallet_rounded,
            iconColor: colors.secondary,
            bgColor: colors.secondary.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22.sp),
          ),
          12.verticalSpace,
          Text(
            title,
            style: AppTextStyles.text12w600(color: colors.textSecondary),
          ),
          4.verticalSpace,
          Text(
            value,
            style: AppTextStyles.text16w700(color: colors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, WidgetRef ref) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.text18w700(color: colors.textPrimary)),
        TextButton.icon(
          onPressed: () => ref.read(captainOrdersProvider.notifier).loadAll(),
          icon: Icon(Icons.refresh_rounded, size: 16.sp, color: colors.primary),
          label: Text(AppStrings.refresh, style: AppTextStyles.text12w700(color: colors.primary)),
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
          child: Column(
            children: [
              Icon(Icons.inbox_rounded, size: 48.sp, color: colors.textHint.withValues(alpha: 0.5)),
              12.verticalSpace,
              Text(
                'لا توجد طلبات متاحة حالياً',
                style: AppTextStyles.text14w600(color: colors.textHint),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      separatorBuilder: (context, index) => 16.verticalSpace,
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
                  order.type == 0 ? Icons.restaurant_rounded : Icons.shopping_bag_rounded,
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
                      storeName,
                      style: AppTextStyles.text15w700(color: colors.textPrimary),
                    ),
                    2.verticalSpace,
                    Text(
                      storeAddress,
                      style: AppTextStyles.text12w500(color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
              Icon(Icons.location_on_rounded, color: colors.secondary, size: 20.sp),
              8.horizontalSpace,
              Expanded(
                child: Text(
                  '${AppStrings.deliverToLabel}: ${order.address ?? 'عنوان الزبون غير متوفر'}',
                  style: AppTextStyles.text12w600(color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              12.horizontalSpace,
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.captainOrderDetails,
                  arguments: order,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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

  Widget _buildBreakMessage(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.coffee_rounded, size: 64.sp, color: colors.warning),
          16.verticalSpace,
          Text(AppStrings.breakLabel, style: AppTextStyles.text16w700(color: colors.textPrimary)),
          6.verticalSpace,
          Text(AppStrings.openOnlineToReceiveOrdersMsg, style: AppTextStyles.text13w600(color: colors.textSecondary), textAlign: TextAlign.center),
          24.verticalSpace,
          ElevatedButton(
            onPressed: () => _toggleStatus(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text(AppStrings.endBreakBtn, style: AppTextStyles.text13w700(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
                Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.warning.withValues(alpha: 0.3),
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
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: colors.warning.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: colors.warning.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: colors.warning.withValues(alpha: 0.15),
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
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (mounted) {
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
}

class _NotificationBell extends ConsumerWidget {
  const _NotificationBell();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(9.r),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      style: TextStyle(
                        fontSize: 9.sp,
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
