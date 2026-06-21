// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(favoritesApiService)
final favoritesApiServiceProvider = FavoritesApiServiceProvider._();

final class FavoritesApiServiceProvider
    extends
        $FunctionalProvider<
          FavoritesApiService,
          FavoritesApiService,
          FavoritesApiService
        >
    with $Provider<FavoritesApiService> {
  FavoritesApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'favoritesApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$favoritesApiServiceHash();

  @$internal
  @override
  $ProviderElement<FavoritesApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FavoritesApiService create(Ref ref) {
    return favoritesApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FavoritesApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FavoritesApiService>(value),
    );
  }
}

String _$favoritesApiServiceHash() =>
    r'9a62187c3bdd0dbf46ebcf65cffeedb98b6fb0a8';
