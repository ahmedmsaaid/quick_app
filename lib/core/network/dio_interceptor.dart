import 'dart:developer';
import 'package:dio/dio.dart';

class DioInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // final lang = CacheHelper.lang;
    // final token = await CacheHelper.token;
    //
    // options.headers[HttpHeaders.acceptLanguageHeader] = lang;
    // if (token != null && token.isNotEmpty) {
    //   options.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
    //   log("TOKEN: $token");
    // }

    log('REQUEST[${options.method}] => PATH: ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log(
      'RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
    );
    // log("TOKEN: ${CacheHelper.token}");

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log(
      'ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}',
    );

    // if 401 Unauthorized => try refresh token
    // if (err.response?.statusCode == 401) {
    //   final refreshToken = await CacheHelper.refreshToken;
    //
    //   if (refreshToken != null && refreshToken.isNotEmpty) {
    //     try {
    //       final newToken = await _refreshToken(refreshToken);
    //
    //       // if successfully refreshed, save and retry request
    //       if (newToken != null) {
    //         await CacheHelper.setToken(newToken);
    //
    //         final retryRequest = await _retryRequest(
    //           err.requestOptions,
    //           newToken,
    //         );
    //
    //         return handler.resolve(retryRequest); // ✅ return retried response
    //       }
    //     } catch (e, st) {
    //       log("Token refresh failed: $e\n$st");
    //     }
    //   }
    // }

    // if cannot refresh, forward the error
    return handler.next(err);
  }

  // Future<String?> _refreshToken(String refreshToken) async {
  //   try {
  //     final response = await Dio().put(
  //       EndPoints.refreshToken,
  //       data: {"refreshToken": refreshToken},
  //     );
  //
  //     final newAccessToken = response.data['accessToken'] as String?;
  //     log("✅ New token acquired: $newAccessToken");
  //     return newAccessToken;
  //   } catch (e) {
  //     log("❌ Failed to refresh token: $e");
  //     return null;
  //   }
  // }

  // Future<Response> _retryRequest(
  //     RequestOptions requestOptions,
  //     String newToken,
  //     ) async {
  //   final retryOptions = Options(
  //     method: requestOptions.method,
  //     headers: {
  //       ...requestOptions.headers,
  //       HttpHeaders.authorizationHeader: 'Bearer $newToken',
  //     },
  //   );
  //
  //   log("🔁 Retrying request: ${requestOptions.path}");
  //   return Dio().request(
  //     requestOptions.path,
  //     data: requestOptions.data,
  //     queryParameters: requestOptions.queryParameters,
  //     options: retryOptions,
  //   );
  // }
}
