import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/pagination/screens/pagination_list_view.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/user_wallet_transactions_pagination_notifier.dart';
import 'package:base_app/features/customer/profile/presentation/widgets/wallet_transaction_tile_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_dashboard_provider.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/shared/finance/data/models/delivery_dashboard_model.dart';
import 'package:base_app/features/shared/finance/data/models/time_filter_type.dart';
import 'package:base_app/features/shared/finance/data/models/wallet_transaction_model.dart';

/// Modern Captain Wallet screen displaying remittance, earnings, daily orders,
/// and live transactions with reference numbers and details.
class CaptainWalletScreen extends ConsumerStatefulWidget {
  const CaptainWalletScreen({super.key});

  @override
  ConsumerState<CaptainWalletScreen> createState() =>
      _CaptainWalletScreenState();
}

class _CaptainWalletScreenState extends ConsumerState<CaptainWalletScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(userWalletTransactionsPaginationProvider.notifier).loadInitial();
    // });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    ref.invalidate(captainWalletDashboardProvider);
    ref.invalidate(captainWalletSummaryProvider);
    ref.invalidate(captainDashboardProvider);
    // await ref
    //     .read(userWalletTransactionsPaginationProvider.notifier)
    //     .loadInitial();
  }

  /// Modern Captain Remittance Hero Card
  /// Core Metric #1: الرصيد المطلوب توريده لكويك (Cash to Remit to Quick)
  Widget _buildRemittanceHeroCard(
    BuildContext context,
    DeliveryDashboardModel data,
  ) {
    final colors = AppColors(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1E1B4B),
            const Color(0xFF1E293B),
            colors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Decorative background glowing circles
            Positioned(
              top: -30.r,
              right: -30.r,
              child: Container(
                width: 140.r,
                height: 140.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Positioned(
              bottom: -40.r,
              left: -20.r,
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Card Body
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 22.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand & Verified Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Icon(
                              Icons.delivery_dining_rounded,
                              color: Colors.white,
                              size: 22.sp,
                            ),
                          ),
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'QUICK CAPTAIN',
                                    style: AppTextStyles.text11w500(
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                  if (data.deliveryId > 0) ...[
                                    6.horizontalSpace,
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 1.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        '#${data.deliveryId}',
                                        style: AppTextStyles.text10w700(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                data.deliveryName?.isNotEmpty == true
                                    ? data.deliveryName!
                                    : AppStrings.captainNameLabel,
                                style: AppTextStyles.text14w700(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: colors.success.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.r,
                              height: 7.r,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            6.horizontalSpace,
                            Text(
                              AppStrings.verifiedCaptainBadge,
                              style: AppTextStyles.text11w600(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  20.verticalSpace,

                  // 1. الرصيد المطلوب توريده لكويك (Cash Balance to Remit to Quick)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.payments_rounded,
                              color: const Color(0xFFFBBF24),
                              size: 18.sp,
                            ),
                            8.horizontalSpace,
                            Text(
                              AppStrings.totalCashToRemitTitle,
                              style: AppTextStyles.text13w600(
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                        8.verticalSpace,
                        Text(
                          '${data.totalCashToRemit.toStringAsFixed(2)} ${AppStrings.currency}',
                          style: AppTextStyles.text28w700(
                            color: const Color(0xFFFFD54F),
                          ),
                        ),
                        4.verticalSpace,
                        Text(
                          AppStrings.totalCashToRemitSubtitle,
                          style: AppTextStyles.text11w500(
                            color: Colors.white.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Modern Orders Count Card
  /// Core Metric #2: عدد الأوردرات (Orders Count)
  Widget _buildOrdersCountCard(
    BuildContext context,
    DeliveryDashboardModel data,
  ) {
    final colors = AppColors(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              color: colors.primary,
              size: 26.sp,
            ),
          ),
          14.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.completedOrdersCountLabel,
                  style: AppTextStyles.text13w600(
                    color: colors.textSecondary,
                  ),
                ),
                4.verticalSpace,
                Text(
                  AppStrings.completedOrdersCountSubtitle,
                  style: AppTextStyles.text11w500(
                    color: colors.textHint,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data.ordersCount}',
                style: AppTextStyles.text26w700(
                  color: colors.primary,
                ),
              ),
              Text(
                AppStrings.ordersUnitLabel,
                style: AppTextStyles.text11w600(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /*
  ==============================================================================
  PREVIOUS CAPTAIN HERO CARD & STAT TILE (COMMENTED OUT PER USER REQUEST)
  ==============================================================================
  Widget _buildCaptainHeroCard(
    BuildContext context,
    DeliveryDashboardModel data,
  ) {
    final colors = AppColors(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        gradient: LinearGradient(
          colors: [
            colors.primary,
            const Color(0xFF1E3A8A),
            const Color(0xFF0F172A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: Stack(
          children: [
            // Decorative background glowing circles
            Positioned(
              top: -30.r,
              right: -30.r,
              child: Container(
                width: 140.r,
                height: 140.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              bottom: -40.r,
              left: -20.r,
              child: Container(
                width: 150.r,
                height: 150.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),

            // Card Body
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand & Contactless
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(7.r),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.delivery_dining_rounded,
                              color: Colors.white,
                              size: 20.sp,
                            ),
                          ),
                          10.horizontalSpace,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'QUICK CAPTAIN',
                                    style: AppTextStyles.text11w500(
                                      color: Colors.white.withValues(alpha: 0.75),
                                    ),
                                  ),
                                  if (data.deliveryId > 0) ...[
                                    6.horizontalSpace,
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 6.w,
                                        vertical: 1.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6.r),
                                      ),
                                      child: Text(
                                        '#${data.deliveryId}',
                                        style: AppTextStyles.text10w700(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(
                                data.deliveryName?.isNotEmpty == true
                                    ? data.deliveryName!
                                    : AppStrings.captainNameLabel,
                                style: AppTextStyles.text14w700(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        Icons.contactless_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 26.sp,
                      ),
                    ],
                  ),
                  18.verticalSpace,

                  // Golden Chip Graphic
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 42.w,
                        height: 30.h,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFFFDF7A),
                              Color(0xFFD4AF37),
                              Color(0xFFA67C00),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(
                            color: const Color(0xFFFFE082),
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Container(
                            width: 28.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.black.withValues(alpha: 0.25),
                                width: 0.8,
                              ),
                              borderRadius: BorderRadius.circular(3.r),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: colors.success.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7.r,
                              height: 7.r,
                              decoration: const BoxDecoration(
                                color: Colors.greenAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            6.horizontalSpace,
                            Text(
                              'كابتن معتمد',
                              style: AppTextStyles.text11w600(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  16.verticalSpace,

                  // Current Wallet Balance
                  Text(
                    AppStrings.currentWalletBalanceLabel,
                    style: AppTextStyles.text12w500(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  4.verticalSpace,
                  Text(
                    '${data.currentWalletBalance.toStringAsFixed(2)} ${AppStrings.currency}',
                    style: AppTextStyles.text24w700(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          10.verticalSpace,
          Text(
            title,
            style: AppTextStyles.text12w500(color: colors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          4.verticalSpace,
          Text(
            value,
            style: AppTextStyles.text16w700(color: colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  ==============================================================================
  */

  Widget _buildTimeFilterBar(
    BuildContext context,
    DeliveryDashboardModel? data,
  ) {
    final colors = AppColors(context);
    final selectedFilter = ref.watch(captainWalletFilterProvider);
    final customRange = ref.watch(captainWalletCustomRangeProvider);

    final filters = [
      (TimeFilterType.today, AppStrings.filterToday),
      (TimeFilterType.thisWeek, AppStrings.filterThisWeek),
      (TimeFilterType.thisMonth, AppStrings.filterThisMonth),
      (TimeFilterType.custom, AppStrings.filterCustom),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: filters.map((item) {
              final isSelected = selectedFilter == item.$1;
              return Padding(
                padding: EdgeInsetsDirectional.only(end: 8.w),
                child: InkWell(
                  onTap: () async {
                    if (item.$1 == TimeFilterType.custom) {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2023),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDateRange: customRange ??
                            DateTimeRange(
                              start: DateTime.now().subtract(const Duration(days: 7)),
                              end: DateTime.now(),
                            ),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: colors.primary,
                                onPrimary: Colors.white,
                                surface: colors.surface,
                                onSurface: colors.textPrimary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        ref.read(captainWalletCustomRangeProvider.notifier).state = picked;
                        ref.read(captainWalletFilterProvider.notifier).state = TimeFilterType.custom;
                      }
                    } else {
                      ref.read(captainWalletFilterProvider.notifier).state = item.$1;
                    }
                  },
                  borderRadius: BorderRadius.circular(20.r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected ? colors.primary : colors.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary
                            : colors.border.withValues(alpha: 0.6),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: colors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.$1 == TimeFilterType.custom) ...[
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 15.sp,
                            color: isSelected ? Colors.white : colors.textSecondary,
                          ),
                          6.horizontalSpace,
                        ],
                        Text(
                          item.$2,
                          style: isSelected
                              ? AppTextStyles.text13w700(color: Colors.white)
                              : AppTextStyles.text13w600(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (data?.fromDate != null && data?.toDate != null) ...[
          8.verticalSpace,
          Row(
            children: [
              Icon(
                Icons.event_note_rounded,
                size: 14.sp,
                color: colors.textSecondary,
              ),
              6.horizontalSpace,
              Text(
                '${data!.fromDate!.toLocal().toString().split(' ')[0]}  —  ${data.toDate!.toLocal().toString().split(' ')[0]}',
                style: AppTextStyles.text11w500(color: colors.textSecondary),
              ),
            ],
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final dashboardAsync = ref.watch(captainWalletDashboardProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          AppStrings.myCaptainWalletTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Captain Hero Digital Card & Stats
              dashboardAsync.when(
                skipLoadingOnRefresh: true,
                loading: () => Container(
                  height: 210.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => InkWell(
                  onTap: () => ref.invalidate(captainWalletDashboardProvider),
                  child: Container(
                    height: 120.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: colors.border),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, color: colors.primary),
                          8.horizontalSpace,
                          Text(
                            '${AppStrings.serverError} - ${AppStrings.retry}',
                            style: AppTextStyles.text14w600(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                data: (data) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Interactive Time Filter Bar
                    _buildTimeFilterBar(context, data),
                    16.verticalSpace,

                    // 1. الرصيد المطلوب توريده لكويك (Cash to Remit to Quick)
                    _buildRemittanceHeroCard(context, data),
                    14.verticalSpace,

                    // 2. عدد الأوردرات (Orders Count)
                    _buildOrdersCountCard(context, data),
                    24.verticalSpace,

                    /*
                    ============================================================
                    THE FOLLOWING METRICS AND SECTIONS WERE COMMENTED OUT
                    PER USER REQUEST (Displaying only 2 numbers: Orders count and Cash to remit)
                    ============================================================

                    _buildCaptainHeroCard(context, data),
                    18.verticalSpace,

                    // Primary Highlight Row: The 2 Core Captain Wallet Numbers (Orders Count + Total Cash to Remit)
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            context,
                            title: AppStrings.deliveredOrdersCountLabel,
                            value: '${data.ordersCount}',
                            icon: Icons.check_circle_rounded,
                            color: colors.secondary,
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: _buildStatTile(
                            context,
                            title: 'المطلوب توريده (الكاش)',
                            value:
                                '${data.totalCashToRemit.toStringAsFixed(2)} ${AppStrings.currency}',
                            icon: Icons.request_page_rounded,
                            color: const Color(0xFFEF4444),
                          ),
                        ),
                      ],
                    ),
                    12.verticalSpace,
                    // Cash Orders Total & Settled Amount
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            context,
                            title: 'إجمالي أوردرات الكاش',
                            value:
                                '${data.cashOrdersTotal.toStringAsFixed(2)} ${AppStrings.currency}',
                            icon: Icons.local_atm_rounded,
                            color: const Color(0xFF10B981),
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: _buildStatTile(
                            context,
                            title: AppStrings.settledAmountLabel,
                            value:
                                '${data.settledAmount.toStringAsFixed(2)} ${AppStrings.currency}',
                            icon: Icons.account_balance_rounded,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                    12.verticalSpace,
                    // Net Earnings & Quick Commission
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatTile(
                            context,
                            title: AppStrings.captainNetEarnings,
                            value:
                                '${data.totalEarnings.toStringAsFixed(2)} ${AppStrings.currency}',
                            icon: Icons.payments_rounded,
                            color: colors.success,
                          ),
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: _buildStatTile(
                            context,
                            title: AppStrings.quickCommissionLabel,
                            value:
                                '${data.quickCommission.toStringAsFixed(2)} ${AppStrings.currency}',
                            icon: Icons.pie_chart_rounded,
                            color: const Color(0xFFF59E0B),
                          ),
                        ),
                      ],
                    ),
                    12.verticalSpace,

                    // Due Payout Banner with link to settlements
                    InkWell(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.mySettlements),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
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
                                    AppStrings.settlementDuePayout,
                                    style: AppTextStyles.text12w500(
                                      color: colors.textSecondary,
                                    ),
                                  ),
                                  2.verticalSpace,
                                  Text(
                                    '${data.duePayout.toStringAsFixed(2)} ${AppStrings.currency}',
                                    style: AppTextStyles.text16w700(
                                      color: colors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14.sp,
                              color: colors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                    ============================================================
                    */
                  ],
                ),
              ),
              /*
              22.verticalSpace,

              // 3. Transactions Section Header
              Row(
                children: [
                  Text(
                    AppStrings.lastOperationsLabel,
                    style: AppTextStyles.text16w700(color: colors.textPrimary),
                  ),
                ],
              ),
              12.verticalSpace,

              // 4. Live Paginated Transactions List
              PaginationListView<WalletTransactionModel>(
                provider: userWalletTransactionsPaginationProvider,
                controller: _scrollController,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                emptyWidget: Container(
                  padding: EdgeInsets.symmetric(vertical: 40.h),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 48.sp,
                        color: colors.textHint,
                      ),
                      12.verticalSpace,
                      Text(
                        AppStrings.walletEmptyTransactions,
                        style: AppTextStyles.text14w600(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                itemBuilder: (context, transaction, index) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: WalletTransactionTileWidget(transaction: transaction),
                ),
              ),
              20.verticalSpace,
              */
            ],
          ),
        ),
      ),
    );
  }
}
