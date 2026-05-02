import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'onboarding_action_button.dart';
import 'onboarding_page_indicator.dart';

class OnboardingBottomControls extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageController pageController;
  final VoidCallback onNext;
  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;

  const OnboardingBottomControls({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageController,
    required this.onNext,
    required this.fadeAnimation,
    required this.slideAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: 45.w),
              OnboardingPageIndicator(
                currentPage: currentPage,
                totalPages: totalPages,
                pageController: pageController,
              ),
              OnboardingActionButton(
                currentPage: currentPage,
                totalPages: totalPages,
                onNext: onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
