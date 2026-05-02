// lib/features/auth/presentation/widgets/add_service_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_button.dart';

import '../../../../../core/styles/app_colors.dart';

class AddServiceButton extends StatelessWidget {
  const AddServiceButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return CustomAppButton(
      width: 200.w,
      text: AppStrings.addAnotherService,
      textStyle: AppTextStyles.text13w700(),
      backgroundColor: AppColors(context).surface,
      onPressed: onPressed,
      icon: Icon(Icons.add, color: colors.primaryVariant, size: 20.w),
    );
  }
}
