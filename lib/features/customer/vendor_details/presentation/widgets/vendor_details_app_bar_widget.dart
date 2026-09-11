import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class VendorDetailsAppBarWidget extends StatelessWidget {
  const VendorDetailsAppBarWidget({
    super.key,
    required this.vendor,
    required this.colors,
    this.onFavoriteTap,
    this.isFavorite = false,
  });

  final UserDto vendor;
  final AppColors colors;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;

  String _formatImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '${ApiConstants.streamUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final bool isMarket = vendor.role == 1;
    final String? vendorPhoto = vendor.photo ?? vendor.avatar;
    final String vendorImageUrl = _formatImageUrl(vendorPhoto);

    return SliverAppBar(
      expandedHeight: 220.h,
      pinned: true,
      elevation: 0,
      backgroundColor: colors.surface,
      automaticallyImplyLeading: false,
      leadingWidth: 54.w,
      leading: Padding(
        padding: EdgeInsetsDirectional.only(start: 12.w),
        child: Center(
          child: CustomArrowBack(
            color: Colors.white,
            iconColor: Colors.black87,
            isCircular: true,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(8.r),
          ),
        ),
      ),
      actions: [
        // Favorite Icon Button
        GestureDetector(
          onTap: onFavoriteTap,
          child: Container(
            width: 36.r,
            height: 36.r,
            margin: EdgeInsetsDirectional.only(end: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 18.sp,
              color: isFavorite ? Colors.redAccent : Colors.black87,
            ),
          ),
        ),
      ],
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double top = constraints.biggest.height;
          final bool isCollapsed = top <= (kToolbarHeight + MediaQuery.of(context).padding.top + 20);

          return FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(
              left: 54.w,
              right: 140.w,
              bottom: 14.h,
            ),
            centerTitle: true,
            title: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isCollapsed ? 1.0 : 0.0,
              child: Text(
                vendor.name ?? (isMarket ? 'المتجر' : 'المطعم'),
                style: AppTextStyles.text14w700(color: colors.textPrimary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                // Cover Image
                vendorImageUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: vendorImageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: colors.shimmerBase),
                        errorWidget: (_, __, ___) => _placeholderBg(colors, isMarket),
                      )
                    : _placeholderBg(colors, isMarket),

                // Top Subtle Gradient for Button Legibility
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 90.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.35),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _placeholderBg(AppColors colors, bool isMarket) => Container(
        color: colors.containerBackground,
        child: Icon(
          isMarket ? Icons.storefront_rounded : Icons.restaurant_rounded,
          size: 64.sp,
          color: colors.border,
        ),
      );
}
