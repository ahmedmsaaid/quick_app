import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class CaptainOrdersScreen extends StatelessWidget {
  const CaptainOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

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
            tabs: [
              Tab(text: AppStrings.activeOrdersTab),
              Tab(text: AppStrings.finishedOrdersTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrdersList(context, true),
            _buildOrdersList(context, false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, bool isActive) {
    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: isActive ? 1 : 5,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, isActive);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, bool isActive) {
    final colors = AppColors(context);
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.captainOrderDetails);
      },
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10)],
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Text('${AppStrings.order} #12345', style: AppTextStyles.text14w700(color: colors.textPrimary)),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: isActive ? colors.warning.withOpacity(0.1) : colors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isActive ? AppStrings.onWayLabel : AppStrings.arrivedDoneLabel,
                    style: AppTextStyles.text10w500(color: isActive ? colors.warning : colors.success),
                  ),
                ),
              ],
            ),
            20.verticalSpace,
            _buildLocationRow(context, Icons.store, '${AppStrings.pickupFromLabel}: ${AppStrings.quickBurgerRestaurant}'),
            10.verticalSpace,
            _buildLocationRow(context, Icons.location_on, '${AppStrings.deliverToLabel}: ${AppStrings.userNamePlaceholder}'),
            15.verticalSpace,
            Divider(color: colors.divider),
            15.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppStrings.yourEarningsInThisOrder, style: AppTextStyles.text12w400(color: colors.textSecondary)),
                Text('5,000 ${AppStrings.currency}', style: AppTextStyles.text14w700(color: colors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(BuildContext context, IconData icon, String text) {
    final colors = AppColors(context);
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: colors.textSecondary),
        10.horizontalSpace,
        Expanded(child: Text(text, style: AppTextStyles.text12w500(color: colors.textPrimary))),
      ],
    );
  }
}
