import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:base_app/core/routes/app_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/see_all_widget.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/core/exports/exports.dart';

class HomeFeaturedRestaurants extends ConsumerWidget {
  const HomeFeaturedRestaurants({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final homeState = ref.watch(homeProvider);

    if (homeState.restaurantsStatus == HomeStatus.loading) {
      return Column(
        children: [
          SeeAllWidget(
            title: AppStrings.featuredRestaurants,
            onTap: () {},
          ),
          12.verticalSpace,
          SizedBox(
            height: 250.h,
            child: const LoadingButton(),
          ),
        ],
      );
    }

    final restaurants = homeState.featuredRestaurants;
    if (restaurants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SeeAllWidget(
          title: AppStrings.featuredRestaurants,
          onTap: () {
            context.pushNamed(
              AppRoutes.StoreScreen,
              arguments: VendorListArgs(
                title: AppStrings.featuredRestaurants,
                userRole: 0,
              ),
            );
          },
        ),
        12.verticalSpace,
        Padding(
          padding:   EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            height: 255.h,
            child: ListView.separated(              padding: EdgeInsets.symmetric(horizontal: 20.w),

              scrollDirection: Axis.horizontal,
              itemCount: restaurants.length,
              reverse: true,
              separatorBuilder: (context, index) => 16.horizontalSpace,
              itemBuilder: (context, index) {
                final restaurant = restaurants[index];
                final String? photo = restaurant.photo ?? restaurant.avatar;
                final String imageUrl = (photo != null && photo.isNotEmpty)
                    ? (photo.startsWith('http')
                        ? photo
                        : '${ApiConstants.streamUrl}$photo')
                    : '';

                final screenW = MediaQuery.sizeOf(context).width;
                final cardW = screenW * 0.52;

                return GestureDetector(
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.providerProductDetailsScreen,
                      arguments: restaurant,
                    );
                  },
                  child: Container(
                    width: cardW,
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: colors.border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(23.r)),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                imageUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: imageUrl,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) => Container(
                                          color: colors.shimmerBase,
                                        ),
                                        errorWidget: (_, __, ___) => Container(
                                          color: colors.shimmerBase,
                                          child: Icon(Icons.storefront_rounded,
                                              size: 40.sp, color: colors.textHint),
                                        ),
                                      )
                                    : Container(
                                        color: colors.shimmerBase,
                                        child: Icon(Icons.storefront_rounded,
                                            size: 40.sp, color: colors.textHint),
                                      ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 50.h,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withValues(alpha: 0.55),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (restaurant.busy == true || !(restaurant.active ?? true))
                                  Positioned(
                                    top: 12.r,
                                    right: 12.r,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20.r),
                                      child: BackdropFilter(
                                        filter:
                                            ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.5),
                                            borderRadius: BorderRadius.circular(20.r),
                                            border: Border.all(
                                              color: Colors.white
                                                  .withValues(alpha: 0.15),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6.w,
                                                height: 6.w,
                                                decoration: BoxDecoration(
                                                  color: (restaurant.busy == true)
                                                      ? Colors.amber
                                                      : colors.error,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: (restaurant.busy == true)
                                                          ? Colors.amber
                                                          : colors.error,
                                                      blurRadius: 6,
                                                      spreadRadius: 2,
                                                    )
                                                  ],
                                                ),
                                              ),
                                              6.horizontalSpace,
                                              Text(
                                                (restaurant.busy == true)
                                                    ? 'مشغول'
                                                    : AppStrings.closedStatus,
                                                style: AppTextStyles.text10w700(
                                                    color: Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 10.r,
                                  left: 12.r,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: colors.surface,
                                      borderRadius: BorderRadius.circular(12.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.12),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        )
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded,
                                            color: colors.ratingActive,
                                            size: 14.sp),
                                        4.horizontalSpace,
                                        Text(
                                          restaurant.rating.toStringAsFixed(1),
                                          style: AppTextStyles.text11w700(
                                              color: colors.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: EdgeInsets.all(12.r),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      restaurant.name ?? '',
                                      style: AppTextStyles.text14w700(
                                          color: colors.textPrimary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    2.verticalSpace,
                                    Text(
                                      restaurant.description ??
                                          AppStrings.defaultRestaurantDesc,
                                      style: AppTextStyles.text11w400(
                                          color: colors.textSecondary),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.access_time_filled_rounded,
                                            color: colors.primary, size: 14.sp),
                                        4.horizontalSpace,
                                        Text(
                                          "15-25 ${AppStrings.minsSuffix}",
                                          style: AppTextStyles.text11w600(
                                              color: colors.textSecondary),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.w, vertical: 3.h),
                                      decoration: BoxDecoration(
                                        color: colors.tealLight,
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Text(
                                        AppStrings.fastDelivery,
                                        style: AppTextStyles.text10w700(
                                            color: colors.primary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
