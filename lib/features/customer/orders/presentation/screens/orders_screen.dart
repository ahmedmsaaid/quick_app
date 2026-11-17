import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/customer/orders/presentation/riverpod/orders_provider.dart';
import 'package:base_app/features/customer/main_nav/presentation/riverpod/user_nav_provider.dart';
import 'package:base_app/features/customer/orders/presentation/widgets/orders_list_view_widget.dart';

class OrdersScreen extends ConsumerWidget {
  final int? initialTabIndex;
  const OrdersScreen({super.key, this.initialTabIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final ordersState = ref.watch(ordersProvider);
    final initialTabFromProvider = ref.watch(ordersInitialTabProvider);
    final activeTab = (initialTabIndex ?? initialTabFromProvider).clamp(0, 1);

    return DefaultTabController(
      key: ValueKey('orders_tab_$activeTab'),
      length: 2,
      initialIndex: activeTab,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          leading: Navigator.canPop(context) ? const CustomArrowBack() : null,
          title: Text(
            AppStrings.myBookings,
            style: AppTextStyles.text18w700(color: colors.textPrimary),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.textHint,
            indicatorColor: colors.primary,
            labelStyle: AppTextStyles.text14w600(),
            tabs: [
              Tab(text: AppStrings.currentOrders),
              Tab(text: AppStrings.completed),
            ],
          ),
        ),
        body: _buildBody(context, ref, ordersState),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, OrdersState state) {
    final colors = AppColors(context);

    if (state.status == OrdersStatus.loading && state.orders.isEmpty) {
      return const Center(child: LoadingButton());
    }

    if (state.status == OrdersStatus.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48.sp, color: colors.error),
              15.verticalSpace,
              Text(
                state.errorMessage ?? AppStrings.serverError,
                style: AppTextStyles.text14w500(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              20.verticalSpace,
              ElevatedButton(
                onPressed: () {
                  ref.read(ordersProvider.notifier).loadOrders(forceRefresh: true);
                },
                style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
                child: Text(
                  AppStrings.retry,
                  style: AppTextStyles.text14w600(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final allOrders = state.orders;
    final currentOrders = allOrders.where((o) => o.status < 7).toList();
    final pastOrders = allOrders.where((o) => o.status >= 7).toList();

    return TabBarView(
      children: [
        OrdersListViewWidget(orders: currentOrders, isCurrent: true),
        OrdersListViewWidget(orders: pastOrders, isCurrent: false),
      ],
    );
  }
}
