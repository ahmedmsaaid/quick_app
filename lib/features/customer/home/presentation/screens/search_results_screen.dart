import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/utils/assets/app_icons.dart';
import 'package:base_app/core/widgets/custome_svg_image.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/product_search_provider.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
    Future.microtask(() {
      ref.read(productSearchProvider.notifier).search(widget.query);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final searchState = ref.watch(productSearchProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: CustomTextField(
          controller: _searchController,
          hintText: AppStrings.search,
          prefixIcon: Padding(
            padding: EdgeInsets.all(12.r),
            child: CustomSVGImage(asset: AppIcons.searchIcon, color: colors.textHint),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              ref.read(productSearchProvider.notifier).search(value.trim());
            }
          },
        ),
        titleSpacing: 0,
        actions: [15.horizontalSpace],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              '${AppStrings.searchResultsForTitle} "${_searchController.text}"',
              style: AppTextStyles.text14w600(color: colors.textSecondary),
            ),
          ),
          Expanded(
            child: _buildBody(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductSearchState state) {
    final colors = AppColors(context);

    if (state.status == ProductSearchStatus.loading) {
      return const LoadingButton();
    }

    if (state.status == ProductSearchStatus.error) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: colors.error),
              10.verticalSpace,
              Text(
                state.errorMessage ?? AppStrings.errorOccurred,
                style: AppTextStyles.text14w500(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              15.verticalSpace,
              ElevatedButton(
                onPressed: () {
                  ref.read(productSearchProvider.notifier).search(_searchController.text);
                },
                child: Text(AppStrings.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    if (state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.sp, color: colors.textHint),
            10.verticalSpace,
            Text(
              AppStrings.noResults,
              style: AppTextStyles.text16w600(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: state.products.length,
      separatorBuilder: (context, index) => 15.verticalSpace,
      itemBuilder: (context, index) {
        final product = state.products[index];
        return _buildSearchResultItem(context, product);
      },
    );
  }

  Widget _buildSearchResultItem(BuildContext context, ProductDetailDto product) {
    final colors = AppColors(context);
    final String? photo = product.photo;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.storeProductDetailsScreen,
        arguments: product,
      ),
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 70.w,
                      height: 70.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 70.w,
                        height: 70.h,
                        color: colors.border.withValues(alpha: 0.5),
                      ),
                      errorWidget: (context, url, error) => Image.asset('assets/image/logo.png', width: 70.w, height: 70.h, fit: BoxFit.cover),
                    )
                  : Image.asset('assets/image/logo.png', width: 70.w, height: 70.h, fit: BoxFit.cover),
            ),
            15.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name ?? '',
                    style: AppTextStyles.text14w600(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  5.verticalSpace,
                  Text(
                    product.description ?? '',
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  8.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.hasDiscount ? (product.price * (1 - product.discountPercentage / 100)).toStringAsFixed(0) : product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                        style: AppTextStyles.text14w700(color: colors.primary),
                      ),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          4.horizontalSpace,
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: AppTextStyles.text12w600(color: colors.textPrimary)!,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            10.horizontalSpace,
            Icon(
              Icons.arrow_forward_ios,
              size: 14.sp,
              color: colors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}
