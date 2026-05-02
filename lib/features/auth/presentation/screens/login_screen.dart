import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../widgets/custom_password_text_field.dart';
import '../widgets/custom_phone_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key, this.isUser = false});

  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                40.verticalSpace,
                Image.asset(AppIcons.styleIcon),
                16.verticalSpace,
                RichText(
                  text: TextSpan(
                    children: [
                      if (AppStrings.welcomeToStylePart1.isNotEmpty)
                        TextSpan(
                          text: '${AppStrings.welcomeToStylePart1} ',
                          style: AppTextStyles.text20w500(
                            color: AppColors(context).textPrimary,
                          ),
                        ),
                      TextSpan(
                        text: AppStrings.appName,
                        style: AppTextStyles.text20w700(
                          color: AppColors(context).primaryVariant,
                        ),
                      ),
                      TextSpan(
                        text: ' ${AppStrings.welcomeToStylePart2}',
                        style: AppTextStyles.text20w500(
                          color: AppColors(context).textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppStrings.chooseYourLoginMethod,
                  style: AppTextStyles.text18w500(
                    color: AppColors(context).textPrimary,
                  ),
                ),
                60.verticalSpace,
                CustomPhoneTextField(),
                20.verticalSpace,
                CustomPasswordTextField(hintText: AppStrings.password),
                Align(
                  alignment: AlignmentDirectional.bottomEnd,
                  child: TextButton(
                    onPressed: () {
                      context.pushNamedAndRemoveUntil(
                        AppRoutes.forgetPasswordScreen,
                        arguments: isUser,
                      );
                    },
                    child: Text(
                      AppStrings.forgotPassword,
                      style: AppTextStyles.text12w500(
                        color: AppColors(context).textPrimary,
                      ),
                    ),
                  ),
                ),
                40.verticalSpace,
                CustomAppButton(
                  text: AppStrings.login,
                  onPressed: () {
                    if (isUser) {
                      context.pushNamedAndRemoveUntil(AppRoutes.userNav);
                    } else {
                      context.pushNamedAndRemoveUntil(AppRoutes.providerNav);
                    }
                  },
                ),
                20.verticalSpace,
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppStrings.dontHaveAccount,
                        style: AppTextStyles.text12w400(
                          color: AppColors(context).textPrimary,
                        ),
                        children: [
                          WidgetSpan(
                            child: InkWell(
                              onTap: () {
                                context.pushNamed(
                                  AppRoutes.registerScreen,
                                  arguments: isUser,
                                );
                              },
                              child: Text(
                                ' ${AppStrings.registerNow}',
                                style: AppTextStyles.text12w500(
                                  color: AppColors(context).primaryVariant,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
