// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OrdersNotifier)
final ordersProvider = OrdersNotifierProvider._();

final class OrdersNotifierProvider
    extends $NotifierProvider<OrdersNotifier, OrdersState> {
  OrdersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersNotifierHash();

  @$internal
  @override
  OrdersNotifier create() => OrdersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrdersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrdersState>(value),
    );
  }
}

String _$ordersNotifierHash() => r'0762090f9e5a9041baac31ae3ca0d8e4de58db30';

abstract class _$OrdersNotifier extends $Notifier<OrdersState> {
  OrdersState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OrdersState, OrdersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OrdersState, OrdersState>,
              OrdersState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(trackOrder)
final trackOrderProvider = TrackOrderFamily._();

final class TrackOrderProvider
    extends
        $FunctionalProvider<AsyncValue<OrderDto>, OrderDto, Stream<OrderDto>>
    with $FutureModifier<OrderDto>, $StreamProvider<OrderDto> {
  TrackOrderProvider._({
    required TrackOrderFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'trackOrderProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$trackOrderHash();

  @override
  String toString() {
    return r'trackOrderProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<OrderDto> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<OrderDto> create(Ref ref) {
    final argument = this.argument as int;
    return trackOrder(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TrackOrderProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$trackOrderHash() => r'5b77bee92364d8155c1797d6e72bf2337b9dad67';

final class TrackOrderFamily extends $Family
    with $FunctionalFamilyOverride<Stream<OrderDto>, int> {
  TrackOrderFamily._()
    : super(
        retry: null,
        name: r'trackOrderProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TrackOrderProvider call(int orderId) =>
      TrackOrderProvider._(argument: orderId, from: this);

  @override
  String toString() => r'trackOrderProvider';
}
