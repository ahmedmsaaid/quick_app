// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HomeNotifier)
final homeProvider = HomeNotifierProvider._();

final class HomeNotifierProvider
    extends $NotifierProvider<HomeNotifier, HomeState> {
  HomeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeNotifierHash();

  @$internal
  @override
  HomeNotifier create() => HomeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeState>(value),
    );
  }
}

String _$homeNotifierHash() => r'6ab9e7cedf5f0eb3abf2f5e70af5999c0bd9d263';

abstract class _$HomeNotifier extends $Notifier<HomeState> {
  HomeState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HomeState, HomeState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HomeState, HomeState>,
              HomeState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(getOfferDetails)
final getOfferDetailsProvider = GetOfferDetailsFamily._();

final class GetOfferDetailsProvider
    extends
        $FunctionalProvider<AsyncValue<OfferDto>, OfferDto, FutureOr<OfferDto>>
    with $FutureModifier<OfferDto>, $FutureProvider<OfferDto> {
  GetOfferDetailsProvider._({
    required GetOfferDetailsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'getOfferDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getOfferDetailsHash();

  @override
  String toString() {
    return r'getOfferDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OfferDto> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<OfferDto> create(Ref ref) {
    final argument = this.argument as int;
    return getOfferDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOfferDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getOfferDetailsHash() => r'4618652ad91faad139c54b6fd0305b1037664c4c';

final class GetOfferDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OfferDto>, int> {
  GetOfferDetailsFamily._()
    : super(
        retry: null,
        name: r'getOfferDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetOfferDetailsProvider call(int id) =>
      GetOfferDetailsProvider._(argument: id, from: this);

  @override
  String toString() => r'getOfferDetailsProvider';
}
