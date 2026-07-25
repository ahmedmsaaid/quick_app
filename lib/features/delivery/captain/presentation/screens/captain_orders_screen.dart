import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:base_app/core/widgets/lading_button.dart';

class CaptainOrdersScreen extends ConsumerWidget {
  const CaptainOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final ordersState = ref.watch(captainMyOrdersProvider);
    if (ordersState.status == MyOrdersStatus.initial) {
      Future.microtask(() => ref.read(captainMyOrdersProvider.notifier).loadOrders());
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          title: Text(
            AppStrings.myTripsTitle,
            style: AppTextStyles.text18w700(color: colors.textPrimary),
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: colors.primary,
            unselectedLabelColor: colors.textHint,
            indicatorColor: colors.primary,
            indicatorWeight: 3.h,
            labelStyle: AppTextStyles.text14w700(color: colors.primary),
            unselectedLabelStyle: AppTextStyles.text14w600(color: colors.textHint),
            tabs: [
              Tab(text: AppStrings.activeOrdersTab),
              Tab(text: AppStrings.finishedOrdersTab),
            ],
          ),
        ),
        body: ordersState.status == MyOrdersStatus.loading && ordersState.activeOrders.isEmpty && ordersState.finishedOrders.isEmpty
            ? Center(child: LoadingButton(color: colors.primary))
            : TabBarView(
                children: [
                  _buildOrdersList(context, ordersState.activeOrders, true, ref),
                  _buildOrdersList(context, ordersState.finishedOrders, false, ref),
                ],
              ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<OrderDto> orders, bool isActive, WidgetRef ref) {
    if (orders.isEmpty) {
      final colors = AppColors(context);
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(captainMyOrdersProvider.notifier).loadOrders();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            height: 400.h,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 56.sp, color: colors.textHint.withValues(alpha: 0.5)),
                16.verticalSpace,
                Text(
                  isActive ? 'لا توجد مشاوير نشطة حالياً' : 'لم تقم بتوصيل أي طلبات بعد',
                  style: AppTextStyles.text14w600(color: colors.textHint),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(captainMyOrdersProvider.notifier).loadOrders();
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(20.w),
        itemCount: orders.length,
        separatorBuilder: (context, index) => 16.verticalSpace,
        itemBuilder: (context, index) {
          return _buildOrderCard(context, orders[index], isActive);
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, OrderDto order, bool isActive) {
    final colors = AppColors(context);
    final storeName = order.creator?.name ?? 'متجر غير معروف';
    final customerName = order.user?.name ?? 'زبون غير معروف';
    final earnings = order.deliveryFee;

    String statusLabelText = isActive ? AppStrings.onWayLabel : AppStrings.arrivedDoneLabel;
    if (isActive && (order.status == 2 || order.status == 5)) {
      statusLabelText = 'بانتظار الاستلام';
    }

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.captainOrderDetails, arguments: order);
      },
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.6),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    order.type == 0 ? Icons.restaurant_rounded : Icons.shopping_bag_rounded,
                    color: colors.primary,
                    size: 20.sp,
                  ),
                ),
                12.horizontalSpace,
                Expanded(
                  child: Text(
                    '${AppStrings.order} #${order.id}',
                    style: AppTextStyles.text15w700(color: colors.textPrimary),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isActive
                        ? colors.warning.withValues(alpha: 0.12)
                        : colors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    statusLabelText,
                    style: AppTextStyles.text11w700(
                      color: isActive ? colors.warning : colors.success,
                    ),
                  ),
                ),
              ],
            ),
            16.verticalSpace,
            _buildLocationRow(
              context,
              Icons.store_rounded,
              '${AppStrings.pickupFromLabel}: $storeName',
              colors.primary,
            ),
            10.verticalSpace,
            _buildLocationRow(
              context,
              Icons.location_on_rounded,
              '${AppStrings.deliverToLabel}: $customerName',
              colors.secondary,
            ),
            16.verticalSpace,
            Divider(color: colors.border.withValues(alpha: 0.5), height: 1),
            14.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.yourEarningsInThisOrder,
                  style: AppTextStyles.text12w600(color: colors.textSecondary),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${earnings.toStringAsFixed(0)} ${AppStrings.currency}',
                    style: AppTextStyles.text14w700(color: colors.primary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, IconData icon, String text, Color iconColor) {
    final colors = AppColors(context);
    return Row(
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        10.horizontalSpace,
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.text13w600(color: colors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
