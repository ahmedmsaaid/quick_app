import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/custom_button_return_login_screen.dart';
import '../widgets/custom_password_text_field.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({super.key, this.isUser = false});

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  40.verticalSpace,
                  Image.asset(AppIcons.styleIcon),
                  16.verticalSpace,
                  Text(
                    AppStrings.createNewPassword,
                    style: AppTextStyles.text20w500(
                      color: AppColors(context).textPrimary,
                    ),
                  ),
                  4.verticalSpace,
                  Text(
                    AppStrings.getExtraProtection,
                    style: AppTextStyles.text15w500(
                      color: AppColors(context).textPrimary,
                    ),
                  ),
                  30.verticalSpace,
                  CustomPasswordTextField(
                    hintText: AppStrings.enterNewPassword,
                  ),
                  15.verticalSpace,
                  CustomPasswordTextField(
                    hintText: AppStrings.enterPasswordAgain,
                  ),
                  48.verticalSpace,
                  CustomAppButton(
                    text: AppStrings.saveChanges,
                    onPressed: () {},
                  ),
                  15.verticalSpace,
                  CustomButtonReturnLoginScreen(isUser: isUser),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
