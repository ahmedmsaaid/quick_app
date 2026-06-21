// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(checkoutApiService)
final checkoutApiServiceProvider = CheckoutApiServiceProvider._();

final class CheckoutApiServiceProvider
    extends
        $FunctionalProvider<
          CheckoutApiService,
          CheckoutApiService,
          CheckoutApiService
        >
    with $Provider<CheckoutApiService> {
  CheckoutApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkoutApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkoutApiServiceHash();

  @$internal
  @override
  $ProviderElement<CheckoutApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CheckoutApiService create(Ref ref) {
    return checkoutApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CheckoutApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CheckoutApiService>(value),
    );
  }
}

String _$checkoutApiServiceHash() =>
    r'fa4290ae4d89ac3a3755af1b347e3d2d69f557e6';
