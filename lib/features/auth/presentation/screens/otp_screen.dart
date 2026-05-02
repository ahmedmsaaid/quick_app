import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/custom_button_return_login_screen.dart';

class OtpScreen extends StatelessWidget {
  const OtpScreen({super.key, this.isUser = false});

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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Center(
                      child: Column(
                        children: [
                          Text(
                            AppStrings.twoFactorAuthCode,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text20w500(
                              color: AppColors(context).textPrimary,
                            ),
                          ),
                          Text(
                            AppStrings.enterVerificationCode,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text15w500(
                              color: AppColors(context).textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  30.verticalSpace,
                  OtpTextField(
                    numberOfFields: 4,
                    keyboardType: TextInputType.number,
                    fieldWidth: 75.w,
                    fieldHeight: 60.h,
                    cursorColor: AppColors(context).primary,
                    textStyle: AppTextStyles.text18w700(
                      color: AppColors(context).textPrimary,
                    ),
                    focusedBorderColor: AppColors(context).primary,
                    borderRadius: BorderRadius.all(Radius.circular(16.sp)),
                    borderColor: AppColors(context).textPrimary,
                    showFieldAsBox: true,
                    onCodeChanged: (String code) {},
                    onSubmit: (String verificationCode) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Verification Code"),
                            content: Text('Code entered is $verificationCode'),
                          );
                        },
                      );
                    }, // end onSubmit
                  ),
                  10.verticalSpace,
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${AppStrings.ifCodeNotReceived} ',
                          style: AppTextStyles.text12w500(
                            color: AppColors(context).textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: AppStrings.resendCode,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // context.pushNamedAndRemoveUntil(AppRoutes.otp);
                            },
                          style: AppTextStyles.text14w700(
                            color: AppColors(context).primaryVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  30.verticalSpace,
                  CustomAppButton(
                    text: AppStrings.send,
                    onPressed: () {
                      context.pushNamedAndRemoveUntil(
                        AppRoutes.createNewPasswordScreen,
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
