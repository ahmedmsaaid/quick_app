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

String _$captainOrdersHash() => r'328befb96cc982935b7dac589d99e1836e8e5cc8';

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

@ProviderFor(CaptainMyOrders)
final captainMyOrdersProvider = CaptainMyOrdersProvider._();

final class CaptainMyOrdersProvider
    extends $NotifierProvider<CaptainMyOrders, MyOrdersState> {
  CaptainMyOrdersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'captainMyOrdersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$captainMyOrdersHash();

  @$internal
  @override
  CaptainMyOrders create() => CaptainMyOrders();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MyOrdersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MyOrdersState>(value),
    );
  }
}

String _$captainMyOrdersHash() => r'2f844ddbced7e58848efc008717a0a045b56183e';

abstract class _$CaptainMyOrders extends $Notifier<MyOrdersState> {
  MyOrdersState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<MyOrdersState, MyOrdersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MyOrdersState, MyOrdersState>,
              MyOrdersState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
