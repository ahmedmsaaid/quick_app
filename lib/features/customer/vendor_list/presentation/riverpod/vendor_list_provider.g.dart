// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(VendorListNotifier)
final vendorListProvider = VendorListNotifierFamily._();

final class VendorListNotifierProvider
    extends $NotifierProvider<VendorListNotifier, VendorListState> {
  VendorListNotifierProvider._({
    required VendorListNotifierFamily super.from,
    required (int, {int? categoryId}) super.argument,
  }) : super(
         retry: null,
         name: r'vendorListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$vendorListNotifierHash();

  @override
  String toString() {
    return r'vendorListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  VendorListNotifier create() => VendorListNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VendorListState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VendorListState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is VendorListNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$vendorListNotifierHash() =>
    r'928c706118da1697698c350ec03e54d47efcccce';

final class VendorListNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          VendorListNotifier,
          VendorListState,
          VendorListState,
          VendorListState,
          (int, {int? categoryId})
        > {
  VendorListNotifierFamily._()
    : super(
        retry: null,
        name: r'vendorListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  VendorListNotifierProvider call(int role, {int? categoryId}) =>
      VendorListNotifierProvider._(
        argument: (role, categoryId: categoryId),
        from: this,
      );

  @override
  String toString() => r'vendorListProvider';
}

abstract class _$VendorListNotifier extends $Notifier<VendorListState> {
  late final _$args = ref.$arg as (int, {int? categoryId});
  int get role => _$args.$1;
  int? get categoryId => _$args.categoryId;

  VendorListState build(int role, {int? categoryId});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<VendorListState, VendorListState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<VendorListState, VendorListState>,
              VendorListState,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(_$args.$1, categoryId: _$args.categoryId),
    );
  }
}
