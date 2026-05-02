import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

import '../../../core/exports/exports.dart';
import '../data/models/on_boarding_model.dart';

class OnboardingPageWidget extends StatelessWidget {
  final OnBoardingModel page;

  const OnboardingPageWidget({super.key, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: [
          const Spacer(),

          SizedBox(
            height: 400.h,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 20.h,
                  child: Container(
                    width: 300.w,
                    height: 300.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors(
                        context,
                      ).primaryVariant.withValues(alpha: 0.05),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  child: SizedBox(
                    width: 400.w,
                    height: 350.h,
                    child: Image.asset(page.mainImage, fit: BoxFit.contain),
                  ),
                ),

                Positioned(
                  bottom: 10.h,
                  left: 20.w,
                  right: 20.w,
                  child: Image.asset(page.smallImage, fit: BoxFit.cover),
                ),
              ],
            ),
          ),

          20.verticalSpace,

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTextStyles.text24w500(),
                children: _buildColoredText(page.title, context),
              ),
            ),
          ),

          6.verticalSpace,

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              page.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.text16w500(
                color: AppColors(context).textPrimary,
              ),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }

  List<TextSpan> _buildColoredText(String text, BuildContext context) {
    final words = text.split(' ');
    return words.asMap().entries.map((entry) {
      final index = entry.key;
      final word = entry.value;

      return TextSpan(
        text: word + (index < words.length - 1 ? ' ' : ''),
        style: index % 2 == 0
            ? AppTextStyles.text24w700(color: AppColors(context).primaryVariant)
            : AppTextStyles.text24w500(color: AppColors(context).textPrimary),
      );
    }).toList();
  }
}
