import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_app_bar.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/routes/app_routes.dart';

class CaptainRegistrationDetailsScreen extends StatelessWidget {
  const CaptainRegistrationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(title: AppStrings.completeCaptainDataTitle),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.vehicleInfoLabel, style: AppTextStyles.text16w700(color: colors.textPrimary)),
            20.verticalSpace,
            CustomTextField(hintText: AppStrings.vehicleTypeHint),
            15.verticalSpace,
            CustomTextField(hintText: AppStrings.plateNumberHint),
            25.verticalSpace,
            Text(AppStrings.requiredDocsLabel, style: AppTextStyles.text16w700(color: colors.textPrimary)),
            15.verticalSpace,
            _buildUploadCard(context, AppStrings.licensePhotoLabel, Icons.card_membership),
            10.verticalSpace,
            _buildUploadCard(context, AppStrings.vehicleRegPhotoLabel, Icons.assignment_outlined),
            40.verticalSpace,
            CustomAppButton(
              text: AppStrings.submitForReviewBtn,
              onPressed: () {
                // Show success and go to dashboard for prototype
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppStrings.dataSentSuccessMsg)),
                );
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.captainNav, (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadCard(BuildContext context, String title, IconData icon) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(15.r),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.textSecondary),
          15.horizontalSpace,
          Expanded(child: Text(title, style: AppTextStyles.text14w400(color: colors.textPrimary))),
          Icon(Icons.upload_file, color: colors.primary, size: 20.sp),
        ],
      ),
    );
  }
}
