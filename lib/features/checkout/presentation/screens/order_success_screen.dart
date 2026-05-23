import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/widgets/custom_button.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check_circle, color: colors.primary, size: 100.sp),
            ),
            30.verticalSpace,
            Text(
              AppStrings.orderArrivedHeroMsg,
              style: AppTextStyles.text20w700(color: colors.textPrimary),
            ),
            10.verticalSpace,
            Text(
              AppStrings.orderReviewMsg,
              textAlign: TextAlign.center,
              style: AppTextStyles.text14w400(color: colors.textSecondary),
            ),
            40.verticalSpace,
            CustomAppButton(
              text: AppStrings.trackOrderNowBtn,
              onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.orderDetailsScreen),
            ),
            15.verticalSpace,
            TextButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.userNav, (route) => false),
              child: Text(AppStrings.backToHomeBtn, style: AppTextStyles.text14w600(color: colors.textHint)),
            ),
          ],
        ),
      ),
    );
  }
}
