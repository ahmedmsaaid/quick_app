import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_speed_header.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_modern_banner.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_featured_restaurants.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_type_segment_tab.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_todays_offers.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_order_again.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_store_categories_section.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_recommended_stores_section.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_product_categories_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

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
              // 1. Colored Speed Header Container (Search, location, cart)
              const HomeSpeedHeader(),
              12.verticalSpace,

              // 2. Store Type Segment Tab (Restaurants shown; Quick Market hidden via AppConfig)
              const HomeTypeSegmentTab(),
              12.verticalSpace,

              // 3. Modern Banner Slider
              const HomeModernBanner(),
              16.verticalSpace,

              // 4. Today's Special Offers
              const HomeTodaysOffers(),
              12.verticalSpace,

              // 5. Order Again from previous orders
              const HomeOrderAgain(),
              12.verticalSpace,

              // 6. Store Categories Section
              const HomeStoreCategoriesSection(),
              6.verticalSpace,

              // 7. Recommended Stores Section
              const HomeRecommendedStoresSection(),
              16.verticalSpace,

              // 8. Product Categories Section
              const HomeProductCategoriesSection(),
              24.verticalSpace,

              // 9. Featured Restaurants Section
              const HomeFeaturedRestaurants(),
              110.verticalSpace,
            ],
          ),
        ),
      ),
    );
  }
}
