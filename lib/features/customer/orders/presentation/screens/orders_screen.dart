import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

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
        body: TabBarView(
          children: [
            _buildOrdersList(context, isCurrent: true),
            _buildOrdersList(context, isCurrent: false),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, {required bool isCurrent}) {
    return ListView.separated(
      padding: EdgeInsets.all(20.w),
      itemCount: 3,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        return _buildOrderCard(context, isCurrent);
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, bool isCurrent) {
    final colors = AppColors(context);

    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  image: const DecorationImage(
                    image: AssetImage('assets/image/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              15.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.orderFromQuickBurgerMsg,
                      style: AppTextStyles.text14w600(color: colors.textPrimary),
                    ),
                    5.verticalSpace,
                    Text(
                      '${AppStrings.uniqueNumber}: #12345',
                      style: AppTextStyles.text12w400(color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: isCurrent 
                      ? colors.primary.withOpacity(0.1)
                      : colors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isCurrent ? AppStrings.driverOnWayStep : AppStrings.completed,
                  style: AppTextStyles.text10w500(
                    color: isCurrent ? colors.primary : colors.success,
                  ),
                ),
              ),
            ],
          ),
          15.verticalSpace,
          Divider(color: colors.divider),
          15.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.mockDate} • ${AppStrings.mockTime}',
                style: AppTextStyles.text12w400(color: colors.textSecondary),
              ),
              Text(
                '17,500 ${AppStrings.iqdCurrency}',
                style: AppTextStyles.text14w700(color: colors.primary),
              ),
            ],
          ),
          if (isCurrent) ...[
            15.verticalSpace,
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.orderDetailsScreen);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      AppStrings.trackOrderBtn,
                      style: AppTextStyles.text12w600(color: colors.primary),
                    ),
                  ),
                ),
                15.horizontalSpace,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                       Navigator.of(context).pushNamed(AppRoutes.chatDetailsScreen, arguments: AppStrings.technicalSupportTitle);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                    child: Text(
                      AppStrings.helpBtn,
                      style: AppTextStyles.text12w600(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            15.verticalSpace,
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.sendReview);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colors.primary),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text(AppStrings.rateOrderTitle, style: AppTextStyles.text12w600(color: colors.primary)),
                    ),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.cartScreen);
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                      label: Text(
                        AppStrings.reBooking,
                        style: AppTextStyles.text12w600(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
