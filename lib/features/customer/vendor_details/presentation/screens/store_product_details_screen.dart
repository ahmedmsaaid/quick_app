import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/favorites/presentation/riverpod/favorites_provider.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/rating_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:base_app/features/customer/home/data/rating_api_service.dart';
import 'package:base_app/features/customer/home/data/models/rating_models.dart';
import 'package:base_app/core/network/api_result.dart';

class StoreProductDetailsScreen extends ConsumerStatefulWidget {
  const StoreProductDetailsScreen({super.key, required this.product, this.vendorId});

  final ProductDetailDto product;
  final int? vendorId;

  @override
  ConsumerState<StoreProductDetailsScreen> createState() =>
      _StoreProductDetailsScreenState();
}

class _StoreProductDetailsScreenState
    extends ConsumerState<StoreProductDetailsScreen>
    with SingleTickerProviderStateMixin {
  int _quantity = 1;
  late AnimationController _addController;
  late Animation<double> _scaleAnim;

  ProductDetailDto get product => widget.product;

  double get effectivePrice => product.hasDiscount
      ? product.price * (1 - product.discountPercentage / 100)
      : product.price;

  @override
  void initState() {
    super.initState();
    _addController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _addController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  void _addToCart() async {
    await _addController.forward();
    await _addController.reverse();
    ref.read(cartProvider.notifier).addItem(product, quantity: _quantity, vendorId: widget.vendorId);
    if (mounted) {
      final colors = AppColors(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(children: [
          Icon(Icons.check_circle, color: Colors.white, size: 18.sp),
          8.horizontalSpace,
          Text(AppStrings.addedToCartSuccessMsg),
        ]),
        backgroundColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _showRatingBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductRatingBottomSheet(productId: widget.product.id);
      },
    );
  }

  void _showProductRatingsListBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _ProductRatingsListBottomSheet(product: widget.product);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final screenH = MediaQuery.sizeOf(context).height;
    final String? photo = product.photo;
    final String imageUrl = (photo != null && photo.isNotEmpty)
        ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
        : '';

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
          Consumer(
            builder: (context, ref, child) {
              final bool isFavorite = ref.watch(favoritesProvider).any((p) => p.id == product.id);
              return GestureDetector(
                onTap: () => ref.read(favoritesProvider.notifier).toggleFavorite(product),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.redAccent : Colors.white,
                    size: 20.sp,
                  ),
                ),
              );
            },
          ),
          12.horizontalSpace,
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
      body: Stack(
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
                        placeholder: (_, __) => Container(color: colors.shimmerBase),
                        errorWidget: (_, __, ___) => Container(
                          color: colors.shimmerBase,
                          child: Icon(Icons.fastfood, size: 80.sp, color: colors.textHint),
                        ),
                      )
                    : Container(
                        color: colors.shimmerBase,
                        child: Icon(Icons.fastfood, size: 80.sp, color: colors.textHint),
                      ),
                // Premium Ambient Dark Gradients
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
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
                    padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 110.h),
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

                        // ─── Main Info Floating Style Card ───
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
                              // Row: Availability Badge + Discount Badge
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Pulsating Availability dot indicator inside pill
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                    decoration: BoxDecoration(
                                      color: product.isAvailable
                                          ? colors.success.withValues(alpha: 0.08)
                                          : colors.error.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: product.isAvailable
                                            ? colors.success.withValues(alpha: 0.25)
                                            : colors.error.withValues(alpha: 0.25),
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
                                                color: product.isAvailable
                                                    ? colors.success.withValues(alpha: 0.3)
                                                    : colors.error.withValues(alpha: 0.3),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            Container(
                                              width: 5.w,
                                              height: 5.w,
                                              decoration: BoxDecoration(
                                                color: product.isAvailable
                                                    ? colors.success
                                                    : colors.error,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ],
                                        ),
                                        6.horizontalSpace,
                                        Text(
                                          product.isAvailable ? 'متاح الآن' : 'غير متوفر حالياً',
                                          style: AppTextStyles.text11w700(
                                            color: product.isAvailable ? colors.success : colors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Discount Badge
                                  if (product.hasDiscount)
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                      decoration: BoxDecoration(
                                        color: colors.secondary,
                                        borderRadius: BorderRadius.circular(12.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colors.secondary.withValues(alpha: 0.2),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: Text(
                                        'خصم ${product.discountPercentage.toStringAsFixed(0)}%',
                                        style: AppTextStyles.text11w700(color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                              14.verticalSpace,

                              // Product Title
                              Text(
                                product.name ?? '',
                                style: AppTextStyles.text22w700(color: colors.textPrimary),
                              ),
                              12.verticalSpace,

                              // Rating Box link
                              GestureDetector(
                                onTap: () => _showProductRatingsListBottomSheet(context),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: Row(
                                    children: [
                                      Icon(Icons.star_rounded, color: Colors.amber, size: 20.sp),
                                      6.horizontalSpace,
                                      Text(
                                        product.rating.toStringAsFixed(1),
                                        style: AppTextStyles.text14w700(color: colors.textPrimary),
                                      ),
                                      8.horizontalSpace,
                                      Text(
                                        "(عرض الآراء)",
                                        style: AppTextStyles.text12w600(color: colors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        24.verticalSpace,

                        // ─── Description Card ───
                        if (product.description != null && product.description!.isNotEmpty) ...[
                          Text(
                            'التفاصيل والوصف',
                            style: AppTextStyles.text16w700(color: colors.textPrimary),
                          ),
                          10.verticalSpace,
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: BorderRadius.circular(18.r),
                              border: Border.all(color: colors.border.withValues(alpha: 0.6)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline_rounded, color: colors.primary, size: 18.sp),
                                10.horizontalSpace,
                                Expanded(
                                  child: Text(
                                    product.description!,
                                    style: AppTextStyles.text14w400(color: colors.textSecondary).copyWith(height: 1.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          24.verticalSpace,
                        ],

                        // ─── Price & Quantity Selector Card ───
                        Container(
                          padding: EdgeInsets.all(18.r),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Price details
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.hasDiscount) ...[
                                    Text(
                                      '${product.price.toStringAsFixed(0)} ${AppStrings.currency}',
                                      style: AppTextStyles.text14w400(color: colors.textHint).copyWith(
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                    4.verticalSpace,
                                  ],
                                  Text(
                                    '${effectivePrice.toStringAsFixed(0)} ${AppStrings.currency}',
                                    style: AppTextStyles.text24w700(color: colors.primary),
                                  ),
                                ],
                              ),
                              // Circular Quantity controls
                              Row(
                                children: [
                                  _QtyBtn(
                                    icon: Icons.remove_rounded,
                                    onTap: () { if (_quantity > 1) setState(() => _quantity--); },
                                    colors: colors,
                                    enabled: _quantity > 1,
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                                    child: Text('$_quantity', style: AppTextStyles.text18w700(color: colors.textPrimary)),
                                  ),
                                  _QtyBtn(
                                    icon: Icons.add_rounded,
                                    onTap: () => setState(() => _quantity++),
                                    colors: colors,
                                    enabled: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        24.verticalSpace,

                        // ─── Rating banner ───
                        InkWell(
                          onTap: () => _showRatingBottomSheet(context),
                          borderRadius: BorderRadius.circular(20.r),
                          child: Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(color: Colors.amber.withValues(alpha: 0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10.r),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.rate_review_rounded, color: Colors.amber[700], size: 22.sp),
                                ),
                                12.horizontalSpace,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ما رأيك في هذا المنتج؟',
                                        style: AppTextStyles.text14w700(color: colors.textPrimary),
                                      ),
                                      4.verticalSpace,
                                      Text(
                                        'قيم المنتج وشاركنا رأيك وتجربتك',
                                        style: AppTextStyles.text11w400(color: colors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios_rounded, color: colors.textHint, size: 14.sp),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),



          // ─── 4. Floating Bottom Add to Cart Bar ───
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
                  child: ScaleTransition(
                    scale: _scaleAnim,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16.r),
                        onTap: product.isAvailable ? _addToCart : null,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          decoration: BoxDecoration(
                            gradient: product.isAvailable ? AppColors.gradient : null,
                            color: product.isAvailable ? null : colors.border,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: product.isAvailable
                                ? [
                                    BoxShadow(
                                      color: colors.primary.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    )
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20.sp),
                              10.horizontalSpace,
                              Text(
                                product.isAvailable
                                    ? 'أضف للعربة — ${(effectivePrice * _quantity).toStringAsFixed(0)} ${AppStrings.currency}'
                                    : 'غير متوفر',
                                style: AppTextStyles.text15w700(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quantity button ───────────────────────────────────────────
class _QtyBtn extends StatelessWidget {
  const _QtyBtn({required this.icon, required this.onTap, required this.colors, required this.enabled});

  final IconData icon;
  final VoidCallback onTap;
  final AppColors colors;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: enabled ? colors.tealLight : colors.border,
          shape: BoxShape.circle,
          border: Border.all(
            color: enabled ? colors.primary.withValues(alpha: 0.35) : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          color: enabled ? colors.primary : colors.textHint,
          size: 18.sp,
        ),
      ),
    );
  }
}

class _ProductRatingBottomSheet extends ConsumerStatefulWidget {
  final int productId;
  final VoidCallback? onSuccess;
  const _ProductRatingBottomSheet({required this.productId, this.onSuccess});

  @override
  ConsumerState<_ProductRatingBottomSheet> createState() => _ProductRatingBottomSheetState();
}

class _ProductRatingBottomSheetState extends ConsumerState<_ProductRatingBottomSheet> {
  int _rating = 5;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final note = _commentController.text.trim();
    final success = await ref.read(ratingProvider.notifier).submitProductRating(
          productId: widget.productId,
          value: _rating,
          note: note.isEmpty ? "منتج جيد جداً" : note,
        );

    if (!mounted) return;

    if (success) {
      CustomToast.success(context, AppStrings.thanksForRatingMsg);
      Navigator.pop(context);
      if (widget.onSuccess != null) widget.onSuccess!();
    } else {
      final errorMsg = ref.read(ratingProvider).errorMessage;
      CustomToast.error(context, errorMsg ?? AppStrings.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final ratingState = ref.watch(ratingProvider);
    final isLoading = ratingState.status == RatingStatus.loading;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
        left: 20.w,
        right: 20.w,
        top: 20.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          20.verticalSpace,
          Text(
            'تقييم المنتج',
            style: AppTextStyles.text18w700(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          15.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starIndex = index + 1;
              final isSelected = starIndex <= _rating;
              return IconButton(
                icon: Icon(
                  isSelected ? Icons.star_rounded : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 40.sp,
                ),
                onPressed: isLoading ? null : () => setState(() => _rating = starIndex),
              );
            }),
          ),
          15.verticalSpace,
          CustomTextField(
            controller: _commentController,
            hintText: 'اكتب رأيك حول جودة ومذاق المنتج هنا...',
            maxLines: 3,
            enabled: !isLoading,
          ),
          24.verticalSpace,
          isLoading
              ? const LoadingButton()
              : CustomAppButton(
                  text: 'إرسال التقييم',
                  onPressed: _submit,
                ),
        ],
      ),
    );
  }
}

class _ProductRatingsListBottomSheet extends ConsumerStatefulWidget {
  final ProductDetailDto product;
  const _ProductRatingsListBottomSheet({required this.product});

  @override
  ConsumerState<_ProductRatingsListBottomSheet> createState() => _ProductRatingsListBottomSheetState();
}

class _ProductRatingsListBottomSheetState extends ConsumerState<_ProductRatingsListBottomSheet> {
  List<ProductRatingDto>? _ratings;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRatings();
  }

  Future<void> _loadRatings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await ref.read(ratingApiServiceProvider).getProductRatings(productId: widget.product.id);
    if (!mounted) return;
    result.when(
      success: (response) {
        setState(() {
          _ratings = response.result;
          _isLoading = false;
        });
      },
      failure: (error) {
        setState(() {
          _error = error.message;
          _isLoading = false;
        });
      },
    );
  }

  Widget _avatarFallback(AppColors colors, String name) {
    final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';
    return Container(
      width: 36.r,
      height: 36.r,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Text(
        initial,
        style: AppTextStyles.text13w700(color: colors.primary),
      ),
    );
  }

  Widget _buildSummaryHeader(AppColors colors) {
    final double avg = widget.product.rating;
    final int totalCount = _ratings?.length ?? 0;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    avg.toStringAsFixed(1),
                    style: AppTextStyles.text32w700(color: colors.textPrimary),
                  ),
                  4.horizontalSpace,
                  Text(
                    "/ 5.0",
                    style: AppTextStyles.text14w500(color: colors.textHint),
                  ),
                ],
              ),
              8.verticalSpace,
              Row(
                children: List.generate(5, (index) {
                  final double starVal = index + 1;
                  return Icon(
                    starVal <= avg
                        ? Icons.star_rounded
                        : (starVal - 0.5 <= avg ? Icons.star_half_rounded : Icons.star_border_rounded),
                    color: Colors.amber,
                    size: 18.sp,
                  );
                }),
              ),
              6.verticalSpace,
              Text(
                "بناءً على $totalCount تقييم",
                style: AppTextStyles.text11w400(color: colors.textSecondary),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: colors.primary,
              size: 40.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(AppColors colors) {
    if (_isLoading) {
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 3,
        separatorBuilder: (_, __) => 12.verticalSpace,
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: colors.shimmerBase,
            highlightColor: colors.shimmerHighlight,
            child: Container(
              height: 90.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        },
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, color: colors.error, size: 40.sp),
            12.verticalSpace,
            Text(_error!, style: AppTextStyles.text12w500(color: colors.textSecondary)),
            12.verticalSpace,
            TextButton(
              onPressed: _loadRatings,
              child: Text("إعادة المحاولة", style: AppTextStyles.text13w700(color: colors.primary)),
            ),
          ],
        ),
      );
    }

    if (_ratings == null || _ratings!.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.rate_review_outlined, color: colors.textHint, size: 50.sp),
              16.verticalSpace,
              Text(
                "لا توجد تقييمات بعد",
                style: AppTextStyles.text14w700(color: colors.textPrimary),
              ),
              6.verticalSpace,
              Text(
                "كن أول من يشارك تجربته مع هذا المنتج!",
                style: AppTextStyles.text12w400(color: colors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemCount: _ratings!.length,
      separatorBuilder: (_, __) => 12.verticalSpace,
      itemBuilder: (context, index) {
        final review = _ratings![index];
        final creator = review.creator;
        final name = creator?.name ?? "مستخدم";
        final photo = creator?.photo ?? creator?.avatar;
        final String imgUrl = (photo != null && photo.isNotEmpty)
            ? (photo.startsWith('http') ? photo : '${ApiConstants.streamUrl}$photo')
            : '';

        return Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipOval(
                    child: imgUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imgUrl,
                            width: 36.r,
                            height: 36.r,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: colors.shimmerBase),
                            errorWidget: (_, __, ___) => _avatarFallback(colors, name),
                          )
                        : _avatarFallback(colors, name),
                  ),
                  10.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.text13w700(color: colors.textPrimary),
                        ),
                        4.verticalSpace,
                        Row(
                          children: List.generate(5, (i) {
                            return Icon(
                              i < review.value ? Icons.star_rounded : Icons.star_border_rounded,
                              color: Colors.amber,
                              size: 14.sp,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (review.note != null && review.note!.trim().isNotEmpty) ...[
                10.verticalSpace,
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    review.note!,
                    style: AppTextStyles.text12w500(color: colors.textSecondary).copyWith(height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.75,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + MediaQuery.of(context).viewInsets.bottom + 16.h,
        left: 16.w,
        right: 16.w,
        top: 16.h,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          Text(
            "تقييمات وآراء العملاء",
            style: AppTextStyles.text18w700(color: colors.textPrimary),
            textAlign: TextAlign.center,
          ),
          4.verticalSpace,
          Text(
            widget.product.name ?? "",
            style: AppTextStyles.text12w400(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          16.verticalSpace,

          if (!_isLoading && _error == null && _ratings != null && _ratings!.isNotEmpty) ...[
            _buildSummaryHeader(colors),
            16.verticalSpace,
          ],

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildMainContent(colors),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 12.h),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    return _ProductRatingBottomSheet(
                      productId: widget.product.id,
                      onSuccess: () {
                        _loadRatings();
                      },
                    );
                  },
                );
              },
              icon: Icon(Icons.star_rate_rounded, color: Colors.white, size: 20.sp),
              label: Text(
                "أضف تقييمك الآن",
                style: AppTextStyles.text14w700(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
