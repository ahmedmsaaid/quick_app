import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:base_app/core/styles/app_colors.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final PageController pageController;

  const OnboardingPageIndicator({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSmoothIndicator(
      activeIndex: currentPage,
      count: totalPages,
      effect: JumpingDotEffect(
        dotHeight: 12.h,
        dotWidth: 12.w,
        spacing: 15.w,
        activeDotColor: AppColors(context).primary,
        dotColor: AppColors(context).onBoardingIndicator,
        jumpScale: 1.5,
      ),
    );
  }
}
