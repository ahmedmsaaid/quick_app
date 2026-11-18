import 'package:flutter/material.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/features/customer/vendor_list/presentation/screens/restaurant_list_screen.dart';
import 'package:base_app/features/customer/vendor_list/presentation/screens/market_vendor_list_screen.dart';

/// Entry screen that dispatches to either [MarketVendorListScreen] or [RestaurantListScreen].
class VendorListScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final bool isMarket =
        userRole == 1 || title == AppStrings.quickMarketCategory;

    if (isMarket) {
      return MarketVendorListScreen(
        title: title,
        categoryId: categoryId,
      );
    }

    return RestaurantListScreen(
      title: title,
      categoryId: categoryId,
    );
  }
}
