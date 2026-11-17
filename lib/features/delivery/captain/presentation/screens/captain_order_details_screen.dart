import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';
import 'package:base_app/core/constans/role_type_enum.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/models/app_chat_argument.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/home/data/home_api_service.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_location_stream_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_bottom_panel_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_order_map_widget.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/core/services/audio/order_sound_service.dart';

class CaptainOrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderDto order;
  const CaptainOrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<CaptainOrderDetailsScreen> createState() =>
      _CaptainOrderDetailsScreenState();
}

class _CaptainOrderDetailsScreenState
    extends ConsumerState<CaptainOrderDetailsScreen> {
  late int _orderState;
  bool _isLoading = false;
  bool _isFetchingDetails = false;
  int _fetchDetailsRequestId = 0;
  late OrderDto _order;
  LocationDto? _vendorLocation;
  Position? _currentCaptainPosition;
  StreamSubscription<Position>? _positionSubscription;

  final MapController _mapController = MapController();
  RouteResult? _roadRouteResult;
  bool _isAutoCentering = true;

  @override
  void initState() {
    super.initState();
    OrderSoundService.stopRingtone();
    _order = widget.order;
    _initializeOrderState();
    _startCaptainLocationListener();
    Future.microtask(() => _fetchOrderDetails());
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _startCaptainLocationListener() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse) {
        final initialPos = await Geolocator.getCurrentPosition();
        if (mounted) setState(() => _currentCaptainPosition = initialPos);
        _positionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 3,
          ),
        ).listen((pos) {
          if (mounted) {
            setState(() => _currentCaptainPosition = pos);
            if (_isAutoCentering) {
              _mapController.move(
                ll.LatLng(pos.latitude, pos.longitude),
                _mapController.camera.zoom > 10
                    ? _mapController.camera.zoom
                    : 15.5,
              );
            }
            _fetchRoadRoute();
          }
        });
      }
    } catch (e) {
      debugPrint('Captain location error: $e');
    }
  }

  Future<void> _fetchRoadRoute() async {
    final pos = _currentCaptainPosition;
    final storeLat = _vendorLocation?.latitude ??
        _order.userLocation?.latitude ??
        _order.creator?.location?.latitude;
    final storeLng = _vendorLocation?.longitude ??
        _order.userLocation?.longitude ??
        _order.creator?.location?.longitude;
    final destLat = _order.latitude;
    final destLng = _order.longitude;

    final hasStore = storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0;
    final hasDest = destLat != 0 && destLng != 0;

    final ll.LatLng? startPt = pos != null
        ? ll.LatLng(pos.latitude, pos.longitude)
        : (hasStore ? ll.LatLng(storeLat, storeLng) : null);

    final ll.LatLng? endPt = _orderState >= 2
        ? (hasDest ? ll.LatLng(destLat, destLng) : null)
        : (hasStore ? ll.LatLng(storeLat, storeLng) : null);

    if (startPt != null && endPt != null) {
      final route = await MapService.getDrivingRoute(startPt, endPt);
      if (mounted) setState(() => _roadRouteResult = route);
    }
  }

  double? get _distanceToCustomerMeters {
    final pos = _currentCaptainPosition;
    final destLat = _order.latitude;
    final destLng = _order.longitude;
    if (pos == null || destLat == 0 || destLng == 0) return null;
    return Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      destLat,
      destLng,
    );
  }

  void _initializeOrderState() {
    final hasDeliveryAssigned =
        _order.deliveryId != null && _order.deliveryId != 0;
    if (!hasDeliveryAssigned && _order.status < 6) {
      _orderState = 0;
    } else if (_order.status >= 3 && _order.status <= 5) {
      _orderState = 1;
    } else if (_order.status == 6) {
      _orderState = 2;
    } else if (_order.status >= 7) {
      _orderState = 3;
    } else {
      _orderState = 0;
    }
  }

  UserDto? get _customerUser => _order.creator ?? _order.user;

  Future<void> _fetchOrderDetails() async {
    final int requestId = ++_fetchDetailsRequestId;
    if (mounted) setState(() => _isFetchingDetails = true);
    final updatedOrder =
        await ref.read(captainOrdersProvider.notifier).getOrderDetails(widget.order.id);
    if (!mounted || requestId != _fetchDetailsRequestId) return;

    OrderDto? processedOrder = updatedOrder;

    if (processedOrder != null) {
      UserDto? customer = processedOrder.creator ?? processedOrder.user;
      final int customerId = processedOrder.creatorId != 0
          ? processedOrder.creatorId
          : (customer?.id ?? processedOrder.userId);

      if ((customer == null || customer.name == null || customer.name!.isEmpty) && customerId != 0) {
        final userResult = await ref.read(homeApiServiceProvider).getUserById(customerId);
        if (!mounted || requestId != _fetchDetailsRequestId) return;
        switch (userResult) {
          case Success(data: final userRes):
            if (userRes.success && userRes.result != null) {
              customer = userRes.result;
            }
            break;
          case Failure():
            break;
        }
      }

      if (customer != null) {
        processedOrder = processedOrder.copyWith(
          creator: processedOrder.creator ?? customer,
          user: processedOrder.user ?? customer,
          paymentMethod: processedOrder.paymentMethod != 0
              ? processedOrder.paymentMethod
              : widget.order.paymentMethod,
        );
      } else if (processedOrder.paymentMethod == 0 &&
          widget.order.paymentMethod != 0) {
        processedOrder = processedOrder.copyWith(
          paymentMethod: widget.order.paymentMethod,
        );
      }

      if (processedOrder.userLocationId != null) {
        final locResult = await ref
            .read(profileApiServiceProvider)
            .getLocationById(processedOrder.userLocationId!);
        if (!mounted || requestId != _fetchDetailsRequestId) return;
        switch (locResult) {
          case Success(data: final locResponse):
            if (locResponse.success && locResponse.result != null) {
              if (mounted) setState(() => _vendorLocation = locResponse.result);
            }
            break;
          case Failure(appError: final error):
            debugPrint('Error fetching location: ${error.message}');
            break;
        }
      }
    } else if (mounted) {
      CustomToast.error(context, AppStrings.fetchOrderDetailsFailed);
    }

    if (processedOrder != null && mounted && requestId == _fetchDetailsRequestId) {
      setState(() {
        _order = processedOrder!.copyWith(
          status: math.max(_order.status, processedOrder.status),
        );
        _initializeOrderState();
      });
    }

    if (mounted && requestId == _fetchDetailsRequestId) {
      setState(() => _isFetchingDetails = false);
    }
    _fetchRoadRoute();
  }

  Future<void> _handleActionButton() async {
    OrderSoundService.stopRingtone();
    if (_isLoading) return;
    _fetchDetailsRequestId++;

    if (_orderState == 0) {
      setState(() => _isLoading = true);
      final success =
          await ref.read(captainOrdersProvider.notifier).acceptOrder(_order);
      if (!mounted) return;

      if (success) {
        final profileState = ref.read(profileProvider);
        final user = profileState.user;
        setState(() {
          _isLoading = false;
          _order = _order.copyWith(
            status: 3,
            deliveryId: user?.id ?? _order.deliveryId,
          );
          _initializeOrderState();
        });
        CustomToast.success(context, AppStrings.orderAcceptedSuccess);
        _fetchOrderDetails();
      } else {
        setState(() => _isLoading = false);
        CustomToast.error(context, AppStrings.orderAcceptFailed);
      }
    } else if (_orderState == 1) {
      setState(() => _isLoading = true);
      final success =
          await ref.read(captainOrdersProvider.notifier).updateStatus(_order, 6);
      if (!mounted) return;

      if (success) {
        setState(() {
          _isLoading = false;
          _order = _order.copyWith(status: 6);
          _initializeOrderState();
        });
        ref.read(captainLocationStreamProvider.notifier).startStreaming(
              orderId: _order.id,
              deliveryId: _order.deliveryId ?? 0,
            );
        CustomToast.success(context, AppStrings.orderPickedUpSuccess);
        _fetchOrderDetails();
      } else {
        setState(() => _isLoading = false);
        CustomToast.error(context, AppStrings.orderPickupFailed);
      }
    } else if (_orderState == 2) {
      final distMeters = _distanceToCustomerMeters;
      if (distMeters != null && distMeters > 100) {
        if (mounted) {
          CustomToast.error(
            context,
            AppStrings.mustBeWithin100m,
          );
        }
        return;
      }

      setState(() => _isLoading = true);
      final success =
          await ref.read(captainOrdersProvider.notifier).updateStatus(_order, 7);
      setState(() => _isLoading = false);

      if (success) {
        await ref
            .read(captainLocationStreamProvider.notifier)
            .sendDeliveredSignal(
              orderId: _order.id,
              deliveryId: _order.deliveryId ?? 0,
            );
        if (mounted) {
          CustomToast.success(context, AppStrings.orderDeliveredSuccess);
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          CustomToast.error(context, AppStrings.orderStatusUpdateFailed);
        }
      }
    }
  }

  void _handleCall() {
    final customer = _customerUser;
    final phone = (customer?.phone != null && customer!.phone!.isNotEmpty)
        ? customer.phone!
        : (_order.creator?.phone ?? _order.user?.phone);

    if (phone != null && phone.isNotEmpty) {
      _launchCall(context, phone);
    } else {
      CustomToast.error(context, AppStrings.noCustomerPhone);
    }
  }

  void _handleChat() {
    final customer = _customerUser;
    final String customerName = (customer?.name != null && customer!.name!.isNotEmpty)
        ? customer.name!
        : AppStrings.contactCustomer;
    final String? photoKey = customer?.photo ??
        customer?.avatar ??
        _order.creator?.photo ??
        _order.creator?.avatar ??
        _order.user?.photo ??
        _order.user?.avatar;
    final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
        ? (photoKey.startsWith('http')
            ? photoKey
            : '${ApiConstants.streamUrl}$photoKey')
        : '';

    final int recipientId = customer?.id ??
        (_order.creatorId != 0 ? _order.creatorId : _order.userId);

    if (recipientId != 0) {
      Navigator.of(context).pushNamed(
        AppRoutes.chatDetailsScreen,
        arguments: AppChatArgument(
          chatId: null,
          recipientId: recipientId,
          profileId: 0,
          typeEnum: RoleTypeEnum.customer,
          recipientName: customerName,
          recipientImage: photoUrl,
        ),
      );
    } else {
      CustomToast.error(context, AppStrings.noCustomerData);
    }
  }

  Future<void> _launchCall(BuildContext context, String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          CustomToast.error(context, '${AppStrings.cannotCallNumber} $phone');
        }
      }
    } catch (e) {
      if (context.mounted) {
        CustomToast.error(context, '${AppStrings.callError}: $e');
      }
    }
  }

  List<Marker> _buildMarkers(AppColors colors) {
    final markers = <Marker>[];
    final pos = _currentCaptainPosition;

    final storeLat = _vendorLocation?.latitude ??
        _order.userLocation?.latitude ??
        _order.creator?.location?.latitude;
    final storeLng = _vendorLocation?.longitude ??
        _order.userLocation?.longitude ??
        _order.creator?.location?.longitude;
    final destLat = _order.latitude;
    final destLng = _order.longitude;

    if (pos != null) {
      final capPoint = ll.LatLng(pos.latitude, pos.longitude);
      final bool isPickedUp = _order.status >= 6;
      final targetPoint = isPickedUp
          ? (destLat != 0 && destLng != 0 ? ll.LatLng(destLat, destLng) : capPoint)
          : (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0
              ? ll.LatLng(storeLat, storeLng)
              : capPoint);

      double bearingAngle = 0.0;
      if (pos.heading > 0) {
        bearingAngle = pos.heading * (math.pi / 180.0);
      } else if (capPoint.latitude != targetPoint.latitude ||
          capPoint.longitude != targetPoint.longitude) {
        final dLng = (targetPoint.longitude - capPoint.longitude) * (math.pi / 180.0);
        final sLat = capPoint.latitude * (math.pi / 180.0);
        final eLat = targetPoint.latitude * (math.pi / 180.0);
        final y = math.sin(dLng) * math.cos(eLat);
        final x = math.cos(sLat) * math.sin(eLat) -
            math.sin(sLat) * math.cos(eLat) * math.cos(dLng);
        bearingAngle = math.atan2(y, x);
      }

      markers.add(Marker(
        point: capPoint,
        width: 54.w,
        height: 54.w,
        child: Transform.rotate(
          angle: bearingAngle,
          child: Image.asset(
            'assets/icons/delivarey-mab.png',
            fit: BoxFit.contain,
          ),
        ),
      ));
    }

    if (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0) {
      markers.add(Marker(
        point: ll.LatLng(storeLat, storeLng),
        width: 44.w,
        height: 44.w,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: const Icon(
            Icons.storefront_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ));
    }

    if (destLat != 0 && destLng != 0) {
      markers.add(Marker(
        point: ll.LatLng(destLat, destLng),
        width: 44.w,
        height: 44.w,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: const Icon(
            Icons.person_pin_circle_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
      ));
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final pos = _currentCaptainPosition;

    final storeLat = _vendorLocation?.latitude ??
        _order.userLocation?.latitude ??
        _order.creator?.location?.latitude;
    final storeLng = _vendorLocation?.longitude ??
        _order.userLocation?.longitude ??
        _order.creator?.location?.longitude;
    final destLat = _order.latitude;
    final destLng = _order.longitude;

    final centerPoint = pos != null
        ? ll.LatLng(pos.latitude, pos.longitude)
        : (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0
            ? ll.LatLng(storeLat, storeLng)
            : (destLat != 0 && destLng != 0
                ? ll.LatLng(destLat, destLng)
                : const ll.LatLng(30.0444, 31.2357)));

    final markers = _buildMarkers(colors);
    final polylines = <Polyline>[];
    final routePoints = _roadRouteResult?.points ?? [];
    if (routePoints.isNotEmpty) {
      polylines.add(Polyline(
        points: routePoints,
        strokeWidth: 5.5,
        color: _orderState >= 2 ? Colors.orange : colors.primary,
        borderStrokeWidth: 2.0,
        borderColor: _orderState >= 2
            ? const Color(0xFF7C2D12)
            : const Color(0xFF0F172A),
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ));
    }

    return Scaffold(
      backgroundColor: colors.background,
      body: Stack(
        children: [
          CaptainOrderMapWidget(
            mapController: _mapController,
            centerPoint: centerPoint,
            markers: markers,
            polylines: polylines,
            roadRouteResult: _roadRouteResult,
            orderState: _orderState,
            order: _order,
            isAutoCentering: _isAutoCentering,
            onRecenter: () {
              setState(() => _isAutoCentering = true);
              final p = _currentCaptainPosition;
              if (p != null) {
                _mapController.move(ll.LatLng(p.latitude, p.longitude), 15.5);
              }
            },
            onPositionChanged: (position, hasGesture) {
              if (hasGesture && _isAutoCentering) {
                setState(() => _isAutoCentering = false);
              }
            },
          ),
          CaptainBottomPanelWidget(
            order: _order,
            orderState: _orderState,
            isLoading: _isLoading,
            onCall: _handleCall,
            onChat: _handleChat,
            onAction: _handleActionButton,
            distanceToCustomerMeters: _distanceToCustomerMeters,
            vendorLocation: _vendorLocation,
            isFetchingDetails: _isFetchingDetails,
          ),
        ],
      ),
    );
  }
}
