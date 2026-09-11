import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/vendor_details/presentation/riverpod/vendor_details_provider.dart';

class VendorCategoriesHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  VendorCategoriesHeaderDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      elevation: overlapsContent ? 3 : 0,
      color: AppColors(context).surface,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors(context).surface,
          border: Border(
            bottom: BorderSide(
              color: AppColors(context).border.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  double get minExtent => 46.h;
  @override
  double get maxExtent => 46.h;
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

  void _showCategoriesBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            14.verticalSpace,
            Text(
              'أقسام القائمة 📋',
              style: AppTextStyles.text16w700(color: colors.textPrimary),
            ),
            12.verticalSpace,
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: state.categories.length,
                separatorBuilder: (_, __) => Divider(
                  color: colors.border.withValues(alpha: 0.4),
                  height: 1,
                ),
                itemBuilder: (ctx, i) {
                  final cat = state.categories[i];
                  final bool selected = state.selectedCategory?.id == cat.id;
                  final bool isOffers = cat.id == -999;
                  final bool isAll = cat.id == -888;
                  final String displayName = isAll
                      ? 'اختيارات على ذوقك'
                      : (cat.name ?? '');

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? colors.primary.withValues(alpha: 0.15)
                            : colors.containerBackground,
                      ),
                      child: Center(
                        child: isOffers
                            ? Text('🔥', style: TextStyle(fontSize: 14.sp))
                            : (isAll
                                ? Icon(Icons.star_rounded, size: 18.sp, color: colors.primary)
                                : Icon(Icons.fastfood_rounded, size: 16.sp, color: colors.textSecondary)),
                      ),
                    ),
                    title: Text(
                      displayName,
                      style: AppTextStyles.text14w600(
                        color: selected ? colors.primary : colors.textPrimary,
                      ),
                    ),
                    trailing: selected
                        ? Icon(Icons.check_circle_rounded, color: colors.primary, size: 20.sp)
                        : Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: colors.textSecondary),
                    onTap: () {
                      Navigator.pop(ctx);
                      if (isOffers) {
                        onTapOffers();
                      } else {
                        notifier.selectCategory(cat);
                      }
                    },
                  );
                },
              ),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.categoriesStatus == VendorDetailsStatus.loading) {
      return SizedBox(
        height: 46.h,
        child: ListView.separated(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, __) => 16.horizontalSpace,
          itemBuilder: (_, __) => Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Container(
              width: 80.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      );
    }

    if (state.categories.isEmpty) return const SizedBox(height: 46.0);

    return SizedBox(
      height: 46.h,
      child: Row(
        children: [
          // 1. Horizontal Tab Categories
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              scrollDirection: Axis.horizontal,
              itemCount: state.categories.length,
              separatorBuilder: (_, __) => 18.horizontalSpace,
              itemBuilder: (_, i) {
                final CategoryDto cat = state.categories[i];
                final bool selected = state.selectedCategory?.id == cat.id;
                final bool isOffersCategory = cat.id == -999;
                final bool isAllCategory = cat.id == -888;

                final String label = isAllCategory
                    ? 'اختيارات على ذوقك'
                    : (cat.name ?? '');

                return GestureDetector(
                  onTap: () {
                    if (isOffersCategory) {
                      onTapOffers();
                    } else {
                      notifier.selectCategory(cat);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 6.h),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAllCategory || isOffersCategory) ...[
                              Text(
                                '🔥 ',
                                style: TextStyle(fontSize: 14.sp),
                              ),
                            ],
                            Text(
                              label,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                                color: selected ? colors.textPrimary : colors.textSecondary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Underline indicator for active tab (matching screenshot)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 3.h,
                        width: selected ? 32.w : 0,
                        decoration: BoxDecoration(
                          color: selected ? colors.textPrimary : Colors.transparent,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 2. Trailing Menu Icon `≡` (Left in RTL)
          Padding(
            padding: EdgeInsetsDirectional.only(end: 12.w),
            child: GestureDetector(
              onTap: () => _showCategoriesBottomSheet(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: colors.containerBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.menu_rounded,
                  size: 20.sp,
                  color: colors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
