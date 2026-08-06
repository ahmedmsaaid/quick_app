// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captain_location_stream_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: type=lint, type=warning

@ProviderFor(CaptainLocationStreamNotifier)
final captainLocationStreamNotifierProvider =
    CaptainLocationStreamNotifierProvider._();

final class CaptainLocationStreamNotifierProvider
    extends $NotifierProvider<CaptainLocationStreamNotifier, bool> {
  CaptainLocationStreamNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captainLocationStreamNotifierProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captainLocationStreamNotifierHash();

  @$internal
  @override
  CaptainLocationStreamNotifier create() => CaptainLocationStreamNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$captainLocationStreamNotifierHash() =>
    r'a9b8c7d6e5f43210fe9876543210fedcba987654';

abstract class _$CaptainLocationStreamNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
