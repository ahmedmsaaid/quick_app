import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';

import '../extintions/navigation_extension.dart';

class CustomArrowBack extends StatelessWidget {
  const CustomArrowBack({
    super.key,
    this.onTap,
    this.color,
    this.isCircular = false,
  });

  final VoidCallback? onTap;
  final Color? color;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap ?? () => context.pop(),
        child: Container(
          height: 35.h,
          width: 35.w,
          margin: EdgeInsets.all(8.r),
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color ?? AppColors(context).primaryVariant.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isCircular ? 60.r : 10.r),
          ),
          child: CustomSVGImage(
            matchTextDirection: true, // هذي الخاصية تقلب السهم تلقائياً حسب اتجاه اللغة
            asset: AppIcons.arrowIcon,
            color: AppColors(context).primaryVariant,
          ),
        ),
      ),
    );
  }
}
