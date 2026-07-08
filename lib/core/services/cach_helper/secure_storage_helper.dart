import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';

/// Adapter wrapping CacheHelper to provide token retrieval
/// compatible with the chat feature's SecureStorageHelper interface.
class SecureStorageHelper {
  static Future<String?> getToken() async {
    return CacheHelper.getString(CacheKeys.token);
  }
}
