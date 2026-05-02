import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/extensions.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../widgets/custom_password_text_field.dart';
import '../widgets/custom_phone_text_field.dart';

class RegisterScreen extends StatelessWidget {
  final bool isUser;

  const RegisterScreen({super.key, this.isUser = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    print("object ${isUser}");
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.loginNow, showTrailing: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            children: [
              const ProfileImagePicker(),
              30.verticalSpace,
              CustomTextField(
                hintText: AppStrings.fullName,
                prefixIcon: Icon(
                  Icons.person_outline,
                  color: colors.textPrimary.withValues(alpha: 0.6),
                ),
              ),
              20.verticalSpace,
              const CustomPhoneTextField(),
              20.verticalSpace,
              const CountryDropdown(),
              20.verticalSpace,
              CustomPasswordTextField(hintText: AppStrings.password),
              20.verticalSpace,
              CustomPasswordTextField(hintText: AppStrings.confirmPassword),
              if (isUser == false)
                Column(
                  children: [
                    20.verticalSpace,
                    CustomTextField(
                      hintText: AppStrings.serviceLocationAddress,
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: colors.textPrimary.withValues(alpha: 0.6),
                      ),
                      maxLines: 3,
                    ),
                    20.verticalSpace,
                    CustomTextField(
                      hintText: AppStrings.profileBio,
                      maxLines: 3,
                    ),
                  ],
                ),

              40.verticalSpace,
              CustomAppButton(
                text: AppStrings.completeRegistration,
                onPressed: () {
                  if (isUser == true) {
                    context.pushNamed(AppRoutes.otpScreen, arguments: isUser);
                  } else {
                    context.pushNamed(AppRoutes.completeRegisterScreen);
                  }
                },
              ),
              20.verticalSpace,
              const LoginLink(),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileImagePicker extends StatelessWidget {
  const ProfileImagePicker({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Stack(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: colors.divider,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 80.w,
            color: colors.textSecondary.withValues(alpha: 0.5),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: colors.textPrimary,
              shape: BoxShape.circle,
              border: Border.all(color: colors.background, width: 2),
            ),
            child: Icon(Icons.camera_alt, size: 20.w, color: colors.background),
          ),
        ),
      ],
    );
  }
}

class CountryDropdown extends StatelessWidget {
  const CountryDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return CustomTextField(
      hintText: AppStrings.country,
      readOnly: true,
      onTap: () {},
      prefixIcon: Icon(
        Icons.location_on_outlined,
        color: colors.textPrimary.withValues(alpha: 0.6),
      ),
      suffixIcon: Icon(
        Icons.keyboard_arrow_down,
        color: colors.textPrimary.withValues(alpha: 0.6),
      ),
    );
  }
}

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return InkWell(
      onTap: () => context.pop(context),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: AppStrings.haveAccount,
              style: AppTextStyles.text14w400(color: colors.textPrimary),
            ),
            TextSpan(
              text: ' ${AppStrings.loginNow}',
              style: AppTextStyles.text14w600(color: colors.primaryVariant),
            ),
          ],
        ),
      ),
    );
  }
}
