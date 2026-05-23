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
    final colors = AppColors(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.w),
        width: 277.w,
        height: 120.h,
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
            ClipRRect(
              borderRadius: BorderRadius.circular(5.r),
              child: Image.asset(img, width: 45.w, height: 30.h, fit: BoxFit.cover),
            ),
            15.verticalSpace,
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
