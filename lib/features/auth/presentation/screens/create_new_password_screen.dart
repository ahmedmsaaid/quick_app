import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
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
    final bool isFromSettings = (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: isFromSettings 
          ? AppBar(
              backgroundColor: colors.surface,
              elevation: 0,
              leading: const CustomArrowBack(),
              title: Text(
                AppStrings.changePasswordBtn,
                style: AppTextStyles.text18w700(color: colors.textPrimary),
              ),
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isFromSettings) ...[
                    40.verticalSpace,
                    Image.asset(AppIcons.appIcon),
                    16.verticalSpace,
                    Text(
                      AppStrings.createNewPassword,
                      style: AppTextStyles.text20w500(
                        color: colors.textPrimary,
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      AppStrings.getExtraProtection,
                      style: AppTextStyles.text15w500(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                  if (isFromSettings) 40.verticalSpace,
                  
                  if (isFromSettings) ...[
                    CustomPasswordTextField(
                      hintText: AppStrings.currentPasswordHint,
                    ),
                    15.verticalSpace,
                  ],
                  
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
                    onPressed: () {
                      if (isFromSettings) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppStrings.passwordChangedSuccessMsg)),
                        );
                        Navigator.pop(context);
                      } else {
                        if (isUser) {
                          context.pushNamedAndRemoveUntil(AppRoutes.userNav);
                        } else {
                          context.pushNamedAndRemoveUntil(AppRoutes.captainNav);
                        }
                      }
                    },
                  ),
                  if (!isFromSettings) ...[
                    15.verticalSpace,
                    CustomButtonReturnLoginScreen(isUser: isUser),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
