import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.notifications,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: 5,
        separatorBuilder: (context, index) => 10.verticalSpace,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              color: AppColors(context).surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors(context).border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors(context).primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    index % 2 == 0 ? Icons.local_offer : Icons.delivery_dining,
                    color: AppColors(context).primary,
                    size: 20.sp,
                  ),
                ),
                15.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index % 2 == 0 ? AppStrings.greatOfferAvailableMsg : AppStrings.orderOnWayMsg,
                        style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
                      ),
                      5.verticalSpace,
                      Text(
                        AppStrings.discount20BurgerMsg,
                        style: AppTextStyles.text12w400(color: AppColors(context).textSecondary),
                      ),
                      10.verticalSpace,
                      Text(
                        AppStrings.fiveMinutesAgoMsg,
                        style: AppTextStyles.text10w400(color: AppColors(context).textHint),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
