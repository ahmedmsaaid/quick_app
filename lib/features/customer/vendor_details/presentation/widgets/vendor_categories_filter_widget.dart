import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/vendor_details/presentation/riverpod/vendor_details_provider.dart';

class VendorCategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  VendorCategoriesHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 4 : 0,
      color: AppColors(context).surface,
      child: child,
    );
  }

  @override
  double get minExtent => 52.h;
  @override
  double get maxExtent => 52.h;
  @override
  bool shouldRebuild(covariant VendorCategoriesHeaderDelegate old) => old.child != child;
}

class VendorCategoriesFilterWidget extends StatelessWidget {
  const VendorCategoriesFilterWidget({
    super.key,
    required this.state,
    required this.notifier,
    required this.colors,
    required this.onTapOffers,
  });

  final VendorDetailsState state;
  final VendorDetailsNotifier notifier;
  final AppColors colors;
  final VoidCallback onTapOffers;

  String _imageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${ApiConstants.streamUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    if (state.categoriesStatus == VendorDetailsStatus.loading) {
      return SizedBox(
        height: 52.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, __) => 10.horizontalSpace,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Container(
              width: 100.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ),
        ),
      );
    }

    if (state.categories.isEmpty) return const SizedBox(height: 52.0);

    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        scrollDirection: Axis.horizontal,
        itemCount: state.categories.length,
        separatorBuilder: (_, __) => 10.horizontalSpace,
        itemBuilder: (_, i) {
          final CategoryDto cat = state.categories[i];
          final bool selected = state.selectedCategory?.id == cat.id;
          final bool isOffersCategory = cat.id == -999;
          final String imageUrl = _imageUrl(cat.photo);

          return GestureDetector(
            onTap: () {
              if (isOffersCategory) {
                onTapOffers();
              } else {
                context.pushNamed(
                  AppRoutes.products,
                  arguments: {
                    'category': cat,
                    'categoriesList': state.categories.where((c) => c.id != -999).toList(),
                  },
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: selected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: selected ? colors.primary : colors.border.withValues(alpha: 0.6),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [BoxShadow(color: colors.primary.withValues(alpha: 0.25), blurRadius: 6, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 22.r,
                    height: 22.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? Colors.white24
                          : (isOffersCategory ? Colors.orange.withValues(alpha: 0.15) : colors.containerBackground),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(11.r),
                      child: isOffersCategory
                          ? Icon(
                              Icons.local_fire_department_rounded,
                              size: 13.sp,
                              color: selected ? Colors.white : Colors.deepOrange,
                            )
                          : imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: colors.shimmerBase),
                                  errorWidget: (_, __, ___) => Icon(
                                    Icons.fastfood_rounded,
                                    size: 12.sp,
                                    color: selected ? Colors.white : colors.textSecondary,
                                  ),
                                )
                              : Icon(
                                  Icons.fastfood_rounded,
                                  size: 12.sp,
                                  color: selected ? Colors.white : colors.textSecondary,
                                ),
                    ),
                  ),
                  8.horizontalSpace,
                  Text(
                    cat.name ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: selected ? Colors.white : colors.textSecondary,
                      fontFamily: 'Cairo',
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
}
