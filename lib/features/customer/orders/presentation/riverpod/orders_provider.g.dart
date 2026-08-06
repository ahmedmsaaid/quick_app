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

String _$trackOrderHash() => r'd2944a5ff37eca3d2f594435c64e85da639462cd';

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

@ProviderFor(orderTrackingGrpcStream)
final orderTrackingGrpcStreamProvider = OrderTrackingGrpcStreamFamily._();

final class OrderTrackingGrpcStreamProvider
    extends
        $FunctionalProvider<AsyncValue<tracking_pb.GrpcLocationUpdate>, tracking_pb.GrpcLocationUpdate, Stream<tracking_pb.GrpcLocationUpdate>>
    with $FutureModifier<tracking_pb.GrpcLocationUpdate>, $StreamProvider<tracking_pb.GrpcLocationUpdate> {
  OrderTrackingGrpcStreamProvider._({
    required OrderTrackingGrpcStreamFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'orderTrackingGrpcStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$orderTrackingGrpcStreamHash();

  @override
  String toString() {
    return r'orderTrackingGrpcStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<tracking_pb.GrpcLocationUpdate> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<tracking_pb.GrpcLocationUpdate> create(Ref ref) {
    final argument = this.argument as int;
    return orderTrackingGrpcStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is OrderTrackingGrpcStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$orderTrackingGrpcStreamHash() => r'e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0';

final class OrderTrackingGrpcStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<tracking_pb.GrpcLocationUpdate>, int> {
  OrderTrackingGrpcStreamFamily._()
    : super(
        retry: null,
        name: r'orderTrackingGrpcStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OrderTrackingGrpcStreamProvider call(int orderId) =>
      OrderTrackingGrpcStreamProvider._(argument: orderId, from: this);

  @override
  String toString() => r'orderTrackingGrpcStreamProvider';
}

