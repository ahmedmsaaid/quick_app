// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stream_repo_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(streamRepo)
final streamRepoProvider = StreamRepoProvider._();

final class StreamRepoProvider
    extends $FunctionalProvider<StreamRepo, StreamRepo, StreamRepo>
    with $Provider<StreamRepo> {
  StreamRepoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streamRepoProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streamRepoHash();

  @$internal
  @override
  $ProviderElement<StreamRepo> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  StreamRepo create(Ref ref) {
    return streamRepo(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StreamRepo value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StreamRepo>(value),
    );
  }
}

String _$streamRepoHash() => r'7c9af524ccf6e65342ffdbe7ed47405b957ae92e';
