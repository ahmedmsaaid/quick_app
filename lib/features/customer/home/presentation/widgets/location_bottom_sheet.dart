import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/lading_button.dart';

class LocationBottomSheet extends ConsumerWidget {
  const LocationBottomSheet({super.key});

  Future<void> _useCurrentLocation(BuildContext context, WidgetRef ref) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // ignore: check_permission_before_requesting
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final address = await MapService.getAddressFromCoordsFree(position.latitude, position.longitude);
        
        final success = await ref.read(profileProvider.notifier).saveAddress(
          address: address,
          latitude: position.latitude,
          longitude: position.longitude,
        );
        if (success && context.mounted) {
          Navigator.pop(context);
        }
      } else {
        if (context.mounted) {
          CustomToast.error(context, "يرجى تفعيل صلاحية الوصول للموقع");
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomToast.error(context, "فشل تحديد الموقع الحالي");
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final locations = profileState.locations;
    final isUpdating = profileState.status == ProfileStatus.updating;

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
          _buildCurrentLocationItem(context, ref, isUpdating),
          20.verticalSpace,
          Text(
            AppStrings.savedAddressesTitle,
            style: AppTextStyles.text14w600(color: colors.textSecondary),
          ),
          10.verticalSpace,
          if (locations.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: Text(
                  "لا توجد عناوين محفوظة بعد",
                  style: AppTextStyles.text14w400(color: colors.textHint),
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locations.length,
                separatorBuilder: (context, index) => 10.verticalSpace,
                itemBuilder: (context, index) {
                  final loc = locations[index];
                  return _buildSavedLocationItem(
                    context,
                    ref: ref,
                    loc: loc,
                    isSelected: loc.base,
                    isUpdating: isUpdating,
                  );
                },
              ),
            ),
          20.verticalSpace,
          _buildAddNewAddress(context),
          20.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildCurrentLocationItem(BuildContext context, WidgetRef ref, bool isUpdating) {
    final colors = AppColors(context);
    return InkWell(
      onTap: isUpdating ? null : () => _useCurrentLocation(context, ref),
      child: Container(
        padding: EdgeInsets.all(15.r),
        decoration: BoxDecoration(
          color: colors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            isUpdating 
              ? LoadingButton(size: 24.w, color: colors.primary)
              : Icon(Icons.my_location, color: colors.primary),
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
    required WidgetRef ref,
    required LocationDto loc,
    required bool isSelected,
    required bool isUpdating,
  }) {
    final colors = AppColors(context);
    return InkWell(
      onTap: (isSelected || isUpdating)
          ? null
          : () async {
              final success = await ref.read(profileProvider.notifier).setBaseAddress(loc);
              if (success && context.mounted) {
                Navigator.pop(context);
              }
            },
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
            Icon(
              loc.base ? Icons.home_outlined : Icons.location_on_outlined,
              color: isSelected ? colors.primary : colors.textHint,
            ),
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.base ? "العنوان الافتراضي" : "عنوان محفوظ",
                    style: AppTextStyles.text12w400(color: isSelected ? colors.primary : colors.textSecondary),
                  ),
                  Text(
                    loc.address ?? '',
                    style: AppTextStyles.text14w600(color: colors.textPrimary),
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
