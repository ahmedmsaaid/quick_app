import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class CustomPasswordGuidelinesWidget extends StatefulWidget {
  final TextEditingController? controller;
  final String? password;

  const CustomPasswordGuidelinesWidget({
    super.key,
    this.controller,
    this.password,
  });

  @override
  State<CustomPasswordGuidelinesWidget> createState() =>
      _CustomPasswordGuidelinesWidgetState();
}

class _CustomPasswordGuidelinesWidgetState
    extends State<CustomPasswordGuidelinesWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onPasswordChanged);
  }

  @override
  void didUpdateWidget(covariant CustomPasswordGuidelinesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onPasswordChanged);
      widget.controller?.addListener(_onPasswordChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onPasswordChanged);
    super.dispose();
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final text = widget.controller?.text ?? widget.password ?? '';

    final hasMinLength = text.length >= 6;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(text);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(text);
    final hasDigits = RegExp(r'[0-9]').hasMatch(text);

    return Container(
      margin: EdgeInsets.only(top: 8.h, bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colors.containerBackground,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colors.border.withValues(alpha: 0.6),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                size: 16.sp,
                color: colors.primary,
              ),
              6.horizontalSpace,
              Text(
                AppStrings.passwordGuidelinesTitle,
                style: AppTextStyles.text12w600(color: colors.textPrimary),
              ),
            ],
          ),
          8.verticalSpace,
          _buildRequirementRow(
            colors: colors,
            isMet: hasMinLength,
            label: AppStrings.min6Characters,
          ),
          4.verticalSpace,
          _buildRequirementRow(
            colors: colors,
            isMet: hasUppercase,
            label: AppStrings.passwordNeedUppercase,
          ),
          4.verticalSpace,
          _buildRequirementRow(
            colors: colors,
            isMet: hasLowercase,
            label: AppStrings.passwordNeedLowercase,
          ),
          4.verticalSpace,
          _buildRequirementRow(
            colors: colors,
            isMet: hasDigits,
            label: AppStrings.passwordNeedNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementRow({
    required AppColors colors,
    required bool isMet,
    required String label,
  }) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 15.sp,
            color: isMet ? Colors.green : colors.textHint.withValues(alpha: 0.7),
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTextStyles.text11w400(
              color: isMet ? Colors.green : colors.textSecondary,
            ),
            child: Text(label),
          ),
        ),
      ],
    );
  }
}
