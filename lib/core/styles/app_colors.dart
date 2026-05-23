import 'package:flutter/material.dart';

class AppColors {
  final BuildContext context;

  AppColors(this.context);

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ===== Brand Palette =====
  static const Color brandTeal = Color(0xFF008C8C);
  static const Color brandTealDark = Color(0xFF006D6D);
  static const Color brandTealLight = Color(0xFFE6F6F6);

  static const Color brandOrange = Color(0xFFFF8A1F);
  static const Color brandOrangeDark = Color(0xFFE96F00);
  static const Color brandOrangeLight = Color(0xFFFFF1E4);

  static const Color darkBackground = Color(0xFF101718);
  static const Color darkSurface = Color(0xFF172224);
  static const Color darkCard = Color(0xFF1D2B2D);

  // ===== Background Colors =====
  Color get background =>
      _isDark ? darkBackground : const Color(0xFFF7FAFA);

  Color get surface =>
      _isDark ? darkSurface : const Color(0xFFFFFFFF);

  Color get backGroundType =>
      _isDark ? const Color(0xFF132022) : const Color(0xFFFFFFFF);

  Color get cardBackground =>
      _isDark ? darkCard : const Color(0xFFFFFFFF);

  Color get containerBackground =>
      _isDark ? const Color(0xFF142123) : const Color(0xFFF2F7F7);

  // ===== Primary Colors =====
  Color get primary =>
      _isDark ? const Color(0xFF20B8B8) : brandTeal;

  Color get primaryVariant =>
      _isDark ? const Color(0xFF65D6D6) : brandTealDark;

  Color get secondary =>
      _isDark ? const Color(0xFFFFA64D) : brandOrange;

  // ===== Text Colors =====
  Color get textPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF172124);

  Color get textSecondary =>
      _isDark ? const Color(0xFFB8C7C7) : const Color(0xFF5F6F72);

  Color get textHint =>
      _isDark ? const Color(0xFF7E8E90) : const Color(0xFF9AA6A8);

  Color get textDisabled =>
      _isDark ? const Color(0xFF566466) : const Color(0xFFC0C8C9);

  Color get onBoardingIndicator =>
      _isDark ? const Color(0xFF3E5558) : const Color(0xFFD9EAEA);

  // ===== Accent Colors =====
  Color get accent =>
      _isDark ? const Color(0xFFFFA64D) : brandOrange;

  Color get accentGold => const Color(0xFFFFC166);

  // ===== Status Colors =====
  Color get error => const Color(0xFFE54848);

  Color get success => const Color(0xFF20A66A);

  Color get warning => const Color(0xFFFFC145);

  // ===== Price & Discount =====
  Color get price =>
      _isDark ? const Color(0xFF49D17D) : const Color(0xFF16834A);

  Color get discount => const Color(0xFFE54848);

  Color get priceOld =>
      _isDark ? const Color(0xFF8A999B) : const Color(0xFF8A8A8A);

  // ===== Border & Divider =====
  Color get border =>
      _isDark ? const Color(0xFF2E4245) : const Color(0xFFE1EEEE);

  Color get divider =>
      _isDark ? const Color(0xFF263A3D) : const Color(0xFFE7F0F0);

  // ===== Icon Colors =====
  Color get iconPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xFF172124);

  Color get iconSecondary =>
      _isDark ? const Color(0xFF8BA0A3) : const Color(0xFF7A8A8D);

  // ===== Button Colors =====
  Color get buttonPrimary => secondary;

  Color get buttonSecondary =>
      _isDark ? const Color(0xFF233638) : brandTealLight;

  Color get buttonDisabled =>
      _isDark ? const Color(0xFF263234) : const Color(0xFFE1E8E8);

  // ===== Rating Colors =====
  Color get ratingActive => const Color(0xFFFFC145);

  Color get ratingInactive =>
      _isDark ? const Color(0xFF33484B) : const Color(0xFFE1E8E8);

  // ===== Shimmer Colors =====
  Color get shimmerBase =>
      _isDark ? const Color(0xFF1C2A2C) : const Color(0xFFE6EEEE);

  Color get shimmerHighlight =>
      _isDark ? const Color(0xFF293B3E) : const Color(0xFFF7FAFA);

  // ===== Shadow Colors =====
  Color get shadow => _isDark
      ? Colors.black.withValues(alpha: 0.45)
      : const Color(0xFF006D6D).withValues(alpha: 0.08);

  // ===== Extra Colors =====
  Color get bink => const Color(0xFFF11BB4);

  Color get orangeLight =>
      _isDark ? const Color(0xFF3A2514) : brandOrangeLight;

  Color get tealLight =>
      _isDark ? const Color(0xFF143334) : brandTealLight;

  // ===== Static Colors =====
  static const white = Colors.white;
  static const gray = Color(0xFFA7A7A7);
  static const black = Colors.black;
  static const transparent = Colors.transparent;

  static const gradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFF008C8C),
      Color(0xFF006D6D),
    ],
  );

  static const orangeGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [
      Color(0xFFFF9A2E),
      Color(0xFFFF7A00),
    ],
  );

  static const blue = Color(0xFF0077FF);
}