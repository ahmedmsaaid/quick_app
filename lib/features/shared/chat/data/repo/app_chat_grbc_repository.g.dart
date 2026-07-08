// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_chat_grbc_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appChatGrbcRepository)
final appChatGrbcRepositoryProvider = AppChatGrbcRepositoryProvider._();

final class AppChatGrbcRepositoryProvider
    extends
        $FunctionalProvider<
          AppChatGrbcRepository,
          AppChatGrbcRepository,
          AppChatGrbcRepository
        >
    with $Provider<AppChatGrbcRepository> {
  AppChatGrbcRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appChatGrbcRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appChatGrbcRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppChatGrbcRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppChatGrbcRepository create(Ref ref) {
    return appChatGrbcRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppChatGrbcRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppChatGrbcRepository>(value),
    );
  }
}

String _$appChatGrbcRepositoryHash() =>
    r'98dc907ffa254bab51500ebcff5e962b37dc73bc';
