// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_service_module.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dioInterceptor)
final dioInterceptorProvider = DioInterceptorProvider._();

final class DioInterceptorProvider
    extends $FunctionalProvider<DioInterceptor, DioInterceptor, DioInterceptor>
    with $Provider<DioInterceptor> {
  DioInterceptorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioInterceptorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioInterceptorHash();

  @$internal
  @override
  $ProviderElement<DioInterceptor> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DioInterceptor create(Ref ref) {
    return dioInterceptor(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DioInterceptor value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DioInterceptor>(value),
    );
  }
}

String _$dioInterceptorHash() => r'9cc27a407f86ff2abde07cc150419429b81c1fd1';

@ProviderFor(prettyDioLogger)
final prettyDioLoggerProvider = PrettyDioLoggerProvider._();

final class PrettyDioLoggerProvider
    extends
        $FunctionalProvider<PrettyDioLogger, PrettyDioLogger, PrettyDioLogger>
    with $Provider<PrettyDioLogger> {
  PrettyDioLoggerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prettyDioLoggerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prettyDioLoggerHash();

  @$internal
  @override
  $ProviderElement<PrettyDioLogger> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PrettyDioLogger create(Ref ref) {
    return prettyDioLogger(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrettyDioLogger value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrettyDioLogger>(value),
    );
  }
}

String _$prettyDioLoggerHash() => r'ab6e42624de4f2cdd71d8ef7f2e20674a1f112c5';
