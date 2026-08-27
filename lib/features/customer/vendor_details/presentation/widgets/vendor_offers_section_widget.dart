import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';

class VendorOffersSectionWidget extends StatelessWidget {
  const VendorOffersSectionWidget({
    super.key,
    required this.offers,
    required this.colors,
  });

  final List<OfferDto> offers;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    if (offers.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Text(
              isArabic ? 'عروض هذا المتجر 🎁' : 'Shop Offers 🎁',
              style: AppTextStyles.text13w700(color: colors.textPrimary),
            ),
          ),
          SizedBox(
            height: 95.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                final String? featuredPhoto = offer.featuredPhoto;
                final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
                    ? (featuredPhoto.startsWith('http') ? featuredPhoto : '${ApiConstants.streamUrl}$featuredPhoto')
                    : '';
                final bool hasProducts = offer.products != null && offer.products!.isNotEmpty;

                return GestureDetector(
                  onTap: hasProducts
                      ? () {
                          Navigator.of(context).pushNamed(AppRoutes.specialOfferDetails, arguments: offer);
                        }
                      : null,
                  child: Container(
                    width: 250.w,
                    margin: EdgeInsets.only(left: 10.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14.r),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F2027), Color(0xFF203A43)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14.r),
                      child: Stack(
                        children: [
                          if (imageUrl.isNotEmpty)
                            Positioned.fill(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: colors.border,
                                  child: const Center(child: LoadingButton(size: 15)),
                                ),
                                errorWidget: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: isArabic ? Alignment.centerRight : Alignment.centerLeft,
                                  end: isArabic ? Alignment.centerLeft : Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.8),
                                    Colors.black.withValues(alpha: 0.15),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.r),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.18),
                                          borderRadius: BorderRadius.circular(5.r),
                                        ),
                                        child: Text(
                                          offer.offerType == 1
                                              ? (isArabic ? 'قابل للتعديل 🛠️' : 'Editable 🛠️')
                                              : (isArabic ? 'عرض خاص' : 'Special Offer'),
                                          style: TextStyle(
                                            fontSize: 7.5.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'Cairo',
                                          ),
                                        ),
                                      ),
                                      3.verticalSpace,
                                      Text(
                                        offer.name ?? '',
                                        style: TextStyle(
                                          fontSize: 11.5.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'Cairo',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      1.verticalSpace,
                                      Text(
                                        offer.description ?? '',
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontFamily: 'Cairo',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                6.horizontalSpace,
                                if (hasProducts)
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                    decoration: BoxDecoration(
                                      color: colors.secondary,
                                      borderRadius: BorderRadius.circular(8.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: colors.secondary.withValues(alpha: 0.25),
                                          blurRadius: 3,
                                          offset: const Offset(0, 1.5),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      '${offer.price.toStringAsFixed(0)} ${AppStrings.currency}',
                                      style: TextStyle(
                                        fontSize: 9.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontFamily: 'Cairo',
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
                );
              },
            ),
          ),
          6.verticalSpace,
        ],
      ),
    );
  }
}

class VendorOfferCardWidget extends StatelessWidget {
  const VendorOfferCardWidget({super.key, required this.offer, required this.colors});

  final OfferDto offer;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String? featuredPhoto = offer.featuredPhoto;
    final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
        ? (featuredPhoto.startsWith('http') ? featuredPhoto : '${ApiConstants.streamUrl}$featuredPhoto')
        : '';
    final bool hasProducts = offer.products != null && offer.products!.isNotEmpty;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16.r),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: hasProducts
            ? () => Navigator.of(context).pushNamed(AppRoutes.specialOfferDetails, arguments: offer)
            : null,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          height: 125.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.r),
                  bottomLeft: Radius.circular(16.r),
                ),
                child: Stack(
                  children: [
                    imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            width: 115.w,
                            height: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(color: colors.shimmerBase),
                            errorWidget: (_, __, ___) => Image.asset(
                              'assets/image/logo.png',
                              width: 115.w,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Image.asset(
                            'assets/image/logo.png',
                            width: 115.w,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEE9C20),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          offer.offerType == 1
                              ? (isArabic ? 'عرض حصري 🔥' : 'Exclusive 🔥')
                              : (isArabic ? 'عرض خاص 🎁' : 'Special 🎁'),
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.name ?? '',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              fontFamily: 'Cairo',
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          4.verticalSpace,
                          Text(
                            offer.description ?? '',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                              fontFamily: 'Cairo',
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${offer.price.toStringAsFixed(0)} ${AppStrings.currency}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w900,
                              color: colors.primary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                            decoration: BoxDecoration(
                              gradient: AppColors.gradient,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.25),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isArabic ? 'التفاصيل' : 'Details',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                                3.horizontalSpace,
                                Icon(
                                  isArabic ? Icons.arrow_back_ios_new_rounded : Icons.arrow_forward_ios_rounded,
                                  color: Colors.white,
                                  size: 10.sp,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExclusiveOffersScreen extends StatelessWidget {
  const ExclusiveOffersScreen({
    super.key,
    required this.offers,
    required this.vendorName,
  });

  final List<OfferDto> offers;
  final String vendorName;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          'عروض $vendorName',
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: offers.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_outlined, size: 64.sp, color: colors.textHint),
                  12.verticalSpace,
                  Text(
                    'لا توجد عروض حصرية حالياً',
                    style: AppTextStyles.text16w600(color: colors.textSecondary),
                  ),
                ],
              ),
            )
          : GridView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
              ),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                return SquareOfferCardWidget(offer: offer, colors: colors);
              },
            ),
    );
  }
}

class SquareOfferCardWidget extends StatelessWidget {
  const SquareOfferCardWidget({super.key, required this.offer, required this.colors});

  final OfferDto offer;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final String? featuredPhoto = offer.featuredPhoto;
    final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
        ? (featuredPhoto.startsWith('http') ? featuredPhoto : '${ApiConstants.streamUrl}$featuredPhoto')
        : '';
    final bool hasProducts = offer.products != null && offer.products!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: colors.border.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20.r),
          onTap: hasProducts
              ? () => Navigator.of(context).pushNamed(AppRoutes.specialOfferDetails, arguments: offer)
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: colors.shimmerBase),
                              errorWidget: (_, __, ___) => Image.asset('assets/image/logo.png', fit: BoxFit.cover),
                            )
                          : Image.asset('assets/image/logo.png', fit: BoxFit.cover),
                      Positioned(
                        top: 8.r,
                        right: 8.r,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEE9C20),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            offer.offerType == 1
                                ? (isArabic ? 'عرض حصري 🔥' : 'Exclusive 🔥')
                                : (isArabic ? 'عرض خاص 🎁' : 'Special 🎁'),
                            style: TextStyle(
                              fontSize: 9.5.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.name ?? '',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                              fontFamily: 'Cairo',
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          3.verticalSpace,
                          Text(
                            offer.description ?? '',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: colors.textSecondary,
                              fontFamily: 'Cairo',
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${offer.price.toStringAsFixed(0)} ${AppStrings.currency}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              color: colors.primary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              gradient: AppColors.gradient,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              isArabic ? 'التفاصيل' : 'Details',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
