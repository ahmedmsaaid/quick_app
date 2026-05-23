import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
          AppStrings.contactUs,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: colors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.headset_mic, color: colors.primary, size: 40.sp),
                  20.horizontalSpace,
                  Expanded(
                    child: Text(
                      AppStrings.contactUsMsg,
                      style: AppTextStyles.text14w600(color: colors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
            30.verticalSpace,
            CustomTextField(hintText: AppStrings.subjectHint),
            20.verticalSpace,
            CustomTextField(hintText: AppStrings.messageHint, maxLines: 5),
            30.verticalSpace,
            CustomAppButton(
              text: AppStrings.sendMessageBtn,
              onPressed: () => Navigator.pop(context),
            ),
            20.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(context, Icons.facebook, Colors.blue),
                20.horizontalSpace,
                _buildSocialIcon(context, Icons.camera_alt, Colors.purple),
                20.horizontalSpace,
                _buildSocialIcon(context, Icons.chat, Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
      child: Icon(icon, color: color),
    );
  }
}
