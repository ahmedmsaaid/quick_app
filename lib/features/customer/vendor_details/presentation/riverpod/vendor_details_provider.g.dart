// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_details_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VendorDetailsNotifier)
final vendorDetailsProvider = VendorDetailsNotifierFamily._();

final class VendorDetailsNotifierProvider
    extends $NotifierProvider<VendorDetailsNotifier, VendorDetailsState> {
  VendorDetailsNotifierProvider._({
    required VendorDetailsNotifierFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'vendorDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vendorDetailsNotifierHash();

  @override
  String toString() {
    return r'vendorDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  VendorDetailsNotifier create() => VendorDetailsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VendorDetailsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VendorDetailsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VendorDetailsNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vendorDetailsNotifierHash() =>
    r'73faecf8f968f7fcff9e6db855a02736d7bf5d94';

final class VendorDetailsNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          VendorDetailsNotifier,
          VendorDetailsState,
          VendorDetailsState,
          VendorDetailsState,
          int
        > {
  VendorDetailsNotifierFamily._()
    : super(
        retry: null,
        name: r'vendorDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VendorDetailsNotifierProvider call(int vendorId) =>
      VendorDetailsNotifierProvider._(argument: vendorId, from: this);

  @override
  String toString() => r'vendorDetailsProvider';
}

abstract class _$VendorDetailsNotifier extends $Notifier<VendorDetailsState> {
  late final _$args = ref.$arg as int;
  int get vendorId => _$args;

  VendorDetailsState build(int vendorId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VendorDetailsState, VendorDetailsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VendorDetailsState, VendorDetailsState>,
              VendorDetailsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
