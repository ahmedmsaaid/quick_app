import 'package:shared_preferences/shared_preferences.dart';

import '../../exports/exports.dart';
import 'cache_helper_keys.dart';

class CacheHelper {
  static late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
 Future<void> clear() async {
    _prefs.clear();
  }

  static Future<void> clearAll() async {
    await _prefs.clear();
  }

  static Future<bool> setString(String key, String value) async {
    return await _prefs.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    return await _prefs.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    return await _prefs.setInt(key, value);
  }

  static Future<bool> setDouble(String key, double value) async {
    return await _prefs.setDouble(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<bool> remove(String key) async {
    return await _prefs.remove(key);
  }

  static bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  static String get currentLang => _prefs.getString(CacheKeys.lang) ?? 'ar';

  static Future<bool> setLang(String lang) async {
    return await _prefs.setString(CacheKeys.lang, lang);
  }

  static bool get isDarkMode =>
      _prefs.getBool(CacheKeys.isDark) ?? ThemeMode.system == ThemeMode.dark;

  static Future<bool> setDarkMode(bool isDark) async {
    return await _prefs.setBool(CacheKeys.isDark, isDark);
  }
}

abstract class CacheModule {
  Future<CacheHelper> get cacheHelper async {
    final cache = CacheHelper();
    await cache.init();
    return cache;
  }
}
