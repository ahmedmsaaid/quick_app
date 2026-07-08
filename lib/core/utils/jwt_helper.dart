import 'package:jwt_decoder/jwt_decoder.dart';
import '../services/cach_helper/cache_helper.dart';
import '../services/cach_helper/cache_helper_keys.dart';

class JwtHelper {
  static Future<String?> getUserId() async {
    try {
      final token = CacheHelper.getString(CacheKeys.token) ?? '';
      if (token.isNotEmpty) {
        final decoded = JwtDecoder.decode(token);
        final rawVal = decoded['UserId'] ??
            decoded['userId'] ??
            decoded['id'] ??
            decoded['nameid'] ??
            decoded['sub'] ??
            decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
        if (rawVal != null) {
          return rawVal.toString();
        }
      }
    } catch (e) {
      print('❌ Failed to parse user ID from token in JwtHelper: $e');
    }
    return null;
  }
}
