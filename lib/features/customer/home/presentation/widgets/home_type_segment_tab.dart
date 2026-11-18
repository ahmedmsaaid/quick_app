import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/routes/app_router.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/constans/app_config.dart';
import 'package:base_app/features/customer/home/presentation/widgets/home_type_card_widget.dart';

class HomeTypeSegmentTab extends StatelessWidget {
  const HomeTypeSegmentTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          // Restaurant Card
          HomeTypeCardWidget(
            title: AppStrings.restaurantsCategory,
            subtitle: AppStrings.tastiestMeals,
            emoji: '🍔',
            accentColor: const Color(0xFFFF5F6D),
            onTap: () {
              context.pushNamed(
                AppRoutes.StoreScreen,
                arguments: VendorListArgs(
                  title: AppStrings.restaurantsCategory,
                  userRole: 0,
                ),
              );
            },
          ),
          if (AppConfig.enableQuickMarket) ...[
            12.horizontalSpace,
            // Market Card
            HomeTypeCardWidget(
              title: AppStrings.quickMarketCategory,
              subtitle: AppStrings.allServicesInOnePlace,
              emoji: '🛒',
              accentColor: const Color(0xFF00B09B),
              onTap: () {
                context.pushNamed(
                  AppRoutes.StoreScreen,
                  arguments: VendorListArgs(
                    title: AppStrings.quickMarketCategory,
                    userRole: 1,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
