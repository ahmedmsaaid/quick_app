import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_dashboard_provider.dart';
import 'package:base_app/features/shared/finance/data/models/delivery_dashboard_model.dart';
import 'package:base_app/features/shared/finance/data/models/time_filter_type.dart';

/// Modern horizontal time filter bar for Captain Wallet metrics.
class CustomCaptainWalletFilterBarWidget extends ConsumerWidget {
  final DeliveryDashboardModel? data;

  const CustomCaptainWalletFilterBarWidget({
    super.key,
    this.data,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                '${data!.fromDate!.toLocal().toString().split(' ')[0]}  —  ${data!.toDate!.toLocal().toString().split(' ')[0]}',
                style: AppTextStyles.text11w500(color: colors.textSecondary),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
