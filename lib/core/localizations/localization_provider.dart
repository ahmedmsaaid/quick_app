import 'package:flutter/material.dart';
import 'package:riverpod/legacy.dart';
import 'package:base_app/core/constans/app_localizations_constants.dart';

import '../services/cach_helper/cache_helper.dart';
import '../services/cach_helper/cache_helper_keys.dart';

// ===== Localization Notifier =====
class LocalizationNotifier extends StateNotifier<Locale> {
  LocalizationNotifier() : super(AppLocalizationsConstants().arLocale) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final localeCode = CacheHelper.getString(CacheKeys.appLocale);

    if (localeCode != null) {
      final parts = localeCode.split('_');
      if (parts.length == 2) {
        state = Locale(parts[0], parts[1]);
      }
    }
  }

  Future<void> changeLocale(Locale locale) async {
    print('savedLang: $locale');

    await CacheHelper.setString(
      CacheKeys.appLocale,
      '${locale.languageCode}_${locale.countryCode}',
    );
    state = Locale(locale.languageCode, locale.countryCode);
    print(state);
  }

  Future<void> changeToArabic() async {
    print('changeToArabic');
    await changeLocale(AppLocalizationsConstants().arLocale);
  }

  Future<void> changeToEnglish() async {
    await changeLocale(AppLocalizationsConstants().enLocale);
  }

  Future<void> changeToTurkish() async {
    await changeLocale(AppLocalizationsConstants().trLocale);
  }

  bool get isArabic => state.languageCode == 'ar';

  bool get isEnglish => state.languageCode == 'en';

  bool get isTurkish => state.languageCode == 'tr';
}

// ===== Localization Provider =====
final localizationProvider =
    StateNotifierProvider<LocalizationNotifier, Locale>((ref) {
      return LocalizationNotifier();
    });
