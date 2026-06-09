import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          AppStrings.privacyPolicy,
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
              AppStrings.quickPolicyTitle,
              style: AppTextStyles.text16w700(color: colors.textPrimary),
            ),
            15.verticalSpace,
            Text(
              AppStrings.policyContentMsg,
              style: AppTextStyles.text14w400(color: colors.textSecondary),
            ),
            20.verticalSpace,
            Text(
              AppStrings.dataCollectionTitle,
              style: AppTextStyles.text16w700(color: colors.textPrimary),
            ),
            10.verticalSpace,
            Text(
              AppStrings.dataCollectionMsg,
              style: AppTextStyles.text14w400(color: colors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
