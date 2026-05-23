import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class LocationBottomSheet extends StatelessWidget {
  const LocationBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          20.verticalSpace,
          Text(
            AppStrings.chooseDeliveryLocationTitle,
            style: AppTextStyles.text18w700(color: colors.textPrimary),
          ),
          20.verticalSpace,
          _buildCurrentLocationItem(context),
          20.verticalSpace,
          Text(
            AppStrings.savedAddressesTitle,
            style: AppTextStyles.text14w600(color: colors.textSecondary),
          ),
          10.verticalSpace,
          _buildSavedLocationItem(
            context,
            title: AppStrings.homeLabel,
            address: AppStrings.mansourAddressMsg,
            icon: Icons.home_outlined,
            isSelected: true,
          ),
          10.verticalSpace,
          _buildSavedLocationItem(
            context,
            title: AppStrings.workLabel,
            address: AppStrings.universityAddressMsg,
            icon: Icons.work_outline,
            isSelected: false,
          ),
          20.verticalSpace,
          _buildAddNewAddress(context),
          20.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildCurrentLocationItem(BuildContext context) {
    final colors = AppColors(context);
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.my_location, color: colors.primary),
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.useCurrentLocationBtn,
                    style: AppTextStyles.text14w600(color: colors.primary),
                  ),
                  Text(
                    AppStrings.gpsAutoLocationMsg,
                    style: AppTextStyles.text12w400(color: colors.textHint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedLocationItem(
    BuildContext context, {
    required String title,
    required String address,
    required IconData icon,
    required bool isSelected,
  }) {
    final colors = AppColors(context);
    return InkWell(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? colors.primary : colors.textHint),
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.text14w600(color: colors.textPrimary)),
                  Text(
                    address,
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: colors.primary, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewAddress(BuildContext context) {
    final colors = AppColors(context);
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        Navigator.of(context).pushNamed(AppRoutes.addAddress);
      },
      child: Row(
        children: [
          Icon(Icons.add_location_alt_outlined, color: colors.primary, size: 20.sp),
          10.horizontalSpace,
          Text(
            AppStrings.addNewAddressBtn,
            style: AppTextStyles.text14w600(color: colors.primary),
          ),
        ],
      ),
    );
  }
}
