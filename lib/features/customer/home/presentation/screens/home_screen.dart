import 'package:base_app/core/exports/exports.dart';
import 'package:base_app/core/widgets/see_all_widget.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_speed_header.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_modern_banner.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_featured_restaurants.dart';
import 'package:base_app/features/customer/home/presentation/widgets/mock_category_card.dart';
import 'package:base_app/features/customer/home/presentation/widgets/mock_store_card.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_type_segment_tab.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/core/routes/app_router.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_todays_offers.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_order_again.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final homeState = ref.watch(homeProvider);

    final selectedCat = homeState.selectedCategory;
    final recommendedStores = homeState.recommendedStores;

    // Prepare categories list for rendering: prepend "All" virtual category
    final List<Map<String, dynamic>> renderingCategories = [
      {
        'id': 0,
        'name': AppStrings.catAll,
        'emoji': '🍽️',
        'photo': null,
      },
      ...homeState.categories.map((c) => {
        'id': c.id,
        'name': c.name,
        'emoji': '📁',
        'photo': c.photo,
        'model': c,
      }),
    ];

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.secondary,
        backgroundColor: colors.cardBackground,
        strokeWidth: 2.5,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          await ref.read(homeProvider.notifier).refreshAllData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Colored Speed Header Container
            const HomeSpeedHeader(),

            12.verticalSpace,
            const HomeTypeSegmentTab(),
            12.verticalSpace,
            const HomeModernBanner(),
            16.verticalSpace,

            // عروض الـ API الحقيقية
            const HomeTodaysOffers(),
            12.verticalSpace,
            // العروض القابلة للتعديل
            const HomeEditableOffers(),
            12.verticalSpace,
            // اطلب مرة أخرى من الطلبات السابقة
            const HomeOrderAgain(),
            12.verticalSpace,

            // Rest of page content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Categories Header
                SeeAllWidget(
                  title: AppStrings.categories,
                  onTap: () {
                    context.pushNamed(AppRoutes.allCategoriesScreen);
                  },
                ),
                // Categories List
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SizedBox(
                    height: 130.h,
                    child: homeState.categoriesStatus == HomeStatus.loading
                        ? const Center(child: LoadingButton())
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: renderingCategories.length,
                            itemBuilder: (context, index) {
                              final cat = renderingCategories[index];
                              final isSelected = (selectedCat == null && cat['id'] == 0) ||
                                  (selectedCat != null && selectedCat.id == cat['id']);
                              final String? photoKey = cat['photo'];
                              final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
                                  ? (photoKey.startsWith('http') ? photoKey : '${ApiConstants.streamUrl}$photoKey')
                                  : '';

                              return MockCategoryCard(
                                name: cat['name'] ?? '',
                                emoji: cat['emoji'],
                                photoUrl: photoUrl.isNotEmpty ? photoUrl : null,
                                isSelected: isSelected,
                                onTap: () {
                                  if (cat['id'] == 0) {
                                    ref.read(homeProvider.notifier).selectCategory(null);
                                  } else {
                                    ref.read(homeProvider.notifier).selectCategory(cat['model'] as MainCategoryDto);
                                  }
                                },
                              );
                            },
                          ),
                  ),
                ),
                6.verticalSpace,
                SeeAllWidget(
                  title: AppStrings.recommended,
                  onTap: () {
                    final role = selectedCat?.userRole ?? 0;
                    context.pushNamed(
                      AppRoutes.StoreScreen,
                      arguments: VendorListArgs(
                        title: selectedCat?.name ?? AppStrings.recommended,
                        categoryId: selectedCat?.id,
                        userRole: role,
                      ),
                    );
                  },
                ),
                // Recommended Title

                // Recommended Grid
                if (homeState.recommendedStoresStatus == HomeStatus.loading)
                  SizedBox(
                    height: 180.h,
                    child: const Center(child: LoadingButton()),
                  )
                else if (recommendedStores.isEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    alignment: Alignment.center,
                    child: Text(
                      AppStrings.noItemsFound,
                      style: AppTextStyles.text14w600(
                          color: colors.textSecondary),
                    ),
                  )
                else
                  GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recommendedStores.length>4?4: recommendedStores.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.78,
                    ),
                    itemBuilder: (context, index) {
                      final store = recommendedStores[index];
                      return MockStoreCard(
                        store: store,
                        onTap: () {
                          context.pushNamed(AppRoutes.providerProductDetailsScreen,
                              arguments: store);
                        },
                      );
                    },
                  ),
                24.verticalSpace,

                // Featured Restaurants Section
                const HomeFeaturedRestaurants(),
                40.verticalSpace,
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}
