import 'package:base_app/core/localizations/app_strings.g.dart';
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

  @override
  Widget build(BuildContext context) {
    final bool isSupermarket = widget.userRole == 1 || widget.title == AppStrings.quickMarketCategory;
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
      body: Column(
        children: [
          if (isSupermarket) _buildMarketBanner(context, vendorListState.vendors),
          if (!isSupermarket) _buildFilterChips(context, role),
          Expanded(
            child: _buildBody(context, ref, vendorListState, isSupermarket, role),
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
    int role,
  ) {
    final colors = AppColors(context);

    if (isSupermarket) {
      final otherMarkets = state.vendors.where((v) => v.id != 31).toList();
      
      if (state.status == VendorListStatus.loading) {
        return const LoadingButton();
      }

      if (otherMarkets.isEmpty) {
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

      return _buildVendorsGrid(context, ref, otherMarkets, isSupermarket);
    }

    if (state.status == VendorListStatus.loading) {
      return const LoadingButton();
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

    if (state.vendors.isEmpty) {
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

    return _buildVendorsGrid(context, ref, state.vendors, isSupermarket);
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

  Widget _buildVendorsGrid(BuildContext context, WidgetRef ref, List<UserDto> vendors, bool isMarket) {
    return GridView.builder(
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

  Widget _buildMarketCategoriesGrid(BuildContext context, WidgetRef ref, List<UserDto> vendors) {
    final colors = AppColors(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final categories = [
      {
        'title': isArabic ? 'ألبان وأجبان' : 'Dairy & Cheese',
        'emoji': '🥛',
        'color': const Color(0xFFE3F2FD),
        'iconColor': const Color(0xFF1E88E5),
      },
      {
        'title': isArabic ? 'مجمدات' : 'Frozen Foods',
        'emoji': '❄️',
        'color': const Color(0xFFE0F7FA),
        'iconColor': const Color(0xFF00ACC1),
      },
      {
        'title': isArabic ? 'بقالة ومواد غذائية' : 'Groceries',
        'emoji': '🌾',
        'color': const Color(0xFFF1F8E9),
        'iconColor': const Color(0xFF7CB342),
      },
      {
        'title': isArabic ? 'خضار وفواكه' : 'Fruits & Veggies',
        'emoji': '🍎',
        'color': const Color(0xFFFFF3E0),
        'iconColor': const Color(0xFFFB8C00),
      },
      {
        'title': isArabic ? 'مخبوزات وحلويات' : 'Bakery & Sweets',
        'emoji': '🍞',
        'color': const Color(0xFFEFEBE9),
        'iconColor': const Color(0xFF8D6E63),
      },
      {
        'title': isArabic ? 'مشروبات وعصائر' : 'Beverages',
        'emoji': '🥤',
        'color': const Color(0xFFFFFDE7),
        'iconColor': const Color(0xFFFBC02D),
      },
      {
        'title': isArabic ? 'منظفات وعناية' : 'Detergents & Care',
        'emoji': '🧼',
        'color': const Color(0xFFF3E5F5),
        'iconColor': const Color(0xFF8E24AA),
      },
      {
        'title': isArabic ? 'معلبات وجاهز' : 'Canned Foods',
        'emoji': '🥫',
        'color': const Color(0xFFFFEBEE),
        'iconColor': const Color(0xFFE53935),
      },
    ];

    return GridView.builder(
      padding: EdgeInsets.all(20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: () {
            if (vendors.isNotEmpty) {
              context.pushNamed(
                AppRoutes.providerProductDetailsScreen,
                arguments: vendors.first,
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isArabic ? 'جاري تحميل بيانات السوبر ماركت...' : 'Loading supermarket details...',
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  duration: const Duration(seconds: 1),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: cat['color'] as Color,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: (cat['iconColor'] as Color).withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  cat['emoji'] as String,
                  style: TextStyle(fontSize: 36.sp),
                ),
                10.verticalSpace,
                Text(
                  cat['title'] as String,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                    fontFamily: 'Cairo',
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
            arguments: market31,
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
