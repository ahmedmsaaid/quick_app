import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/custom_button.dart';

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.personalInformation,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50.r,
                    backgroundColor: AppColors(context).divider,
                    backgroundImage: const AssetImage('assets/image/logo.png'),
                  ),
                  Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: AppColors(context).primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.camera_alt, color: Colors.white, size: 20.sp),
                  ),
                ],
              ),
            ),
            30.verticalSpace,
            _buildField(context, AppStrings.fullName, AppStrings.userNamePlaceholder),
            20.verticalSpace,
            _buildField(context, AppStrings.phoneNumber, '+20 123 456 7890'),
            20.verticalSpace,
            _buildField(context, AppStrings.email, 'ahmed@example.com'),
            40.verticalSpace,
            CustomAppButton(
              text: AppStrings.saveChanges,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(BuildContext context, String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
        ),
        10.verticalSpace,
        CustomTextField(
          controller: TextEditingController(text: initialValue),
        ),
      ],
    );
  }
}
