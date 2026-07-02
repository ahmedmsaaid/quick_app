// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notificationsApiService)
final notificationsApiServiceProvider = NotificationsApiServiceProvider._();

final class NotificationsApiServiceProvider
    extends
        $FunctionalProvider<
          NotificationsApiService,
          NotificationsApiService,
          NotificationsApiService
        >
    with $Provider<NotificationsApiService> {
  NotificationsApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsApiServiceHash();

  @$internal
  @override
  $ProviderElement<NotificationsApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsApiService create(Ref ref) {
    return notificationsApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsApiService>(value),
    );
  }
}

String _$notificationsApiServiceHash() =>
    r'637d78d4d8d7543a8ff7cec7b2ea209baeacd082';
