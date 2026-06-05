import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/widgets/custom_toast.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/styles/app_colors.dart';
import '../../../../core/styles/app_text_style.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/lading_button.dart';
import '../widgets/custom_button_return_login_screen.dart';
import '../riverpod/auth_provider.dart';
import '../../data/auth_api_service.dart';

/// OTP screen mode constants
class OtpMode {
  static const String register = 'register';
  static const String forgotPassword = 'forgotPassword';
}

/// Arguments passed to OtpScreen via route settings.
class OtpArgs {
  final bool isUser;

  /// 'register' or 'forgotPassword'
  final String mode;

  const OtpArgs({
    this.isUser = false,
    this.mode = OtpMode.register,
  });
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({
    super.key,
    this.isUser = false,
    this.mode = OtpMode.register,
  });

  final bool isUser;
  final String mode;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  String _otpCode = '';
  bool _isLoading = false;

  // Timer State Variables
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _canResend = false;

  bool get _isForgotPasswordMode => widget.mode == OtpMode.forgotPassword;

  @override
  void initState() {
    super.initState();
    _sendOtpOnInit();
    _startTimer();
  }

  void _sendOtpOnInit() {
    final phone = CacheHelper.getString('temp_phone') ?? '';
    if (phone.isNotEmpty) {
      ref.read(authApiServiceProvider).sendOtp(
            phone: phone,
            type: _isForgotPasswordMode ? 1 : 0,
          );
    }
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 60;
      _canResend = false;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
          _timer?.cancel();
        });
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _verifyOtp() async {
    if (_otpCode.length < 5) {
      CustomToast.error(context, AppStrings.enterCodeComplete);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final phone = CacheHelper.getString('temp_phone') ?? '';

    final result = await ref.read(authApiServiceProvider).verifyOtp(
          phone: phone,
          code: _otpCode,
        );

    setState(() {
      _isLoading = false;
    });

    result.when(
      success: (response) async {
        if (response.success) {
          if (_isForgotPasswordMode) {
            // Extract the token returned by verifyOtp and cache it
            final resetToken = response.result?['token'] as String?;
            if (resetToken != null && resetToken.isNotEmpty) {
              await CacheHelper.setString('reset_token', resetToken);
            }

            if (mounted) {
              context.pushNamed(
                AppRoutes.createNewPasswordScreen,
                arguments: widget.isUser,
              );
            }
          } else {
            // Register flow: promote tempToken to main token
            final tempToken = CacheHelper.getString('tempToken');
            if (tempToken != null && tempToken.isNotEmpty) {
              await CacheHelper.setString(CacheKeys.token, tempToken);
              await CacheHelper.remove('tempToken');
            } else {
              // Fallback: in case verifyOtp result contains a token
              final token = response.result?['token'] as String?;
              if (token != null && token.isNotEmpty) {
                await CacheHelper.setString(CacheKeys.token, token);
              }
            }

            final refreshToken = response.result?['refreshToken'] as String?;
            if (refreshToken != null && refreshToken.isNotEmpty) {
              await CacheHelper.setString('refreshToken', refreshToken);
            }

            // Mark AuthState as authenticated directly without calling getProfile
            ref.read(authProvider.notifier).setAuthenticated();

            if (mounted) {
              if (widget.isUser) {
                context.pushNamedAndRemoveUntil(AppRoutes.userNav);
              } else {
                context.pushNamedAndRemoveUntil(AppRoutes.captainNav);
              }
            }
          }
        } else {
          _showError(response.message ?? "رمز التحقق غير صحيح");
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
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  40.verticalSpace,
                  Image.asset(AppIcons.appIcon),
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
                              color: colors.textPrimary,
                            ),
                          ),
                          Text(
                            AppStrings.enterVerificationCode,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.text15w500(
                              color: colors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  30.verticalSpace,
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: OtpTextField(
                      numberOfFields: 5,
                      keyboardType: TextInputType.number,
                      fieldWidth: 60.w,
                      fieldHeight: 60.h,
                      cursorColor: colors.primary,
                      textStyle: AppTextStyles.text18w700(
                        color: colors.textPrimary,
                      ),
                      focusedBorderColor: colors.primary,
                      borderRadius: BorderRadius.all(Radius.circular(16.sp)),
                      borderColor: colors.textPrimary,
                      showFieldAsBox: true,
                      onCodeChanged: (String code) {
                        _otpCode = code;
                      },
                      onSubmit: (String verificationCode) {
                        _otpCode = verificationCode;
                        _verifyOtp();
                      },
                    ),
                  ),
                  10.verticalSpace,
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${AppStrings.ifCodeNotReceived} ',
                          style: AppTextStyles.text12w500(
                            color: colors.textPrimary,
                          ),
                        ),
                        if (!_canResend)
                          TextSpan(
                            text: '(${_formatTime(_secondsRemaining)})',
                            style: AppTextStyles.text12w500(
                              color: colors.textSecondary,
                            ),
                          )
                        else
                          TextSpan(
                            text: AppStrings.resendCode,
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                final phone =
                                    CacheHelper.getString('temp_phone') ?? '';
                                ref.read(authApiServiceProvider).sendOtp(
                                      phone: phone,
                                      type: _isForgotPasswordMode ? 1 : 0,
                                    );
                                _startTimer();
                              },
                            style: AppTextStyles.text14w700(
                              color: colors.primaryVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  30.verticalSpace,
                  if (_isLoading)
                    const LoadingButton()
                  else
                    CustomAppButton(
                      text: AppStrings.send,
                      onPressed: _verifyOtp,
                    ),
                  20.verticalSpace,
                  CustomButtonReturnLoginScreen(isUser: widget.isUser),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
