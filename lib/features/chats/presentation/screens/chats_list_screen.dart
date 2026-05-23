import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          AppStrings.chats,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(20.w),
        itemCount: 5,
        separatorBuilder: (context, index) => Divider(color: colors.divider),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 25.r,
              backgroundColor: colors.divider,
              backgroundImage: const AssetImage('assets/image/logo.png'),
            ),
            title: Text(
              AppStrings.quickBurgerRestaurant,
              style: AppTextStyles.text14w600(color: colors.textPrimary),
            ),
            subtitle: Text(
              AppStrings.orderPreparingMsg,
              style: AppTextStyles.text12w400(color: colors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppStrings.mockTime,
                  style: AppTextStyles.text10w400(color: colors.textHint),
                ),
                5.verticalSpace,
                if (index == 0)
                  Container(
                    padding: EdgeInsets.all(5.r),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '1',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.chatDetailsScreen, arguments: AppStrings.quickBurgerRestaurant);
            },
          );
        },
      ),
    );
  }
}
