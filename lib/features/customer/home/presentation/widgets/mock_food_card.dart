import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/customer/home/data/models/offer_model.dart';

class MockFoodCard extends StatelessWidget {
  final OfferDto offer;
  final VoidCallback onTap;

  const MockFoodCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final String? featuredPhoto = offer.featuredPhoto;
    final String imageUrl = (featuredPhoto != null && featuredPhoto.isNotEmpty)
        ? (featuredPhoto.startsWith('http')
            ? featuredPhoto
            : '${ApiConstants.streamUrl}$featuredPhoto')
        : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: colors.border, width: 1.0),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Expanded(
              child: Container(
                width: double.infinity,
                margin: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: colors.containerBackground,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: colors.shimmerBase),
                          errorWidget: (_, __, ___) => Icon(
                            Icons.fastfood_rounded,
                            size: 30.sp,
                            color: colors.textHint,
                          ),
                        )
                      : Icon(
                          Icons.fastfood_rounded,
                          size: 30.sp,
                          color: colors.textHint,
                        ),
                ),
              ),
            ),
            // Details Section
            Padding(
              padding: EdgeInsets.fromLTRB(10.w, 0, 10.w, 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.name ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      fontFamily: 'Cairo',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  3.verticalSpace,
                  Text(
                    AppStrings.startingFrom,
                    style: TextStyle(
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w500,
                      color: colors.textSecondary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  1.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${offer.price} ${AppStrings.currency}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: colors.primary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: colors.containerBackground,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Icon(
                          Icons.add_rounded,
                          color: colors.textPrimary,
                          size: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
