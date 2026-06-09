import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';

class SpecialOfferDetailsScreen extends StatelessWidget {
  const SpecialOfferDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.h,
            pinned: true,
            leading: const CustomArrowBack(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/image/logo.png', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(color: colors.error, borderRadius: BorderRadius.circular(5.r)),
                        child: Text(AppStrings.discount50Label, style: AppTextStyles.text12w700(color: Colors.white)),
                      ),
                      10.horizontalSpace,
                      Text(AppStrings.limitedTimeOfferLabel, style: AppTextStyles.text12w400(color: colors.error)),
                    ],
                  ),
                  15.verticalSpace,
                  Text(
                    AppStrings.quickFamilyMealTitle, 
                    style: AppTextStyles.text24w700(color: colors.textPrimary),
                  ),
                  10.verticalSpace,
                  Text(
                    AppStrings.quickFamilyMealDescMsg,
                    style: AppTextStyles.text14w400(color: colors.textSecondary),
                  ),
                  25.verticalSpace,
                  Text(AppStrings.offerContentsLabel, style: AppTextStyles.text16w700(color: colors.textPrimary)),
                  15.verticalSpace,
                  _buildOfferItem(context, AppStrings.offerItemBurger),
                  _buildOfferItem(context, AppStrings.offerItemFries),
                  _buildOfferItem(context, AppStrings.offerItemCola),
                  30.verticalSpace,
                  Divider(color: colors.divider),
                  30.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${AppStrings.originalPriceLabel} 40,000 ${AppStrings.iqdCurrency}', 
                            style: AppTextStyles.text14w400(color: colors.textHint).copyWith(decoration: TextDecoration.lineThrough),
                          ),
                          Text(
                            '20,000 ${AppStrings.iqdCurrency}',
                            style: AppTextStyles.text22w700(color: colors.primary),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 150.w,
                        child: CustomAppButton(
                          text: AppStrings.orderNowBtn,
                          onPressed: () {
                             Navigator.of(context).pushNamed(AppRoutes.cartScreen);
                          },
                        ),
                      ),
                    ],
                  ),
                  50.verticalSpace,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors(context).success, size: 20.sp),
          10.horizontalSpace,
          Text(text, style: AppTextStyles.text14w500(color: AppColors(context).textPrimary)),
        ],
      ),
    );
  }
}
