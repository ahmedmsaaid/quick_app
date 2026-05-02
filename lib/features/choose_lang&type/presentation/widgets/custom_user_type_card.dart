import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';

class CustomUserTypeCard extends StatelessWidget {
  final String txt, img;
  final VoidCallback onTap;

  const CustomUserTypeCard({
    super.key,
    required this.txt,
    required this.img,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.w),
        width: 277.w,
        height: 153.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors(context).border, width: 0.8),
          boxShadow: [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 10.h),
              width: 60.w,
              height: 60.h,

              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors(context).secondary,
              ),
              child: Center(
                child: SvgPicture.asset(
                  img,
                  width: 24.w,
                  height: 24.h,
                  // colorFilter: ColorFilter.mode(
                  //   AppColors.black,
                  //   BlendMode.srcIn,
                  // ),
                ),
              ),
            ),
            5.verticalSpace,
            Text(txt, style: AppTextStyles.text16w700()),
          ],
        ),
      ),
    );
  }
}
