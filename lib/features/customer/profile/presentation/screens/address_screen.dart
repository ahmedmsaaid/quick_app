import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class AddressScreen extends ConsumerWidget {
  const AddressScreen({super.key});

  void _deleteAddress(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors(context).surface,
        title: Text(
          "حذف العنوان",
          style: AppTextStyles.text16w700(color: AppColors(context).textPrimary),
          textAlign: TextAlign.right,
        ),
        content: Text(
          "هل أنت متأكد من رغبتك في حذف هذا العنوان؟",
          style: AppTextStyles.text14w400(color: AppColors(context).textSecondary),
          textAlign: TextAlign.right,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("إلغاء", style: TextStyle(color: AppColors(context).textHint)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(profileProvider.notifier).deleteAddress(id);
              if (success && context.mounted) {
                CustomToast.success(context, "تم حذف العنوان بنجاح");
              } else if (context.mounted) {
                final err = ref.read(profileProvider).errorMessage;
                CustomToast.error(context, err ?? AppStrings.errorOccurred);
              }
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final locations = profileState.locations;
    final isLoading = profileState.status == ProfileStatus.updating || profileState.status == ProfileStatus.loading;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.myAddressesTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const LoadingButton()
          : locations.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  padding: EdgeInsets.all(20.w),
                  itemCount: locations.length,
                  separatorBuilder: (context, index) => 15.verticalSpace,
                  itemBuilder: (context, index) {
                    final loc = locations[index];
                    return _buildAddressCard(context, ref, loc);
                  },
                ),
      bottomNavigationBar: locations.isEmpty
          ? null
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
              child: CustomAppButton(
                text: AppStrings.addNewAddressBtn,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.addAddress),
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colors = AppColors(context);
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80.sp, color: colors.textHint),
          20.verticalSpace,
          Text(
            "لا توجد عناوين محفوظة بعد",
            style: AppTextStyles.text16w700(color: colors.textPrimary),
          ),
          10.verticalSpace,
          Text(
            "أضف عنوانك لتوصيل أسرع وأسهل لطلباتك",
            style: AppTextStyles.text14w400(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          30.verticalSpace,
          CustomAppButton(
            text: AppStrings.addNewAddressBtn,
            onPressed: () => Navigator.pushNamed(context, AppRoutes.addAddress),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, WidgetRef ref, LocationDto loc) {
    final colors = AppColors(context);
    final String addressName = (loc.name != null && loc.name!.trim().isNotEmpty)
        ? loc.name!.trim()
        : (loc.base ? "العنوان الافتراضي" : "عنوان محفوظ");

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: loc.base ? colors.primary : colors.border.withValues(alpha: 0.6),
          width: loc.base ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: loc.base
                            ? colors.primary.withValues(alpha: 0.12)
                            : colors.containerBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        loc.base ? Icons.home_rounded : Icons.location_on_rounded,
                        color: loc.base ? colors.primary : colors.textSecondary,
                        size: 20.sp,
                      ),
                    ),
                    10.horizontalSpace,
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              addressName,
                              style: AppTextStyles.text16w700(color: colors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (loc.base) ...[
                            8.horizontalSpace,
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                "افتراضي",
                                style: TextStyle(
                                  color: colors.primary,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Cairo',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!loc.base)
                    TextButton.icon(
                      onPressed: () async {
                        final success = await ref.read(profileProvider.notifier).setBaseAddress(loc);
                        if (success && context.mounted) {
                          CustomToast.success(context, "تم تعيين كالعنوان الافتراضي");
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      icon: Icon(Icons.check_circle_outline_rounded, size: 14.sp, color: colors.primary),
                      label: Text(
                        "تعيين كافتراضي",
                        style: AppTextStyles.text12w600(color: colors.primary),
                      ),
                    ),
                  IconButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.addAddress, arguments: loc),
                    icon: Icon(Icons.edit_outlined, color: colors.primary, size: 20.sp),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "تعديل العنوان",
                  ),
                  8.horizontalSpace,
                  IconButton(
                    onPressed: () => _deleteAddress(context, ref, loc.id),
                    icon: Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20.sp),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: "حذف العنوان",
                  ),
                ],
              ),
            ],
          ),
          12.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.place_outlined, size: 16.sp, color: colors.primary),
              6.horizontalSpace,
              Expanded(
                child: Text(
                  loc.address ?? '',
                  style: AppTextStyles.text14w400(color: colors.textSecondary),
                ),
              ),
            ],
          ),
          if (loc.latitude != 0 && loc.longitude != 0) ...[
            10.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: colors.containerBackground,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.my_location_rounded, color: colors.textHint, size: 13.sp),
                  6.horizontalSpace,
                  Text(
                    "${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}",
                    style: AppTextStyles.text11w400(color: colors.textHint),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
