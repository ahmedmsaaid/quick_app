import 'package:flutter/services.dart' show rootBundle;

/// Loads and exposes environment variables from `.env` and `--dart-define`.
class EnvConfig {
  EnvConfig._();

  static final Map<String, String> _values = {};

  /// Loads `.env` from bundled assets if present. Safe to call multiple times.
  static Future<void> load() async {
    try {
      final content = await rootBundle.loadString('.env');
      for (final rawLine in content.split('\n')) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#')) continue;
        final eqIndex = line.indexOf('=');
        if (eqIndex <= 0) continue;
        final key = line.substring(0, eqIndex).trim();
        var value = line.substring(eqIndex + 1).trim();
        if ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'"))) {
          value = value.substring(1, value.length - 1);
        }
        _values[key] = value;
      }
    } catch (_) {
      // Fallback to --dart-define values if .env asset is absent
    }
  }

  static String get(String key, {String fallback = ''}) =>
      _values[key] ?? fallback;

  static String get googleMapsApiKey => get(
        'GOOGLE_MAPS_API_KEY',
        fallback: const String.fromEnvironment('GOOGLE_MAPS_API_KEY'),
      );

  static String get firebaseAndroidApiKey => get(
        'FIREBASE_ANDROID_API_KEY',
        fallback: const String.fromEnvironment('FIREBASE_ANDROID_API_KEY'),
      );

  static String get firebaseIosApiKey => get(
        'FIREBASE_IOS_API_KEY',
        fallback: const String.fromEnvironment('FIREBASE_IOS_API_KEY'),
      );

  static String get apiBaseUrl => get(
        'API_BASE_URL',
        fallback: const String.fromEnvironment('API_BASE_URL'),
      );

  static String get streamBaseUrl => get(
        'STREAM_BASE_URL',
        fallback: const String.fromEnvironment('STREAM_BASE_URL'),
      );

  static String get googleServerClientId => get(
        'GOOGLE_SERVER_CLIENT_ID',
        fallback: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
      );
}
