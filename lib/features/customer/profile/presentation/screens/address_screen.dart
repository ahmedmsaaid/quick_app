import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
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
          ? Center(child: CircularProgressIndicator(color: colors.primary))
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

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: loc.base ? colors.primary : Colors.transparent,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    loc.base ? Icons.home : Icons.location_on,
                    color: loc.base ? colors.primary : colors.textHint,
                    size: 20.sp,
                  ),
                  8.horizontalSpace,
                  Text(
                    loc.base ? "العنوان الافتراضي" : "عنوان إضافي",
                    style: AppTextStyles.text14w700(
                      color: loc.base ? colors.primary : colors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (!loc.base)
                    TextButton(
                      onPressed: () async {
                        final success = await ref.read(profileProvider.notifier).setBaseAddress(loc);
                        if (success && context.mounted) {
                          CustomToast.success(context, "تم تعيين كالعنوان الافتراضي");
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        "تعيين كافتراضي",
                        style: AppTextStyles.text12w600(color: colors.primary),
                      ),
                    ),
                  IconButton(
                    onPressed: () => _deleteAddress(context, ref, loc.id),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
          10.verticalSpace,
          Text(
            loc.address ?? '',
            style: AppTextStyles.text14w400(color: colors.textSecondary),
          ),
          12.verticalSpace,
          Row(
            children: [
              Icon(Icons.gps_fixed, color: colors.textHint, size: 14.sp),
              6.horizontalSpace,
              Text(
                "خط العرض: ${loc.latitude.toStringAsFixed(4)} | خط الطول: ${loc.longitude.toStringAsFixed(4)}",
                style: AppTextStyles.text12w400(color: colors.textHint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
