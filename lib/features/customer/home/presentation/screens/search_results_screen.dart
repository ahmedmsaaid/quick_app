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
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/product_search_provider.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/search_history_provider.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key, required this.query});

  final String query;

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  late final TextEditingController _searchController;
  int _selectedFilterIndex = 0; // 0: All, 1: Vendors, 2: Products

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
            final query = value.trim();
            if (query.isNotEmpty) {
              ref.read(searchHistoryProvider.notifier).addQuery(query);
              ref.read(productSearchProvider.notifier).search(query);
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
    final searchHistory = ref.watch(searchHistoryProvider);

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

    if (state.products.isEmpty && state.vendors.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          children: [
            _buildSearchHistorySection(searchHistory, colors),
            Expanded(
              child: Center(
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
              ),
            ),
          ],
        ),
      );
    }

    final showVendors = (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) && state.vendors.isNotEmpty;
    final showProducts = (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) && state.products.isNotEmpty;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Persistent Search History Section
          _buildSearchHistorySection(searchHistory, colors),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(0, "الكل (${state.vendors.length + state.products.length})", colors),
                10.horizontalSpace,
                _buildFilterChip(1, "🏪 المطاعم والمتاجر (${state.vendors.length})", colors),
                10.horizontalSpace,
                _buildFilterChip(2, "🧺 المنتجات (${state.products.length})", colors),
              ],
            ),
          ),
          20.verticalSpace,

          // Stores & Restaurants Section
          if (showVendors) ...[
            Text(
              '🏪 المطاعم والمتاجر (${state.vendors.length})',
              style: AppTextStyles.text16w700(color: colors.textPrimary),
            ),
            12.verticalSpace,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.vendors.length,
              separatorBuilder: (_, __) => 12.verticalSpace,
              itemBuilder: (context, index) => _buildVendorResultItem(context, state.vendors[index]),
            ),
            25.verticalSpace,
          ],

          // Products Section
          if (showProducts) ...[
            Text(
              '🧺 المنتجات (${state.products.length})',
              style: AppTextStyles.text16w700(color: colors.textPrimary),
            ),
            12.verticalSpace,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.products.length,
              separatorBuilder: (_, __) => 12.verticalSpace,
              itemBuilder: (context, index) => _buildSearchResultItem(context, state.products[index]),
            ),
            25.verticalSpace,
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, AppColors colors) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(
        label,
        style: isSelected
            ? AppTextStyles.text12w600(color: Colors.white)
            : AppTextStyles.text12w600(color: colors.textSecondary),
      ),
      selected: isSelected,
      selectedColor: colors.primary,
      backgroundColor: colors.surface,
      onSelected: (_) => setState(() => _selectedFilterIndex = index),
    );
  }

  Widget _buildVendorResultItem(BuildContext context, UserDto vendor) {
    final colors = AppColors(context);
    final String? photo = vendor.photo ?? vendor.avatar;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';
    final roleTitle = vendor.role == 0 ? "مطعم" : "متجر / سوبرماركت";

    return InkWell(
      onTap: () => context.pushNamed(
        AppRoutes.providerProductDetailsScreen,
        arguments: vendor,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          vendor.name ?? 'متجر غير معنون',
                          style: AppTextStyles.text14w700(color: colors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          roleTitle,
                          style: AppTextStyles.text10w700(color: colors.primary),
                        ),
                      ),
                    ],
                  ),
                  6.verticalSpace,
                  Text(
                    vendor.description ?? vendor.phone ?? 'متاح للطلب الآن',
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
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
                      /*
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
                      */
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

  Widget _buildSearchHistorySection(List<String> history, AppColors colors) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 18.sp, color: colors.textSecondary),
                6.horizontalSpace,
                Text(
                  'سجل البحث',
                  style: AppTextStyles.text14w700(color: colors.textPrimary),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => ref.read(searchHistoryProvider.notifier).clearAll(),
              child: Text(
                'مسح الكل',
                style: AppTextStyles.text12w600(color: colors.error),
              ),
            ),
          ],
        ),
        10.verticalSpace,
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: history.map((item) {
            return Container(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: colors.border),
              ),
              child: InkWell(
                onTap: () {
                  _searchController.text = item;
                  ref.read(searchHistoryProvider.notifier).addQuery(item);
                  ref.read(productSearchProvider.notifier).search(item);
                },
                borderRadius: BorderRadius.circular(20.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: AppTextStyles.text12w500(color: colors.textPrimary),
                      ),
                      6.horizontalSpace,
                      GestureDetector(
                        onTap: () {
                          ref.read(searchHistoryProvider.notifier).removeQuery(item);
                        },
                        child: Icon(
                          Icons.close_rounded,
                          size: 14.sp,
                          color: colors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        20.verticalSpace,
      ],
    );
  }
}
