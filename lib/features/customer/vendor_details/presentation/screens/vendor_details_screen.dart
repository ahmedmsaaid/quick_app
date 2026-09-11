import 'package:flutter/material.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/vendor_details/presentation/screens/general_vendor_details_screen.dart';
import 'package:base_app/features/customer/vendor_details/presentation/screens/market_vendor_details_screen.dart';

/// Main entry widget for Vendor Details.
/// Dispatches to [MarketVendorDetailsScreen] for Market stores (role == 1)
/// or [GeneralVendorDetailsScreen] for all other stores (role != 1).
class VendorDetailsScreen extends StatelessWidget {
  const VendorDetailsScreen({
    super.key,
    required this.vendor,
    this.initialCategory,
  });

  final UserDto vendor;
  final CategoryDto? initialCategory;

  @override
  Widget build(BuildContext context) {
    final bool isMarket = vendor.role == 1;

    if (isMarket) {
      return MarketVendorDetailsScreen(
        vendor: vendor,
        initialCategory: initialCategory,
      );
    }

    return GeneralVendorDetailsScreen(
      vendor: vendor,
      initialCategory: initialCategory,
    );
  }
}
