import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/favorites/presentation/riverpod/favorites_provider.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.favorites,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? _buildEmptyState(context, "لا توجد منتجات مفضلة بعد")
          : _buildFavoritesList(context, ref, favorites),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border_rounded, size: 80.sp, color: Colors.grey.withValues(alpha: 0.5)),
          20.verticalSpace,
          Text(
            message,
            style: AppTextStyles.text16w600(color: AppColors(context).textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(
    BuildContext context,
    WidgetRef ref,
    List<ProductDetailDto> favorites,
  ) {
    return ListView.separated(
      padding: EdgeInsets.all(20.r),
      itemCount: favorites.length,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        final product = favorites[index];
        final colors = AppColors(context);
        return Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: colors.border),
            boxShadow: [
              BoxShadow(
                color: colors.shadow,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name ?? '',
                      style: AppTextStyles.text14w600(
                        color: colors.textPrimary,
                      ),
                    ),
                    5.verticalSpace,
                    if (product.description != null && product.description!.isNotEmpty)
                      Text(
                        product.description!,
                        style: AppTextStyles.text12w400(
                          color: colors.textSecondary,
                        ),
                        maxLines: 2,
                      ),
                    12.verticalSpace,
                    Text(
                      '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                      style: AppTextStyles.text14w700(
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              15.horizontalSpace,
              _buildProductImage(context, ref, product),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductImage(
    BuildContext context,
    WidgetRef ref,
    ProductDetailDto product,
  ) {
    final colors = AppColors(context);
    final String imageUrl = (product.photo != null && product.photo!.isNotEmpty)
        ? (product.photo!.startsWith('http') ? product.photo! : '${ApiConstants.streamUrl}${product.photo}')
        : '';

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SizedBox(
            width: 90.w,
            height: 90.h,
            child: imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: colors.shimmerBase),
                    errorWidget: (_, __, ___) => Container(
                      color: colors.shimmerBase,
                      child: Icon(Icons.fastfood, color: colors.textHint),
                    ),
                  )
                : Container(
                    color: colors.shimmerBase,
                    child: Icon(Icons.fastfood, color: colors.textHint),
                  ),
          ),
        ),
        Positioned(
          top: 5.r,
          left: 5.r,
          child: InkWell(
            onTap: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(product);
            },
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: const BoxDecoration(
                color: Colors.black26,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_rounded,
                color: Colors.redAccent,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }


}
