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
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: isLastPage
          ? _StartButton(onNext: onNext)
          : _NextButton(onNext: onNext),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback onNext;

  const _StartButton({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return CustomAppButton(
      text: AppStrings.next,
      onPressed: onNext,
      width: 120.w,
      height: 48.h,
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback onNext;

  const _NextButton({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('next_button'),
      width: 45.w,
      height: 45.h,
      decoration: BoxDecoration(
        color: AppColors(context).primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors(context).primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onNext,
          borderRadius: BorderRadius.circular(50.r),
          child: Icon(
            Directionality.of(context) != TextDirection.rtl
                ? CupertinoIcons.arrow_right
                : CupertinoIcons.arrow_left,
            color: AppColors.white,
            size: 24.sp,
          ),
        ),
      ),
    );
  }
}
