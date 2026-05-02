import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';

class CustomChooseCard extends StatelessWidget {
  final String txt, img;
  final VoidCallback onTap;

  const CustomChooseCard({
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
        height: 120.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors(context).border, width: 0.8),
          boxShadow: [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(img),
            10.verticalSpace,
            Text(txt, style: AppTextStyles.text16w700()),
          ],
        ),
      ),
    );
  }
}
