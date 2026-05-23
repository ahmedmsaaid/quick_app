import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/features/auth/presentation/widgets/custom_password_text_field.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.changePasswordBtn,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.changePasswordInstructionsMsg,
              style: AppTextStyles.text14w400(color: colors.textSecondary),
            ),
            30.verticalSpace,
            _buildLabel(context, AppStrings.currentPasswordLabel),
            10.verticalSpace,
            CustomPasswordTextField(
              hintText: AppStrings.enterCurrentPasswordHint,
            ),
            20.verticalSpace,
            _buildLabel(context, AppStrings.newPasswordLabel),
            10.verticalSpace,
            CustomPasswordTextField(
              hintText: AppStrings.enterNewPasswordHint,
            ),
            20.verticalSpace,
            _buildLabel(context, AppStrings.confirmNewPasswordLabel),
            10.verticalSpace,
            CustomPasswordTextField(
              hintText: AppStrings.reEnterNewPasswordHint,
            ),
            40.verticalSpace,
            CustomAppButton(
              text: AppStrings.updatePasswordBtn,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.passwordUpdatedSuccessMsg),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
    );
  }
}
