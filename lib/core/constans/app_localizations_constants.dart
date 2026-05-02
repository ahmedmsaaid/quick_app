import 'package:flutter/material.dart';

class AppLocalizationsConstants {
  static final AppLocalizationsConstants _instance =
  AppLocalizationsConstants._internal();

  factory AppLocalizationsConstants() => _instance;

  AppLocalizationsConstants._internal() {
    arLocale = Locale(arLanguage, arRegion);
    enLocale = Locale(enLanguage, enRegion);
    trLocale = Locale(trLanguage, trRegion);
    supportedLocales = [arLocale, enLocale, trLocale];
  }

  // Languages
  final String arLanguage = 'ar';
  final String enLanguage = 'en';
  final String trLanguage = 'tr';

  // Regions
  final String arRegion = 'IQ'; // العراق
  final String enRegion = 'US';
  final String trRegion = 'TR';

  // Path
  final String path = "assets/translations";

  // Locales
  late final Locale arLocale;
  late final Locale enLocale;
  late final Locale trLocale;
  late final List<Locale> supportedLocales;
}
