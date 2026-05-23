import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/theme/theme_provider.dart';
import '../../../../core/routes/app_routes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.settings,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          20.verticalSpace,
          _buildSettingItem(
            context, 
            AppStrings.languageLabel, 
            context.locale.languageCode == 'ar' ? AppStrings.arabic : AppStrings.english, 
            Icons.language,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.chooseYourLanguageScreen, arguments: true);
            },
          ),
          _buildSettingItem(
            context, 
            AppStrings.displayModeLabel, 
            themeMode == ThemeMode.dark ? AppStrings.nightLabel : AppStrings.dayLabel, 
            Icons.dark_mode_outlined,
            onTap: () {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
          ),
          _buildSettingItem(context, AppStrings.notifications, AppStrings.notificationsOnLabel, Icons.notifications_none),
          _buildSettingItem(
            context, 
            AppStrings.changePasswordBtn,
            '', 
            Icons.lock_outline,
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.changePassword);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, String title, String value, IconData icon, {VoidCallback? onTap}) {
    final colors = AppColors(context);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: colors.surface, 
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: colors.primary),
        title: Text(title, style: AppTextStyles.text14w500(color: colors.textPrimary)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTextStyles.text12w400(color: colors.textSecondary)),
            10.horizontalSpace,
            Icon(
              Icons.arrow_forward_ios,
              size: 14, 
              color: colors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
