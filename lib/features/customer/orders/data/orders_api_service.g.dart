// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ordersApiService)
final ordersApiServiceProvider = OrdersApiServiceProvider._();

final class OrdersApiServiceProvider
    extends
        $FunctionalProvider<
          OrdersApiService,
          OrdersApiService,
          OrdersApiService
        >
    with $Provider<OrdersApiService> {
  OrdersApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ordersApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ordersApiServiceHash();

  @$internal
  @override
  $ProviderElement<OrdersApiService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  OrdersApiService create(Ref ref) {
    return ordersApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OrdersApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OrdersApiService>(value),
    );
  }
}

String _$ordersApiServiceHash() => r'419cf39673a589739333bce62ed482870df1ac6e';
