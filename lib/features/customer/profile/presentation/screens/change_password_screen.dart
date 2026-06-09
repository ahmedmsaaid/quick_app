import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_password_text_field.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _oldPasswordController;
  late final TextEditingController _newPasswordController;
  late final TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _oldPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword != confirmPassword) {
      CustomToast.error(context, AppStrings.passwordNotMatch);
      return;
    }

    final success = await ref.read(profileProvider.notifier).changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
      confirmedNewPassword: confirmPassword,
    );

    if (success) {
      if (mounted) {
        CustomToast.success(context, AppStrings.passwordUpdatedSuccessMsg);
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        final profileState = ref.read(profileProvider);
        CustomToast.error(context, profileState.errorMessage ?? AppStrings.errorOccurred);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);

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
        child: Form(
          key: _formKey,
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
                controller: _oldPasswordController,
                hintText: AppStrings.enterCurrentPasswordHint,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return AppStrings.pleaseEnterPassword;
                  }
                  return null;
                },
              ),
              20.verticalSpace,
              _buildLabel(context, AppStrings.newPasswordLabel),
              10.verticalSpace,
              CustomPasswordTextField(
                controller: _newPasswordController,
                hintText: AppStrings.enterNewPasswordHint,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return AppStrings.pleaseEnterPassword;
                  }
                  if (val.length < 6) {
                    return AppStrings.passwordTooShort;
                  }
                  return null;
                },
              ),
              20.verticalSpace,
              _buildLabel(context, AppStrings.confirmNewPasswordLabel),
              10.verticalSpace,
              CustomPasswordTextField(
                controller: _confirmPasswordController,
                hintText: AppStrings.reEnterNewPasswordHint,
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return AppStrings.pleaseEnterPassword;
                  }
                  return null;
                },
              ),
              40.verticalSpace,
              if (profileState.status == ProfileStatus.updating)
                const LoadingButton()
              else
                CustomAppButton(
                  text: AppStrings.updatePasswordBtn,
                  onPressed: _handleChangePassword,
                ),
            ],
          ),
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
