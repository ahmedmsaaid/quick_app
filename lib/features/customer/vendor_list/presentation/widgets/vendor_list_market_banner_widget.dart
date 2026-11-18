import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/constans/app_config.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/vendor_list/presentation/widgets/vendor_banner_feature_item_widget.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class VendorListMarketBannerWidget extends StatelessWidget {
  final List<UserDto> vendors;

  const VendorListMarketBannerWidget({super.key, required this.vendors});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: AppConfig.enableQuickMarket
            ? () {
                final UserDto market31 = vendors.firstWhere(
                  (v) => v.id == 31,
                  orElse: () => UserDto(
                    id: 31,
                    name: AppStrings.quickMarketCategory,
                    role: 1,
                    status: 1,
                    rating: 5.0,
                    active: true,
                  ),
                );
                Navigator.pushNamed(
                  context,
                  AppRoutes.providerStoreScreen,
                  arguments: {
                    'vendor': market31,
                    'initialCategory': null,
                  },
                );
              }
            : null,
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          width: double.infinity,
          height: 200.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF033E3B),
                Color(0xFF09524D),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                Positioned(
                  right: -40.w,
                  bottom: -60.h,
                  child: Container(
                    width: 180.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFEE9C20).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -30.w,
                  top: -30.h,
                  child: CircleAvatar(
                    radius: 70.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Column(
                    children: [
                      // Top Row (Logo + Title & Subtitle + Action Badge)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo Box on Left
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: Image.asset(
                                'assets/image/logo.png',
                                width: 48.w,
                                height: 48.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Spacer(),
                            // Text on Right
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  AppStrings.quickMarketCategory,
                                  style: AppTextStyles.text22w700(
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                4.verticalSpace,
                                Text(
                                  AppStrings.allDailyNeedsInOnePlace,
                                  style: AppTextStyles.text11w500(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                8.verticalSpace,
                                // Crisp, clear action button
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 14.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppStrings.browseProductsBtn,
                                        style: AppTextStyles.text12w700(
                                          color: const Color(0xFF033E3B),
                                        ),
                                      ),
                                      6.horizontalSpace,
                                      Icon(
                                        Icons.arrow_forward_ios_rounded,
                                        color: const Color(0xFFEE9C20),
                                        size: 12.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Divider line above features
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.h),
                        height: 1.h,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),

                      // Features row (Bottom)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          VendorBannerFeatureItemWidget(
                            icon: Icons.verified_user,
                            label: AppStrings.qualityGuaranteed,
                          ),
                          Container(
                            width: 1.w,
                            height: 25.h,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          VendorBannerFeatureItemWidget(
                            icon: Icons.shopping_bag,
                            label: AppStrings.diverseProducts,
                          ),
                          Container(
                            width: 1.w,
                            height: 25.h,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          VendorBannerFeatureItemWidget(
                            icon: Icons.percent,
                            label: AppStrings.exclusiveOffersBadge,
                          ),
                          Container(
                            width: 1.w,
                            height: 25.h,
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                          VendorBannerFeatureItemWidget(
                            icon: Icons.motorcycle,
                            label: AppStrings.fastDelivery,
                          ),
                        ].reversed.toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
