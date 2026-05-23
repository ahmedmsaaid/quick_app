import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/utils/extensions.dart';
import '../../../../core/routes/app_routes.dart';

class VendorListScreen extends StatelessWidget {
  const VendorListScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final bool isSupermarket = title == AppStrings.quickMarketCategory;

    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrow_Back(),
        title: Text(
          title,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (!isSupermarket) _buildFilterChips(context),
          Expanded(
            child: isSupermarket 
                ? _buildSupermarketCategories(context)
                : _buildRestaurantsGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final filters = [
      AppStrings.allFilter,
      AppStrings.topRatedFilter,
      AppStrings.fastestDeliveryFilter,
      AppStrings.exclusiveOffersFilter,
      AppStrings.nearestFilter
    ];
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => 10.horizontalSpace,
        itemBuilder: (context, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: index == 0 ? AppColors(context).primary : AppColors(context).surface,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: index == 0 ? Colors.transparent : AppColors(context).border),
            ),
            child: Text(
              filters[index],
              style: AppTextStyles.text12w600(color: index == 0 ? Colors.white : AppColors(context).textSecondary),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantsGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            context.pushNamed(AppRoutes.providerProductDetailsScreen, arguments: false);
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors(context).surface,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors(context).shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                    child: Image.asset(
                      'assets/image/logo.png',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppStrings.quickBurgerRestaurant} #$index',
                        style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      5.verticalSpace,
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14.sp),
                          2.horizontalSpace,
                          Text('4.8', style: AppTextStyles.text12w400(color: AppColors(context).textSecondary)),
                          const Spacer(),
                          Text('15-25 ${AppStrings.minute}', style: AppTextStyles.text10w500(color: AppColors(context).primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSupermarketCategories(BuildContext context) {
    final categories = [
      {'name': AppStrings.dairyLabel, 'icon': '🥛'},
      {'name': AppStrings.vegetablesLabel, 'icon': '🥦'},
      {'name': AppStrings.cannedFoodLabel, 'icon': '🥫'},
      {'name': AppStrings.beveragesLabel, 'icon': '🥤'},
      {'name': AppStrings.detergentsLabel, 'icon': '🧼'},
      {'name': AppStrings.bakeryLabel, 'icon': '🍞'},
    ];

    return Column(
      children: [
        // One Supermarket Header
        Container(
          margin: EdgeInsets.all(20.w),
          padding: EdgeInsets.all(15.r),
          decoration: BoxDecoration(
            color: AppColors(context).primary,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: Colors.white,
                child: Icon(Icons.shopping_cart, color: AppColors(context).primary),
              ),
              15.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.appName} ${AppStrings.categoryMakeup}',
                      style: AppTextStyles.text16w700(color: Colors.white),
                    ),
                    Text(
                      AppStrings.supermarketSubtitleMsg,
                      style: AppTextStyles.text12w400(color: Colors.white.withOpacity(0.9)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  context.pushNamed(AppRoutes.providerProductDetailsScreen, arguments: true);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors(context).surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors(context).border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(categories[index]['icon']!, style: TextStyle(fontSize: 30.sp)),
                      10.verticalSpace,
                      Text(
                        categories[index]['name']!,
                        style: AppTextStyles.text12w600(color: AppColors(context).textPrimary),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CustomArrow_Back extends StatelessWidget {
  const CustomArrow_Back({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomArrowBack();
  }
}
