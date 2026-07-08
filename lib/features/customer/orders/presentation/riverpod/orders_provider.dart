import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';

part 'orders_provider.g.dart';

enum OrdersStatus { initial, loading, loaded, error }

enum ReorderStatus { idle, loading, success, error }

class OrdersState {
  final OrdersStatus status;
  final List<OrderDto> orders;
  final String? errorMessage;
  final ReorderStatus reorderStatus;
  final String? reorderError;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.reorderStatus = ReorderStatus.idle,
    this.reorderError,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderDto>? orders,
    String? errorMessage,
    ReorderStatus? reorderStatus,
    String? reorderError,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      reorderStatus: reorderStatus ?? this.reorderStatus,
      reorderError: reorderError ?? this.reorderError,
    );
  }
}

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  @override
  OrdersState build() {
    Future.microtask(() => loadOrders());
    return const OrdersState();
  }

  Future<void> loadOrders() async {
    state = state.copyWith(status: OrdersStatus.loading);

    final profileState = ref.read(profileProvider);
    final user = profileState.user;
    if (user == null) {
      state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: 'الرجاء تسجيل الدخول أولاً لرؤية الطلبات',
      );
      return;
    }

    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.getOrders(userId: user.id);

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          state = state.copyWith(
            status: OrdersStatus.loaded,
            orders: response.result!,
          );
        } else {
          state = state.copyWith(
            status: OrdersStatus.error,
            errorMessage: response.message ?? 'فشل تحميل الطلبات',
          );
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: OrdersStatus.error,
          errorMessage: error.message,
        );
      },
    );
  }

  /// إعادة الطلب — يجهز السلة بمنتجات الطلب القديم ويعيد true للبدء في توجيه المستخدم لصفحة السلة
  Future<bool> reorder(OrderDto oldOrder) async {
    state = state.copyWith(
      reorderStatus: ReorderStatus.loading,
      reorderError: null,
    );

    if (oldOrder.products.isEmpty) {
      state = state.copyWith(
        reorderStatus: ReorderStatus.error,
        reorderError: 'لا توجد منتجات في هذا الطلب لإعادتها',
      );
      return false;
    }

    try {
      final cartNotifier = ref.read(cartProvider.notifier);

      // تفريغ السلة الحالية
      cartNotifier.clearCart();

      // إضافة منتجات الطلب القديم إلى السلة
      for (final p in oldOrder.products) {
        final product = ProductDetailDto(
          id: p.productId,
          name: p.productName ?? 'منتج',
          photo: p.photo,
          description: '',
          price: p.price,
          rating: 5.0,
          isFavorite: false,
          isAvailable: true,
          hasDiscount: false,
          discountPercentage: 0.0,
          categoryId: 0,
          createdOn: '',
          type: oldOrder.type,
          creatorId: oldOrder.creatorId,
        );

        cartNotifier.addItem(
          product,
          quantity: p.quantity,
          vendorId: oldOrder.creatorId,
        );
      }

      state = state.copyWith(reorderStatus: ReorderStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        reorderStatus: ReorderStatus.error,
        reorderError: 'حدث خطأ أثناء إعداد السلة: $e',
      );
      return false;
    }
  }

  Future<bool> cancelOrder(OrderDto order) async {
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.updateOrderStatus(
      orderId: order.id,
      status: 8, // Cancelled
      rowVersion: order.rowVersion,
    );
    if (!ref.mounted) return false;

    return result.when(
      success: (response) {
        if (response.success) {
          loadOrders(); // Refresh orders list
          return true;
        }
        return false;
      },
      failure: (_) => false,
    );
  }

  void resetReorderStatus() {
    state = state.copyWith(
      reorderStatus: ReorderStatus.idle,
      reorderError: null,
    );
  }
}

@riverpod
Stream<OrderDto> trackOrder(Ref ref, int orderId) async* {
  final apiService = ref.watch(ordersApiServiceProvider);
  
  while (true) {
    final result = await apiService.getOrderById(
      orderId: orderId,
      includesPath: const ["User", "Creator", "OrderProducts.Product", "Updator", "UserLocation"],
    );
    
    final order = result.when(
      success: (response) {
        if (response.success && response.result != null) {
          return response.result!;
        }
        return null;
      },
      failure: (error) => null,
    );
    
    if (order != null) {
      yield order;
    }
    
    await Future.delayed(const Duration(seconds: 10));
  }
}

