import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';

import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/lading_button.dart';
import '../widgets/custom_button_return_login_screen.dart';
import '../widgets/custom_password_text_field.dart';
import '../../data/auth_api_service.dart';

class CreateNewPasswordScreen extends ConsumerStatefulWidget {
  const CreateNewPasswordScreen({super.key, this.isUser = false});

  final bool isUser;

  @override
  ConsumerState<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState
    extends ConsumerState<CreateNewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _savePassword() async {
    final bool isFromSettings =
        (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;

    if (isFromSettings) {
      // Settings flow: just pop
      CustomToast.success(context, AppStrings.passwordChangedSuccessMsg);
      Navigator.pop(context);
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = CacheHelper.getString('reset_token') ?? '';
    final newPassword = _newPasswordController.text;
    final confirmedNewPassword = _confirmPasswordController.text;

    final result = await ref.read(authApiServiceProvider).changePassword(
          token: token,
          newPassword: newPassword,
          confirmedNewPassword: confirmedNewPassword,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (response) async {
        if (response.success) {
          // Clean up cached temp data
          await CacheHelper.remove('temp_phone');
          await CacheHelper.remove('reset_token');

          if (mounted) {
            CustomToast.success(context, AppStrings.passwordChangedSuccessMsg);
            // Navigate to login
            context.pushNamedAndRemoveUntil(
              AppRoutes.loginScreen,
              arguments: widget.isUser,
            );
          }
        } else {
          _showError(response.message ?? AppStrings.errorOccurred);
        }
      },
      failure: (error) {
        _showError(error.message);
      },
    );
  }

  void _showError(String message) {
    CustomToast.error(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final bool isFromSettings =
        (ModalRoute.of(context)?.settings.arguments as bool?) ?? false;
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
            child: Form(
              key: _formKey,
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
                    40.verticalSpace,
                    CustomPasswordTextField(
                      controller: _newPasswordController,
                      hintText: AppStrings.enterNewPassword,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.enterNewPassword;
                        }
                        if (value.length < 6) {
                          return AppStrings.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    15.verticalSpace,
                    CustomPasswordTextField(
                      controller: _confirmPasswordController,
                      hintText: AppStrings.enterPasswordAgain,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.enterPasswordAgain;
                        }
                        if (value != _newPasswordController.text) {
                          return AppStrings.passwordNotMatch;
                        }
                        return null;
                      },
                    ),
                    48.verticalSpace,
                    if (_isLoading)
                      const LoadingButton()
                    else
                      CustomAppButton(
                        text: AppStrings.saveChanges,
                        onPressed: _savePassword,
                      ),
                    if (!isFromSettings) ...[
                      15.verticalSpace,
                      CustomButtonReturnLoginScreen(isUser: widget.isUser),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
