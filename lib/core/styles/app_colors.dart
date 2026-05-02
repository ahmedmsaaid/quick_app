import 'package:flutter/material.dart';

class AppColors {
  final BuildContext context;

  AppColors(this.context);

  // ✅ التحقق من Dark Mode
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  // ===== Background Colors =====
  Color get background =>
      _isDark ? const Color(0xFF121212) : const Color(0xFFFAFAFA);

  Color get surface =>
      _isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

  Color get backGroundType =>
      _isDark ? const Color(0xFF1A1622) : const Color(0xFFFFFFFF);

  Color get cardBackground =>
      _isDark ? Color(0xff8A63C8).withOpacity(0.1) : Colors.white;

  Color get containerBackground =>
      _isDark ? Color(0xFF121212) : Color(0xffF7F7F7);

  // ===== Primary Colors =====
  Color get primary =>
      _isDark ? const Color(0xFF5C3D8C) : const Color(0xFFD5B98F);

  Color get primaryVariant =>
      _isDark ? const Color(0xff8A63C8) : const Color(0xFF5C3D8C);

  Color get secondary =>
      _isDark ? const Color(0xFFD4A574) : const Color(0xFFB8935E);

  // ===== Text Colors =====
  Color get textPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xDD000000);

  Color get onBoardingIndicator =>
      _isDark ? const Color(0xffD9D9D9) : const Color(0xffD9D9D9);

  Color get textSecondary =>
      _isDark ? const Color(0xB3FFFFFF) : const Color(0xFF757575);

  Color get textHint =>
      _isDark ? const Color(0x80FFFFFF) : const Color(0x73000000);

  Color get textDisabled =>
      _isDark ? const Color(0x4DFFFFFF) : const Color(0x61000000);

  // ===== Accent Colors =====
  Color get accent =>
      _isDark ? const Color(0xFFFF7043) : const Color(0xFFFF5722);

  Color get accentGold => const Color(0xFFD4A574);

  // ===== Status Colors =====
  Color get error => const Color(0xFFC84242);

  Color get success => const Color(0xFF2E8B57);

  Color get warning => const Color(0xFFFFC107);

  // ===== Price & Discount =====
  Color get price =>
      _isDark ? const Color(0xFF66BB6A) : const Color(0xFF1B5E20);

  Color get discount => const Color(0xFFC62828);

  Color get priceOld =>
      _isDark ? const Color(0xFF9E9E9E) : const Color(0xFF757575);

  // ===== Border & Divider =====
  Color get border =>
      _isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0);

  Color get divider =>
      _isDark ? const Color(0xFFE3E3E3) : const Color(0xFFE3E3E3);

  // ===== Icon Colors =====
  Color get iconPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : const Color(0xDD000000);

  Color get iconSecondary =>
      _isDark ? const Color(0xFF757575) : const Color(0xffD9D9D9);

  // ===== Button Colors =====
  Color get buttonPrimary => primary;

  Color get buttonSecondary =>
      _isDark ? const Color(0xFF424242) : const Color(0xFFEEEEEE);

  Color get buttonDisabled =>
      _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

  // ===== Rating Colors =====
  Color get ratingActive => const Color(0xFFFFC107);

  Color get ratingInactive =>
      _isDark ? const Color(0xFF424242) : const Color(0xFFE0E0E0);

  // ===== Shimmer Colors =====
  Color get shimmerBase =>
      _isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);

  Color get shimmerHighlight =>
      _isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF5F5F5);

  // ===== Shadow Colors =====
  Color get shadow => _isDark
      ? Colors.black.withValues(alpha: 0.5)
      : Colors.black.withValues(alpha: 0.1);

  Color get bink => Color(0xffF11BB4);

  // ===== Static Colors =====
  static const white = Colors.white;
  static const gray = Color(0xffA7A7A7);

  static const black = Colors.black;
  static const transparent = Colors.transparent;
  static const gradient = LinearGradient(
    colors: [Color(0xFF170237), Color(0xFF5C3D8C)],
  );

  static const blue = Color(0xff0077FF);
}
