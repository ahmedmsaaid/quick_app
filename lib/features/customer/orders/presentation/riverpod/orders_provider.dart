import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/home/data/models/product_detail_model.dart';
import 'package:base_app/features/shared/tracking/data/data_source/app_order_tracking_grpc_data_source.dart';
import 'package:base_app/features/shared/tracking/data/data_source/generated/Tracking.pb.dart' as tracking_pb;

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

    var profileState = ref.read(profileProvider);
    var user = profileState.user;

    // If profile user is null, try fetching the profile dynamically
    if (user == null) {
      final profileResult = await ref.read(profileApiServiceProvider).getProfile();
      profileResult.when(
        success: (response) {
          if (response.success && response.result != null) {
            user = response.result;
            ref.read(profileProvider.notifier).loadProfile();
          }
        },
        failure: (_) {},
      );
    }

    if (user == null) {
      state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: 'الرجاء تسجيل الدخول أولاً لرؤية الطلبات',
      );
      return;
    }

    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.getOrders(userId: user!.id);

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
Stream<tracking_pb.GrpcLocationUpdate> orderTrackingGrpcStream(Ref ref, int orderId) async* {
  final dataSource = ref.watch(appOrderTrackingGrpcDataSourceProvider);
  try {
    final stream = await dataSource.subscribeToOrderTracking(orderId);
    await for (final update in stream) {
      yield update;
      if (update.status == tracking_pb.GrpcOrderStatus.Delivered) {
        break;
      }
    }
  } catch (e) {
    debugPrint("⚠️ gRPC Order Tracking stream error: $e");
  }
}

@riverpod
Stream<OrderDto> trackOrder(Ref ref, int orderId) async* {
  final apiService = ref.watch(ordersApiServiceProvider);
  final trackingDataSource = ref.watch(appOrderTrackingGrpcDataSourceProvider);

  // 1. Fetch initial hydrated order details via REST
  final initialResult = await apiService.getOrderById(
    orderId: orderId,
    includesPath: const ["User", "Creator", "OrderProducts.Product", "Delivery", "UserLocation"],
  );

  OrderDto? currentOrder = initialResult.when(
    success: (response) => (response.success && response.result != null) ? response.result : null,
    failure: (error) => null,
  );

  if (currentOrder != null) {
    yield currentOrder;
  }

  // 2. Subscribe to gRPC live location & status stream
  try {
    final stream = await trackingDataSource.subscribeToOrderTracking(orderId);
    await for (final update in stream) {
      int newStatus = currentOrder?.status ?? 6;
      if (update.status == tracking_pb.GrpcOrderStatus.OutForDelivery) {
        newStatus = 6;
      } else if (update.status == tracking_pb.GrpcOrderStatus.Delivered) {
        newStatus = 7;
      }

      if (currentOrder != null) {
        final newDeliveryLocation = LocationModel(
          latitude: update.latitude != 0 ? update.latitude : (currentOrder.delivery?.location?.latitude ?? 0.0),
          longitude: update.longitude != 0 ? update.longitude : (currentOrder.delivery?.location?.longitude ?? 0.0),
        );

        final updatedDelivery = (currentOrder.delivery ??
                UserDto(
                  id: update.deliveryId.toInt() != 0 ? update.deliveryId.toInt() : (currentOrder.deliveryId ?? 0),
                  role: 3,
                  status: 1,
                ))
            .copyWith(location: newDeliveryLocation);

        currentOrder = currentOrder.copyWith(
          status: newStatus,
          deliveryId: update.deliveryId.toInt() != 0 ? update.deliveryId.toInt() : currentOrder.deliveryId,
          delivery: updatedDelivery,
        );
        yield currentOrder;
      }

      if (update.status == tracking_pb.GrpcOrderStatus.Delivered) {
        break;
      }
    }
  } catch (e) {
    debugPrint("⚠️ [gRPC trackOrder Stream Exception] Falling back to REST polling: $e");

    // Fallback polling loop if gRPC stream encounters an error
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      final result = await apiService.getOrderById(
        orderId: orderId,
        includesPath: const ["User", "Creator", "OrderProducts.Product", "Delivery", "UserLocation"],
      );
      final fetched = result.when(
        success: (res) => res.success ? res.result : null,
        failure: (_) => null,
      );
      if (fetched != null) {
        yield fetched;
      }
    }
  }
}


