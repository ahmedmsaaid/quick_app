import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key, required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: CustomTextField(
          hintText: query,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.r),
            child: CustomSVGImage(asset: AppIcons.searchIcon, color: colors.textHint),
          ),
        ),
        titleSpacing: 0,
        actions: [15.horizontalSpace],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              '${AppStrings.searchResultsForTitle} "$query"',
              style: AppTextStyles.text14w600(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: 4,
              separatorBuilder: (context, index) => 15.verticalSpace,
              itemBuilder: (context, index) {
                return _buildSearchResultItem(context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResultItem(BuildContext context, int index) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset('assets/image/logo.png', width: 70.w, height: 70.h),
          ),
          15.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${AppStrings.searchResultItemTitle} #$index', style: AppTextStyles.text14w600(color: colors.textPrimary)),
                5.verticalSpace,
                Text(AppStrings.searchResultDescMsg, style: AppTextStyles.text12w400(color: colors.textSecondary)),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 14.sp, 
            color: colors.textHint,
          ),
        ],
      ),
    );
  }
}
