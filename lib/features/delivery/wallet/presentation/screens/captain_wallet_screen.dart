import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_dashboard_provider.dart';
import 'package:base_app/features/delivery/wallet/presentation/widgets/custom_captain_orders_count_card_widget.dart';
import 'package:base_app/features/delivery/wallet/presentation/widgets/custom_captain_remittance_card_widget.dart';
import 'package:base_app/features/delivery/wallet/presentation/widgets/custom_captain_wallet_filter_bar_widget.dart';

/// Modern Captain Wallet screen displaying the two core financial metrics:
/// 1. Cash to Remit to Quick (الرصيد المطلوب توريده لكويك)
/// 2. Total Completed Orders (عدد الأوردرات المكتملة)
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
              dashboardAsync.when(
                skipLoadingOnRefresh: true,
                loading: () => Container(
                  height: 200.h,
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
                    // 1. Interactive Time Filter Bar
                    CustomCaptainWalletFilterBarWidget(data: data),
                    16.verticalSpace,

                    // 2. الرصيد المطلوب توريده لكويك (Cash to Remit to Quick)
                    CustomCaptainRemittanceCardWidget(data: data),
                    14.verticalSpace,

                    // 3. عدد الأوردرات (Orders Count)
                    CustomCaptainOrdersCountCardWidget(data: data),
                    24.verticalSpace,
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
