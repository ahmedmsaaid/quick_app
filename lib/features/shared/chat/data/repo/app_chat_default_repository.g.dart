// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_chat_default_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appChatDefaultRepo)
final appChatDefaultRepoProvider = AppChatDefaultRepoProvider._();

final class AppChatDefaultRepoProvider
    extends
        $FunctionalProvider<
          AppChatDefaultRepo,
          AppChatDefaultRepo,
          AppChatDefaultRepo
        >
    with $Provider<AppChatDefaultRepo> {
  AppChatDefaultRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appChatDefaultRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appChatDefaultRepoHash();

  @$internal
  @override
  $ProviderElement<AppChatDefaultRepo> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppChatDefaultRepo create(Ref ref) {
    return appChatDefaultRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppChatDefaultRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppChatDefaultRepo>(value),
    );
  }
}

String _$appChatDefaultRepoHash() =>
    r'e72c289267ad4c490b58df13553f521909040343';
