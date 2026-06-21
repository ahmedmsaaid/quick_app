import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';

final subCategoriesProvider = FutureProvider.autoDispose<List<CategoryDto>>((ref) async {
  final apiService = ref.watch(homeApiServiceProvider);
  final result = await apiService.getCategories();
  return result.when(
    success: (response) {
      if (response.success && response.result != null) {
        return response.result!;
      }
      return [];
    },
    failure: (error) => [],
  );
});

class AllCategoriesScreen extends ConsumerWidget {
  const AllCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final subCategoriesAsync = ref.watch(subCategoriesProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.categories,
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
                AppStrings.errorOccurred,
                style: AppTextStyles.text16w600(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        data: (categories) => categories.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.category_outlined, size: 64.sp, color: colors.textHint),
                    16.verticalSpace,
                    Text(
                      AppStrings.noItemsFound,
                      style: AppTextStyles.text16w600(color: colors.textSecondary),
                    ),
                  ],
                ),
              )
            : GridView.builder(
                padding: EdgeInsets.all(20.w),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _CategoryCard(
                    category: cat,
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.products,
                        arguments: cat,
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryDto category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final String photoUrl = (category.photo != null && category.photo!.isNotEmpty)
        ? (category.photo!.startsWith('http')
            ? category.photo!
            : '${ApiConstants.streamUrl}${category.photo!}')
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image / Emoji circle
            Container(
              width: 72.w,
              height: 72.w,
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
                        child: Text('🍽️', style: TextStyle(fontSize: 28.sp)),
                      ),
                      errorWidget: (context, url, error) => Center(
                        child: Text('🍽️', style: TextStyle(fontSize: 28.sp)),
                      ),
                    )
                  : Center(
                      child: Text('📁', style: TextStyle(fontSize: 28.sp)),
                    ),
            ),
            12.verticalSpace,
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                category.name ?? '',
                style: AppTextStyles.text14w600(color: colors.textPrimary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            6.verticalSpace,
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                AppStrings.seeAll,
                style: AppTextStyles.text10w500(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
