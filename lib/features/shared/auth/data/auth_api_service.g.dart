// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authApiService)
final authApiServiceProvider = AuthApiServiceProvider._();

final class AuthApiServiceProvider
    extends $FunctionalProvider<AuthApiService, AuthApiService, AuthApiService>
    with $Provider<AuthApiService> {
  AuthApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authApiServiceHash();

  @$internal
  @override
  $ProviderElement<AuthApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthApiService create(Ref ref) {
    return authApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthApiService>(value),
    );
  }
}

String _$authApiServiceHash() => r'2fc9f9f86499ae863235a25dc38bb7d9a1ff328b';
