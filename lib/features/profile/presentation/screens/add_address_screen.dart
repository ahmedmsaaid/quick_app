import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';

class AddAddressScreen extends StatelessWidget {
  const AddAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.addNewAddressBtn,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Map Placeholder
            Container(
              height: 250.h,
              width: double.infinity,
              color: AppColors(context).containerBackground,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.map, size: 100.sp, color: AppColors(context).textDisabled),
                  Positioned(
                    bottom: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors(context).surface,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [BoxShadow(color: AppColors(context).shadow, blurRadius: 10)],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.my_location, color: AppColors(context).primary, size: 18.sp),
                          8.horizontalSpace,
                          Text(AppStrings.setLocOnMapLabel, style: AppTextStyles.text12w600(color: AppColors(context).textPrimary)),
                        ],
                      ),
                    ),
                  ),
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
                ],
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppStrings.addressDetailsLabel, style: AppTextStyles.text16w700(color: AppColors(context).textPrimary)),
                  20.verticalSpace,
                  CustomTextField(
                    hintText: AppStrings.addressNameHint,
                    prefixIcon: const Icon(Icons.label_outline),
                  ),
                  15.verticalSpace,
                  CustomTextField(
                    hintText: AppStrings.areaHint,
                    prefixIcon: const Icon(Icons.location_city),
                  ),
                  15.verticalSpace,
                  CustomTextField(
                    hintText: AppStrings.streetHint,
                    prefixIcon: const Icon(Icons.location_on_outlined),
                  ),
                  15.verticalSpace,
                  CustomTextField(
                    hintText: AppStrings.additionalNotesHint,
                    maxLines: 3,
                  ),
                  30.verticalSpace,
                  CustomAppButton(
                    text: AppStrings.saveAddressBtn,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(AppStrings.addressSavedSuccessMsg)),
                      );
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
