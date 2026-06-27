import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/vendor_list/presentation/riverpod/vendor_list_provider.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';

class VendorListScreen extends ConsumerStatefulWidget {
  const VendorListScreen({super.key, required this.title, this.categoryId, this.userRole});

  final String title;
  final int? categoryId;
  final int? userRole;

  @override
  ConsumerState<VendorListScreen> createState() => _VendorListScreenState();
}

class _VendorListScreenState extends ConsumerState<VendorListScreen> {
  int _selectedFilterIndex = 0;
  bool _isLoading = false;
  List<MainCategoryDto> _marketCategories = [];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  @override
  void initState() {
    super.initState();
    final bool isSupermarket = widget.userRole == 1 || widget.title == AppStrings.quickMarketCategory;
    final bool isMainMarketScreen = isSupermarket && widget.categoryId == null;
    if (isMainMarketScreen) {
      _loadMarketCategories();
    }
  }

  Future<void> _loadMarketCategories() async {
    if (!mounted) return;
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    final result = await ref.read(homeApiServiceProvider).getMainCategories(role: 1);

    if (!mounted) return;
    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          setState(() {
            _marketCategories = response.result!
                .where((category) => category.userRole == 1)
                .toList();
            _isLoadingCategories = false;
          });
        } else {
          setState(() {
            _categoriesError = response.message ?? AppStrings.errorOccurred;
            _isLoadingCategories = false;
          });
        }
      },
      failure: (error) {
        setState(() {
          _categoriesError = error.message;
          _isLoadingCategories = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSupermarket = widget.userRole == 1 || widget.title == AppStrings.quickMarketCategory;
    final bool isMainMarketScreen = isSupermarket && widget.categoryId == null;
    final int role = widget.userRole ?? (isSupermarket ? 1 : 0);
    final vendorListState = ref.watch(vendorListProvider(role, categoryId: widget.categoryId));
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          widget.title,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (isMainMarketScreen) _buildMarketBanner(context, vendorListState.vendors),
              if (!isSupermarket) _buildFilterChips(context, role),
              Expanded(
                child: _buildBody(context, ref, vendorListState, isSupermarket, isMainMarketScreen, role),
              ),
            ],
          ),
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: LoadingButton(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    VendorListState state,
    bool isSupermarket,
    bool isMainMarketScreen,
    int role,
  ) {
    final colors = AppColors(context);

    if (isMainMarketScreen) {
      if (_isLoadingCategories && _marketCategories.isEmpty) {
        return const LoadingButton();
      }

      if (_categoriesError != null && _marketCategories.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: colors.error),
              10.verticalSpace,
              Text(
                _categoriesError!,
                style: AppTextStyles.text14w500(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
              15.verticalSpace,
              ElevatedButton(
                onPressed: () {
                  _loadMarketCategories();
                },
                child: Text(AppStrings.tryAgain),
              ),
            ],
          ),
        );
      }

      return _buildMarketCategoriesGrid(context, ref, _marketCategories);
    }

    if (state.status == VendorListStatus.error) {
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
                  ref.read(vendorListProvider(role, categoryId: widget.categoryId).notifier).loadVendors(
                    orderByRate: _selectedFilterIndex == 1,
                    categoryId: widget.categoryId,
                  );
                },
                child: Text(AppStrings.tryAgain),
              ),
            ],
          ),
        ),
      );
    }

    final displayVendors = isSupermarket
        ? state.vendors.where((v) => v.role == 1).toList()
        : state.vendors.where((v) => v.role == 0).toList();

    if (displayVendors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 64.sp, color: colors.textHint),
            10.verticalSpace,
            Text(
              AppStrings.noItemsFound,
              style: AppTextStyles.text16w600(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return _buildVendorsGrid(context, ref, displayVendors, isSupermarket);
  }

  Widget _buildFilterChips(BuildContext context, int role) {
    final filters = [
      AppStrings.allFilter,
      AppStrings.topRatedFilter,
    ];
    return SizedBox(
      height: 50.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (context, index) => 10.horizontalSpace,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedFilterIndex;
          return GestureDetector(
            onTap: () {
              if (_selectedFilterIndex == index) return;
              setState(() {
                _selectedFilterIndex = index;
              });
              ref.read(vendorListProvider(role, categoryId: widget.categoryId).notifier).loadVendors(
                orderByRate: index == 1,
                categoryId: widget.categoryId,
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors(context).primary : AppColors(context).surface,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: isSelected ? Colors.transparent : AppColors(context).border),
              ),
              child: Text(
                filters[index],
                style: AppTextStyles.text12w600(color: isSelected ? Colors.white : AppColors(context).textSecondary),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorsGrid(
    BuildContext context,
    WidgetRef ref,
    List<UserDto> vendors,
    bool isMarket, {
    bool shrinkWrap = false,
  }) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 15.w,
        mainAxisSpacing: 15.h,
      ),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        final vendor = vendors[index];
        final String? photo = vendor.photo ?? vendor.avatar;
        final String imageUrl = (photo != null && photo.isNotEmpty)
            ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
            : '';

        return InkWell(
          onTap: () {
            context.pushNamed(
              AppRoutes.providerProductDetailsScreen,
              arguments: vendor,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors(context).surface,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors(context).shadow,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15.r)),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors(context).border.withValues(alpha: 0.5),
                              child: const LoadingButton(size: 30),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/image/logo.png',
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/image/logo.png',
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name ?? '',
                        style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (vendor.description != null && vendor.description!.isNotEmpty) ...[
                        2.verticalSpace,
                        Text(
                          vendor.description!,
                          style: AppTextStyles.text10w400(color: AppColors(context).textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      5.verticalSpace,
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 14.sp),
                          2.horizontalSpace,
                          Text(vendor.rating.toStringAsFixed(1), style: AppTextStyles.text12w400(color: AppColors(context).textSecondary)),
                          const Spacer(),
                          Text('15-25 د', style: AppTextStyles.text10w500(color: AppColors(context).primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketCategoriesGrid(
    BuildContext context,
    WidgetRef ref,
    List<MainCategoryDto> categories,
  ) {
    final colors = AppColors(context);

    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_rounded, size: 64.sp, color: colors.textHint),
            10.verticalSpace,
            Text(
              AppStrings.noItemsFound,
              style: AppTextStyles.text16w600(color: colors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.05,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final String photo = category.photo ?? '';
        final String imageUrl = (photo.isNotEmpty)
            ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
            : '';

        return GestureDetector(
          onTap: () async {
            if (_isLoading) return;
            setState(() {
              _isLoading = true;
            });

            try {
              final result = await ref.read(homeApiServiceProvider).getUsersPaginate(
                role: 1,
                categoryId: category.id,
                pageSize: 2,
              );

              result.when(
                success: (response) {
                  if (response.success && response.result != null && response.result!.isNotEmpty) {
                    final shops = response.result!;
                    if (shops.length == 1) {
                      context.pushNamed(
                        AppRoutes.providerStoreScreen,
                        arguments: {
                          'vendor': shops.first,
                          'initialCategory': CategoryDto(
                            id: category.id,
                            name: category.name,
                            description: category.description,
                            photo: category.photo,
                            type: 1,
                            creatorId: shops.first.id,
                          ),
                        },
                      );
                    } else {
                      context.pushNamed(
                        AppRoutes.StoreScreen,
                        arguments: VendorListArgs(
                          title: category.name ?? '',
                          categoryId: category.id,
                          userRole: 1,
                        ),
                      );
                    }
                  } else {
                    context.pushNamed(
                      AppRoutes.StoreScreen,
                      arguments: VendorListArgs(
                        title: category.name ?? '',
                        categoryId: category.id,
                        userRole: 1,
                      ),
                    );
                  }
                },
                failure: (error) {
                  context.pushNamed(
                    AppRoutes.StoreScreen,
                    arguments: VendorListArgs(
                      title: category.name ?? '',
                      categoryId: category.id,
                      userRole: 1,
                    ),
                  );
                },
              );
            } catch (e) {
              context.pushNamed(
                AppRoutes.StoreScreen,
                arguments: VendorListArgs(
                  title: category.name ?? '',
                  categoryId: category.id,
                  userRole: 1,
                ),
              );
            } finally {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colors.surface,
                  colors.primary.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.12),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -12.r,
                  right: -12.r,
                  child: Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.primary.withValues(alpha: 0.025),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64.r,
                        height: 64.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: colors.primary.withValues(alpha: 0.06),
                          boxShadow: [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: imageUrl.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(color: colors.shimmerBase),
                                  errorWidget: (_, __, ___) => Center(
                                    child: Icon(Icons.category_rounded, size: 28.sp, color: colors.primary),
                                  ),
                                )
                              : Center(
                                  child: Icon(Icons.category_rounded, size: 28.sp, color: colors.primary),
                                ),
                        ),
                      ),
                      12.verticalSpace,
                      Text(
                        category.name ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          fontFamily: 'Cairo',
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      6.verticalSpace,
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "تسوّق الآن",
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: colors.primary,
                                fontFamily: 'Cairo',
                              ),
                            ),
                            2.horizontalSpace,
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 7.sp,
                              color: colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMarketBanner(BuildContext context, List<UserDto> vendors) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          final UserDto market31 = vendors.firstWhere(
            (v) => v.id == 31,
            orElse: () => UserDto(
              id: 31,
              name: isArabic ? 'كويك ماركت' : 'Quick Market',
              role: 1,
              status: 1,
              rating: 5.0,
              active: true,
            ),
          );
          context.pushNamed(
            AppRoutes.providerStoreScreen,
            arguments: {
              'vendor': market31,
              'initialCategory': null,
            },
          );
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          width: double.infinity,
          height: 110.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.brandTeal,
                Color(0xFF00B0B0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandTeal.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background graphic elements
              Positioned(
                right: -20.w,
                top: -20.h,
                child: CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                left: -10.w,
                bottom: -30.h,
                child: CircleAvatar(
                  radius: 50.r,
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isArabic ? 'كويك ماركت' : 'Quick Market',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                              height: 1.2,
                            ),
                          ),
                          6.verticalSpace,
                          Text(
                            isArabic ? 'كل احتياجاتك اليومية في مكان واحد' : 'All your daily needs in one place',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontFamily: 'Cairo',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    10.horizontalSpace,
                    // Logo
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Image.asset(
                        'assets/image/logo.png',
                        width: 50.w,
                        height: 50.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
