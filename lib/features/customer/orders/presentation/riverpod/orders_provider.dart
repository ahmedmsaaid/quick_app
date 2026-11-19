import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/customer/cart/presentation/riverpod/cart_provider.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
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
  final int pageNumber;
  final bool hasMore;
  final bool isLoadingMore;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.errorMessage,
    this.reorderStatus = ReorderStatus.idle,
    this.reorderError,
    this.pageNumber = 1,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderDto>? orders,
    String? errorMessage,
    ReorderStatus? reorderStatus,
    String? reorderError,
    int? pageNumber,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      errorMessage: errorMessage ?? this.errorMessage,
      reorderStatus: reorderStatus ?? this.reorderStatus,
      reorderError: reorderError ?? this.reorderError,
      pageNumber: pageNumber ?? this.pageNumber,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

@Riverpod(keepAlive: true)
class OrdersNotifier extends _$OrdersNotifier {
  static const int _pageSize = 10;

  @override
  OrdersState build() {
    ref.listen(profileProvider, (previous, next) {
      final wasLoaded = previous?.status == ProfileStatus.loaded;
      final isNowLoaded =
          next.status == ProfileStatus.loaded && next.user != null;
      if (!wasLoaded && isNowLoaded) {
        final currentStatus = state.status;
        final userChanged = previous?.user?.id != next.user?.id;
        if (currentStatus == OrdersStatus.initial || userChanged) {
          loadOrders(forceRefresh: true);
        }
      }
    });

    final profile = ref.read(profileProvider);
    if (profile.status == ProfileStatus.loaded && profile.user != null) {
      Future.microtask(() {
        if (state.status == OrdersStatus.initial) {
          loadOrders();
        }
      });
    }
    return const OrdersState();
  }

  Future<void> loadOrders({bool forceRefresh = false}) async {
    if (state.status == OrdersStatus.loading) return;
    if (state.status == OrdersStatus.loaded && !forceRefresh) return;

    state = state.copyWith(
      status: OrdersStatus.loading,
      errorMessage: null,
      pageNumber: 1,
      hasMore: true,
      isLoadingMore: false,
    );

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
    final result = await apiService.getOrders(
      userId: user!.id,
      pageNumber: 1,
      pageSize: _pageSize,
    );

    if (!ref.mounted) return;

    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          final list = response.result!;
          state = state.copyWith(
            status: OrdersStatus.loaded,
            orders: list,
            pageNumber: 1,
            hasMore: list.length >= _pageSize,
            isLoadingMore: false,
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

  /// تحميل المزيد من الطلبات (Pagination / Infinite Scroll)
  Future<void> loadMoreOrders() async {
    if (!state.hasMore ||
        state.isLoadingMore ||
        state.status != OrdersStatus.loaded) {
      return;
    }

    final user = ref.read(profileProvider).user;
    if (user == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.pageNumber + 1;
      final apiService = ref.read(ordersApiServiceProvider);
      final result = await apiService.getOrders(
        userId: user.id,
        pageNumber: nextPage,
        pageSize: _pageSize,
      );

      if (!ref.mounted) return;

      result.when(
        success: (response) {
          final list = response.result ?? [];
          final existingIds = state.orders.map((o) => o.id).toSet();
          final uniqueNew =
              list.where((o) => !existingIds.contains(o.id)).toList();

          state = state.copyWith(
            orders: [...state.orders, ...uniqueNew],
            pageNumber: nextPage,
            hasMore: list.length >= _pageSize,
            isLoadingMore: false,
          );
        },
        failure: (_) {
          state = state.copyWith(
            isLoadingMore: false,
            hasMore: false,
          );
        },
      );
    } catch (_) {
      if (ref.mounted) {
        state = state.copyWith(isLoadingMore: false);
      }
    }
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
      final homeApi = ref.read(homeApiServiceProvider);
      final ordersApi = ref.read(ordersApiServiceProvider);

      int? fallbackVendorId = (oldOrder.userId > 0 && oldOrder.userId != oldOrder.creatorId)
          ? oldOrder.userId
          : (oldOrder.user?.id ?? oldOrder.userLocation?.creatorId);

      // جلب بيانات المنتجات الحقيقية بالتوازي لمعرفة المطعم/المتجر الفعلي المالك للمنتج
      final fetchedProducts = await Future.wait(
        oldOrder.products.map((p) async {
          if (p.productId <= 0) return null;
          final res = await homeApi.getProductById(p.productId);
          return res.when(
            success: (apiRes) => apiRes.success ? apiRes.result : null,
            failure: (_) => null,
          );
        }),
      );

      for (int i = 0; i < oldOrder.products.length; i++) {
        final cId = fetchedProducts[i]?.creatorId ?? oldOrder.products[i].creatorId;
        if (cId != null && cId > 0) {
          fallbackVendorId = cId;
          break;
        }
      }

      if (fallbackVendorId == null || fallbackVendorId <= 0) {
        final orderRes = await ordersApi.getOrderById(orderId: oldOrder.id);
        orderRes.when(
          success: (apiRes) {
            final fullOrder = apiRes.result;
            if (fullOrder != null) {
              fallbackVendorId = (fullOrder.userId > 0 && fullOrder.userId != fullOrder.creatorId)
                  ? fullOrder.userId
                  : (fullOrder.user?.id ??
                      fullOrder.userLocation?.creatorId ??
                      (fullOrder.userId > 0 ? fullOrder.userId : null));
            }
          },
          failure: (_) {},
        );
      }

      fallbackVendorId ??= oldOrder.userId > 0 ? oldOrder.userId : null;

      // تفريغ السلة الحالية
      cartNotifier.clearCart();

      // إضافة منتجات الطلب القديم إلى السلة مع ربطها بالمطعم/المتجر الصحيح
      for (int i = 0; i < oldOrder.products.length; i++) {
        final p = oldOrder.products[i];
        final fetched = fetchedProducts[i];
        final int? itemVendorId = fetched?.creatorId ?? p.creatorId ?? fallbackVendorId;

        final product = ProductDetailDto(
          id: p.productId,
          name: fetched?.name ?? p.productName ?? 'منتج',
          photo: fetched?.photo ?? p.photo,
          description: fetched?.description ?? '',
          price: fetched != null && fetched.price > 0 ? fetched.price : p.price,
          rating: fetched?.rating ?? 5.0,
          isFavorite: fetched?.isFavorite ?? false,
          isAvailable: fetched?.isAvailable ?? true,
          hasDiscount: fetched?.hasDiscount ?? false,
          discountPercentage: fetched?.discountPercentage ?? 0.0,
          categoryId: fetched?.categoryId ?? 0,
          createdOn: fetched?.createdOn ?? '',
          type: fetched?.type ?? oldOrder.type,
          creatorId: itemVendorId,
        );

        cartNotifier.addItem(
          product,
          quantity: p.quantity,
          vendorId: itemVendorId,
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
          final updatedOrders = state.orders
              .map((o) => o.id == order.id ? o.copyWith(status: 8) : o)
              .toList();
          state = state.copyWith(orders: updatedOrders);
          loadOrders(forceRefresh: true);
          ref
              .read(homeRecentOrdersProvider.notifier)
              .loadRecentOrders(forceRefresh: true);
          ref.invalidate(trackOrderProvider(order.id));
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

@Riverpod(keepAlive: true)
class HomeRecentOrdersNotifier extends _$HomeRecentOrdersNotifier {
  @override
  OrdersState build() {
    ref.listen(profileProvider, (previous, next) {
      final wasLoaded = previous?.status == ProfileStatus.loaded;
      final isNowLoaded =
          next.status == ProfileStatus.loaded && next.user != null;
      if (!wasLoaded && isNowLoaded) {
        final currentStatus = state.status;
        final userChanged = previous?.user?.id != next.user?.id;
        if (currentStatus == OrdersStatus.initial || userChanged) {
          loadRecentOrders(forceRefresh: true);
        }
      }
    });

    final profile = ref.read(profileProvider);
    if (profile.status == ProfileStatus.loaded && profile.user != null) {
      Future.microtask(() => loadRecentOrders());
    }
    return const OrdersState();
  }

  /// جلب آخر 5 طلبات فقط لصفحة الهوم بدلاً من 50
  Future<void> loadRecentOrders({bool forceRefresh = false}) async {
    if (state.status == OrdersStatus.loading && !forceRefresh) return;

    state = state.copyWith(
      status: OrdersStatus.loading,
      errorMessage: null,
    );

    var profileState = ref.read(profileProvider);
    var user = profileState.user;

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
        status: OrdersStatus.loaded,
        orders: const [],
      );
      return;
    }

    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.getOrders(
      userId: user!.id,
      pageNumber: 1,
      pageSize: 5,
    );

    if (!ref.mounted) return;

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
        final incomingDeliveryId = update.deliveryId.toInt();
        if (incomingDeliveryId != 0 &&
            incomingDeliveryId != currentOrder.deliveryId) {
          final refreshedRes = await apiService.getOrderById(
            orderId: orderId,
            includesPath: const [
              "User",
              "Creator",
              "OrderProducts.Product",
              "Delivery",
              "UserLocation",
            ],
          );
          final refreshed = refreshedRes.when(
            success: (res) => res.success ? res.result : null,
            failure: (_) => null,
          );
          if (refreshed != null) {
            currentOrder = refreshed;
          }
        }

        final newDeliveryLocation = LocationModel(
          latitude: update.latitude != 0 ? update.latitude : (currentOrder.delivery?.location?.latitude ?? 0.0),
          longitude: update.longitude != 0 ? update.longitude : (currentOrder.delivery?.location?.longitude ?? 0.0),
        );

        final updatedDelivery = (currentOrder.delivery ??
                UserDto(
                  id: incomingDeliveryId != 0 ? incomingDeliveryId : (currentOrder.deliveryId ?? 0),
                  role: 3,
                  status: 1,
                ))
            .copyWith(location: newDeliveryLocation);

        currentOrder = currentOrder.copyWith(
          status: newStatus,
          deliveryId: incomingDeliveryId != 0 ? incomingDeliveryId : currentOrder.deliveryId,
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


