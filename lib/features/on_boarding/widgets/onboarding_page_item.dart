import 'dart:ui';
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
    final isCurrentPage = index == currentPageValue.floor();
    final isNextPage = index == currentPageValue.floor() + 1;
    final isPreviousPage = index == currentPageValue.floor() - 1;

    double scale = 1.0;
    double opacity = 1.0;
    double rotationY = 0.0;
    double translateX = 0.0;
    double translateZ = 0.0;
    double blur = 0.0;

    if (isCurrentPage) {
      final progress = currentPageValue - index;
      scale = 1.0 - (progress * 0.15);
      opacity = 1.0 - (progress * 0.25);
      rotationY = -progress * 0.4;
      translateX = -progress * 35.w;
      translateZ = -progress * 70;
      blur = progress * 3;
    } else if (isNextPage) {
      final progress = currentPageValue - index + 1;
      scale = 0.75 + (progress * 0.25);
      opacity = 0.5 + (progress * 0.5);
      rotationY = -(1 - progress) * 0.4;
      translateX = (1 - progress) * 35.w;
      translateZ = -(1 - progress) * 70;
      blur = (1 - progress) * 3;
    } else if (isPreviousPage) {
      scale = 0.75;
      opacity = 0.3;
      translateX = -35.w;
      translateZ = -70;
      blur = 3;
    } else {
      scale = 0.75;
      opacity = 0.2;
      translateZ = -100;
      blur = 4;
    }

    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001)
      ..translate(translateX, 0.0, translateZ)
      ..rotateY(rotationY)
      ..scale(scale);

    return Transform(
      transform: matrix,
      alignment: Alignment.center,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(
          sigmaX: blur,
          sigmaY: blur,
          tileMode: TileMode.decal,
        ),
        child: Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: OnboardingPageWidget(page: page),
        ),
      ),
    );
  }
}
