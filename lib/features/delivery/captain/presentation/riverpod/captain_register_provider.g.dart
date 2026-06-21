// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captain_register_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CaptainRegisterNotifier)
final captainRegisterProvider = CaptainRegisterNotifierProvider._();

final class CaptainRegisterNotifierProvider
    extends $NotifierProvider<CaptainRegisterNotifier, CaptainRegisterState> {
  CaptainRegisterNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captainRegisterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captainRegisterNotifierHash();

  @$internal
  @override
  CaptainRegisterNotifier create() => CaptainRegisterNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptainRegisterState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptainRegisterState>(value),
    );
  }
}

String _$captainRegisterNotifierHash() =>
    r'6b11d305bf563355feec68c4b4609999553a6e1a';

abstract class _$CaptainRegisterNotifier
    extends $Notifier<CaptainRegisterState> {
  CaptainRegisterState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CaptainRegisterState, CaptainRegisterState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CaptainRegisterState, CaptainRegisterState>,
              CaptainRegisterState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
