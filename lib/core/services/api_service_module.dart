import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../network/dio_factory.dart';
import '../network/dio_interceptor.dart';

part 'api_service_module.g.dart';

@Riverpod(keepAlive: true)
DioInterceptor dioInterceptor(Ref ref) {
  return DioInterceptor();
}

@Riverpod(keepAlive: true)
PrettyDioLogger prettyDioLogger(Ref ref) {
  return PrettyDioLogger(
    requestHeader: true,
    requestBody: true,
    responseBody: true,
    responseHeader: false,
    error: true,
    compact: true,
    maxWidth: 90,
  );
}
