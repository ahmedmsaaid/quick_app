import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final colors = AppColors(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.w),
        width: 277.w,
        height: 153.h,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: colors.shadow,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                color: colors.primary.withOpacity(0.1),
              ),
              child: Center(
                child: Image.asset(
                  img,
                  width: 35.w,
                  height: 35.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            5.verticalSpace,
            Text(
              txt, 
              style: AppTextStyles.text16w700(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
