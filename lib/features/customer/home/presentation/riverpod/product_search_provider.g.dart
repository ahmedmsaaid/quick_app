// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProductSearchNotifier)
final productSearchProvider = ProductSearchNotifierProvider._();

final class ProductSearchNotifierProvider
    extends $NotifierProvider<ProductSearchNotifier, ProductSearchState> {
  ProductSearchNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'productSearchProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$productSearchNotifierHash();

  @$internal
  @override
  ProductSearchNotifier create() => ProductSearchNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProductSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProductSearchState>(value),
    );
  }
}

String _$productSearchNotifierHash() =>
    r'6cf553f296cabb28704a63d3faed3989839eacdc';

abstract class _$ProductSearchNotifier extends $Notifier<ProductSearchState> {
  ProductSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ProductSearchState, ProductSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ProductSearchState, ProductSearchState>,
              ProductSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
