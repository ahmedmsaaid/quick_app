import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:lottie/lottie.dart' hide Marker;
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/utils/assets/app_assets.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';

class CaptainOrderMapWidget extends StatelessWidget {
  final MapController mapController;
  final ll.LatLng centerPoint;
  final List<Marker> markers;
  final List<Polyline> polylines;
  final RouteResult? roadRouteResult;
  final int orderState;
  final OrderDto order;
  final bool isAutoCentering;
  final bool isMapReady;
  final VoidCallback onRecenter;
  final void Function(MapCamera, bool) onPositionChanged;

  const CaptainOrderMapWidget({
    super.key,
    required this.mapController,
    required this.centerPoint,
    required this.markers,
    required this.polylines,
    required this.roadRouteResult,
    required this.orderState,
    required this.order,
    required this.isAutoCentering,
    this.isMapReady = true,
    required this.onRecenter,
    required this.onPositionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return Stack(
      children: [
        // Full-screen map (hidden until order details & route distance are ready)
        if (isMapReady)
          Positioned.fill(
            child: FlutterMap(
              mapController: mapController,
              options: MapOptions(
                initialCenter: centerPoint,
                initialZoom: 14.5,
                onPositionChanged: onPositionChanged,
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
            ),
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
                    AppStrings.loading,
                    style: AppTextStyles.text14w600(
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Back button
        Positioned(top: 50.h, right: 20.w, child: const CustomArrowBack()),

        // Order ID badge
        Positioned(
          top: 50.h,
          left: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(color: colors.shadow, blurRadius: 8),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 14.sp,
                  color: colors.primary,
                ),
                6.horizontalSpace,
                Text(
                  '#${order.id}',
                  style: AppTextStyles.text14w700(color: colors.primary),
                ),
              ],
            ),
          ),
        ),

        // ETA / Route banner
        if (roadRouteResult != null && roadRouteResult!.distanceMeters > 0)
          Positioned(
            top: 105.h,
            left: 20.w,
            right: 20.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                ),
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
                      Icons.alt_route_rounded,
                      color: colors.primary,
                      size: 20.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          orderState >= 2
                              ? AppStrings.distanceToCustomer
                              : AppStrings.distanceToStore,
                          style: AppTextStyles.text12w600(
                            color: colors.textSecondary,
                          ),
                        ),
                        3.verticalSpace,
                        Text(
                          roadRouteResult!.formattedDistance,
                          style: AppTextStyles.text14w700(
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Map controls (zoom + recenter)
        if (isMapReady)
          Positioned(
            top: 170.h,
            left: 20.w,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: colors.border.withValues(alpha: 0.5),
                  ),
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
                        final z = (mapController.camera.zoom + 0.8)
                            .clamp(1.0, 19.0);
                        mapController.move(mapController.camera.center, z);
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
                        final z = (mapController.camera.zoom - 0.8)
                            .clamp(1.0, 19.0);
                        mapController.move(mapController.camera.center, z);
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
                color: isAutoCentering ? colors.primary : colors.surface,
                elevation: 6,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onRecenter,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAutoCentering
                          ? colors.primary
                          : colors.surface,
                      border: Border.all(
                        color: isAutoCentering
                            ? colors.primary
                            : colors.border.withValues(alpha: 0.5),
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
                      color: isAutoCentering
                          ? Colors.white
                          : colors.primary,
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
