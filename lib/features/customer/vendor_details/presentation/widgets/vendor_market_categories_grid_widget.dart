import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/vendor_details/presentation/riverpod/vendor_details_provider.dart';

class VendorMarketCategoriesGridWidget extends StatelessWidget {
  const VendorMarketCategoriesGridWidget({
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
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        sliver: SliverGrid(
          delegate: SliverChildBuilderDelegate(
            (context, _) => Shimmer.fromColors(
              baseColor: colors.shimmerBase,
              highlightColor: colors.shimmerHighlight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
            ),
            childCount: 6,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 0.78,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
          ),
        ),
      );
    }

    if (state.categories.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.category_outlined, size: 56.sp, color: colors.textHint),
              12.verticalSpace,
              Text(
                'لا توجد فئات متاحة حالياً',
                style: AppTextStyles.text14w600(color: colors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final cat = state.categories[index];
            final bool isOffers = cat.id == -999;
            final String imageUrl = _imageUrl(cat.photo);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (isOffers) {
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
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: isOffers ? colors.secondary.withValues(alpha: 0.6) : colors.border.withValues(alpha: 0.8),
                      width: isOffers ? 1.5 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isOffers ? colors.secondary.withValues(alpha: 0.12) : colors.shadow.withValues(alpha: 0.04),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(padding: EdgeInsets.all(2.w),
                        width: 58.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: isOffers ? Colors.orange.withValues(alpha: 0.12) : colors.containerBackground,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isOffers ? Colors.orange.withValues(alpha: 0.3) : colors.divider ,
                            width:isOffers? 1.0:.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9.r),
                          child: isOffers
                              ? Icon(Icons.local_fire_department_rounded, size: 28.sp, color: Colors.deepOrange)
                              : imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(color: colors.shimmerBase),
                                      errorWidget: (_, __, ___) => Icon(Icons.shopping_bag_outlined, size: 24.sp, color: colors.primary),
                                    )
                                  : Icon(Icons.shopping_bag_outlined, size: 24.sp, color: colors.primary),
                        ),
                      ),
                      4.verticalSpace,
                       Padding(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        child: Text(
                          cat.name ?? '',
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            fontWeight: FontWeight.bold,
                            color: isOffers ? Colors.deepOrange : colors.textPrimary,
                            fontFamily: 'Cairo',
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          childCount: state.categories.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.9,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
        ),
      ),
    );
  }
}
