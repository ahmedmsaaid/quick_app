// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'captain_orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CaptainOrders)
final captainOrdersProvider = CaptainOrdersProvider._();

final class CaptainOrdersProvider
    extends $NotifierProvider<CaptainOrders, CaptainOrdersState> {
  CaptainOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captainOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captainOrdersHash();

  @$internal
  @override
  CaptainOrders create() => CaptainOrders();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaptainOrdersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaptainOrdersState>(value),
    );
  }
}

String _$captainOrdersHash() => r'de6c74f0dc5f8c2a0296f076d2723ace4e2fbff6';

abstract class _$CaptainOrders extends $Notifier<CaptainOrdersState> {
  CaptainOrdersState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CaptainOrdersState, CaptainOrdersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CaptainOrdersState, CaptainOrdersState>,
              CaptainOrdersState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
