import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/see_all_widget.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';

class HomeMostRequested extends ConsumerWidget {
  const HomeMostRequested({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final homeState = ref.watch(homeProvider);

    if (homeState.popularProductsStatus == HomeStatus.loading &&
        homeState.popularProducts.isEmpty) {
      return SizedBox(
        height: 180.h,
        child: const Center(child: LoadingButton()),
      );
    }

    final products = homeState.popularProducts;

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeeAllWidget(
          title: 'الأكثر طلباً',
          onTap: () {
            context.pushNamed(
              AppRoutes.StoreScreen,
              arguments: 'الأكثر طلباً',
            );
          },
        ),
        SizedBox(
          height: 210.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final String? photoKey = product.photo;
              final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
                  ? (photoKey.startsWith('http')
                      ? photoKey
                      : '${ApiConstants.streamUrl}$photoKey')
                  : '';

              return Container(
                width: 130.w,
                margin: EdgeInsets.only(left: 12.w),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.storeProductDetailsScreen,
                      arguments: product,
                    );
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: colors.background,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: photoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: colors.shimmerBase,
                                      ),
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.fastfood_rounded,
                                        color: colors.textHint,
                                        size: 32.sp,
                                      ),
                                    )
                                  : Icon(
                                      Icons.fastfood_rounded,
                                      color: colors.textHint,
                                      size: 32.sp,
                                    ),
                            ),
                          ),
                        ),
                        8.verticalSpace,

                        // Product Name
                        Text(
                          product.name ?? '',
                          style: AppTextStyles.text12w700(
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        2.verticalSpace,

                        // Description/Size (Virtual description like "بيج كينج" or rating)
                        Text(
                          product.description ?? 'حجم كبير',
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: colors.textHint,
                            fontFamily: 'Cairo',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        8.verticalSpace,

                        // Price
                        Text(
                          '${product.price.toStringAsFixed(1)} ج.م',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: colors.secondary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
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
