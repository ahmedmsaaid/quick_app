import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/utils/extensions.dart';
import '../../../../core/routes/app_routes.dart';

class VendorDetailsScreen extends StatefulWidget {
  const VendorDetailsScreen({super.key, this.isMarket = false});

  final bool isMarket;

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  int _selectedCategory = 0;
  
  final List<String> _restaurantCategories = [
    AppStrings.mostOrderedLabel,
    AppStrings.savingOffersLabel,
    AppStrings.beefBurgerLabel,
    AppStrings.chickenBurgerLabel,
    AppStrings.appetizersLabel,
    AppStrings.beveragesLabel
  ];
  final List<String> _marketCategories = [
    AppStrings.dairyLabel,
    AppStrings.vegetablesLabel,
    AppStrings.cannedFoodLabel,
    AppStrings.detergentsLabel,
    AppStrings.beveragesLabel,
    AppStrings.bakeryLabel
  ];

  @override
  Widget build(BuildContext context) {
    final categories = widget.isMarket ? _marketCategories : _restaurantCategories;

    return Scaffold(
      backgroundColor: AppColors(context).background,
      appBar: AppBar(
        backgroundColor: AppColors(context).surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          widget.isMarket ? AppStrings.browseCategoriesLabel : AppStrings.restaurantDetailsLabel,
          style: AppTextStyles.text18w700(color: AppColors(context).textPrimary),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          10.verticalSpace,
          _buildCategoriesFilter(categories),
          15.verticalSpace,
          Expanded(
            child: widget.isMarket 
                ? _buildMarketProductGrid(context) 
                : _buildRestaurantProductList(context),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomCartBar(context),
    );
  }

  Widget _buildCategoriesFilter(List<String> categories) {
    return SizedBox(
      height: 45.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => 10.horizontalSpace,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == index;
          return InkWell(
            onTap: () => setState(() => _selectedCategory = index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors(context).primary : AppColors(context).surface,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(color: isSelected ? Colors.transparent : AppColors(context).border),
              ),
              child: Text(
                categories[index],
                style: AppTextStyles.text14w600(
                  color: isSelected ? Colors.white : AppColors(context).textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Restaurant Style: Horizontal List Cards ---
  Widget _buildRestaurantProductList(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 8,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: AppColors(context).surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: AppColors(context).border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.classicBurgerDoubleTitle} #${index + 1}',
                      style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
                    ),
                    5.verticalSpace,
                    Text(
                      AppStrings.burgerDescriptionMsg,
                      style: AppTextStyles.text12w400(color: AppColors(context).textSecondary),
                      maxLines: 2,
                    ),
                    12.verticalSpace,
                    Text(
                      '8,500 ${AppStrings.currency}',
                      style: AppTextStyles.text14w700(color: AppColors(context).primary),
                    ),
                  ],
                ),
              ),
              15.horizontalSpace,
              _buildProductImageWithAdd(context),
            ],
          ),
        );
      },
    );
  }

  // --- Market Style: Vertical Grid Cards ---
  Widget _buildMarketProductGrid(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors(context).surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: AppColors(context).border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildProductImageWithAdd(context, isFullWidth: true)),
              Padding(
                padding: EdgeInsets.all(10.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${AppStrings.foodProductLabel} #${index + 1}',
                      style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.verticalSpace,
                    Text(
                      '3,500 ${AppStrings.currency}',
                      style: AppTextStyles.text14w700(color: AppColors(context).primary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImageWithAdd(BuildContext context, {bool isFullWidth = false}) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: Image.asset(
            'assets/image/logo.png',
            width: isFullWidth ? double.infinity : 90.w,
            height: isFullWidth ? double.infinity : 90.h,
            fit: BoxFit.cover,
          ),
        ),
        InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.addedToCartSuccessMsg),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(5.r),
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: AppColors(context).primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors(context).shadow, blurRadius: 4)],
            ),
            child: Icon(Icons.add, color: Colors.white, size: 18.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCartBar(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, -5)),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => context.pushNamed(AppRoutes.cartScreen),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors(context).primary,
          minimumSize: Size(double.infinity, 55.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8.r)),
              child: Text('2', style: AppTextStyles.text14w700(color: Colors.white)),
            ),
            Text(AppStrings.viewCartBtn, style: AppTextStyles.text16w700(color: Colors.white)),
            Text('17,000 ${AppStrings.currency}', style: AppTextStyles.text14w700(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}
