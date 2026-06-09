import 'package:flutter/material.dart';
import 'package:base_app/core/utils/extensions.dart';

import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class CustomButtonReturnLoginScreen extends StatelessWidget {
  const CustomButtonReturnLoginScreen({super.key, this.isUser = false});

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.pushNamedAndRemoveUntil(
          AppRoutes.loginScreen,
          arguments: isUser,
        );
      },
      child: Text(
        AppStrings.backToLogin,
        style: AppTextStyles.text16w500(color: AppColors(context).textPrimary),
      ),
    );
  }
}
