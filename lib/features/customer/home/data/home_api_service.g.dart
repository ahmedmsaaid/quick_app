// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeApiService)
final homeApiServiceProvider = HomeApiServiceProvider._();

final class HomeApiServiceProvider
    extends $FunctionalProvider<HomeApiService, HomeApiService, HomeApiService>
    with $Provider<HomeApiService> {
  HomeApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeApiServiceHash();

  @$internal
  @override
  $ProviderElement<HomeApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeApiService create(Ref ref) {
    return homeApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeApiService>(value),
    );
  }
}

String _$homeApiServiceHash() => r'0ea0c91f5a191080ffaa2923f08f98504b232ede';
