import 'dart:async';
import 'package:base_app/core/utils/assets/app_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/see_all_widget.dart';
import 'package:base_app/core/utils/extensions.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/location_bottom_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerPage = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    _startBannerTimer();
  }

  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        int nextPage = (_currentBannerPage + 1) % 3;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildCustomHeader(context),
            20.verticalSpace,
            _buildCategoriesSection(context),
            20.verticalSpace,
            _buildFeaturedRestaurantsSection(context),
            30.verticalSpace,
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppIcons.homeContainer),
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.only(

        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
             Padding(
              padding: EdgeInsets.only(right: 20.w,left: 20, top: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _showLocationSheet(context),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.white, size: 18.sp),
                        6.horizontalSpace,
                        Text(
                          AppStrings.homeLocation,
                          style: AppTextStyles.text18w500(color: Colors.white),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 18.sp),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => context.pushNamed(AppRoutes.notifications),
                    child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28.sp),
                  ),
                ],
              ),
            ),

             Image.asset(AppIcons.homeLogo, height: 100.h),
            

             Padding(
               padding: EdgeInsets.only(right: 20.w,left: 20, top: 10.h),
              child: Container(
                height: 50.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        textAlign: TextAlign.right,
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            context.pushNamed(AppRoutes.searchResults, arguments: value);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: AppStrings.whereToDeliver,
                          hintStyle: AppTextStyles.text14w500(color: colors.textHint),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Icon(Icons.search, color: colors.textHint, size: 22.sp),
                    ),
                  ],
                ),
              ),
            ),
            12.verticalSpace,
             _buildModernBanner(context),

          ],
        ),
      ),
    );
  }

  Widget _buildModernBanner(BuildContext context) {
    return SizedBox(
      height: 150.h,
      child: PageView.builder(
        controller: _bannerController,
        onPageChanged: (index) {
          setState(() {
            _currentBannerPage = index;
          });
        },
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(
              color: const Color(0xFF002B2B).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.tastiestMeals,
                                style: AppTextStyles.text20w700(color: Colors.white),
                              ),
                              Text(
                                AppStrings.fromNearestPlace,
                                style: AppTextStyles.text14w400(color: Colors.white70),
                                textAlign: TextAlign.right,
                              ),
                              12.verticalSpace,
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF8C00),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                                  padding: EdgeInsets.symmetric(horizontal: 25.w),
                                  elevation: 0,
                                ),
                                child: Text(AppStrings.orderNow, style: AppTextStyles.text12w700()),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Image.asset(
                          'assets/image/logo.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (dotIndex) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 2.5.w),
                          width: dotIndex == _currentBannerPage ? 15.w : 5.w,
                          height: 4.h,
                          decoration: BoxDecoration(
                            color: dotIndex == _currentBannerPage ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LocationBottomSheet(),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final colors = AppColors(context);
    final categories = [
      {'name': AppStrings.restaurantsCategory, 'icon': 'assets/icons/fast-food.png'},
      {'name': AppStrings.quickMarketCategory, 'icon': 'assets/icons/img.png'},
    ];

    return Column(
      children: [
        SeeAllWidget(
          title: AppStrings.categories,
          onTap: () {},
        ),
        10.verticalSpace,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: categories.map((cat) => Expanded(
              child: InkWell(
                onTap: () => context.pushNamed(AppRoutes.StoreScreen, arguments: cat['name']),
                child: Column(
                  children: [
                    Container(
                      width: 90.w,
                      height: 90.h,
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(22.r),
                      ),
                      child: Image.asset(cat['icon'] as String, fit: BoxFit.contain),
                    ),
                    10.verticalSpace,
                    Text(
                      cat['name'] as String,
                      style: AppTextStyles.text13w700(color: colors.textPrimary),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedRestaurantsSection(BuildContext context) {
    final colors = AppColors(context);

    return Column(
      children: [
        SeeAllWidget(
          title: AppStrings.featuredRestaurants,
          onTap: () {},
        ),
        10.verticalSpace,
        SizedBox(
          height: 230.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            reverse: true,
            separatorBuilder: (context, index) => 15.horizontalSpace,
            itemBuilder: (context, index) {
              return Container(
                width: 170.w,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                      child: Image.asset(
                        'assets/image/logo.png',
                        height: 120.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(12.r),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            index == 0 ? "بيتزا هت" : "كرسبي تشيكن",
                            style: AppTextStyles.text14w700(color: colors.textPrimary),
                          ),
                          10.verticalSpace,
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 16.sp),
                                  4.horizontalSpace,
                                  Text("4.5", style: AppTextStyles.text12w600(color: colors.textPrimary)),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined, color: Colors.orange, size: 16.sp),
                                  4.horizontalSpace,
                                  Text("9-40 د", style: AppTextStyles.text10w400(color: colors.textSecondary)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
