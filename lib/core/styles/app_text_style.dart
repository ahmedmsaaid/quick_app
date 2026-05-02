import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Cairo';

  static TextStyle _buildTextStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize.sp,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontFamily: _fontFamily,
    );
  }

  static TextStyle text10w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 10.sp, color: color, height: height);

  static TextStyle text12w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 12.sp, color: color, height: height);

  static TextStyle text14w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 14.sp, color: color, height: height);

  static TextStyle text15w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 15.sp, color: color, height: height);

  static TextStyle text16w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 16.sp, color: color, height: height);

  static TextStyle text18w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 18.sp, color: color, height: height);

  static TextStyle text20w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 20.sp, color: color, height: height);

  static TextStyle text22w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 22.sp, color: color, height: height);

  static TextStyle text24w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 24.sp, color: color, height: height);

  static TextStyle text28w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 28.sp, color: color, height: height);

  static TextStyle text32w500({Color? color, double? height}) =>
      _buildTextStyle(fontSize: 32.sp, color: color, height: height);

  static TextStyle text12w400({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
      );

  static TextStyle text12w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text14w400({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
      );

  static TextStyle text15w400({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
      );

  static TextStyle text16w400({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: color,
        height: height,
      );

  static TextStyle text14w600({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
      );

  static TextStyle text16w600({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
      );

  static TextStyle text18w600({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
      );

  static TextStyle text20w600({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: color,
        height: height,
      );

  static TextStyle text22w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text25w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 25.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text16w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text13w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text14w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text15w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text18w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text20w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle text24w700({Color? color, double? height}) =>
      _buildTextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: color,
        height: height,
      );

  static TextStyle custom({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return _buildTextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  static TextStyle? text12w600({required Color color}) {
    return _buildTextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w600,
      color: color,
    );
  }

  static TextStyle? text10w400({Color? color}) {
    return _buildTextStyle(
      fontSize: 10.sp,
      fontWeight: FontWeight.w400,
      color: color,
    );
  }

  static TextStyle? text32w700({required Color color}) {
    return _buildTextStyle(
      fontSize: 32.sp,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }
}
