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
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return GestureDetector(
      onTap: onTap ?? () => context.pop(),
      child: Container(
        height: isCircular ? 40.h : 30.h,
        width: isCircular ? 40.w : 30.w,
        padding: EdgeInsets.symmetric(
          horizontal: isCircular ? 2.w : 7.w,
          vertical: isCircular ? 2.h : 7.h,
        ),
        decoration: BoxDecoration(
          color: color ?? AppColors(context).primaryVariant.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isCircular ? 60.r : 10.r),
        ),
        child: Transform(
          alignment: Alignment.center,
          transform:
              isRtl
                    ? Matrix4.identity() // في RTL خليه زي ما هو (سهم لليسار)
                    : Matrix4.identity()
                ..scale(-1.0, 1.0, 1.0), // في LTR اقلبه
          child: CustomSVGImage(
            matchTextDirection: true,
            asset: AppIcons.arrowIcon,
            color: AppColors(context).primaryVariant,
            height: isCircular ? 22.sp : 18.sp,
            width: isCircular ? 22.sp : 18.sp,
          ),
        ),
      ),
    );
  }
}
