import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/models/on_boarding_model.dart';
import 'on_boarding_page_widget.dart';

class OnboardingPageItem extends StatelessWidget {
  final int index;
  final double currentPageValue;
  final OnBoardingModel page;

  const OnboardingPageItem({
    super.key,
    required this.index,
    required this.currentPageValue,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    final difference = (currentPageValue - index).abs();

    final scale = (1 - difference * 0.06).clamp(0.92, 1.0);
    final opacity = (1 - difference * 0.35).clamp(0.55, 1.0);
    final translateY = (difference * 18.h).clamp(0.0, 18.h);

    return Transform.translate(
      offset: Offset(0, translateY),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
          opacity: opacity,
          child: OnboardingPageWidget(page: page),
        ),
      ),
    );
  }
}