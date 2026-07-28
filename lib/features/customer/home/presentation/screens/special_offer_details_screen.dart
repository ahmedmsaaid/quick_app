import 'dart:ui';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/core/widgets/custom_toast.dart';

class SpecialOfferDetailsScreen extends ConsumerStatefulWidget {
  final OfferDto? offer;

  const SpecialOfferDetailsScreen({super.key, this.offer});

  @override
  ConsumerState<SpecialOfferDetailsScreen> createState() => _SpecialOfferDetailsScreenState();
}

class _SpecialOfferDetailsScreenState extends ConsumerState<SpecialOfferDetailsScreen> {
  List<ProductDto> _displayProducts = [];
  List<ProductDto> _customProducts = [];
  bool _isInitialized = false;

  void _initEditableOffer(OfferDto detailedOffer) {
    if (_isInitialized) return;
    _displayProducts = List.from(detailedOffer.products ?? []);
    _customProducts = List.from(detailedOffer.products ?? []);
    _isInitialized = true;
  }

  double _getCurrentPrice(OfferDto detailedOffer) {
    if (detailedOffer.offerType != 1) return detailedOffer.price;
    if (_customProducts.isEmpty) return 0.0;
    return _customProducts.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  void _toggleProduct(ProductDto product, bool? isSelected) {
    setState(() {
      final idx = _customProducts.indexWhere((p) => p.id == product.id);
      if (isSelected == true) {
        if (idx == -1) {
          _customProducts.add(product);
        }
      } else {
        if (idx != -1) {
          _customProducts.removeAt(idx);
        }
      }
    });
  }

  void _updateQuantity(ProductDto product, int delta) {
    setState(() {
      final idx = _customProducts.indexWhere((p) => p.id == product.id);
      if (idx != -1) {
        final currentQty = _customProducts[idx].quantity;
        final newQty = currentQty + delta;
        if (newQty <= 0) {
          // Remove product completely if quantity is 0
          _customProducts.removeAt(idx);
        } else {
          _customProducts[idx] = ProductDto(
            id: _customProducts[idx].id,
            name: _customProducts[idx].name,
            photo: _customProducts[idx].photo,
            description: _customProducts[idx].description,
            price: _customProducts[idx].price,
            categoryId: _customProducts[idx].categoryId,
            creatorId: _customProducts[idx].creatorId,
            quantity: newQty,
          );
        }
      } else if (delta > 0) {
        // If not selected yet, add with quantity 1
        _customProducts.add(ProductDto(
          id: product.id,
          name: product.name,
          photo: product.photo,
          description: product.description,
          price: product.price,
          categoryId: product.categoryId,
          creatorId: product.creatorId,
          quantity: 1,
        ));
      }
    });
  }

  Future<void> _showAddProductBottomSheet(BuildContext context, int vendorId, AppColors colors) async {
    final ProductDetailDto? selectedProduct = await showModalBottomSheet<ProductDetailDto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddProductBottomSheet(vendorId: vendorId, colors: colors),
    );

    if (selectedProduct != null) {
      setState(() {
        final productDto = ProductDto(
          id: selectedProduct.id,
          name: selectedProduct.name,
          photo: selectedProduct.photo,
          description: selectedProduct.description,
          price: selectedProduct.price,
          categoryId: selectedProduct.categoryId,
          creatorId: vendorId,
          quantity: 1,
        );

        // Add to display products if not present
        if (!_displayProducts.any((p) => p.id == productDto.id)) {
          _displayProducts.add(productDto);
        }

        // Add to custom products (checked list)
        final customIdx = _customProducts.indexWhere((p) => p.id == productDto.id);
        if (customIdx == -1) {
          _customProducts.add(productDto);
        } else {
          // Increment quantity if already added
          _updateQuantity(productDto, 1);
        }
      });
      if (mounted) {
        CustomToast.success(context, 'تم إضافة المنتج إلى قائمتك! ➕');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    if (widget.offer == null) {
      return Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          leading: const CustomArrowBack(),
          elevation: 0,
        ),
        body: const Center(
          child: Text('العرض غير متوفر'),
        ),
      );
    }

    final offerAsync = ref.watch(getOfferDetailsProvider(widget.offer!.id));

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leadingWidth: 70.w,
        leading: Center(
          child: CustomArrowBack(
            color: Colors.black.withValues(alpha: 0.35),
            iconColor: Colors.white,
            isCircular: true,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(8.r),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => context.pushNamed(AppRoutes.cartScreen),
            child: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20.sp),
            ),
          ),
          20.horizontalSpace,
        ],
      ),
      backgroundColor: colors.background,
      body: offerAsync.when(
        data: (detailedOffer) {
          if (detailedOffer.offerType == 1) {
            _initEditableOffer(detailedOffer);
          }
          return _buildContent(context, detailedOffer, colors);
        },
        loading: () => _buildContent(context, widget.offer!, colors, isLoading: true),
        error: (err, stack) => _buildContent(context, widget.offer!, colors, errorMsg: err.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    OfferDto currentOffer,
    AppColors colors, {
    bool isLoading = false,
    String? errorMsg,
  }) {
    final screenH = MediaQuery.sizeOf(context).height;
    final String? featuredPhoto = currentOffer.featuredPhoto;
    final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
        ? (featuredPhoto.startsWith('http') ? featuredPhoto : '${ApiConstants.streamUrl}$featuredPhoto')
        : '';

    final double priceToShow = _getCurrentPrice(currentOffer);

    return Stack(
      children: [
        // ─── 1. Background Hero Image with Gradients ───
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: screenH * 0.46,
          child: Stack(
            fit: StackFit.expand,
            children: [
              imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: colors.border,
                        child: const LoadingButton(size: 30),
                      ),
                      errorWidget: (context, url, error) => Image.asset('assets/image/logo.png', fit: BoxFit.cover),
                    )
                  : Image.asset('assets/image/logo.png', fit: BoxFit.cover),
              // Premium Ambient Dark Gradients
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ─── 2. Scrollable Body Content Sheet ───
        Positioned.fill(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: screenH * 0.38),
                // Rounded Content Card Sheet
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      )
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pill handle indicator
                      Center(
                        child: Container(
                          width: 45.w,
                          height: 4.5.h,
                          decoration: BoxDecoration(
                            color: colors.divider,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                      ),
                      24.verticalSpace,

                      // ─── Main Details Overlapping Card ───
                      Container(
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(color: colors.border.withValues(alpha: 0.7), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Pulsating Offer available badge
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: colors.success.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: colors.success.withValues(alpha: 0.25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            width: 10.w,
                                            height: 10.w,
                                            decoration: BoxDecoration(
                                              color: colors.success.withValues(alpha: 0.3),
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Container(
                                            width: 5.w,
                                            height: 5.w,
                                            decoration: BoxDecoration(
                                              color: colors.success,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      6.horizontalSpace,
                                      Text(
                                        AppStrings.offerAvailable,
                                        style: AppTextStyles.text11w700(color: colors.success),
                                      ),
                                    ],
                                  ),
                                ),

                                // Limited Time Banner
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                  decoration: BoxDecoration(
                                    color: colors.error.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(color: colors.error.withValues(alpha: 0.25), width: 0.8),
                                  ),
                                  child: Text(
                                    currentOffer.offerType == 1 ? 'قابل للتعديل 🛠️' : AppStrings.limitedTimeOfferLabel,
                                    style: AppTextStyles.text11w700(color: currentOffer.offerType == 1 ? colors.secondary : colors.error),
                                  ),
                                ),
                              ],
                            ),
                            14.verticalSpace,

                            // Offer Title
                            Text(
                              currentOffer.name ?? '',
                              style: AppTextStyles.text22w700(color: colors.textPrimary),
                            ),
                            10.verticalSpace,

                            // Offer Description
                            Text(
                              currentOffer.description ?? '',
                              style: AppTextStyles.text14w400(color: colors.textSecondary).copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      24.verticalSpace,

                      // ─── Content Items Card ───
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppStrings.offerContentsLabel,
                            style: AppTextStyles.text16w700(color: colors.textPrimary),
                          ),
                          if (currentOffer.offerType == 1)
                            TextButton.icon(
                              onPressed: () => _showAddProductBottomSheet(context, currentOffer.creatorId, colors),
                              icon: Icon(Icons.add_circle_outline_rounded, size: 18.sp, color: colors.primary),
                              label: Text(
                                'إضافة منتج',
                                style: AppTextStyles.text12w700(color: colors.primary),
                              ),
                            ),
                        ],
                      ),
                      10.verticalSpace,
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: colors.border),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (currentOffer.offerType == 1) ...[
                              if (_displayProducts.isNotEmpty)
                                ..._displayProducts.map((prod) {
                                  final customIdx = _customProducts.indexWhere((p) => p.id == prod.id);
                                  final isSelected = customIdx != -1;
                                  final quantity = isSelected ? _customProducts[customIdx].quantity : 0;
                                  return _buildEditableOfferItem(context, prod, isSelected, quantity, colors);
                                })
                              else
                                Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20.h),
                                  child: Center(
                                    child: Text(
                                      'تم إزالة جميع المنتجات. أضف منتجات من الزر في الأعلى.',
                                      style: TextStyle(fontFamily: 'Cairo', color: colors.textHint, fontSize: 12.sp),
                                    ),
                                  ),
                                )
                            ] else ...[
                              if (currentOffer.products != null && currentOffer.products!.isNotEmpty)
                                ...currentOffer.products!.map((prod) => _buildOfferItem(context, prod.name ?? ''))
                              else if (isLoading)
                                _buildOfferItem(context, 'جاري تحميل تفاصيل محتويات العرض...')
                              else ...[
                                _buildOfferItem(context, AppStrings.offerItemBurger),
                                _buildOfferItem(context, AppStrings.offerItemFries),
                                _buildOfferItem(context, AppStrings.offerItemCola),
                              ],
                            ],
                          ],
                        ),
                      ),
                      if (isLoading) ...[
                        15.verticalSpace,
                        Center(
                          child: SizedBox(
                            width: 24.r,
                            height: 24.r,
                            child: LoadingButton(  color: colors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─── 4. Floating Price & Action Row ───
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, MediaQuery.of(context).padding.bottom + 14.h),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.88),
                  border: Border(top: BorderSide(color: colors.border.withValues(alpha: 0.6))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'إجمالي العرض',
                          style: AppTextStyles.text11w400(color: colors.textSecondary),
                        ),
                        4.verticalSpace,
                        Text(
                          '${priceToShow.toStringAsFixed(1)} ${AppStrings.currency}',
                          style: AppTextStyles.text22w700(color: colors.primary),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 170.w,
                      child: CustomAppButton(
                        text: AppStrings.orderNowBtn,
                        onPressed: () {
                          if (currentOffer.offerType == 1 && _customProducts.isEmpty) {
                            CustomToast.error(context, 'الرجاء اختيار منتج واحد على الأقل لإتمام الطلب');
                            return;
                          }

                          // Pass the customized offer Dto to checkout
                          final customizedOffer = OfferDto(
                            id: currentOffer.id,
                            name: currentOffer.name,
                            price: priceToShow,
                            featuredPhoto: currentOffer.featuredPhoto,
                            otherPhotos: currentOffer.otherPhotos,
                            description: currentOffer.description,
                            type: currentOffer.type,
                            offerType: currentOffer.offerType,
                            active: currentOffer.active,
                            approved: currentOffer.approved,
                            numberOfClicks: currentOffer.numberOfClicks,
                            numberOfWatches: currentOffer.numberOfWatches,
                            numberOfBooking: currentOffer.numberOfBooking,
                            numberOfAsks: currentOffer.numberOfAsks,
                            createdOn: currentOffer.createdOn,
                            creatorId: currentOffer.creatorId,
                            products: currentOffer.offerType == 1 ? _customProducts : currentOffer.products,
                          );

                          Navigator.of(context).pushNamed(AppRoutes.cart, arguments: customizedOffer);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOfferItem(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppColors(context).success, size: 20.sp),
          12.horizontalSpace,
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.text14w500(color: AppColors(context).textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableOfferItem(
    BuildContext context,
    ProductDto product,
    bool isSelected,
    int quantity,
    AppColors colors,
  ) {
    final String imageUrl = (product.photo != null && product.photo!.isNotEmpty)
        ? (product.photo!.startsWith('http') ? product.photo! : '${ApiConstants.streamUrl}${product.photo}')
        : '';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(8.r),
      decoration: BoxDecoration(
        color: isSelected ? colors.primary.withValues(alpha: 0.03) : Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isSelected ? colors.primary.withValues(alpha: 0.15) : colors.border.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Checkbox to Toggle item inclusion
          Checkbox(
            value: isSelected,
            activeColor: colors.primary,
            onChanged: (val) => _toggleProduct(product, val),
          ),
          4.horizontalSpace,

          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: SizedBox(
              width: 48.w,
              height: 48.h,
              child: imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: colors.shimmerBase),
                      errorWidget: (_, __, ___) => Container(
                        color: colors.background,
                        child: Icon(Icons.fastfood_rounded, color: colors.textHint, size: 20.sp),
                      ),
                    )
                  : Container(
                      color: colors.background,
                      child: Icon(Icons.fastfood_rounded, color: colors.textHint, size: 20.sp),
                    ),
            ),
          ),
          12.horizontalSpace,

          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name ?? 'منتج',
                  style: AppTextStyles.text13w700(color: colors.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.verticalSpace,
                Text(
                  '${product.price} ${AppStrings.currency}',
                  style: AppTextStyles.text11w700(color: colors.primary),
                ),
              ],
            ),
          ),

          // Stepper (+ / -)
          Row(
            children: [
              _buildStepButton(
                icon: Icons.remove,
                onTap: () => _updateQuantity(product, -1),
                colors: colors,
                enabled: isSelected,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  '$quantity',
                  style: AppTextStyles.text14w700(color: isSelected ? colors.textPrimary : colors.textHint),
                ),
              ),
              _buildStepButton(
                icon: Icons.add,
                onTap: () => _updateQuantity(product, 1),
                colors: colors,
                enabled: isSelected,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback onTap,
    required AppColors colors,
    bool enabled = true,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(5.r),
        decoration: BoxDecoration(
          color: enabled ? colors.background : colors.divider.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: colors.border, width: 0.8),
        ),
        child: Icon(
          icon,
          size: 14.sp,
          color: enabled ? colors.textPrimary : colors.textHint.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Bottom Sheet implementation to select vendor products
class _AddProductBottomSheet extends ConsumerStatefulWidget {
  final int vendorId;
  final AppColors colors;
  const _AddProductBottomSheet({required this.vendorId, required this.colors});

  @override
  ConsumerState<_AddProductBottomSheet> createState() => _AddProductBottomSheetState();
}

class _AddProductBottomSheetState extends ConsumerState<_AddProductBottomSheet> {
  List<ProductDetailDto> _allProducts = [];
  List<ProductDetailDto> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final result = await ref.read(homeApiServiceProvider).getVendorProducts(creatorId: widget.vendorId);
    if (!mounted) return;
    result.when(
      success: (response) {
        setState(() {
          _allProducts = response.result ?? [];
          _filteredProducts = _allProducts;
          _isLoading = false;
        });
      },
      failure: (error) {
        setState(() {
          _isLoading = false;
        });
        CustomToast.error(context, error.message ?? 'فشل تحميل المنتجات');
      },
    );
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts
            .where((p) => p.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // Drag handle
          12.verticalSpace,
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: colors.divider,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          16.verticalSpace,

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'إضافة منتج من هذا المتجر',
                  style: AppTextStyles.text16w700(color: colors.textPrimary),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          8.verticalSpace,

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: TextField(
              onChanged: _filterProducts,
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: colors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: colors.border),
                ),
              ),
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ),
          16.verticalSpace,

          // Products List
          Expanded(
            child: _isLoading
                ? const Center(child: LoadingButton())
                : _filteredProducts.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty ? 'لا توجد منتجات متاحة في هذا المتجر' : 'لم يتم العثور على منتجات مطابقة',
                          style: TextStyle(fontFamily: 'Cairo', color: colors.textHint),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        itemCount: _filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = _filteredProducts[index];
                          final String imageUrl = (product.photo != null && product.photo!.isNotEmpty)
                              ? (product.photo!.startsWith('http') ? product.photo! : '${ApiConstants.streamUrl}${product.photo}')
                              : '';

                          return Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: colors.border),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: SizedBox(
                                    width: 50.w,
                                    height: 50.h,
                                    child: imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: imageUrl,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) => Container(color: colors.shimmerBase),
                                            errorWidget: (_, __, ___) => Container(
                                              color: colors.background,
                                              child: Icon(Icons.fastfood_rounded, color: colors.textHint, size: 22.sp),
                                            ),
                                          )
                                        : Container(
                                            color: colors.background,
                                            child: Icon(Icons.fastfood_rounded, color: colors.textHint, size: 22.sp),
                                          ),
                                  ),
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name ?? 'منتج',
                                        style: AppTextStyles.text14w700(color: colors.textPrimary),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      4.verticalSpace,
                                      Text(
                                        '${product.price} ${AppStrings.currency}',
                                        style: AppTextStyles.text12w700(color: colors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context, product),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  ),
                                  child: const Text(
                                    'إضافة',
                                    style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
