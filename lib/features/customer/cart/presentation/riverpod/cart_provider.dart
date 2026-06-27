import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';

part 'cart_provider.g.dart';

// ─── Cart Item Model ───────────────────────────────────
class CartItem {
  final ProductDetailDto product;
  final int quantity;

  const CartItem({required this.product, required this.quantity});

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);

  double get effectivePrice {
    if (product.hasDiscount) {
      return product.price * (1 - product.discountPercentage / 100);
    }
    return product.price;
  }

  double get totalPrice => effectivePrice * quantity;
}

// ─── Cart State ────────────────────────────────────────
class CartState {
  final List<CartItem> items;
  final int? vendorId;

  const CartState({this.items = const [], this.vendorId});

  CartState copyWith({List<CartItem>? items, int? vendorId, bool clearVendorId = false}) =>
      CartState(
        items: items ?? this.items,
        vendorId: clearVendorId ? null : (vendorId ?? this.vendorId),
      );

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => items.fold(0.0, (sum, i) => sum + i.totalPrice);

  bool containsProduct(int productId) =>
      items.any((i) => i.product.id == productId);

  int quantityOf(int productId) =>
      items.where((i) => i.product.id == productId).fold(0, (s, i) => s + i.quantity);
}

// ─── Cart Notifier ─────────────────────────────────────
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  CartState build() => const CartState();

  void addItem(ProductDetailDto product, {int quantity = 1, int? vendorId}) {
    final items = [...state.items];
    final resolvedVendorId = vendorId ?? product.creatorId;

    // Clear cart if product type changes or if vendor ID changes (different vendors)
    if (items.isNotEmpty && 
        (items.first.product.type != product.type || 
         (state.vendorId != null && resolvedVendorId != null && state.vendorId != resolvedVendorId))) {
      items.clear();
    }
    
    final idx = items.indexWhere((i) => i.product.id == product.id);
    if (idx != -1) {
      items[idx] = items[idx].copyWith(quantity: items[idx].quantity + quantity);
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }
    
    state = state.copyWith(
      items: items,
      vendorId: items.isEmpty ? null : (resolvedVendorId ?? state.vendorId),
    );
  }

  void removeItem(int productId) {
    final newItems = state.items.where((i) => i.product.id != productId).toList();
    state = state.copyWith(
      items: newItems,
      clearVendorId: newItems.isEmpty,
    );
  }

  void increaseQuantity(int productId) {
    state = state.copyWith(
      items: state.items.map((i) {
        if (i.product.id == productId) return i.copyWith(quantity: i.quantity + 1);
        return i;
      }).toList(),
    );
  }

  void decreaseQuantity(int productId) {
    final item = state.items.firstWhere(
      (i) => i.product.id == productId,
      orElse: () => throw Exception('Item not found'),
    );
    if (item.quantity <= 1) {
      removeItem(productId);
    } else {
      state = state.copyWith(
        items: state.items.map((i) {
          if (i.product.id == productId) return i.copyWith(quantity: i.quantity - 1);
          return i;
        }).toList(),
      );
    }
  }

  void clearCart() => state = const CartState();
}
