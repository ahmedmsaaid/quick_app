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

String _$captainOrdersHash() => r'9aeed9d893039b3c018023f6a6ba872832bb3d3a';

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

String _$captainMyOrdersHash() => r'e03d2cd59d28e62cc577b5719283d09548a5cbb6';

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
