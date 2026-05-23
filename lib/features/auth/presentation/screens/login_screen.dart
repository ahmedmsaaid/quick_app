import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
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
                  RichText(
                    text: TextSpan(
                      children: [
                        if (AppStrings.welcomeToStylePart1.isNotEmpty)
                          TextSpan(
                            text: '${AppStrings.welcomeToStylePart1} ',
                            style: AppTextStyles.text20w500(
                              color: colors.textPrimary,
                            ),
                          ),
                        TextSpan(
                          text: AppStrings.appName,
                          style: AppTextStyles.text20w700(
                            color: colors.primary,
                          ),
                        ),
                        TextSpan(
                          text: ' ${AppStrings.welcomeToStylePart2}',
                          style: AppTextStyles.text20w500(
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    AppStrings.chooseYourLoginMethod,
                    style: AppTextStyles.text18w500(
                      color: colors.textPrimary,
                    ),
                  ),
                  60.verticalSpace,
                  const CustomPhoneTextField(),
                  20.verticalSpace,
                  CustomPasswordTextField(
                    hintText: AppStrings.password,
                  ),
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
                          color: colors.textPrimary,
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
                        context.pushNamedAndRemoveUntil(AppRoutes.captainNav);
                      }
                    },
                  ),
                  30.verticalSpace,
                  Row(
                    children: [
                      Expanded(child: Divider(color: colors.divider)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          AppStrings.orContinueWith,
                          style: AppTextStyles.text12w400(color: colors.textSecondary),
                        ),
                      ),
                      Expanded(child: Divider(color: colors.divider)),
                    ],
                  ),
                  20.verticalSpace,
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(FontAwesomeIcons.google, color: Colors.red, size: 20.sp),
                    label: Text(
                      AppStrings.loginWithGoogle,
                      style: AppTextStyles.text14w600(color: colors.textPrimary),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(double.infinity, 50.h),
                      side: BorderSide(color: colors.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    ),
                  ),
                  20.verticalSpace,
                  if (isUser)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: AppStrings.dontHaveAccount,
                            style: AppTextStyles.text12w400(
                              color: colors.textPrimary,
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
                                      color: colors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        AppStrings.joinCaptainTeamMsg,
                        style: AppTextStyles.text12w600(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
