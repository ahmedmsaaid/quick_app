import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

class OrderTrackingScreen extends StatelessWidget {
  const OrderTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background "Map" Placeholder
          Container(
            color: AppColors(context).containerBackground,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 100.sp, color: AppColors(context).textHint),
                  Text(AppStrings.orderTrackingMapPlaceholder, style: AppTextStyles.text14w400(color: AppColors(context).textHint)),
                ],
              ),
            ),
          ),
          
          // Custom Back Button
          Positioned(
            top: 50.h,
            right: 20.w,
            child: const CustomArrowBack(),
          ),

          // Tracking Info Bottom Sheet Style
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(25.r),
              decoration: BoxDecoration(
                color: AppColors(context).surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
                boxShadow: [BoxShadow(color: AppColors(context).shadow, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: AppColors(context).primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.delivery_dining, color: AppColors(context).primary, size: 30.sp),
                      ),
                      15.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.orderWillArriveMsg, style: AppTextStyles.text12w400(color: AppColors(context).textSecondary)),
                            Text('05:45 م (${AppStrings.within20MinutesMsg})', style: AppTextStyles.text16w700(color: AppColors(context).textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  25.verticalSpace,
                  _buildTrackingStep(context, AppStrings.orderReceivedStep, '05:15 م', true),
                  _buildTrackingStep(context, AppStrings.foodPreparingNowStep, '05:25 م', true),
                  _buildTrackingStep(context, AppStrings.driverOnWayStep, '05:35 م', true, isLast: true, isCurrent: true),
                  25.verticalSpace,
                  Divider(color: AppColors(context).divider),
                  25.verticalSpace,
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25.r,
                        backgroundImage: const AssetImage('assets/image/logo.png'),
                      ),
                      15.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppStrings.captainNameLabel, style: AppTextStyles.text14w700(color: AppColors(context).textPrimary)),
                            Text('${AppStrings.motorcycleLabel} - ${AppStrings.baghdadLabel} 1234', style: AppTextStyles.text14w400(color: AppColors(context).textSecondary)),
                          ],
                        ),
                      ),
                      _buildContactAction(context, Icons.phone, Colors.green, () {}),
                      10.horizontalSpace,
                      _buildContactAction(context, Icons.chat, AppColors(context).primary, () {
                         Navigator.of(context).pushNamed(AppRoutes.chatDetailsScreen, arguments: AppStrings.deliveryCaptain);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStep(BuildContext context, String title, String time, bool isCompleted, {bool isLast = false, bool isCurrent = false}) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              width: 12.w,
              height: 12.h,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.white : (isCompleted ? AppColors(context).primary : AppColors(context).textDisabled),
                shape: BoxShape.circle,
                border: isCurrent ? Border.all(color: AppColors(context).primary, width: 3) : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 30.h,
                color: isCompleted ? AppColors(context).primary : AppColors(context).divider,
              ),
          ],
        ),
        20.horizontalSpace,
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTextStyles.text14w500(
                  color: isCompleted ? AppColors(context).textPrimary : AppColors(context).textSecondary,
                ),
              ),
              Text(
                time,
                style: AppTextStyles.text14w400(color: AppColors(context).textHint),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactAction(BuildContext context, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
    );
  }
}
