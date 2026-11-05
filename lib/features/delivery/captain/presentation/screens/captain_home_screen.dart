import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
 import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_dashboard_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_available_orders_section.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_order_card_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_break_dialog_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_break_message_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_pending_approval_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_rejected_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_speed_header_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_stats_grid_widget.dart';
import 'package:base_app/features/shared/notifications/presentation/riverpod/notifications_provider.dart';
import 'package:base_app/core/services/audio/order_sound_service.dart';

import '../../../../../core/services/cach_helper/cache_helper.dart';

class CaptainHomeScreen extends ConsumerStatefulWidget {
  const CaptainHomeScreen({super.key});

  @override
  ConsumerState<CaptainHomeScreen> createState() => _CaptainHomeScreenState();
}

class _CaptainHomeScreenState extends ConsumerState<CaptainHomeScreen>
    with WidgetsBindingObserver {
  ScrollController? _scrollController;
  ScrollController get _effectiveScrollController =>
      _scrollController ??= (ScrollController()..addListener(_onScroll));
  bool _isOnline = true;
  Timer? _breakTimer;
  int _breakSecondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    OrderSoundService.stopRingtone();
    _scrollController ??= ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);

    // Check if an active break was saved in cache
    final savedEndTime = CacheHelper.getInt('captain_break_end_time');
    if (savedEndTime != null) {
      final diffSeconds =
          (savedEndTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
      if (diffSeconds > 0) {
        _startBreakTimer(diffSeconds);
      } else {
        CacheHelper.remove('captain_break_end_time');
      }
    }

    // Load profile if not already loaded (avoid clearOld to prevent blank-out loops)
    final profile = ref.read(profileProvider);
    if (profile.user == null) {
      ref.read(profileProvider.notifier).loadProfile();
    } else {
      _isOnline = profile.user?.active ?? true;
    }
  }

  void _onScroll() {
    if (_scrollController == null || !_scrollController!.hasClients) return;
    final maxScroll = _scrollController!.position.maxScrollExtent;
    final currentScroll = _scrollController!.position.pixels;
    if (maxScroll - currentScroll <= 250) {
      ref.read(captainOrdersProvider.notifier).loadMoreAvailableOrders();
    }
  }

  Future<void> _toggleStatus(bool val) async {
    if (!val) {
      final minutes = await CaptainBreakDialogWidget.show(context);
      if (minutes == null) {
        return;
      }
      final endTimeMs =
          DateTime.now().millisecondsSinceEpoch + (minutes * 60 * 1000);
      await CacheHelper.setInt('captain_break_end_time', endTimeMs);
      setState(() {
        _breakSecondsRemaining = minutes * 60;
      });
      _startBreakTimer(minutes * 60);
    } else {
      await CacheHelper.remove('captain_break_end_time');
      _breakTimer?.cancel();
      _breakTimer = null;
      setState(() {
        _breakSecondsRemaining = 0;
      });
    }

    final success = await ref.read(profileProvider.notifier).toggleActivity();
    if (!success) {
      if (mounted) {
        CustomToast.error(context, AppStrings.activityStatusUpdateFailed);
      }
    }
  }

  void _startBreakTimer([int? initialSeconds]) {
    _breakTimer?.cancel();
    if (initialSeconds != null) {
      _breakSecondsRemaining = initialSeconds;
    } else {
      final savedEndTime = CacheHelper.getInt('captain_break_end_time');
      if (savedEndTime != null) {
        final diffSeconds =
            (savedEndTime - DateTime.now().millisecondsSinceEpoch) ~/ 1000;
        if (diffSeconds > 0) {
          _breakSecondsRemaining = diffSeconds;
        } else {
          _breakSecondsRemaining = 0;
          CacheHelper.remove('captain_break_end_time');
          return;
        }
      } else {
        return;
      }
    }

    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_breakSecondsRemaining > 0) {
        if (mounted) {
          setState(() {
            _breakSecondsRemaining--;
          });
        }
      } else {
        timer.cancel();
        _breakTimer = null;
        CacheHelper.remove('captain_break_end_time');
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      OrderSoundService.stopRingtone();
      ref.read(captainOrdersProvider.notifier).loadAll();
      ref.read(notificationsProvider.notifier).fetchUnreadCount();
    }
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_onScroll);
    _scrollController?.dispose();
    _scrollController = null;
    WidgetsBinding.instance.removeObserver(this);
    _breakTimer?.cancel();
    _breakTimer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final ordersState = ref.watch(captainOrdersProvider);

    // Sync online status safely from profile
    if (profileState.user != null) {
      _isOnline = profileState.user!.active ?? false;
    }

    ref.listen(profileProvider, (previous, next) {
      if (next.status == ProfileStatus.loaded && next.user != null) {
        final nextActive = next.user!.active ?? false;
        if (_isOnline != nextActive) {
          setState(() {
            _isOnline = nextActive;
            if (_isOnline) {
              _breakTimer?.cancel();
              _breakTimer = null;
              _breakSecondsRemaining = 0;
              CacheHelper.remove('captain_break_end_time');
            }
          });
        }
      }
    });

    if (profileState.status == ProfileStatus.loading && profileState.user == null) {
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: LoadingButton(color: colors.primary)),
      );
    }

    final userStatus = profileState.user?.status ?? 0;
    if (userStatus == 0) {
      return const CaptainPendingApprovalWidget();
    } else if (userStatus == 2) {
      return const CaptainRejectedWidget();
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.secondary,
        backgroundColor: colors.cardBackground,
        strokeWidth: 2.5,
        onRefresh: () async {
          ref.invalidate(captainDashboardProvider);
          await ref.read(captainOrdersProvider.notifier).loadAll(forceRefresh: true);
        },
        child: SingleChildScrollView(
          controller: _effectiveScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CaptainSpeedHeaderWidget(
                profileState: profileState,
                isOnline: _isOnline,
                breakSecondsRemaining: _breakSecondsRemaining,
                onToggleStatus: _toggleStatus,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CaptainStatsGridWidget(),
                    if (ordersState.activeOrders.isNotEmpty) ...[
                      24.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.activeOrdersTab,
                            style: AppTextStyles.text18w700(
                              color: colors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${ordersState.activeOrders.length}',
                              style: AppTextStyles.text12w700(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      14.verticalSpace,
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ordersState.activeOrders.length,
                        separatorBuilder: (context, index) => 14.verticalSpace,
                        itemBuilder: (context, index) {
                          return CaptainOrderCardWidget(
                            order: ordersState.activeOrders[index],
                            isActive: true,
                          );
                        },
                      ),
                    ],
                    24.verticalSpace,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          AppStrings.availableOrdersNow,
                          style: AppTextStyles.text18w700(color: colors.textPrimary),
                        ),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(captainOrdersProvider.notifier)
                              .loadAll(forceRefresh: true),
                          icon: Icon(
                            Icons.refresh_rounded,
                            size: 16.sp,
                            color: colors.primary,
                          ),
                          label: Text(
                            AppStrings.refresh,
                            style: AppTextStyles.text12w700(color: colors.primary),
                          ),
                        ),
                      ],
                    ),
                    14.verticalSpace,
                    if (_isOnline)
                      CaptainAvailableOrdersSection(ordersState: ordersState)
                    else
                      CaptainBreakMessageWidget(
                        onEndBreak: () => _toggleStatus(true),
                      ),
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
}
