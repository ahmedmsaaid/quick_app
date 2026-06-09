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
    final colors = AppColors(context);

    return AnimatedSmoothIndicator(
      activeIndex: currentPage,
      count: totalPages,
      effect: ExpandingDotsEffect(
        dotHeight: 8.h,
        dotWidth: 8.w,
        spacing: 7.w,
        expansionFactor: 3.2,
        activeDotColor: colors.primary,
        dotColor: colors.onBoardingIndicator,
      ),
    );
  }
}