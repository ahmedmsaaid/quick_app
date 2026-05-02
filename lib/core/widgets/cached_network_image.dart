import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_svg_image/cached_network_svg_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/utils/assets/app_assets.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String? errorAsset;
  final double? bordWidth;
  final double? height;
  final double? width;
  final Color? borderColor;
  final Color? svgColor;

  final double? radius;
  final bool isCircle;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final Color? backGroundColor;
  final BoxFit fit;

  const CustomNetworkImage.circular({
    this.svgColor,
    super.key,
    required this.radius,
    this.borderColor = Colors.white,
    required this.imageUrl,
    this.bordWidth,
    this.errorAsset,
    this.backGroundColor,
    this.fit = BoxFit.contain,
  }) : isCircle = true,
       height = null,
       width = null,
       padding = null,
       color = null;

  const CustomNetworkImage.rectangle({
    super.key,
    this.svgColor,
    this.height,
    this.width,
    required this.imageUrl,
    this.bordWidth,
    this.borderColor,
    this.errorAsset,
    this.radius,
    this.color,
    this.backGroundColor,
    this.fit = BoxFit.contain,
    this.padding,
  }) : isCircle = false;

  @override
  Widget build(BuildContext context) {
    return isCircle
        ? _buildCircularImage(context)
        : _buildRectangleImage(context);
  }

  Widget _buildCircularImage(BuildContext context) => Container(
    height: radius!,
    width: radius!,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: backGroundColor,
      border: bordWidth != null
          ? Border.all(width: bordWidth!, color: borderColor!)
          : null,
    ),
    child: _buildImage(radius, radius, context),
  );

  Widget _buildRectangleImage(BuildContext context) => Container(
    height: height,
    width: width,
    padding: padding,
    clipBehavior: Clip.antiAliasWithSaveLayer,
    decoration: BoxDecoration(
      color: backGroundColor,
      borderRadius: radius != null ? BorderRadius.circular(radius!) : null,
      border: Border.all(
        width: bordWidth ?? 0,
        color: borderColor ?? AppColors.transparent,
      ),
    ),
    child: _buildImage(width, height, context),
  );

  String _getFullImageUrl(String url) {
    if (url.contains('flagcdn') || url.contains('supabase')) {
      return url;
    } else {
      return " ";
    }
  }

  Widget _buildImage(double? w, double? h, BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      if (imageUrl!.startsWith("http")) {
        final fullUrl = _getFullImageUrl(imageUrl!);

        if (imageUrl!.endsWith(".svg")) {
          return CachedNetworkSVGImage(
            fullUrl,
            fit: fit,
            height: h,
            width: w,
            placeholder: _placeHolder(context),
          );
        } else {
          return CachedNetworkImage(
            imageUrl: fullUrl,
            width: w,
            height: h,
            fit: fit,
            placeholder: (context, url) => _placeHolder(context),
            errorWidget: (context, url, error) => _errorWidget(context),
          );
        }
      } else if (imageUrl!.contains('assets')) {
        return _buildAsset(imageUrl, context);
      } else {
        final fullUrl = _getFullImageUrl(imageUrl!);
        return CachedNetworkImage(
          imageUrl: fullUrl,
          width: w,
          height: h,
          fit: fit,
          placeholder: (context, url) => _placeHolder(context),
          errorWidget: (context, url, error) => _errorWidget(context),
        );
      }
    } else {
      return _errorWidget(context);
    }
  }

  Widget _buildAsset(String? asset, BuildContext context) {
    if (asset != null && asset.isNotEmpty) {
      if (asset.contains('assets')) {
        return asset.endsWith(".svg")
            ? SvgPicture.asset(
                asset,
                fit: fit,
                colorFilter: ColorFilter.mode(
                  svgColor ?? AppColors.transparent,
                  BlendMode.srcIn,
                ),
              )
            : Image.asset(asset, fit: fit);
      } else {
        final file = File(asset);
        if (file.existsSync()) {
          return Image.file(file, fit: BoxFit.cover);
        } else {
          return _errorWidget(context);
        }
      }
    }
    return _errorWidget(context);
  }

  Widget _errorWidget(BuildContext context) {
    if (errorAsset != null) {
      if (errorAsset!.startsWith("http")) {
        return errorAsset!.endsWith(".svg")
            ? CachedNetworkSVGImage(errorAsset!, fit: BoxFit.fill)
            : CachedNetworkImage(imageUrl: errorAsset!, fit: BoxFit.fill);
      } else {
        return errorAsset!.endsWith(".svg")
            ? SvgPicture.asset(
                errorAsset!,
                height: radius,
                width: radius,
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  color ?? AppColors(context).primaryVariant,
                  BlendMode.srcIn,
                ),
              )
            : Image.asset(errorAsset!, fit: BoxFit.fill);
      }
    } else {
      return Icon(
        Icons.wifi_tethering_error_rounded_rounded,
        color: AppColors(context).primary,
      );
    }
  }

  Widget _placeHolder(BuildContext context) => Center(child: CustomLoading());
}

class CustomLoading extends StatelessWidget {
  const CustomLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: Lottie.asset(AppAssets.loadingLottie));
  }
}
