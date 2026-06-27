import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/widgets/see_all_widget.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/home/presentation/riverpod/home_provider.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';

class HomeTodaysOffers extends ConsumerWidget {
  const HomeTodaysOffers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final homeState = ref.watch(homeProvider);

    // List of today's offers cards
    final List<Widget> offerCards = [];

    // 1. Build cards for real backend offers
    for (final offer in homeState.offers) {
      final String? featuredPhoto = offer.featuredPhoto;
      final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
          ? (featuredPhoto.startsWith('http')
              ? featuredPhoto
              : '${ApiConstants.streamUrl}$featuredPhoto')
          : '';

      offerCards.add(
        _buildOfferCard(
          context: context,
          colors: colors,
          badgeText: 'عرض خاص',
          badgeColor: colors.primary,
          title: offer.name ?? '',
          subtitle: offer.description ?? 'عرض مميز لفترة محدودة',
          imageUrl: imageUrl,
          isAsset: false,
          onTap: () {
            context.pushNamed(AppRoutes.specialOfferDetails, arguments: offer);
          },
        ),
      );
    }

    // 2. Add beautiful mock promotion cards matching the mockup
    // Offer 1: 15% discount on burgers
    offerCards.add(
      _buildOfferCard(
        context: context,
        colors: colors,
        badgeText: 'خصم 15%',
        badgeColor: colors.secondary, // Orange
        title: 'خصم 15% على البرجر',
        subtitle: 'أطلب من أقرب مطعم برجر',
        imageUrl: 'assets/image/Delivery-amico.png',
        isAsset: true,
        onTap: () {
          context.pushNamed(
            AppRoutes.StoreScreen,
            arguments: 'مطاعم',
          );
        },
      ),
    );

    // Offer 2: Free Delivery
    offerCards.add(
      _buildOfferCard(
        context: context,
        colors: colors,
        badgeText: 'توصيل مجاني',
        badgeColor: const Color(0xFF00796B), // Teal
        title: 'توصيل مجاني لأول طلب',
        subtitle: 'بدون حد أدنى للطلب اليوم',
        imageUrl: 'assets/image/Delivery-bro.png',
        isAsset: true,
        onTap: () {
          context.pushNamed(
            AppRoutes.StoreScreen,
            arguments: 'المحلات',
          );
        },
      ),
    );

    // Offer 3: 20% off sweets
    offerCards.add(
      _buildOfferCard(
        context: context,
        colors: colors,
        badgeText: 'خصم 20%',
        badgeColor: Colors.deepPurple,
        title: 'خصم 20% على الحلويات',
        subtitle: 'تشكيلة لذيذة من الحلويات',
        imageUrl: 'assets/image/time flies-rafiki.png',
        isAsset: true,
        onTap: () {
          context.pushNamed(
            AppRoutes.StoreScreen,
            arguments: 'حلويات',
          );
        },
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeeAllWidget(
          title: 'عروض اليوم',
          onTap: () {
            context.pushNamed(
              AppRoutes.StoreScreen,
              arguments: 'عروض اليوم',
            );
          },
        ),
        SizedBox(
          height: 190.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: offerCards.length,
            itemBuilder: (context, index) => offerCards[index],
          ),
        ),
      ],
    );
  }

  Widget _buildOfferCard({
    required BuildContext context,
    required AppColors colors,
    required String badgeText,
    required Color badgeColor,
    required String title,
    required String subtitle,
    required String imageUrl,
    required bool isAsset,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(left: 12.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: colors.border.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Offer Image Container
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: imageUrl.isNotEmpty
                              ? (isAsset
                                  ? Image.asset(
                                      imageUrl,
                                      fit: BoxFit.contain,
                                    )
                                  : CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: colors.shimmerBase,
                                      ),
                                      errorWidget: (_, __, ___) => Icon(
                                        Icons.local_offer_rounded,
                                        color: colors.textHint,
                                        size: 32.sp,
                                      ),
                                    ))
                              : Icon(
                                  Icons.local_offer_rounded,
                                  color: colors.textHint,
                                  size: 32.sp,
                                ),
                        ),
                      ),
                    ),
                    8.verticalSpace,

                    // Title
                    Text(
                      title,
                      style: AppTextStyles.text12w700(
                        color: colors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    2.verticalSpace,

                    // Subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: colors.textHint,
                        fontFamily: 'Cairo',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Offer Badge in the top-right/left
              Positioned(
                top: 8.h,
                left: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w900,
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
    );
  }
}
