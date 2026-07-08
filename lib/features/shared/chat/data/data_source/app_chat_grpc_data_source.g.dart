// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_chat_grpc_data_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appChatGrpcDataSource)
final appChatGrpcDataSourceProvider = AppChatGrpcDataSourceProvider._();

final class AppChatGrpcDataSourceProvider
    extends
        $FunctionalProvider<
          AppChatGrpcDataSource,
          AppChatGrpcDataSource,
          AppChatGrpcDataSource
        >
    with $Provider<AppChatGrpcDataSource> {
  AppChatGrpcDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appChatGrpcDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appChatGrpcDataSourceHash();

  @$internal
  @override
  $ProviderElement<AppChatGrpcDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppChatGrpcDataSource create(Ref ref) {
    return appChatGrpcDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppChatGrpcDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppChatGrpcDataSource>(value),
    );
  }
}

String _$appChatGrpcDataSourceHash() =>
    r'd03c21ea9dfecefe5c1e0250a4a73dd5a441afa4';
