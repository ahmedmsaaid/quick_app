// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_api_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileApiService)
final profileApiServiceProvider = ProfileApiServiceProvider._();

final class ProfileApiServiceProvider
    extends
        $FunctionalProvider<
          ProfileApiService,
          ProfileApiService,
          ProfileApiService
        >
    with $Provider<ProfileApiService> {
  ProfileApiServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileApiServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileApiServiceHash();

  @$internal
  @override
  $ProviderElement<ProfileApiService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileApiService create(Ref ref) {
    return profileApiService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileApiService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileApiService>(value),
    );
  }
}

String _$profileApiServiceHash() => r'7e6bab7efed6b63b4e7eb83322ee74329782882d';
