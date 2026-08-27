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
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';

class VendorListScreen extends ConsumerStatefulWidget {
  const VendorListScreen({
    super.key,
    required this.title,
    this.categoryId,
    this.userRole,
  });

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
              if (isMainMarketScreen) _MarketBanner(vendors: vendorListState.vendors),
              if (!isSupermarket)
                _FilterChips(
                  selectedIndex: _selectedFilterIndex,
                  onSelected: (index) {
                    setState(() => _selectedFilterIndex = index);
                    ref.read(vendorListProvider(role, categoryId: widget.categoryId).notifier).loadVendors(
                      orderByRate: index == 1,
                      categoryId: widget.categoryId,
                    );
                  },
                ),
              Expanded(
                child: _buildBody(context, vendorListState, isSupermarket, isMainMarketScreen, role),
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
    VendorListState state,
    bool isSupermarket,
    bool isMainMarketScreen,
    int role,
  ) {
    if (isMainMarketScreen) {
      if (_isLoadingCategories && _marketCategories.isEmpty) {
        return const Center(child: LoadingButton());
      }

      if (_categoriesError != null && _marketCategories.isEmpty) {
        return _ErrorState(
          message: _categoriesError!,
          onRetry: _loadMarketCategories,
        );
      }

      return _buildMarketCategoriesGrid(context, _marketCategories);
    }

    if (state.status == VendorListStatus.loading || state.status == VendorListStatus.initial) {
      return const Center(child: LoadingButton());
    }

    if (state.status == VendorListStatus.error) {
      return _ErrorState(
        message: state.errorMessage ?? AppStrings.errorOccurred,
        onRetry: () {
          ref.read(vendorListProvider(role, categoryId: widget.categoryId).notifier).loadVendors(
            orderByRate: _selectedFilterIndex == 1,
            categoryId: widget.categoryId,
          );
        },
      );
    }

    final filtered = isSupermarket
        ? state.vendors.where((v) => v.role == 1).toList()
        : state.vendors.where((v) => v.role == 0).toList();

    final displayVendors = filtered.isNotEmpty ? filtered : state.vendors;

    if (displayVendors.isEmpty) {
      return const _EmptyState();
    }

    return _buildVendorsGrid(context, displayVendors, isSupermarket);
  }

  Widget _buildVendorsGrid(
    BuildContext context,
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
        return _VendorCard(vendor: vendors[index]);
      },
    );
  }

  Widget _buildMarketCategoriesGrid(
    BuildContext context,
    List<MainCategoryDto> categories,
  ) {
    if (categories.isEmpty) {
      return const _EmptyState();
    }

    final int columnCount = 4;
    final double childAspectRatio = 0.70;
    final double crossAxisSpacing = 8.w;
    final double mainAxisSpacing = 10.h;

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryGridItem(
          category: category,
          columnCount: columnCount,
          onTap: () => _handleCategoryTap(category),
        );
      },
    );
  }

  void _handleCategoryTap(MainCategoryDto category) {
    context.pushNamed(
      AppRoutes.StoreScreen,
      arguments: VendorListArgs(
        title: category.name ?? 'المتاجر',
        categoryId: category.id,
        userRole: category.userRole,
      ),
    );
  }
}

/// A clean, modern Filter Tab widget for top rate / all.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
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
        separatorBuilder: (_, __) => 10.horizontalSpace,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? colors.primary : colors.surface,
                borderRadius: BorderRadius.circular(25.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : colors.border,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Text(
                filters[index],
                style: AppTextStyles.text12w600(
                  color: isSelected ? Colors.white : colors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Refactored Vendor card displaying info in a clean layout.
class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor});

  final UserDto vendor;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
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
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.05),
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
                        placeholder: (_, __) => Container(
                          color: colors.border.withValues(alpha: 0.5),
                          child: const LoadingButton(size: 30),
                        ),
                        errorWidget: (_, __, ___) => Image.asset(
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
                    style: AppTextStyles.text14w600(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (vendor.description != null && vendor.description!.isNotEmpty) ...[
                    2.verticalSpace,
                    Text(
                      vendor.description!,
                      style: AppTextStyles.text10w400(color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  5.verticalSpace,
                  Row(
                    children: [
                      /*
                      Icon(Icons.star, color: Colors.amber, size: 14.sp),
                      2.horizontalSpace,
                      Text(
                        vendor.rating.toStringAsFixed(1),
                        style: AppTextStyles.text12w400(color: colors.textSecondary),
                      ),
                      */
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Category Grid item widget with dynamic sizing based on columnCount.
class _CategoryGridItem extends StatelessWidget {
  const _CategoryGridItem({
    required this.category,
    required this.columnCount,
    required this.onTap,
  });

  final MainCategoryDto category;
  final int columnCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final String photo = category.photo ?? '';
    final String imageUrl = (photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(columnCount == 4 ? 14.r : 18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image on top
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(columnCount == 4 ? 14.r : 18.r)),
                child: imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: colors.shimmerBase),
                        errorWidget: (_, __, ___) => Image.asset(
                          'assets/image/logo.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        'assets/image/logo.png',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            // Content on bottom (Name & Shop Now action)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: columnCount == 4 ? 6.w : 10.w,
                vertical: columnCount == 4 ? 6.h : 8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name ?? '',
                    style: TextStyle(
                      fontSize: columnCount == 4 ? 10.5.sp : 12.sp,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      fontFamily: 'Cairo',
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  3.verticalSpace,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "عرض المنتجات",
                        style: TextStyle(
                          fontSize: columnCount == 4 ? 8.sp : 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEE9C20),
                          fontFamily: 'Cairo',
                        ),
                      ),
                      2.horizontalSpace,
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: columnCount == 4 ? 8.sp : 10.sp,
                        color: const Color(0xFFEE9C20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A clean Market Banner widget matching the design of the user provided screenshot.
class _MarketBanner extends StatelessWidget {
  const _MarketBanner({required this.vendors});

  final List<UserDto> vendors;

  @override
  Widget build(BuildContext context) {
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
          height: 200.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF033E3B),
                Color(0xFF09524D),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Stack(
              children: [
                // Soft gradient wave background elements to match the image style
                Positioned(
                  right: -40.w,
                  bottom: -60.h,
                  child: Container(
                    width: 180.w,
                    height: 180.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFFEE9C20).withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -30.w,
                  top: -30.h,
                  child: CircleAvatar(
                    radius: 70.r,
                    backgroundColor: Colors.white.withValues(alpha: 0.03),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Column(
                    children: [
                      // Top Row (Logo + Title & Subtitle + Action Badge)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Logo Box on Left
                            Container(
                              padding: EdgeInsets.all(6.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                              child: Image.asset(
                                'assets/image/logo.png',
                                width: 48.w,
                                height: 48.h,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Spacer(),
                            // Text on Right (Arabic layout)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                4.verticalSpace,
                                Text(
                                  isArabic 
                                      ? 'كل احتياجاتك اليومية في مكان واحد' 
                                      : 'All your daily needs in one place',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                8.verticalSpace,
                                // Crisp, clear action button
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.15),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isArabic ? 'تصفح المنتجات 🛒' : 'Browse Products 🛒',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF033E3B),
                                          fontFamily: 'Cairo',
                                        ),
                                      ),
                                      6.horizontalSpace,
                                      Icon(
                                        isArabic ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                        color: const Color(0xFFEE9C20),
                                        size: 14.sp,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Divider line above features
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 10.h),
                        height: 1.h,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),

                      // Features row (Bottom)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureItem(
                            icon: Icons.verified_user, 
                            label: isArabic ? 'جودة\nنضمنها' : 'Quality\nGuaranteed'
                          ),
                          _buildDivider(),
                          _buildFeatureItem(
                            icon: Icons.shopping_bag, 
                            label: isArabic ? 'منتجات\nمتنوعة' : 'Diverse\nProducts'
                          ),
                          _buildDivider(),
                          _buildFeatureItem(
                            icon: Icons.percent, 
                            label: isArabic ? 'عروض\nحصرية' : 'Exclusive\nOffers'
                          ),
                          _buildDivider(),
                          _buildFeatureItem(
                            icon: Icons.motorcycle, 
                            label: isArabic ? 'توصيل\nسريع' : 'Fast\nDelivery'
                          ),
                        ].reversed.toList(), // Reversed for Arabic RTL matching the visual
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1.w,
      height: 25.h,
      color: Colors.white.withValues(alpha: 0.15),
    );
  }

  Widget _buildFeatureItem({required IconData icon, required String label}) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            color: const Color(0xFFEE9C20), 
            size: 18.sp
          ),
          4.verticalSpace,
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Cairo',
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Clean error display state widget.
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: colors.error),
            10.verticalSpace,
            Text(
              message,
              style: AppTextStyles.text14w500(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            15.verticalSpace,
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(AppStrings.tryAgain),
            ),
          ],
        ),
      ),
    );
  }
}

/// Clean empty display state widget.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
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
}
