import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/custom_button_return_login_screen.dart';
import '../widgets/custom_phone_text_field.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key, this.isUser = false});

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
                  Image.asset(AppIcons.appIcon),
                  16.verticalSpace,
                  Text(
                    AppStrings.forgotPasswordTitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text20w500(
                      color: AppColors(context).textPrimary,
                    ),
                  ),
                  2.verticalSpace,
                  Text(
                    AppStrings.enterPhoneForVerification,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.text15w400(
                      color: AppColors(context).textPrimary,
                    ),
                  ),
                  60.verticalSpace,
                  CustomPhoneTextField(),
                  40.verticalSpace,

                  CustomAppButton(
                    text: AppStrings.send,
                    onPressed: () {
                      context.pushNamedAndRemoveUntil(
                        AppRoutes.otpScreen,
                        arguments: isUser,
                      );
                    },
                  ),
                  20.verticalSpace,

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
