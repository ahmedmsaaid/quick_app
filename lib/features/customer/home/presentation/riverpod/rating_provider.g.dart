// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Rating)
final ratingProvider = RatingProvider._();

final class RatingProvider extends $NotifierProvider<Rating, RatingState> {
  RatingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ratingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ratingHash();

  @$internal
  @override
  Rating create() => Rating();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RatingState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RatingState>(value),
    );
  }
}

String _$ratingHash() => r'89cc434c40207d397304afb830880dd15a04e103';

abstract class _$Rating extends $Notifier<RatingState> {
  RatingState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RatingState, RatingState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RatingState, RatingState>,
              RatingState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
