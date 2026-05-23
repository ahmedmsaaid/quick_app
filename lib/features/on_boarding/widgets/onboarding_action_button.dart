import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';

import '../../../core/localizations/app_strings.g.dart';
import '../../../core/widgets/custom_button.dart';

class OnboardingActionButton extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;

  const OnboardingActionButton({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutBack,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isLastPage
          ? _StartButton(
        key: const ValueKey('start_button'),
        onNext: onNext,
      )
          : _NextButton(
        key: const ValueKey('next_button'),
        onNext: onNext,
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onNext;

  const _StartButton({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppButton(backgroundColor: AppColors(context).secondary,
      text: AppStrings.next,
      onPressed: onNext,
      width: 130.w,
      height: 48.h,
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onNext;

  const _NextButton({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(
        color: colors.secondary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onNext,
          customBorder: const CircleBorder(),
          child: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? CupertinoIcons.arrow_left
                : CupertinoIcons.arrow_right,
            color: AppColors.white,
            size: 22.sp,
          ),
        ),
      ),
    );
  }
}