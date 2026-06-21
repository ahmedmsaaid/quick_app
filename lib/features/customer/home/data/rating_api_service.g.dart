// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ratingApiService)
final ratingApiServiceProvider = RatingApiServiceProvider._();

final class RatingApiServiceProvider
    extends
        $FunctionalProvider<
          RatingApiService,
          RatingApiService,
          RatingApiService
        >
    with $Provider<RatingApiService> {
  RatingApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ratingApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ratingApiServiceHash();

  @$internal
  @override
  $ProviderElement<RatingApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RatingApiService create(Ref ref) {
    return ratingApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RatingApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RatingApiService>(value),
    );
  }
}

String _$ratingApiServiceHash() => r'85861b13eafd669035b681069d357ff603af7797';
