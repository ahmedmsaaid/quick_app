import 'dart:ui';
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

class SpecialOfferDetailsScreen extends ConsumerWidget {
  final OfferDto? offer;

  const SpecialOfferDetailsScreen({super.key, this.offer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);

    if (offer == null) {
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

    final offerAsync = ref.watch(getOfferDetailsProvider(offer!.id));

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
        data: (detailedOffer) => _buildContent(context, ref, detailedOffer, colors),
        loading: () => _buildContent(context, ref, offer!, colors, isLoading: true),
        error: (err, stack) => _buildContent(context, ref, offer!, colors, errorMsg: err.toString()),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
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
                                    AppStrings.limitedTimeOfferLabel,
                                    style: AppTextStyles.text11w700(color: colors.error),
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
                      Text(
                        AppStrings.offerContentsLabel,
                        style: AppTextStyles.text16w700(color: colors.textPrimary),
                      ),
                      10.verticalSpace,
                      Container(
                        width: double.infinity,
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                        ),
                      ),
                      if (isLoading) ...[
                        15.verticalSpace,
                        Center(
                          child: SizedBox(
                            width: 24.r,
                            height: 24.r,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: colors.primary),
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
                          '${currentOffer.price} ${AppStrings.currency}',
                          style: AppTextStyles.text22w700(color: colors.primary),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 170.w,
                      child: CustomAppButton(
                        text: AppStrings.orderNowBtn,
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.cart, arguments: currentOffer);
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
}
