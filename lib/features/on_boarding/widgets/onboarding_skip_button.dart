import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

import '../../../core/localizations/app_strings.g.dart';

class OnboardingSkipButton extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const OnboardingSkipButton({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: TextButton(
            onPressed: currentPage == totalPages - 1 ? null : onSkip,
            child: Text(
              AppStrings.skip,
              style: AppTextStyles.text18w500(
                color: currentPage == totalPages - 1
                    ? AppColors(context).iconSecondary
                    : AppColors(context).primaryVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
