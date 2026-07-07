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

/// العروض العادية (غير القابلة للتعديل - offerType == 0)
class HomeTodaysOffers extends ConsumerWidget {
  const HomeTodaysOffers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final homeState = ref.watch(homeProvider);

    // Loading state
    if (homeState.status == HomeStatus.loading && homeState.offers.isEmpty) {
      return SizedBox(
        height: 210.h,
        child: const Center(child: LoadingButton()),
      );
    }

    final nonEditableOffers = homeState.offers.where((o) => o.offerType == 0).toList();

    // لو مفيش عروض - اخفي السيكشن ده
    if (nonEditableOffers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeeAllWidget(
          title: 'عروض خاصة',
          onTap: () {
            context.pushNamed(AppRoutes.StoreScreen, arguments: 'عروض خاصة');
          },
        ),
        SizedBox(
          height: 190.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: nonEditableOffers.length,
            itemBuilder: (context, index) {
              final offer = nonEditableOffers[index];
              final String? featuredPhoto = offer.featuredPhoto;
              final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
                  ? (featuredPhoto.startsWith('http')
                      ? featuredPhoto
                      : '${ApiConstants.streamUrl}$featuredPhoto')
                  : '';

              return _buildOfferCard(
                context: context,
                colors: colors,
                title: offer.name ?? '',
                subtitle: offer.description ?? 'عرض مميز لفترة محدودة',
                imageUrl: imageUrl,
                badgeText: 'عرض خاص',
                badgeColor: colors.primary,
                onTap: () {
                  context.pushNamed(AppRoutes.specialOfferDetails, arguments: offer);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

/// العروض القابلة للتعديل (offerType == 1)
class HomeEditableOffers extends ConsumerWidget {
  const HomeEditableOffers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors(context);
    final homeState = ref.watch(homeProvider);

    // Loading state
    if (homeState.status == HomeStatus.loading && homeState.offers.isEmpty) {
      return const SizedBox.shrink();
    }

    final editableOffers = homeState.offers.where((o) => o.offerType == 1).toList();

    // لو مفيش عروض قابلة للتعديل - اخفي السيكشن ده
    if (editableOffers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SeeAllWidget(
          title: 'عروض اليوم',
          onTap: () {
            context.pushNamed(AppRoutes.StoreScreen, arguments: 'عروض اليوم');
          },
        ),
        SizedBox(
          height: 190.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: editableOffers.length,
            itemBuilder: (context, index) {
              final offer = editableOffers[index];
              final String? featuredPhoto = offer.featuredPhoto;
              final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
                  ? (featuredPhoto.startsWith('http')
                      ? featuredPhoto
                      : '${ApiConstants.streamUrl}$featuredPhoto')
                  : '';

              return _buildOfferCard(
                context: context,
                colors: colors,
                title: offer.name ?? '',
                subtitle: offer.description ?? 'صمم عرضك المفضل الآن',
                imageUrl: imageUrl,
                badgeText: 'قابل للتعديل 🛠️',
                badgeColor: colors.secondary,
                onTap: () {
                  context.pushNamed(AppRoutes.specialOfferDetails, arguments: offer);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

Widget _buildOfferCard({
  required BuildContext context,
  required AppColors colors,
  required String title,
  required String subtitle,
  required String imageUrl,
  required String badgeText,
  required Color badgeColor,
  required VoidCallback onTap,
}) {
  return Container(
    width: 160.w,
    margin: EdgeInsets.only(left: 12.w),
    decoration: BoxDecoration(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
      border: Border.all(color: colors.primary.withValues(alpha: 0.25), width: 1.2),
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
                  // Offer Image
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
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    Container(color: colors.shimmerBase),
                                errorWidget: (_, __, ___) => Icon(
                                  Icons.local_offer_rounded,
                                  color: colors.primary,
                                  size: 32.sp,
                                ),
                              )
                            : Icon(
                                Icons.local_offer_rounded,
                                color: colors.primary,
                                size: 32.sp,
                              ),
                      ),
                    ),
                  ),
                  8.verticalSpace,
                  Text(
                    title,
                    style: AppTextStyles.text12w700(color: colors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.verticalSpace,
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
            // Badge
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
                      color: badgeColor.withValues(alpha: 0.3),
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
