import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:lottie/lottie.dart' hide Marker;
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/core/utils/assets/app_assets.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/orders/presentation/riverpod/orders_provider.dart';

class OrderTrackingMapWidget extends ConsumerStatefulWidget {
  final OrderDto order;

  const OrderTrackingMapWidget({super.key, required this.order});

  @override
  ConsumerState<OrderTrackingMapWidget> createState() => _OrderTrackingMapWidgetState();
}

class _OrderTrackingMapWidgetState extends ConsumerState<OrderTrackingMapWidget> {
  final MapController _mapController = MapController();
  RouteResult? _roadRouteResult;
  bool _isAutoCentering = true;
  bool _isMapReady = false;

  double? _prevCaptainLat;
  double? _prevCaptainLng;

  @override
  void initState() {
    super.initState();
    _initMapData();
  }

  Future<void> _initMapData() async {
    await _fetchRoadRoute(widget.order);
    if (mounted) {
      setState(() => _isMapReady = true);
    }
  }

  void _onOrderUpdate(OrderDto o) {
    final capLat = o.delivery?.location?.latitude;
    final capLng = o.delivery?.location?.longitude;

    final captainMoved = capLat != null &&
        capLng != null &&
        capLat != 0 &&
        capLng != 0 &&
        (_prevCaptainLat == null ||
            (capLat - (_prevCaptainLat ?? 0)).abs() > 0.0002 ||
            (capLng - (_prevCaptainLng ?? 0)).abs() > 0.0002);

    if (captainMoved) {
      _prevCaptainLat = capLat;
      _prevCaptainLng = capLng;

      if (_isAutoCentering) {
        _mapController.move(
          ll.LatLng(capLat, capLng),
          _mapController.camera.zoom > 10 ? _mapController.camera.zoom : 15.5,
        );
      }

      MapService.invalidateRouteCache(ll.LatLng(capLat, capLng));
      _fetchRoadRoute(o);
    }
  }

  Future<void> _fetchRoadRoute(OrderDto o) async {
    final destLat = o.latitude;
    final destLng = o.longitude;

    final storeLat = o.userLocation?.latitude ?? o.user?.location?.latitude ?? o.creator?.location?.latitude;
    final storeLng = o.userLocation?.longitude ?? o.user?.location?.longitude ?? o.creator?.location?.longitude;

    final captainLat = o.delivery?.location?.latitude;
    final captainLng = o.delivery?.location?.longitude;

    final startLat = (o.status == 6 && captainLat != null && captainLat != 0) ? captainLat : storeLat;
    final startLng = (o.status == 6 && captainLng != null && captainLng != 0) ? captainLng : storeLng;

    if (destLat != 0 && destLng != 0 && startLat != null && startLng != null && startLat != 0 && startLng != 0) {
      if ((startLat - destLat).abs() < 0.0001 && (startLng - destLng).abs() < 0.0001) {
        return;
      }
      final route = await MapService.getDrivingRoute(
        ll.LatLng(startLat, startLng),
        ll.LatLng(destLat, destLng),
      );
      if (mounted) {
        setState(() {
          _roadRouteResult = route;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final liveOrderAsync = ref.watch(trackOrderProvider(widget.order.id));
    final o = liveOrderAsync.value ?? widget.order;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final liveVal = liveOrderAsync.value;
      if (liveVal != null) _onOrderUpdate(liveVal);
    });
    final destLat = o.latitude;
    final destLng = o.longitude;

    final storeLat = o.userLocation?.latitude ?? o.user?.location?.latitude ?? o.creator?.location?.latitude;
    final storeLng = o.userLocation?.longitude ?? o.user?.location?.longitude ?? o.creator?.location?.longitude;

    final captainLat = o.delivery?.location?.latitude;
    final captainLng = o.delivery?.location?.longitude;

    final hasDest = destLat != 0 && destLng != 0;
    final hasStore = storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0;
    final hasCaptain = captainLat != null && captainLng != null && captainLat != 0 && captainLng != 0;

    final centerLat = hasDest ? destLat : (hasStore ? storeLat : 30.0444);
    final centerLng = hasDest ? destLng : (hasStore ? storeLng : 31.2357);

    final markers = <Marker>[];
    final polylines = <Polyline>[];

    final routePoints = _roadRouteResult?.points ?? [];
    if (routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: routePoints,
          strokeWidth: 5.5,
          color: colors.primary,
          borderStrokeWidth: 2.0,
          borderColor: const Color(0xFF0F172A),
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.round,
        ),
      );
    }

    if (hasStore) {
      markers.add(
        Marker(
          point: ll.LatLng(storeLat, storeLng),
          width: 44.w,
          height: 44.w,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 6)],
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
          ),
        ),
      );
    }

    if (hasDest) {
      markers.add(
        Marker(
          point: ll.LatLng(destLat, destLng),
          width: 44.w,
          height: 44.w,
          child: Container(
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 6)],
            ),
            child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
    }

    if (o.status == 6 && (hasCaptain || hasDest)) {
      final capPoint = hasCaptain ? ll.LatLng(captainLat, captainLng) : ll.LatLng(destLat, destLng);
      final destPoint = hasDest ? ll.LatLng(destLat, destLng) : capPoint;

      double bearingAngle = 0.0;
      if (capPoint.latitude != destPoint.latitude || capPoint.longitude != destPoint.longitude) {
        final dLng = (destPoint.longitude - capPoint.longitude) * (math.pi / 180.0);
        final sLat = capPoint.latitude * (math.pi / 180.0);
        final eLat = destPoint.latitude * (math.pi / 180.0);
        final y = math.sin(dLng) * math.cos(eLat);
        final x = math.cos(sLat) * math.sin(eLat) - math.sin(sLat) * math.cos(eLat) * math.cos(dLng);
        bearingAngle = math.atan2(y, x);
      }

      markers.add(
        Marker(
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
        ),
      );
    }

    final bool isPickedUp = o.status >= 6;
    final bool canShowMap = isPickedUp &&
        _isMapReady &&
        (!liveOrderAsync.isLoading || liveOrderAsync.hasValue);

    return Stack(
      children: [
        if (canShowMap)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: ll.LatLng(centerLat, centerLng),
              initialZoom: 14.5,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture && _isAutoCentering) {
                  setState(() {
                    _isAutoCentering = false;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: MapService.googleTileUrl,
                subdomains: MapService.googleTileSubdomains,
                userAgentPackageName: 'com.quickDelivery.quick',
              ),
              if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
              MarkerLayer(markers: markers),
            ],
          )
        else
          Positioned.fill(
            child: Container(
              color: colors.background,
              alignment: const Alignment(0, -0.25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    AppAssets.chef,
                    width: 170.w,
                    height: 170.w,
                    fit: BoxFit.contain,
                  ),
                  10.verticalSpace,
                  Text(
                    !isPickedUp
                        ? AppStrings.orderStatusPreparing
                        : AppStrings.loading,
                    style: AppTextStyles.text14w600(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Live Route ETA & Distance Banner
        if (canShowMap &&
            _roadRouteResult != null &&
            _roadRouteResult!.distanceMeters > 0)
          Positioned(
            top: 105.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(9.r),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delivery_dining_rounded,
                      color: colors.primary,
                      size: 24.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          o.status == 6 ? AppStrings.driverOnTheWayBanner : AppStrings.distanceAndEtaBanner,
                          style: AppTextStyles.text12w600(color: colors.textSecondary),
                        ),
                        3.verticalSpace,
                        Text(
                          "${_roadRouteResult!.formattedDistance} • ${_roadRouteResult!.formattedDuration}",
                          style: AppTextStyles.text15w700(color: colors.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Map controls (zoom in/out & recenter FAB)
        if (canShowMap)
          Positioned(
            top: 175.h,
            left: 20.w,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colors.border.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.15),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        final newZoom = (_mapController.camera.zoom + 0.8).clamp(1.0, 19.0);
                        _mapController.move(_mapController.camera.center, newZoom);
                      },
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Icon(
                          Icons.add_rounded,
                          color: colors.textPrimary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      width: 28.w,
                      color: colors.border.withValues(alpha: 0.6),
                    ),
                    InkWell(
                      onTap: () {
                        final newZoom = (_mapController.camera.zoom - 0.8).clamp(1.0, 19.0);
                        _mapController.move(_mapController.camera.center, newZoom);
                      },
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(10.r),
                        child: Icon(
                          Icons.remove_rounded,
                          color: colors.textPrimary,
                          size: 22.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              10.verticalSpace,

              Material(
                color: _isAutoCentering ? colors.primary : colors.surface,
                elevation: 6,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    setState(() => _isAutoCentering = true);
                    final capLat = o.delivery?.location?.latitude;
                    final capLng = o.delivery?.location?.longitude;
                    final hasCap = capLat != null && capLng != null && capLat != 0 && capLng != 0;
                    final targetLat = (o.status == 6 && hasCap) ? capLat : centerLat;
                    final targetLng = (o.status == 6 && hasCap) ? capLng : centerLng;
                    _mapController.move(ll.LatLng(targetLat, targetLng), 15.5);
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isAutoCentering ? colors.primary : colors.surface,
                      border: Border.all(
                        color: _isAutoCentering ? colors.primary : colors.border.withValues(alpha: 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.shadow.withValues(alpha: 0.2),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.my_location_rounded,
                      color: _isAutoCentering ? Colors.white : colors.primary,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
