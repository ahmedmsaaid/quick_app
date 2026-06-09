import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/cach_helper/cache_helper_keys.dart';
import 'api_constants.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final lang = CacheHelper.currentLang;
    String? token = CacheHelper.getString(CacheKeys.token);
    if (token == null || token.isEmpty) {
      token = CacheHelper.getString('tempToken');
    }

    options.headers[HttpHeaders.acceptLanguageHeader] = lang;
    if (token != null && token.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
      log("TOKEN: $token");
    }

    log('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );

    // If 401 Unauthorized => try refresh token
    if (err.response?.statusCode == 401) {
      final rToken = CacheHelper.getString('refreshToken');

      if (rToken != null && rToken.isNotEmpty) {
        try {
          final newToken = await _refreshToken(rToken);

          if (newToken != null) {
            await CacheHelper.setString(CacheKeys.token, newToken);

            final retryRequest = await _retryRequest(
              err.requestOptions,
              newToken,
            );

            return handler.resolve(retryRequest); // return retried response
          }
        } catch (e, st) {
          log("Token refresh failed: $e\n$st");
        }
      }
    }

    // Forward the error if cannot refresh
    return handler.next(err);
  }

  Future<String?> _refreshToken(String rToken) async {
    try {
      final response = await Dio().patch(
        '${ApiConstants.baseUrl}/${ApiConstants.refreshToken}',
        data: {"refreshToken": rToken},
      );

      final newAccessToken = response.data['result']?['accessToken'] as String?;
      final newRefreshToken = response.data['result']?['refreshToken'] as String?;
      
      log("✅ New token acquired: $newAccessToken");
      if (newAccessToken != null) {
        await CacheHelper.setString(CacheKeys.token, newAccessToken);
      }
      if (newRefreshToken != null) {
        await CacheHelper.setString('refreshToken', newRefreshToken);
      }
      return newAccessToken;
    } catch (e) {
      log("❌ Failed to refresh token: $e");
      return null;
    }
  }

  Future<Response> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    final retryOptions = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        HttpHeaders.authorizationHeader: 'Bearer $newToken',
      },
    );

    log("🔁 Retrying request: ${requestOptions.path}");
    return Dio().request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: retryOptions,
    );
  }
}
