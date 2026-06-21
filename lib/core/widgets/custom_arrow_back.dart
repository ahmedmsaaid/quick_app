import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';

import 'package:base_app/core/extintions/navigation_extension.dart';

class CustomArrowBack extends StatelessWidget {
  const CustomArrowBack({
    super.key,
    this.onTap,
    this.color,
    this.iconColor,
    this.isCircular = false,
    this.margin,
    this.padding,
  });

  final VoidCallback? onTap;
  final Color? color;
  final Color? iconColor;
  final bool isCircular;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap ?? () => context.pop(),
        child: Container(
          height: 35.h,
          width: 35.w,
          margin: margin ?? EdgeInsets.all(8.r),
          padding: padding ?? EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: color ?? AppColors(context).primaryVariant.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(isCircular ? 60.r : 10.r),
          ),
          child: CustomSVGImage(
            matchTextDirection: true, // هذي الخاصية تقلب السهم تلقائياً حسب اتجاه اللغة
            asset: AppIcons.arrowIcon,
            color: iconColor ?? AppColors(context).primaryVariant,
          ),
        ),
      ),
    );
  }
}
