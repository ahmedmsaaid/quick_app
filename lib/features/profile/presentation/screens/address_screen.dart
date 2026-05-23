import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.myAddressesTitle,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: 2,
        separatorBuilder: (context, index) => 15.verticalSpace,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.all(15.r),
            decoration: BoxDecoration(
              color: AppColors(context).surface,
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(color: AppColors(context).border),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: AppColors(context).primary, size: 28.sp),
                15.horizontalSpace,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        index == 0 ? AppStrings.homeAddressLabel : AppStrings.workAddressLabel,
                        style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
                      ),
                      Text(
                        AppStrings.cairoAddressPlaceholder,
                        style: AppTextStyles.text12w400(color: AppColors(context).textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit, color: AppColors(context).textSecondary),
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRoutes.addAddress);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors(context).primary,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.of(context).pushNamed(AppRoutes.addAddress);
        },
      ),
    );
  }
}
