// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_order_tracking_grpc_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: type=lint, type=warning

@ProviderFor(appOrderTrackingGrpcDataSource)
final appOrderTrackingGrpcDataSourceProvider =
    AppOrderTrackingGrpcDataSourceProvider._();

final class AppOrderTrackingGrpcDataSourceProvider
    extends
        $FunctionalProvider<
          AppOrderTrackingGrpcDataSource,
          AppOrderTrackingGrpcDataSource,
          AppOrderTrackingGrpcDataSource
        >
    with $Provider<AppOrderTrackingGrpcDataSource> {
  AppOrderTrackingGrpcDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appOrderTrackingGrpcDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appOrderTrackingGrpcDataSourceHash();

  @$internal
  @override
  $ProviderElement<AppOrderTrackingGrpcDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppOrderTrackingGrpcDataSource create(Ref ref) {
    return appOrderTrackingGrpcDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppOrderTrackingGrpcDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AppOrderTrackingGrpcDataSource>(value),
    );
  }
}

String _$appOrderTrackingGrpcDataSourceHash() =>
    r'a1b2c3d4e5f67890123456789abcdef012345678';
