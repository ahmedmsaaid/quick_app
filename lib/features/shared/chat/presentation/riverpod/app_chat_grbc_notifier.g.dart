// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_chat_grbc_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppChatGrbcNotifier)
final appChatGrbcProvider = AppChatGrbcNotifierProvider._();

final class AppChatGrbcNotifierProvider
    extends $NotifierProvider<AppChatGrbcNotifier, AppChatGrbcState> {
  AppChatGrbcNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appChatGrbcProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appChatGrbcNotifierHash();

  @$internal
  @override
  AppChatGrbcNotifier create() => AppChatGrbcNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppChatGrbcState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppChatGrbcState>(value),
    );
  }
}

String _$appChatGrbcNotifierHash() =>
    r'a33f8738aec7a2a61152d9325e16638aa26ad207';

abstract class _$AppChatGrbcNotifier extends $Notifier<AppChatGrbcState> {
  AppChatGrbcState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppChatGrbcState, AppChatGrbcState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppChatGrbcState, AppChatGrbcState>,
              AppChatGrbcState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
