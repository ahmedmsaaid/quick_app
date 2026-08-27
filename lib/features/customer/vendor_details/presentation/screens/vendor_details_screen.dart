import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/home/data/models/category_model.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/vendor_details/presentation/riverpod/vendor_details_provider.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_details_app_bar_widget.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_categories_filter_widget.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_market_categories_grid_widget.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_offers_section_widget.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_bottom_cart_bar_widget.dart';
import 'package:base_app/features/customer/vendor_details/presentation/widgets/vendor_details_empty_or_error_widget.dart';

class VendorDetailsScreen extends ConsumerStatefulWidget {
  const VendorDetailsScreen({super.key, required this.vendor, this.initialCategory});

  final UserDto vendor;
  final CategoryDto? initialCategory;

  @override
  ConsumerState<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends ConsumerState<VendorDetailsScreen> {
  UserDto? _vendor;
  List<OfferDto> _vendorOffers = [];
  bool _isLoadingOffers = false;

  @override
  void initState() {
    super.initState();
    _vendor = widget.vendor;
    _loadVendorOffers();
    if (_vendor!.photo == null || _vendor!.photo!.isEmpty) {
      _loadVendorDetails();
    }
    if (widget.initialCategory != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(vendorDetailsProvider(widget.vendor.id).notifier).setPreSelectedCategory(widget.initialCategory!);
      });
    }
  }

  Future<void> _loadVendorOffers() async {
    if (!mounted) return;
    setState(() => _isLoadingOffers = true);
    final result = await ref.read(homeApiServiceProvider).getOffers(creatorId: widget.vendor.id, pageSize: 50);
    if (!mounted) return;
    result.when(
      success: (res) {
        if (res.success && res.result != null) {
          setState(() {
            _vendorOffers = res.result!.where((o) => o.active == true).toList();
            _isLoadingOffers = false;
          });
        } else {
          setState(() => _isLoadingOffers = false);
        }
      },
      failure: (_) => setState(() => _isLoadingOffers = false),
    );
  }

  Future<void> _loadVendorDetails() async {
    final result = await ref.read(homeApiServiceProvider).getUserById(widget.vendor.id);
    if (!mounted) return;
    result.when(
      success: (res) {
        if (res.success && res.result != null) {
          setState(() => _vendor = res.result);
        }
      },
      failure: (_) {},
    );
  }

  void _openExclusiveOffersScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExclusiveOffersScreen(
          offers: _vendorOffers,
          vendorName: (_vendor ?? widget.vendor).name ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vendor = _vendor ?? widget.vendor;
    final bool isMarket = vendor.role == 1;
    final bool isBusy = vendor.busy == true;
    final bool isClosed = !(vendor.active ?? true) || vendor.status == 0;
    final state = ref.watch(vendorDetailsProvider(vendor.id));
    final notifier = ref.read(vendorDetailsProvider(vendor.id).notifier);
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      body: CustomScrollView(
        slivers: [
          VendorDetailsAppBarWidget(vendor: vendor, colors: colors),
          if (state.categories.isNotEmpty || state.categoriesStatus == VendorDetailsStatus.loading)
            SliverPersistentHeader(
              pinned: true,
              delegate: VendorCategoriesHeaderDelegate(
                child: VendorCategoriesFilterWidget(
                  state: state,
                  notifier: notifier,
                  colors: colors,
                  onTapOffers: _openExclusiveOffersScreen,
                ),
              ),
            ),
          if (state.selectedCategory != null)
            VendorSelectedCategoryHeaderWidget(colors: colors, state: state, notifier: notifier),
          if (state.selectedCategory == null)
            VendorMarketCategoriesGridWidget(
              state: state,
              notifier: notifier,
              colors: colors,
              onTapOffers: _openExclusiveOffersScreen,
            )
          else if (state.selectedCategory?.id == -999)
            VendorOffersContentWidget(isLoading: _isLoadingOffers, offers: _vendorOffers, colors: colors)
          else
            VendorProductsContentWidget(
              isMarket: isMarket,
              state: state,
              notifier: notifier,
              colors: colors,
              vendorId: vendor.id,
              isClosed: isClosed,
              isBusy: isBusy,
            ),
          SliverToBoxAdapter(child: 90.verticalSpace),
        ],
      ),
      bottomNavigationBar: VendorBottomCartBarWidget(colors: colors, outerContext: context),
    );
  }
}
