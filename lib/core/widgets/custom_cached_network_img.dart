import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/shimmer_palcholder.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    super.key,
    required this.imgUrl,
    required this.imgRadius,
    required this.imgWidth,
    required this.imgHeight,
    this.placholderRadius,
    this.placholderWidth,
    this.placholderHeight,
    this.fit,
  });

  final String imgUrl;
  final double imgRadius;
  final double imgWidth;
  final double imgHeight;
  final double? placholderRadius;
  final double? placholderWidth;
  final double? placholderHeight;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      clipBehavior: Clip.antiAlias,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(imgRadius.r),
        topRight: Radius.circular(imgRadius.r),
      ),
      child: CachedNetworkImage(
        imageUrl: imgUrl,
        width: imgWidth.w,
        height: imgHeight.h,
        fit: fit ?? BoxFit.cover,
        placeholder: (context, url) => ShimmerPlaceholder(
          radius: placholderRadius ?? imgRadius,
          width: placholderWidth ?? imgWidth,
          height: placholderHeight ?? imgHeight,
        ),
        errorWidget: (context, url, error) =>
            Icon(Icons.error, color: AppColors(context).primary),
      ),
    );
  }
}
