import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

import '../data/models/on_boarding_model.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnBoardingModel page;

  const OnboardingPageWidget({
    super.key,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          const Spacer(),

          SizedBox(
            height: 390.h,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 30.h,
                  child: Container(
                    width: 285.w,
                    height: 285.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                ),

                PositionedDirectional(
                  top: 65.h,
                  end: 25.w,
                  child: Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.secondary.withValues(alpha: 0.12),
                    ),
                  ),
                ),

                PositionedDirectional(
                  bottom: 70.h,
                  start: 28.w,
                  child: Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  child: SizedBox(
                    width: 340.w,
                    height: 310.h,
                    child: Image.asset(
                      page.mainImage,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),


              ],
            ),
          ),

          24.verticalSpace,

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: _buildColoredText(page.title, context),
              ),
            ),
          ),

          10.verticalSpace,

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              page.description,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.text16w500(
                color: colors.textSecondary,
                height: 1.5,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  List<TextSpan> _buildColoredText(String text, BuildContext context) {
    final colors = AppColors(context);
    final words = text.trim().split(RegExp(r'\s+'));

    return words.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value;
      final isHighlighted = index == 0 || index == words.length - 1;

      return TextSpan(
        text: word + (index < words.length - 1 ? ' ' : ''),
        style: isHighlighted
            ? AppTextStyles.text24w700(color: colors.primary)
            : AppTextStyles.text24w700(color: colors.textPrimary),
      );
    }).toList();
  }
}