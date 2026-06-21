import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/routes/app_router.dart';
import 'package:base_app/core/utils/extensions.dart';

class HomeTypeSegmentTab extends StatelessWidget {
  const HomeTypeSegmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Restaurant Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.pushNamed(
                  AppRoutes.StoreScreen,
                  arguments: VendorListArgs(
                    title: AppStrings.restaurantsCategory,
                    userRole: 0,
                  ),
                );
              },
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: colors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    children: [
                      // Accent line on side
                      Positioned(
                        left: isArabic ? null : 0,
                        right: isArabic ? 0 : null,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 5.w,
                          color: const Color(0xFFFF5F6D),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        child: Row(
                          children: [
                            isArabic ? const SizedBox.shrink() : 6.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.restaurantsCategory,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: colors.textPrimary,
                                      fontFamily: 'Cairo',
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  2.verticalSpace,
                                  Text(
                                    isArabic ? 'أشهى المأكولات' : 'Tastiest meals',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textSecondary,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            6.horizontalSpace,
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF5F6D).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '🍔',
                                style: TextStyle(fontSize: 20.sp),
                              ),
                            ),
                            isArabic ? 6.horizontalSpace : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          12.horizontalSpace,
          // Market Card
          Expanded(
            child: GestureDetector(
              onTap: () {
                context.pushNamed(
                  AppRoutes.StoreScreen,
                  arguments: VendorListArgs(
                    title: AppStrings.quickMarketCategory,
                    userRole: 1,
                  ),
                );
              },
              child: Container(
                height: 80.h,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: colors.border, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.r),
                  child: Stack(
                    children: [
                      // Accent line on side
                      Positioned(
                        left: isArabic ? null : 0,
                        right: isArabic ? 0 : null,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 5.w,
                          color: const Color(0xFF00B09B),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        child: Row(
                          children: [
                            isArabic ? const SizedBox.shrink() : 6.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    AppStrings.quickMarketCategory,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w800,
                                      color: colors.textPrimary,
                                      fontFamily: 'Cairo',
                                      height: 1.25,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  2.verticalSpace,
                                  Text(
                                    isArabic ? 'السوبرماركت والطلبات' : 'Supermarkets & needs',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w500,
                                      color: colors.textSecondary,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            6.horizontalSpace,
                            Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B09B).withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '🛒',
                                style: TextStyle(fontSize: 20.sp),
                              ),
                            ),
                            isArabic ? 6.horizontalSpace : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
