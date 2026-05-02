import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_constants.dart';
import '../services/api_service_module.dart';

part 'dio_factory.g.dart';

@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  Duration timeOut = const Duration(seconds: 30);

  final dio = Dio();
  dio
    ..options.connectTimeout = timeOut
    ..options.receiveTimeout = timeOut
    ..options.baseUrl = ApiConstants.baseUrl
    ..options.headers = {'Accept': 'application/json'};

  final prettyLogger = ref.watch(prettyDioLoggerProvider);
  final interceptor = ref.watch(dioInterceptorProvider);

  dio.interceptors.addAll([prettyLogger, interceptor]);

  return dio;
}
