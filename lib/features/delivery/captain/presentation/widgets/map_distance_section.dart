import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final MapController _mapController = MapController();
  static const _launcherChannel = MethodChannel('com.quick.app/launcher');

  @override
  void initState() {
    super.initState();
    _calculateDistances();
  }

  @override
  void didUpdateWidget(covariant MapDistanceSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order != widget.order ||
        oldWidget.vendorLocation != widget.vendorLocation) {
      _calculateDistances();
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

  Future<void> _openExternalMap(double lat, double lng) async {
    final url = Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await _launcherChannel.invokeMethod('launchMap', {
          'latitude': lat,
          'longitude': lng,
        });
      }
    } catch (_) {
      try {
        await _launcherChannel.invokeMethod('launchMap', {
          'latitude': lat,
          'longitude': lng,
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("تعذر فتح تطبيق الخرائط الخارجية")),
          );
        }
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

    final ll.LatLng centerPoint = hasStoreLoc
        ? ll.LatLng(storeLat, storeLng)
        : ll.LatLng(destLat, destLng);

    final List<Marker> markers = [];

    if (hasStoreLoc) {
      markers.add(
        Marker(
          point: ll.LatLng(storeLat, storeLng),
          width: 40.w,
          height: 40.w,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
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
          width: 40.w,
          height: 40.w,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
            ),
            child: const Icon(Icons.person_pin_circle_rounded, color: Colors.white, size: 24),
          ),
        ),
      );
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
          
          // OpenStreetMap View
          Container(
            height: 200.h,
            margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colors.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: centerPoint,
                  initialZoom: 13.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.quick.app',
                  ),
                  MarkerLayer(markers: markers),
                ],
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
                  _openExternalMap(targetLat, targetLng);
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
