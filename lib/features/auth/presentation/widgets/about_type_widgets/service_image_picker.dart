import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/extintions/navigation_extension.dart';

import '../../../../../core/localizations/app_strings.g.dart';
import '../../../../../core/styles/app_colors.dart';
import '../../../../../core/styles/app_text_style.dart';
import '../../riverpod/about_type_provider.dart';

class ServiceImagePicker extends ConsumerWidget {
  const ServiceImagePicker({super.key});

  void _showImageSourceDialog(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: colors.primaryVariant),
                title: Text(
                  AppStrings.camera,
                  style: AppTextStyles.text16w500(color: colors.textPrimary),
                ),
                onTap: () {
                  context.pop();
                  ref.read(aboutTypeProvider.notifier).pickImageFromCamera();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_library,
                  color: colors.primaryVariant,
                ),
                title: Text(
                  AppStrings.gallery,
                  style: AppTextStyles.text16w500(color: colors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ref.read(aboutTypeProvider.notifier).pickImage();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final currentImage = ref.watch(
      aboutTypeProvider.select((state) => state.currentServiceImage),
    );
    final isPickingImage = ref.watch(
      aboutTypeProvider.select((state) => state.isPickingImage),
    );

    return InkWell(
      onTap: isPickingImage ? null : () => _showImageSourceDialog(context, ref),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),

        child: Row(
          children: [
            if (isPickingImage)
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primaryVariant,
                ),
              )
            else if (currentImage != null)
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: colors.onBoardingIndicator,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100.r),
                    child: Image.file(
                      currentImage,
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colors.onBoardingIndicator,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors(context).primaryVariant,
                  size: 20.w,
                ),
              ),
            20.horizontalSpace,
            Text(
              AppStrings.serviceImage,
              style: AppTextStyles.text14w500(color: colors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
