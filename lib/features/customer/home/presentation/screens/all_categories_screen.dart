import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/routes/app_router.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/core/utils/extensions.dart';

final subCategoriesProvider = FutureProvider.autoDispose<List<CategoryDto>>((ref) async {
  final apiService = ref.watch(homeApiServiceProvider);
  final result = await apiService.getCategories();
  List<CategoryDto> list = [];
  result.when(
    success: (response) {
      if (response.success && response.result != null) {
        list = response.result!;
      }
    },
    failure: (error) {},
  );
  return list;
});

final mainCategoriesListProvider = FutureProvider.autoDispose<List<MainCategoryDto>>((ref) async {
  final apiService = ref.watch(homeApiServiceProvider);
  final result = await apiService.getMainCategories();
  List<MainCategoryDto> list = [];
  result.when(
    success: (response) {
      if (response.success && response.result != null) {
        list = response.result!;
      }
    },
    failure: (error) {},
  );
  return list;
});

class AllCategoriesScreen extends ConsumerWidget {
  final bool isStoreCategories;

  const AllCategoriesScreen({
    super.key,
    this.isStoreCategories = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    if (isStoreCategories) {
      final mainCategoriesAsync = ref.watch(mainCategoriesListProvider);

      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.surface,
          elevation: 0,
          leading: const CustomArrowBack(),
          title: Text(
            isArabic ? 'أقسام المتاجر' : 'Store Categories',
            style: AppTextStyles.text18w700(color: colors.textPrimary),
          ),
          centerTitle: true,
        ),
        body: mainCategoriesAsync.when(
          loading: () => const Center(child: LoadingButton()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: colors.error),
                16.verticalSpace,
                Text(
                  isArabic ? 'حدث خطأ ما' : 'An error occurred',
                  style: AppTextStyles.text16w600(color: colors.textSecondary),
                ),
                15.verticalSpace,
                ElevatedButton(
                  onPressed: () => ref.refresh(mainCategoriesListProvider),
                  child: Text(isArabic ? 'إعادة المحاولة' : 'Try Again'),
                ),
              ],
            ),
          ),
          data: (categories) {
            if (categories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront_outlined, size: 64.sp, color: colors.textHint),
                    16.verticalSpace,
                    Text(
                      isArabic ? 'لا توجد عناصر' : 'No items found',
                      style: AppTextStyles.text16w600(color: colors.textSecondary),
                    ),
                  ],
                ),
              );
            }

            final int columnCount = categories.length < 15 ? 3 : 4;
            final double childAspectRatio = categories.length < 10 ? 0.78 : 0.72;
            final double crossAxisSpacing = categories.length < 10 ? 12.w : 8.w;
            final double mainAxisSpacing = categories.length < 10 ? 14.h : 10.h;

            return RefreshIndicator(
              onRefresh: () async => ref.refresh(mainCategoriesListProvider),
              child: GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.all(16.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columnCount,
                  childAspectRatio: childAspectRatio,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _MainCategoryCard(
                    category: cat,
                    columnCount: columnCount,
                    isArabic: isArabic,
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.StoreScreen,
                        arguments: VendorListArgs(
                          title: cat.name ?? (isArabic ? 'المتاجر' : 'Stores'),
                          categoryId: cat.id,
                          userRole: cat.userRole,
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      );
    }

    final subCategoriesAsync = ref.watch(subCategoriesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          isArabic ? 'أقسام المنتجات' : 'Product Categories',
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: subCategoriesAsync.when(
        loading: () => const Center(child: LoadingButton()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: colors.error),
              16.verticalSpace,
              Text(
                isArabic ? 'حدث خطأ ما' : 'An error occurred',
                style: AppTextStyles.text16w600(color: colors.textSecondary),
              ),
              15.verticalSpace,
              ElevatedButton(
                onPressed: () => ref.refresh(subCategoriesProvider),
                child: Text(isArabic ? 'إعادة المحاولة' : 'Try Again'),
              ),
            ],
          ),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64.sp, color: colors.textHint),
                  16.verticalSpace,
                  Text(
                    isArabic ? 'لا توجد عناصر' : 'No items found',
                    style: AppTextStyles.text16w600(color: colors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final int columnCount = categories.length < 15 ? 3 : 4;
          final double childAspectRatio = categories.length < 10 ? 0.78 : 0.72;
          final double crossAxisSpacing = categories.length < 10 ? 12.w : 8.w;
          final double mainAxisSpacing = categories.length < 10 ? 14.h : 10.h;

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(subCategoriesProvider),
            child: GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                childAspectRatio: childAspectRatio,
                crossAxisSpacing: crossAxisSpacing,
                mainAxisSpacing: mainAxisSpacing,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return _CategoryCard(
                  category: cat,
                  columnCount: columnCount,
                  onTap: () {
                    context.pushNamed(
                      AppRoutes.products,
                      arguments: cat,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MainCategoryCard extends StatelessWidget {
  final MainCategoryDto category;
  final int columnCount;
  final bool isArabic;
  final VoidCallback onTap;

  const _MainCategoryCard({
    required this.category,
    required this.columnCount,
    required this.isArabic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final String photoUrl = (category.photo != null && category.photo!.isNotEmpty)
        ? (category.photo!.startsWith('http')
            ? category.photo!
            : '${ApiConstants.streamUrl}${category.photo!}')
        : '';

    final double circleSize = columnCount == 4 ? 54.w : 64.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(columnCount == 4 ? 14.r : 18.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(columnCount == 4 ? 6.r : 8.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: Text('🏪', style: TextStyle(fontSize: columnCount == 4 ? 20.sp : 24.sp)),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text('🏪', style: TextStyle(fontSize: columnCount == 4 ? 20.sp : 24.sp)),
                      ),
                    )
                  : Center(
                      child: Text('🏪', style: TextStyle(fontSize: columnCount == 4 ? 20.sp : 24.sp)),
                    ),
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                category.name ?? '',
                style: TextStyle(
                  fontSize: columnCount == 4 ? 10.5.sp : 12.sp,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            4.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: columnCount == 4 ? 6.w : 8.w,
                vertical: columnCount == 4 ? 2.h : 3.h,
              ),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isArabic ? "عرض المتاجر" : "View Stores",
                    style: TextStyle(
                      fontSize: columnCount == 4 ? 8.sp : 9.5.sp,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  2.horizontalSpace,
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: columnCount == 4 ? 8.sp : 10.sp,
                    color: colors.primary,
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

class _CategoryCard extends StatelessWidget {
  final CategoryDto category;
  final int columnCount;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.columnCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final String photoUrl = (category.photo != null && category.photo!.isNotEmpty)
        ? (category.photo!.startsWith('http')
            ? category.photo!
            : '${ApiConstants.streamUrl}${category.photo!}')
        : '';

    final double circleSize = columnCount == 4 ? 54.w : 64.w;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(columnCount == 4 ? 14.r : 18.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.all(columnCount == 4 ? 6.r : 8.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              clipBehavior: Clip.antiAlias,
              child: photoUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: photoUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Center(
                        child: Text('📁', style: TextStyle(fontSize: columnCount == 4 ? 20.sp : 24.sp)),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text('📁', style: TextStyle(fontSize: columnCount == 4 ? 20.sp : 24.sp)),
                      ),
                    )
                  : Center(
                      child: Text('📁', style: TextStyle(fontSize: columnCount == 4 ? 20.sp : 24.sp)),
                    ),
            ),
            8.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                category.name ?? '',
                style: TextStyle(
                  fontSize: columnCount == 4 ? 10.5.sp : 12.sp,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            4.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: columnCount == 4 ? 6.w : 8.w,
                vertical: columnCount == 4 ? 2.h : 3.h,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEE9C20).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }
}
