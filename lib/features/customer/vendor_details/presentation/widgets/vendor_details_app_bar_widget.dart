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
  });

  final UserDto vendor;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final bool isMarket = vendor.role == 1;
    final String? vendorPhoto = vendor.photo ?? vendor.avatar;
    final String vendorImageUrl = (vendorPhoto != null && vendorPhoto.isNotEmpty)
        ? (vendorPhoto.startsWith('http') ? vendorPhoto : '${ApiConstants.streamUrl}$vendorPhoto')
        : '';

    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      backgroundColor: colors.primary,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: CustomArrowBack(
          color: Colors.black26,
          iconColor: Colors.white,
          isCircular: true,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(8.r),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
        title: Text(
          vendor.name ?? (isMarket ? 'السوق' : 'المطعم'),
          style: AppTextStyles.text16w700(color: Colors.white),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            vendorImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: vendorImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: colors.shimmerBase),
                    errorWidget: (_, __, ___) => _placeholderBg(colors, isMarket),
                  )
                : _placeholderBg(colors, isMarket),
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black87],
                ),
              ),
            ),
            // Vendor info at bottom
            Positioned(
              bottom: 50.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  if (vendor.busy == true || !(vendor.active ?? true))
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: (vendor.busy == true) ? Colors.orange : Colors.red,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        (vendor.busy == true) ? 'مشغول' : 'مغلق',
                        style: AppTextStyles.text10w500(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderBg(AppColors colors, bool isMarket) => Container(
    color: colors.primary,
    child: Icon(isMarket ? Icons.store : Icons.restaurant, size: 60.sp, color: Colors.white30),
  );
}
