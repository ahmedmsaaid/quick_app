import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/vendor_details/presentation/riverpod/vendor_details_provider.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_product_card_widget.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_offers_section_widget.dart';

class VendorSelectedCategoryHeaderWidget extends StatelessWidget {
  const VendorSelectedCategoryHeaderWidget({
    super.key,
    required this.colors,
    required this.state,
    required this.notifier,
  });

  final AppColors colors;
  final VendorDetailsState state;
  final VendorDetailsNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            InkWell(
              onTap: () => notifier.selectCategory(null),
              borderRadius: BorderRadius.circular(20.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.grid_view_rounded, size: 15.sp, color: colors.primary),
                    5.horizontalSpace,
                    Text('جميع الفئات', style: AppTextStyles.text12w700(color: colors.primary)),
                  ],
                ),
              ),
            ),
            10.horizontalSpace,
            Expanded(
              child: Text(
                'فئة: ${state.selectedCategory!.name ?? ""}',
                style: AppTextStyles.text14w700(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VendorOffersContentWidget extends StatelessWidget {
  const VendorOffersContentWidget({
    super.key,
    required this.isLoading,
    required this.offers,
    required this.colors,
  });

  final bool isLoading;
  final List<OfferDto> offers;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: const VendorShimmerListWidget(),
      );
    }
    if (offers.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_offer_outlined, size: 56.sp, color: colors.textHint),
              12.verticalSpace,
              Text('لا توجد عروض حصرية حالياً', style: AppTextStyles.text14w600(color: colors.textSecondary)),
            ],
          ),
        ),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => VendorOfferCardWidget(offer: offers[i], colors: colors),
          childCount: offers.length,
        ),
      ),
    );
  }
}

class VendorProductsContentWidget extends StatelessWidget {
  const VendorProductsContentWidget({
    super.key,
    required this.isMarket,
    required this.state,
    required this.notifier,
    required this.colors,
    required this.vendorId,
    this.isClosed = false,
    this.isBusy = false,
  });

  final bool isMarket;
  final VendorDetailsState state;
  final VendorDetailsNotifier notifier;
  final AppColors colors;
  final int vendorId;
  final bool isClosed;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    if (state.productsStatus == VendorDetailsStatus.loading) {
      return SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        sliver: isMarket ? const VendorShimmerGridWidget() : const VendorShimmerListWidget(),
      );
    }
    if (state.productsStatus == VendorDetailsStatus.error) {
      return SliverFillRemaining(
        child: VendorDetailsErrorWidget(
          message: state.errorMessage,
          onRetry: () => notifier.loadProducts(categoryId: state.selectedCategory?.id),
        ),
      );
    }
    if (state.products.isEmpty) {
      return SliverFillRemaining(
        child: VendorEmptyProductsWidget(colors: colors),
      );
    }
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => isMarket
              ? VendorMarketProductCardWidget(product: state.products[i], colors: colors, vendorId: vendorId, isClosed: isClosed, isBusy: isBusy)
              : VendorRestaurantProductCardWidget(product: state.products[i], colors: colors, vendorId: vendorId, isClosed: isClosed, isBusy: isBusy),
          childCount: state.products.length,
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: isMarket ? 0.68 : 0.9,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
        ),
      ),
    );
  }
}

class VendorDetailsErrorWidget extends StatelessWidget {
  const VendorDetailsErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 56.sp, color: colors.textHint),
          16.verticalSpace,
          Text(
            message ?? 'حدث خطأ',
            style: AppTextStyles.text14w600(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          20.verticalSpace,
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary),
          ),
        ],
      ),
    );
  }
}

class VendorEmptyProductsWidget extends StatelessWidget {
  const VendorEmptyProductsWidget({super.key, required this.colors});

  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inventory_2_outlined, size: 56.sp, color: colors.textHint),
          12.verticalSpace,
          Text(
            'لا توجد منتجات في هذه الفئة',
            style: AppTextStyles.text14w600(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class VendorShimmerGridWidget extends StatelessWidget {
  const VendorShimmerGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, _) => Shimmer.fromColors(
          baseColor: colors.shimmerBase,
          highlightColor: colors.shimmerHighlight,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        childCount: 6,
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
    );
  }
}

class VendorShimmerListWidget extends StatelessWidget {
  const VendorShimmerListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, __) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Container(
              height: 110.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ),
        ),
        childCount: 5,
      ),
    );
  }
}
