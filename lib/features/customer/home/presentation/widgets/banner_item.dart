import 'package:flutter/material.dart';

class BannerItem {
  final String title;
  final String description;
  final String? imageUrl;
  final bool isAsset;
  final String? badgeText;
  final String? price;
  final VoidCallback? onTap;
  final List<Color> gradientColors;

  BannerItem({
    required this.title,
    required this.description,
    this.imageUrl,
    this.isAsset = false,
    this.badgeText,
    this.price,
    this.onTap,
    required this.gradientColors,
  });
}
