import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app_colors.dart';

class OldTextStyle {
  final BuildContext context;
  late final AppColors _colors;

  OldTextStyle(this.context) {
    _colors = AppColors(context);
  }

  // ===== Headings =====
  TextStyle get heading => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: _colors.textPrimary,
  );

  TextStyle get title => TextStyle(
    fontSize: 22.sp,
    fontWeight: FontWeight.bold,
    color: _colors.textPrimary,
  );

  TextStyle get sectionTitle => TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
  );

  // ===== Body Text =====
  TextStyle get body => TextStyle(
    fontSize: 16.sp,
    color: _colors.textPrimary,
  );

  TextStyle get bodyMedium => TextStyle(
    fontSize: 14.sp,
    color: _colors.textPrimary,
  );

  TextStyle get bodySmall => TextStyle(
    fontSize: 12.sp,
    color: _colors.textPrimary,
  );

  // ===== Subtitle & Secondary =====
  TextStyle get subtitle => TextStyle(
    fontSize: 16.sp,
    color: _colors.textSecondary,
  );

  TextStyle get info => TextStyle(
    fontSize: 14.sp,
    color: _colors.textSecondary,
  );

  TextStyle get caption => TextStyle(
    fontSize: 12.sp,
    color: _colors.textSecondary,
  );

  // ===== Hint Text =====
  TextStyle get hint => TextStyle(
    fontSize: 14.sp,
    color: _colors.textHint,
  );

  // ===== AppBar =====
  TextStyle get appBarTitle => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: _colors.textPrimary,
  );

  // ===== Price & Discount =====
  TextStyle get price => TextStyle(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: _colors.price,
  );

  TextStyle get priceSmall => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: _colors.price,
  );

  TextStyle get discount => TextStyle(
    fontSize: 16.sp,
    color: _colors.discount,
    fontWeight: FontWeight.w500,
  );

  TextStyle get priceOld => TextStyle(
    fontSize: 14.sp,
    color: _colors.priceOld,
    decoration: TextDecoration.lineThrough,
  );

  // ===== Button Text =====
  TextStyle get buttonText => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  TextStyle get buttonTextSmall => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  TextStyle get buttonTextPrimary => TextStyle(
    fontSize: 16.sp,
    fontWeight: FontWeight.w600,
    color: _colors.primary,
  );

  // ===== Review Text =====
  TextStyle get reviewName => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: _colors.textPrimary,
  );

  TextStyle get reviewComment => TextStyle(
    fontSize: 13.sp,
    color: _colors.textSecondary,
  );

  TextStyle get reviewDate => TextStyle(
    fontSize: 12.sp,
    color: _colors.textHint,
  );

  // ===== Special Text =====
  TextStyle get badge => TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  TextStyle get tag => TextStyle(
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
    color: _colors.textSecondary,
  );

  TextStyle get error => TextStyle(
    fontSize: 14.sp,
    color: _colors.error,
  );

  TextStyle get success => TextStyle(
    fontSize: 14.sp,
    color: _colors.success,
  );

  // ===== Link Text =====
  TextStyle get link => TextStyle(
    fontSize: 14.sp,
    color: _colors.primary,
    decoration: TextDecoration.underline,
  );

  // ===== Rating Text =====
  TextStyle get ratingText => TextStyle(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: _colors.textPrimary,
  );

  TextStyle get ratingCount => TextStyle(
    fontSize: 12.sp,
    color: _colors.textSecondary,
  );
}

