import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';

// الموديل
class IconBadgeModel {
  final String icon;
  final String label;
  final int count;
  final VoidCallback? onTap;

  const IconBadgeModel({
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });
}

// الويدجت
class CustomIconBadge extends StatelessWidget {
  final IconBadgeModel model;

  const CustomIconBadge({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: model.onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 110.w,
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors(context).cardBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors(context).divider, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors(context).primaryVariant,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomSVGImage(asset: model.icon, color: Colors.white),
              ),
            ),
            SizedBox(height: 6.h),

            Text(
              model.label,
              style: AppTextStyles.text10w500(),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            if (model.count > 0) ...[
              SizedBox(height: 2.h),
              Text(
                model.count > 99 ? '99+' : '+${model.count}',
                style: AppTextStyles.text10w500(
                  color: AppColors(context).textHint,
                ).copyWith(fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
