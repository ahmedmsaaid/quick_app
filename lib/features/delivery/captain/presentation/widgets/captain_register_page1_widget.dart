import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_register_provider.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_password_guidelines_widget.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_password_text_field.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_phone_text_field.dart';

class CaptainRegisterPage1Widget extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmPwCtrl;
  final TextEditingController descriptionCtrl;
  final TextEditingController? invitationCodeCtrl;
  final File? profileImage;
  final VehicleType selectedVehicle;
  final CaptainRegisterState state;
  final VoidCallback onPickProfilePhoto;
  final void Function(String) onCountryChanged;
  final void Function(VehicleType) onVehicleChanged;

  const CaptainRegisterPage1Widget({
    super.key,
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.confirmPwCtrl,
    required this.descriptionCtrl,
    this.invitationCodeCtrl,
    required this.profileImage,
    required this.selectedVehicle,
    required this.state,
    required this.onPickProfilePhoto,
    required this.onCountryChanged,
    required this.onVehicleChanged,
  });

  Widget _sectionLabel(AppColors colors, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: colors.primary),
        ),
        10.horizontalSpace,
        Text(title, style: AppTextStyles.text14w700(color: colors.textPrimary)),
      ],
    );
  }

  Widget _buildVehicleSelector(AppColors colors) {
    return Row(
      children: VehicleType.values.map((v) {
        final isSelected = selectedVehicle == v;
        return Expanded(
          child: GestureDetector(
            onTap: () => onVehicleChanged(v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                right: v != VehicleType.values.last ? 8.w : 0,
              ),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : colors.containerBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(v.emoji, style: TextStyle(fontSize: 24.sp)),
                  6.verticalSpace,
                  Text(
                    v.label,
                    style: AppTextStyles.text11w600(
                      color: isSelected ? Colors.white : colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Center(
            child: GestureDetector(
              onTap: onPickProfilePhoto,
              child: Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.containerBackground,
                      border: Border.all(
                        color: state.uploadedKey('profilePhoto') != null
                            ? Colors.green
                            : state.isUploading('profilePhoto')
                                ? colors.primary
                                : colors.border,
                        width: 2.5,
                      ),
                      image: profileImage != null
                          ? DecorationImage(
                              image: FileImage(profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profileImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_alt_1_rounded,
                                size: 32.sp,
                                color: colors.textHint,
                              ),
                              4.verticalSpace,
                              Text(
                                AppStrings.profilePhotoLabel,
                                style: AppTextStyles.text10w500(
                                  color: colors.textHint,
                                ),
                              ),
                            ],
                          )
                        : null,
                  ),
                  if (state.isUploading('profilePhoto'))
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: LoadingButton(
                            size: 28.w,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: state.uploadedKey('profilePhoto') != null
                            ? Colors.green
                            : colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.background,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        state.uploadedKey('profilePhoto') != null
                            ? Icons.check
                            : Icons.camera_alt_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          24.verticalSpace,

          _sectionLabel(colors, AppStrings.basicDataLabel, Icons.person_outline),
          12.verticalSpace,

          CustomTextField(
            controller: nameCtrl,
            hintText: AppStrings.fullName,
            prefixIcon: Icon(Icons.badge_outlined, color: colors.primary),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? AppStrings.pleaseEnterName : null,
          ),
          14.verticalSpace,

          CustomPhoneTextField(
            controller: phoneCtrl,
            onCountryChanged: (c) => onCountryChanged(c.phoneCode),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? AppStrings.pleaseEnterPhone : null,
          ),
          14.verticalSpace,

          CustomTextField(
            controller: emailCtrl,
            hintText: AppStrings.email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: Icon(Icons.email_outlined, color: colors.primary),
          ),
          14.verticalSpace,

          CustomTextField(
            controller: descriptionCtrl,
            hintText: AppStrings.bioOptionalHint,
            prefixIcon: Icon(Icons.info_outline, color: colors.primary),
            maxLines: 2,
          ),
          if (invitationCodeCtrl != null) ...[
            14.verticalSpace,
            CustomTextField(
              controller: invitationCodeCtrl!,
              hintText: AppStrings.promoOrInvitationCodeOptional,
              prefixIcon: Icon(
                Icons.confirmation_number_outlined,
                color: colors.primary,
              ),
            ),
          ],
          20.verticalSpace,

          _sectionLabel(colors, AppStrings.passwordLabel, Icons.lock_outline),
          12.verticalSpace,

          CustomPasswordTextField(
            controller: passwordCtrl,
            hintText: AppStrings.password,
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.pleaseEnterPassword;
              if (v.length < 6) return AppStrings.passwordTooShort;
              return null;
            },
          ),
          CustomPasswordGuidelinesWidget(controller: passwordCtrl),
          10.verticalSpace,

          CustomPasswordTextField(
            controller: confirmPwCtrl,
            hintText: AppStrings.confirmPassword,
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.pleaseEnterPassword;
              if (v != passwordCtrl.text) return AppStrings.passwordNotMatch;
              return null;
            },
          ),
          20.verticalSpace,

          _sectionLabel(
            colors,
            AppStrings.vehicleTypeLabel,
            Icons.directions_car_outlined,
          ),
          12.verticalSpace,

          _buildVehicleSelector(colors),
          20.verticalSpace,
        ],
      ),
    );
  }
}
