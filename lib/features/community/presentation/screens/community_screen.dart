import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          AppStrings.community,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(15.w),
        itemCount: 3,
        separatorBuilder: (context, index) => 15.verticalSpace,
        itemBuilder: (context, index) {
          return _buildPostCard(context);
        },
      ),
    );
  }

  Widget _buildPostCard(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20.r,
                  backgroundImage: const AssetImage('assets/image/logo.png'),
                ),
                10.horizontalSpace,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.userNamePlaceholder,
                      style: AppTextStyles.text14w600(color: colors.textPrimary),
                    ),
                    Text(
                      AppStrings.twoHoursAgoMsg,
                      style: AppTextStyles.text10w400(color: colors.textHint),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              '${AppStrings.greatExperienceReviewMsg} 😍',
              style: AppTextStyles.text12w400(color: colors.textPrimary),
            ),
          ),
          10.verticalSpace,
          ClipRRect(
            borderRadius: BorderRadius.circular(0),
            child: Image.asset(
              'assets/image/logo.png',
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                _buildActionItem(Icons.favorite_border, '24'),
                20.horizontalSpace,
                _buildActionItem(Icons.chat_bubble_outline, '5'),
                const Spacer(),
                const Icon(Icons.share_outlined, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        5.horizontalSpace,
        Text(
          count,
          style: TextStyle(color: Colors.grey, fontSize: 12.sp),
        ),
      ],
    );
  }
}
