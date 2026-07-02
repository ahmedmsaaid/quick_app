import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
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
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  static const _launcherChannel = MethodChannel('com.quick.app/launcher');

  @override
  void initState() {
    super.initState();
    _updateMarkers();
    _calculateDistances();
  }

  @override
  void didUpdateWidget(covariant MapDistanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order ||
        oldWidget.vendorLocation != widget.vendorLocation) {
      _updateMarkers();
      _calculateDistances();
    }
  }

  void _updateMarkers() {
    final storeLat = widget.vendorLocation?.latitude ??
        widget.order.userLocation?.latitude ??
        widget.order.creator?.location?.latitude;
    final storeLng = widget.vendorLocation?.longitude ??
        widget.order.userLocation?.longitude ??
        widget.order.creator?.location?.longitude;
    final destLat = widget.order.latitude;
    final destLng = widget.order.longitude;

    final Set<Marker> newMarkers = {};

    if (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('store'),
          position: LatLng(storeLat, storeLng),
          infoWindow: InfoWindow(
            title: widget.order.creator?.name ?? "المحل",
            snippet: widget.vendorLocation?.address ??
                widget.order.userLocation?.address ??
                widget.order.creator?.address ??
                "عنوان المحل",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
    }

    if (destLat != 0 && destLng != 0) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('customer'),
          position: LatLng(destLat, destLng),
          infoWindow: InfoWindow(
            title: widget.order.user?.name ?? "العميل",
            snippet: widget.order.address ?? "عنوان التوصيل",
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });

    _fitMapToMarkers();
  }

  void _fitMapToMarkers() {
    if (_mapController == null || _markers.isEmpty) return;

    final storeLat = widget.vendorLocation?.latitude ??
        widget.order.userLocation?.latitude ??
        widget.order.creator?.location?.latitude;
    final storeLng = widget.vendorLocation?.longitude ??
        widget.order.userLocation?.longitude ??
        widget.order.creator?.location?.longitude;
    final destLat = widget.order.latitude;
    final destLng = widget.order.longitude;

    if (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0 && destLat != 0 && destLng != 0) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          storeLat < destLat ? storeLat : destLat,
          storeLng < destLng ? storeLng : destLng,
        ),
        northeast: LatLng(
          storeLat > destLat ? storeLat : destLat,
          storeLng > destLng ? storeLng : destLng,
        ),
      );
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50.r));
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

    if (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0) {
      if (destLat != 0 && destLng != 0) {
        final meters = Geolocator.distanceBetween(storeLat, storeLng, destLat, destLng);
        setState(() {
          _distanceBetweenStoreAndCustomer = meters / 1000;
        });
      }

      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
          final position = await Geolocator.getCurrentPosition();
          final meters = Geolocator.distanceBetween(position.latitude, position.longitude, storeLat, storeLng);
          setState(() {
            _distanceToStore = meters / 1000;
          });
        }
      } catch (e) {
        debugPrint("Error getting captain current position: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
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

    if (!hasStoreLoc && !hasDestLoc) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Distance Info Rows
          Padding(
            padding: EdgeInsets.all(15.r),
            child: Column(
              children: [
                if (_distanceToStore != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.directions_bike, color: colors.primary, size: 18.sp),
                          8.horizontalSpace,
                          Text("المسافة إليك من المحل:", style: AppTextStyles.text13w600(color: colors.textSecondary)),
                        ],
                      ),
                      Text("${_distanceToStore!.toStringAsFixed(1)} كم", style: AppTextStyles.text14w700(color: colors.primary)),
                    ],
                  ),
                if (_distanceToStore != null && _distanceBetweenStoreAndCustomer != null)
                  10.verticalSpace,
                if (_distanceBetweenStoreAndCustomer != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.map_outlined, color: Colors.orange, size: 18.sp),
                          8.horizontalSpace,
                          Text("مسافة التوصيل (من المحل للعميل):", style: AppTextStyles.text13w600(color: colors.textSecondary)),
                        ],
                      ),
                      Text("${_distanceBetweenStoreAndCustomer!.toStringAsFixed(1)} كم", style: AppTextStyles.text14w700(color: Colors.orange)),
                    ],
                  ),
              ],
            ),
          ),
          
          // Map View
          Container(
            height: 200.h,
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    storeLat ?? destLat,
                    storeLng ?? destLng,
                  ),
                  zoom: 13,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                onMapCreated: (controller) {
                  _mapController = controller;
                  _fitMapToMarkers();
                },
              ),
            ),
          ),

          // External Map Button
          Padding(
            padding: EdgeInsets.all(10.r),
            child: ElevatedButton.icon(
              onPressed: () {
                final targetLat = (widget.orderState == 0 || widget.orderState == 1) ? storeLat : destLat;
                final targetLng = (widget.orderState == 0 || widget.orderState == 1) ? storeLng : destLng;
                if (targetLat != null && targetLng != null && targetLat != 0 && targetLng != 0) {
                  _launcherChannel.invokeMethod('launchMap', {
                    'latitude': targetLat,
                    'longitude': targetLng,
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("الإحداثيات غير متوفرة لهذا الموقع")),
                  );
                }
              },
              icon: const Icon(Icons.navigation, color: Colors.white),
              label: Text(
                (widget.orderState == 0 || widget.orderState == 1)
                    ? "الذهاب للمحل في الخرائط الخارجية"
                    : "الذهاب للعميل في الخرائط الخارجية",
                style: AppTextStyles.text13w700(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
