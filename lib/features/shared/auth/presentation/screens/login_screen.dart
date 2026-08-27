import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';

import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_password_text_field.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_phone_text_field.dart';
import 'package:base_app/features/shared/auth/presentation/riverpod/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key, this.isUser = false});

  final bool isUser;

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _phoneController;
  late final TextEditingController _passwordController;
  final _formKey = GlobalKey<FormState>();
  
  String _countryCode = "20"; // Default to Egypt phone code

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
      countryCode: _countryCode,
      rawPhone: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
      isUser: widget.isUser,
    );

    if (success) {
      if (mounted) {
        if (widget.isUser) {
          context.pushNamedAndRemoveUntil(AppRoutes.userNav);
        } else {
          context.pushNamedAndRemoveUntil(AppRoutes.captainNav);
        }
      }
    } else {
      if (mounted) {
        final state = ref.read(authProvider);
        if (state.statusCode == 330) {
          if (mounted) {
            context.pushNamed(
              AppRoutes.otpScreen,
              arguments: widget.isUser,
            );
          }
        } else {
          CustomToast.error(context, state.errorMessage ?? AppStrings.errorOccurred);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 20.h,
                ),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        8.verticalSpace,
                        // Logo
                        Image.asset(
                          AppIcons.appIcon,
                          height: 250.h,
                          fit: BoxFit.contain,
                        ),
                        6.verticalSpace,
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              if (AppStrings.welcomeToStylePart1.isNotEmpty)
                                TextSpan(
                                  text: '${AppStrings.welcomeToStylePart1} ',
                                  style: AppTextStyles.text18w500(
                                    color: colors.textPrimary,
                                  ),
                                ),
                              TextSpan(
                                text: AppStrings.appName,
                                style: AppTextStyles.text18w700(
                                  color: colors.primary,
                                ),
                              ),
                              TextSpan(
                                text: ' ${AppStrings.welcomeToStylePart2}',
                                style: AppTextStyles.text18w500(
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        2.verticalSpace,
                        Text(
                          AppStrings.chooseYourLoginMethod,
                          style: AppTextStyles.text14w500(
                            color: colors.textSecondary,
                          ),
                        ),
                        14.verticalSpace,

                        // ── Quick Fill Credentials Buttons ─────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _phoneController.text = "01020183843";
                                    _passwordController.text = "Ahmed@123123";
                                  });
                                },
                                icon: Icon(Icons.person_rounded, size: 16.sp, color: colors.primary),
                                label: Text(
                                  'تعبئة يوزر 👤',
                                  style: AppTextStyles.text12w600(color: colors.primary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  side: BorderSide(color: colors.primary.withValues(alpha: 0.4)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _phoneController.text = "01110019623";
                                    _passwordController.text = "Ahmed@123123";
                                  });
                                },
                                icon: Icon(Icons.two_wheeler_rounded, size: 16.sp, color: colors.secondary),
                                label: Text(
                                  'تعبئة دليفري 🏍️',
                                  style: AppTextStyles.text12w600(color: colors.secondary),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 8.h),
                                  side: BorderSide(color: colors.secondary.withValues(alpha: 0.4)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        14.verticalSpace,

                        // Phone Field
                        CustomPhoneTextField(
                          controller: _phoneController,
                          onCountryChanged: (country) {
                            _countryCode = country.phoneCode;
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return AppStrings.pleaseEnterPhone;
                            }
                            return null;
                          },
                        ),
                        12.verticalSpace,

                        // Password Field
                        CustomPasswordTextField(
                          controller: _passwordController,
                          hintText: AppStrings.password,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return AppStrings.pleaseEnterPassword;
                            }
                            return null;
                          },
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () {
                              context.pushNamedAndRemoveUntil(
                                AppRoutes.forgetPasswordScreen,
                                arguments: widget.isUser,
                              );
                            },
                            child: Text(
                              AppStrings.forgotPassword,
                              style: AppTextStyles.text12w500(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ),
                        14.verticalSpace,

                        // Login Button
                        if (authState.status == AuthStatus.loading)
                          const LoadingButton()
                        else
                          CustomAppButton(
                            text: AppStrings.login,
                            height: 46,
                            onPressed: _handleLogin,
                          ),
                        12.verticalSpace,

                        // Divider
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
                        10.verticalSpace,

                        // Google Login Button
                        OutlinedButton.icon(
                          onPressed: () async {
                            final success = await ref.read(authProvider.notifier).loginWithGoogle(
                              isUser: widget.isUser,
                            );
                            if (success) {
                              if (mounted) {
                                if (widget.isUser) {
                                  context.pushNamedAndRemoveUntil(AppRoutes.userNav);
                                } else {
                                  context.pushNamedAndRemoveUntil(AppRoutes.captainNav);
                                }
                              }
                            } else {
                              if (mounted) {
                                final state = ref.read(authProvider);
                                CustomToast.error(context, state.errorMessage ?? AppStrings.errorOccurred);
                              }
                            }
                          },
                          icon: Icon(FontAwesomeIcons.google, color: Colors.red, size: 18.sp),
                          label: Text(
                            AppStrings.loginWithGoogle,
                            style: AppTextStyles.text14w600(color: colors.textPrimary),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 44.h),
                            side: BorderSide(color: colors.divider),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                          ),
                        ),
                        
                        const Spacer(),
                        10.verticalSpace,

                        // Create Account Section - Both Customer & Captain buttons
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: colors.primary.withValues(alpha: 0.2),
                              width: 1.w,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.person_add_alt_1_rounded, size: 18.sp, color: colors.primary),
                                  6.horizontalSpace,
                                  Text(
                                    'ليس لديك حساب حتى الآن؟',
                                    style: AppTextStyles.text13w600(color: colors.textPrimary),
                                  ),
                                ],
                              ),
                              10.verticalSpace,
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        context.pushNamed(
                                          AppRoutes.registerScreen,
                                          arguments: true,
                                        );
                                      },
                                      icon: Icon(Icons.person_add_rounded, size: 16.sp, color: Colors.white),
                                      label: Text(
                                        'حساب عميل',
                                        style: AppTextStyles.text12w600(color: Colors.white),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: colors.primary,
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                  10.horizontalSpace,
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        context.pushNamed(AppRoutes.captainRegisterScreen);
                                      },
                                      icon: Icon(Icons.two_wheeler_rounded, size: 16.sp, color: colors.primary),
                                      label: Text(
                                        'حساب كابتن/طيار',
                                        style: AppTextStyles.text12w600(color: colors.primary),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(vertical: 10.h),
                                        side: BorderSide(color: colors.primary),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.r),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        4.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
