import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/shared/finance/data/dashboard_api_service.dart';
import 'package:base_app/features/shared/finance/data/models/delivery_dashboard_model.dart';
import 'package:base_app/features/shared/finance/data/models/time_filter_type.dart';

part 'captain_dashboard_provider.g.dart';

/// Filter selection for Captain Wallet dashboard
final captainWalletFilterProvider =
    StateProvider.autoDispose<TimeFilterType>((ref) => TimeFilterType.today);

/// Custom date range when [TimeFilterType.custom] is chosen
final captainWalletCustomRangeProvider =
    StateProvider.autoDispose<DateTimeRange?>((ref) => null);

/// Focused Captain Wallet Summary (`GET wallets/delivery/summary`)
final captainWalletSummaryProvider =
    FutureProvider.autoDispose<DeliveryDashboardModel>((ref) async {
  final result = await ref
      .watch(dashboardApiServiceProvider)
      .getDeliveryWalletSummary();

  return result.when(
    success: (response) {
      final data = response.result;
      if (response.success && data != null) return data;
      throw Exception(response.message);
    },
    failure: (error) => throw Exception(error.message),
  );
});

/// Filtered dashboard stats for Captain Wallet.
/// For [TimeFilterType.today], sends the device's local day bounds as [TimeFilterType.custom]
/// so orders delivered around midnight or across server timezones are included in "Today".
final captainWalletDashboardProvider =
    FutureProvider.autoDispose<DeliveryDashboardModel>((ref) async {
  final filter = ref.watch(captainWalletFilterProvider);
  final customRange = ref.watch(captainWalletCustomRangeProvider);

  final now = DateTime.now();
  final TimeFilterType effectiveFilter =
      filter == TimeFilterType.today ? TimeFilterType.custom : filter;
  final DateTime? fromDate = filter == TimeFilterType.today
      ? DateTime(now.year, now.month, now.day)
      : (filter == TimeFilterType.custom ? customRange?.start : null);
  final DateTime? toDate = filter == TimeFilterType.today
      ? DateTime(now.year, now.month, now.day, 23, 59, 59, 999)
      : (filter == TimeFilterType.custom
          ? (customRange != null
              ? DateTime(
                  customRange.end.year,
                  customRange.end.month,
                  customRange.end.day,
                  23,
                  59,
                  59,
                  999,
                )
              : null)
          : null);

  final result = await ref
      .watch(dashboardApiServiceProvider)
      .getDeliveryDashboard(
        filterType: effectiveFilter,
        fromDate: fromDate,
        toDate: toDate,
      );

  return result.when(
    success: (response) {
      final data = response.result;
      if (response.success && data != null) return data;
      throw Exception(response.message);
    },
    failure: (error) => throw Exception(error.message),
  );
});

/// Today's captain stats using the device's local day bounds.
/// Errors are surfaced through [AsyncError]; refresh with `ref.invalidate(captainDashboardProvider)`.
@riverpod
Future<DeliveryDashboardModel> captainDashboard(Ref ref) async {
  final now = DateTime.now();
  final result = await ref
      .watch(dashboardApiServiceProvider)
      .getDeliveryDashboard(
        filterType: TimeFilterType.custom,
        fromDate: DateTime(now.year, now.month, now.day),
        toDate: DateTime(now.year, now.month, now.day, 23, 59, 59, 999),
      );

  return result.when(
    success: (response) {
      final data = response.result;
      if (response.success && data != null) return data;
      throw Exception(response.message);
    },
    failure: (error) => throw Exception(error.message),
  );
}
