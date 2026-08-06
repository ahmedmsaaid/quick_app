import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class MapDistanceSection extends StatefulWidget {
  final OrderDto order;
  final LocationDto? vendorLocation;
  final int orderState;

  const MapDistanceSection({
    super.key,
    required this.order,
    this.vendorLocation,
    required this.orderState,
  });

  @override
  State<MapDistanceSection> createState() => _MapDistanceSectionState();
}

class _MapDistanceSectionState extends State<MapDistanceSection> {
  double? _distanceBetweenStoreAndCustomer;
  double? _distanceToStore;
  Position? _currentCaptainPosition;
  RouteResult? _roadRouteResult;
  StreamSubscription<Position>? _positionSubscription;
  final MapController _mapController = MapController();
  bool _isAutoCentering = true;

  @override
  void initState() {
    super.initState();
    _calculateDistances();
    _listenToLocationUpdates();
  }

  @override
  void didUpdateWidget(covariant MapDistanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order ||
        oldWidget.vendorLocation != widget.vendorLocation ||
        oldWidget.orderState != widget.orderState) {
      _calculateDistances();
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _listenToLocationUpdates() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentCaptainPosition = position;
          });
        }

        _positionSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 3,
          ),
        ).listen((pos) {
          if (mounted) {
            setState(() {
              _currentCaptainPosition = pos;
            });
            _calculateDistances();

            if (_isAutoCentering) {
              final zoomLevel = _mapController.camera.zoom > 10 ? _mapController.camera.zoom : 15.5;
              _mapController.move(ll.LatLng(pos.latitude, pos.longitude), zoomLevel);
            }
          }
        });
      }
    } catch (e) {
      debugPrint("Error in location stream: $e");
    }
  }

  Future<void> _calculateDistances() async {
    final storeLat = widget.vendorLocation?.latitude ??
        widget.order.userLocation?.latitude ??
        widget.order.creator?.location?.latitude;
    final storeLng = widget.vendorLocation?.longitude ??
        widget.order.userLocation?.longitude ??
        widget.order.creator?.location?.longitude;
    final destLat = widget.order.latitude;
    final destLng = widget.order.longitude;

    final hasStoreLoc = storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0;
    final hasDestLoc = destLat != 0 && destLng != 0;

    if (hasStoreLoc) {
      if (hasDestLoc) {
        final meters = Geolocator.distanceBetween(storeLat, storeLng, destLat, destLng);
        setState(() {
          _distanceBetweenStoreAndCustomer = meters / 1000;
        });
      }

      final pos = _currentCaptainPosition;
      if (pos != null) {
        final meters = Geolocator.distanceBetween(pos.latitude, pos.longitude, storeLat, storeLng);
        setState(() {
          _distanceToStore = meters / 1000;
        });
      }

      // Fetch OSRM Road Route
      final bool isPickedUp = widget.orderState >= 3;
      final ll.LatLng? startPt = pos != null
          ? ll.LatLng(pos.latitude, pos.longitude)
          : (hasStoreLoc ? ll.LatLng(storeLat, storeLng) : null);

      final ll.LatLng? endPt = isPickedUp
          ? (hasDestLoc ? ll.LatLng(destLat, destLng) : null)
          : (hasStoreLoc ? ll.LatLng(storeLat, storeLng) : null);

      if (startPt != null && endPt != null) {
        final route = await MapService.getDrivingRoute(startPt, endPt);
        if (mounted) {
          setState(() {
            _roadRouteResult = route;
          });
        }
      }
    }
  }

  Future<void> _recenterMap() async {
    setState(() {
      _isAutoCentering = true;
    });
    final pos = _currentCaptainPosition;
    if (pos != null) {
      _mapController.move(ll.LatLng(pos.latitude, pos.longitude), 16.0);
    } else {
      try {
        final currentPos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentCaptainPosition = currentPos;
          });
          _mapController.move(ll.LatLng(currentPos.latitude, currentPos.longitude), 16.0);
        }
      } catch (e) {
        debugPrint('Recenter error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final pos = _currentCaptainPosition;

    final storeLat = widget.vendorLocation?.latitude ??
        widget.order.userLocation?.latitude ??
        widget.order.creator?.location?.latitude;
    final storeLng = widget.vendorLocation?.longitude ??
        widget.order.userLocation?.longitude ??
        widget.order.creator?.location?.longitude;

    final destLat = widget.order.latitude;
    final destLng = widget.order.longitude;

    final bool hasStoreLoc = storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0;
    final bool hasDestLoc = destLat != 0 && destLng != 0;

    if (!hasStoreLoc && !hasDestLoc) {
      return const SizedBox.shrink();
    }

    final centerPoint = pos != null
        ? ll.LatLng(pos.latitude, pos.longitude)
        : (hasStoreLoc
            ? ll.LatLng(storeLat, storeLng)
            : (hasDestLoc ? ll.LatLng(destLat, destLng) : const ll.LatLng(30.0444, 31.2357)));

    final List<Marker> markers = [];
    final List<Polyline> polylines = [];

    if (pos != null) {
      markers.add(
        Marker(
          point: ll.LatLng(pos.latitude, pos.longitude),
          width: 48.w,
          height: 48.w,
          child: Container(
            decoration: BoxDecoration(
              color: colors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.navigation_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
    }

    if (hasStoreLoc) {
      markers.add(
        Marker(
          point: ll.LatLng(storeLat, storeLng),
          width: 44.w,
          height: 44.w,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 22),
          ),
        ),
      );
    }

    if (hasDestLoc) {
      markers.add(
        Marker(
          point: ll.LatLng(destLat, destLng),
          width: 44.w,
          height: 44.w,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
            ),
            child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
    }

    final bool isPickedUp = widget.orderState >= 3;
    final routePoints = _roadRouteResult?.points ?? [];

    if (routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          points: routePoints,
          strokeWidth: 5.5,
          color: isPickedUp ? Colors.orange : colors.primary,
          borderStrokeWidth: 2.0,
          borderColor: isPickedUp ? const Color(0xFF7C2D12) : const Color(0xFF0F172A),
          strokeCap: StrokeCap.round,
          strokeJoin: StrokeJoin.round,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              children: [
                if (_distanceToStore != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.directions_bike, color: colors.primary, size: 18.sp),
                            8.horizontalSpace,
                            Flexible(
                              child: Text(
                                "المسافة إليك من المحل:",
                                style: AppTextStyles.text13w600(color: colors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      4.horizontalSpace,
                      Text(
                        "${_distanceToStore!.toStringAsFixed(1)} كم",
                        style: AppTextStyles.text14w700(color: colors.primary),
                      ),
                    ],
                  ),
                if (_distanceToStore != null && _distanceBetweenStoreAndCustomer != null)
                  10.verticalSpace,
                if (_distanceBetweenStoreAndCustomer != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.map_outlined, color: Colors.orange, size: 18.sp),
                            8.horizontalSpace,
                            Flexible(
                              child: Text(
                                "مسافة التوصيل (من المحل للعميل):",
                                style: AppTextStyles.text13w600(color: colors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      4.horizontalSpace,
                      Text(
                        "${_distanceBetweenStoreAndCustomer!.toStringAsFixed(1)} كم",
                        style: AppTextStyles.text14w700(color: Colors.orange),
                      ),
                    ],
                  ),
                if (_roadRouteResult != null && _roadRouteResult!.distanceMeters > 0) ...[
                  10.verticalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.alt_route_rounded, color: colors.primary, size: 18.sp),
                              8.horizontalSpace,
                              Flexible(
                                child: Text(
                                  "مسار الطريق الفعلي:",
                                  style: AppTextStyles.text13w600(color: colors.textPrimary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        4.horizontalSpace,
                        Flexible(
                          child: Text(
                            "${_roadRouteResult!.formattedDistance} • ${_roadRouteResult!.formattedDuration}",
                            style: AppTextStyles.text13w700(color: colors.primary),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          Container(
            height: 260.h,
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: centerPoint,
                      initialZoom: 13.5,
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
                        urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                        userAgentPackageName: 'com.quick.app',
                      ),
                      if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                      MarkerLayer(markers: markers),
                    ],
                  ),

                  // Floating Uber-Style Controls Panel (Zoom In +, Zoom Out -, Recenter 🎯)
                  Positioned(
                    bottom: 12.h,
                    left: 12.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Zoom Controls Pill
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
                              // Zoom In (+)
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
                                  padding: EdgeInsets.all(9.r),
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: colors.textPrimary,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                              Container(
                                height: 1,
                                width: 26.w,
                                color: colors.border.withValues(alpha: 0.6),
                              ),
                              // Zoom Out (-)
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
                                  padding: EdgeInsets.all(9.r),
                                  child: Icon(
                                    Icons.remove_rounded,
                                    color: colors.textPrimary,
                                    size: 20.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        8.verticalSpace,

                        // Recenter FAB Button (🎯)
                        Material(
                          color: _isAutoCentering ? colors.primary : colors.surface,
                          elevation: 6,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: _recenterMap,
                            customBorder: const CircleBorder(),
                            child: Container(
                              padding: EdgeInsets.all(11.r),
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
                                size: 22.sp,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
