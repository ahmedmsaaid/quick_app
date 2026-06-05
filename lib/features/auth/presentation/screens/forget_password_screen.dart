import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:country_picker/country_picker.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/lading_button.dart';
import '../widgets/custom_button_return_login_screen.dart';
import '../widgets/custom_phone_text_field.dart';
import '../../data/auth_api_service.dart';
import 'otp_screen.dart';

class ForgetPasswordScreen extends ConsumerStatefulWidget {
  const ForgetPasswordScreen({super.key, this.isUser = false});

  final bool isUser;

  @override
  ConsumerState<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends ConsumerState<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String _countryCode = '20';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final rawPhone = _phoneController.text.trim();
    final phone = '+$_countryCode$rawPhone';

    // Save phone for OTP screen
    await CacheHelper.setString('temp_phone', phone);

    final result = await ref.read(authApiServiceProvider).sendOtp(
          phone: phone,
          type: 1, // type 1 = forgot password
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    result.when(
      success: (response) {
        if (response.success) {
          context.pushNamed(
            AppRoutes.otpScreen,
            arguments: OtpArgs(
              isUser: widget.isUser,
              mode: OtpMode.forgotPassword,
            ),
          );
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
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
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
                    40.verticalSpace,
                    Image.asset(AppIcons.appIcon),
                    16.verticalSpace,
                    Text(
                      AppStrings.forgotPasswordTitle,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.text20w500(
                        color: colors.textPrimary,
                      ),
                    ),
                    2.verticalSpace,
                    Text(
                      AppStrings.enterPhoneForVerification,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.text15w400(
                        color: colors.textPrimary,
                      ),
                    ),
                    60.verticalSpace,
                    CustomPhoneTextField(
                      controller: _phoneController,
                      onCountryChanged: (Country country) {
                        setState(() {
                          _countryCode = country.phoneCode;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return AppStrings.phoneNumber;
                        }
                        return null;
                      },
                    ),
                    40.verticalSpace,
                    if (_isLoading)
                      const LoadingButton()
                    else
                      CustomAppButton(
                        text: AppStrings.send,
                        onPressed: _sendOtp,
                      ),
                    20.verticalSpace,
                    CustomButtonReturnLoginScreen(isUser: widget.isUser),
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
