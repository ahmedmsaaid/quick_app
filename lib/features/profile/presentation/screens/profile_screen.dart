import 'package:base_app/core/routes/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors(context).background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            20.verticalSpace,
            _buildMenuSection(context),
            30.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 30.h),
      decoration: BoxDecoration(
        color: AppColors(context).surface,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors(context).primary, width: 2),
                  image: const DecorationImage(
                    image: AssetImage('assets/image/logo.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(5.r),
                decoration: BoxDecoration(
                  color: AppColors(context).primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit, color: Colors.white, size: 15.sp),
              ),
            ],
          ),
          15.verticalSpace,
          Text(
            AppStrings.userNamePlaceholder,
            style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
          ),
          5.verticalSpace,
          Text(
            '+20 123 456 7890',
            style: AppTextStyles.text14w400(color: AppColors(context).textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors(context).surface,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          _buildMenuItem(context, Icons.person_outline, AppStrings.personalInformation),
          _buildMenuItem(context, Icons.location_on_outlined, AppStrings.address),
          _buildMenuItem(context, Icons.account_balance_wallet_outlined, AppStrings.wallet),
          _buildMenuItem(context, Icons.notifications_none, AppStrings.notifications),
          _buildMenuItem(context, Icons.settings_outlined, AppStrings.settings),
          _buildMenuItem(context, Icons.privacy_tip_outlined, AppStrings.privacyPolicy),
          _buildMenuItem(context, Icons.help_outline, AppStrings.contactUs),
          
          // --- TEST MODE SWITCH (ONLY FOR TESTING) ---
          Container(
            margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.amber),
            ),
            child: InkWell(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.chooseUserTypeScreen, (route) => false);
              },
              child: Row(
                children: [
                  const Icon(Icons.swap_horizontal_circle, color: Colors.amber),
                  15.horizontalSpace,
                  Expanded(
                    child: Text(
                      AppStrings.switchAppModeLabel,
                      style: AppTextStyles.text14w700(color: AppColors(context).textPrimary),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios, 
                    size: 14, 
                    color: Colors.amber,
                  ),
                ],
              ),
            ),
          ),

          _buildMenuItem(context, Icons.logout, AppStrings.logout, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {bool isLogout = false}) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isLogout ? Colors.red.withOpacity(0.1) : AppColors(context).primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: isLogout ? Colors.red : AppColors(context).primary,
          size: 20.sp,
        ),
      ),
      title: Text(
        title,
        style: AppTextStyles.text14w500(color: isLogout ? Colors.red : AppColors(context).textPrimary),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios, 
        size: 14.sp, 
        color: AppColors(context).textHint,
      ),
      onTap: () {
        if (title == AppStrings.personalInformation) {
          Navigator.of(context).pushNamed(AppRoutes.personalInfo);
        } else if (title == AppStrings.address) {
          Navigator.of(context).pushNamed(AppRoutes.address);
        } else if (title == AppStrings.wallet) {
          Navigator.of(context).pushNamed(AppRoutes.wallet);
        } else if (title == AppStrings.notifications) {
          Navigator.of(context).pushNamed(AppRoutes.notifications);
        } else if (title == AppStrings.settings) {
          Navigator.of(context).pushNamed(AppRoutes.settings);
        } else if (title == AppStrings.privacyPolicy) {
          Navigator.of(context).pushNamed(AppRoutes.privacyPolicy);
        } else if (title == AppStrings.contactUs) {
          Navigator.of(context).pushNamed(AppRoutes.contactUs);
        } else if (isLogout) {
          Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.loginScreen, (route) => false);
        }
      },
    );
  }
}
