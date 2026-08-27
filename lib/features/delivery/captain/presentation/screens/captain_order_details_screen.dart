import 'dart:async';
import 'package:base_app/core/network/api_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/constans/role_type_enum.dart';
import 'package:base_app/core/models/app_chat_argument.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/utils/format_price.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_location_stream_provider.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/order_info_card.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/location_timeline.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/order_summary_card.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/order_action_button.dart';

import '../../../../customer/home/data/home_api_service.dart';

// ─── Tab index ────────────────────────────────────────────────────────────────
enum _CaptainTab { details, call, chat }

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
  late OrderDto _order;
  LocationDto? _vendorLocation;
  Position? _currentCaptainPosition;
  StreamSubscription<Position>? _positionSubscription;

  // Map state
  final MapController _mapController = MapController();
  RouteResult? _roadRouteResult;
  bool _isAutoCentering = true;

  // Tab state
  _CaptainTab _activeTab = _CaptainTab.details;

  @override
  void initState() {
    super.initState();
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
        pos.latitude, pos.longitude, destLat, destLng);
  }

  void _initializeOrderState() {
    if (_order.deliveryId == null || _order.status == 2) {
      _orderState = 0;
    } else if (_order.status == 3 || _order.status == 4 || _order.status == 5) {
      _orderState = 1;
    } else if (_order.status == 6) {
      _orderState = 2;
    } else {
      _orderState = 3;
    }
  }

  UserDto? get _customerUser => _order.creator ?? _order.user;

  Future<void> _fetchOrderDetails() async {
    setState(() => _isFetchingDetails = true);
    final updatedOrder =
        await ref.read(captainOrdersProvider.notifier).getOrderDetails(widget.order.id);

    OrderDto? processedOrder = updatedOrder;

    if (processedOrder != null) {
      UserDto? customer = processedOrder.creator ?? processedOrder.user;
      final int customerId = processedOrder.creatorId != 0
          ? processedOrder.creatorId
          : (customer?.id ?? processedOrder.userId);

      if ((customer == null || customer.name == null || customer.name!.isEmpty) && customerId != 0) {
        final userResult = await ref.read(homeApiServiceProvider).getUserById(customerId);
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
        );
      }

      if (processedOrder.userLocationId != null) {
        final locResult = await ref
            .read(profileApiServiceProvider)
            .getLocationById(processedOrder.userLocationId!);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل جلب تفاصيل الطلب')),
      );
    }

    if (processedOrder != null && mounted) {
      setState(() {
        _order = processedOrder!;
        _initializeOrderState();
      });
    }

    if (mounted) setState(() => _isFetchingDetails = false);
    _fetchRoadRoute();
  }

  Future<void> _handleActionButton() async {
    if (_isLoading) return;

    if (_orderState == 0) {
      setState(() => _isLoading = true);
      final success =
          await ref.read(captainOrdersProvider.notifier).acceptOrder(_order);
      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم قبول الطلب بنجاح')),
          );
        }
        _fetchOrderDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل قبول الطلب')),
          );
        }
      }
    } else if (_orderState == 1) {
      setState(() => _isLoading = true);
      final success =
          await ref.read(captainOrdersProvider.notifier).updateStatus(_order, 6);
      setState(() => _isLoading = false);

      if (success) {
        ref.read(captainLocationStreamNotifierProvider.notifier).startStreaming(
              orderId: _order.id,
              deliveryId: _order.deliveryId ?? 0,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم استلام الطلب وبدء رحلة التوصيل')),
          );
        }
        _fetchOrderDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل تحديث حالة الاستلام')),
          );
        }
      }
    } else if (_orderState == 2) {
      final distMeters = _distanceToCustomerMeters;
      if (distMeters != null && distMeters > 100) {
        final formattedDist = distMeters >= 1000
            ? '${(distMeters / 1000).toStringAsFixed(1)} كم'
            : '${distMeters.toStringAsFixed(0)} متر';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.red.shade700,
              content: Text(
                'يجب التواجد على بعد 100 متر أو أقل من موقع العميل (أنت على بعد $formattedDist)',
              ),
            ),
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
            .read(captainLocationStreamNotifierProvider.notifier)
            .sendDeliveredSignal(
              orderId: _order.id,
              deliveryId: _order.deliveryId ?? 0,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم توصيل الطلب بنجاح!')),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل تحديث حالة الطلب')),
          );
        }
      }
    }
  }

  void _onTabTap(_CaptainTab tab) {
    setState(() => _activeTab = tab);
    switch (tab) {
      case _CaptainTab.details:
        _showDetailsSheet();
        break;
      case _CaptainTab.call:
        _handleCall();
        break;
      case _CaptainTab.chat:
        _handleChat();
        break;
    }
  }

  void _showDetailsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailsSheet(
        order: _order,
        vendorLocation: _vendorLocation,
        isFetchingDetails: _isFetchingDetails,
        orderState: _orderState,
        isLoading: _isLoading,
        onAction: _handleActionButton,
        distanceToCustomerMeters: _distanceToCustomerMeters,
      ),
    ).then((_) => setState(() => _activeTab = _CaptainTab.details));
  }

  void _handleCall() {
    final customer = _customerUser;
    final phone = (customer?.phone != null && customer!.phone!.isNotEmpty)
        ? customer.phone!
        : (_order.creator?.phone ?? _order.user?.phone);

    if (phone != null && phone.isNotEmpty) {
      _launchCall(context, phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رقم هاتف للعميل')),
      );
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _activeTab = _CaptainTab.details);
    });
  }

  void _handleChat() {
    final customer = _customerUser;
    final String customerName = (customer?.name != null && customer!.name!.isNotEmpty)
        ? customer.name!
        : 'تواصل مع العميل';
    final String? photoKey = customer?.photo ?? customer?.avatar ?? _order.creator?.photo ?? _order.creator?.avatar ?? _order.user?.photo ?? _order.user?.avatar;
    final String photoUrl = (photoKey != null && photoKey.isNotEmpty)
        ? (photoKey.startsWith('http')
            ? photoKey
            : '${ApiConstants.streamUrl}$photoKey')
        : '';

    final int recipientId = customer?.id ?? (_order.creatorId != 0 ? _order.creatorId : _order.userId);

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا توجد بيانات متاحة للعميل')),
      );
    }
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _activeTab = _CaptainTab.details);
    });
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
      markers.add(Marker(
        point: ll.LatLng(pos.latitude, pos.longitude),
        width: 54.w,
        height: 54.w,
        child: Image.asset(
          'assets/icons/delivarey-mab.png',
          fit: BoxFit.contain,
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
          child: const Icon(Icons.storefront_rounded,
              color: Colors.white, size: 22),
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
          child: const Icon(Icons.person_pin_circle_rounded,
              color: Colors.white, size: 24),
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
          // ── Full-screen map ────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: centerPoint,
                initialZoom: 14.5,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture && _isAutoCentering) {
                    setState(() => _isAutoCentering = false);
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                  userAgentPackageName: 'com.quick.app',
                ),
                if (polylines.isNotEmpty) PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),
          ),

          // ── Back button ──────────────────────────────────────────────
          Positioned(top: 50.h, right: 20.w, child: const CustomArrowBack()),

          // ── Order ID badge ───────────────────────────────────────────
          Positioned(
            top: 50.h,
            left: 20.w,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(color: colors.shadow, blurRadius: 8)
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_rounded,
                      size: 14.sp, color: colors.primary),
                  6.horizontalSpace,
                  Text('#${_order.id}',
                      style:
                          AppTextStyles.text14w700(color: colors.primary)),
                ],
              ),
            ),
          ),

          // ── ETA / Route banner ──────────────────────────────────────
          if (_roadRouteResult != null &&
              _roadRouteResult!.distanceMeters > 0)
            Positioned(
              top: 105.h,
              left: 20.w,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: colors.primary.withValues(alpha: 0.3)),
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
                      child: Icon(Icons.alt_route_rounded,
                          color: colors.primary, size: 20.sp),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _orderState >= 2
                                ? 'المسافة للعميل'
                                : 'المسافة للمتجر',
                            style: AppTextStyles.text12w600(
                                color: colors.textSecondary),
                          ),
                          3.verticalSpace,
                          Text(
                            _roadRouteResult!.formattedDistance,
                            style: AppTextStyles.text14w700(
                                color: colors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Map controls (zoom + recenter) ───────────────────────────
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
                        color: colors.border.withValues(alpha: 0.5)),
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
                          final z = (_mapController.camera.zoom + 0.8)
                              .clamp(1.0, 19.0);
                          _mapController.move(
                              _mapController.camera.center, z);
                        },
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(12.r),
                          topRight: Radius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.r),
                          child: Icon(Icons.add_rounded,
                              color: colors.textPrimary, size: 22.sp),
                        ),
                      ),
                      Container(
                          height: 1,
                          width: 28.w,
                          color: colors.border.withValues(alpha: 0.6)),
                      InkWell(
                        onTap: () {
                          final z = (_mapController.camera.zoom - 0.8)
                              .clamp(1.0, 19.0);
                          _mapController.move(
                              _mapController.camera.center, z);
                        },
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10.r),
                          child: Icon(Icons.remove_rounded,
                              color: colors.textPrimary, size: 22.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                10.verticalSpace,
                Material(
                  color: _isAutoCentering
                      ? colors.primary
                      : colors.surface,
                  elevation: 6,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: () {
                      setState(() => _isAutoCentering = true);
                      final pos = _currentCaptainPosition;
                      if (pos != null) {
                        _mapController.move(
                            ll.LatLng(pos.latitude, pos.longitude), 15.5);
                      }
                    },
                    customBorder: const CircleBorder(),
                    child: Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isAutoCentering
                            ? colors.primary
                            : colors.surface,
                        border: Border.all(
                          color: _isAutoCentering
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
                        color: _isAutoCentering
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

          // ── Draggable Bottom Sheet Panel ─────────────────────────────
          _CaptainBottomPanel(
            order: _order,
            colors: colors,
            activeTab: _activeTab,
            orderState: _orderState,
            isLoading: _isLoading,
            onTabTap: _onTabTap,
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

// ─── Bottom Panel ─────────────────────────────────────────────────────────────
class _CaptainBottomPanel extends StatelessWidget {
  final OrderDto order;
  final AppColors colors;
  final _CaptainTab activeTab;
  final int orderState;
  final bool isLoading;
  final void Function(_CaptainTab) onTabTap;
  final VoidCallback onAction;
  final double? distanceToCustomerMeters;
  final LocationDto? vendorLocation;
  final bool isFetchingDetails;

  const _CaptainBottomPanel({
    required this.order,
    required this.colors,
    required this.activeTab,
    required this.orderState,
    required this.isLoading,
    required this.onTabTap,
    required this.onAction,
    this.distanceToCustomerMeters,
    this.vendorLocation,
    this.isFetchingDetails = false,
  });

  String get _statusLabel {
    switch (order.status) {
      case 2:
        return 'متاح للقبول';
      case 3:
        return 'تم القبول، توجه للمتجر';
      case 4:
        return 'جاري التحضير';
      case 5:
        return 'الطلب جاهز للاستلام';
      case 6:
        return 'في طريقك للعميل 🚗';
      case 7:
        return 'تم التوصيل بنجاح! 🎉';
      default:
        return 'جاري المعالجة...';
    }
  }

  UserDto? get _customerUser => order.creator ?? order.user;

  String get _customerName {
    final c = _customerUser;
    if (c?.name != null && c!.name!.isNotEmpty) return c.name!;
    return 'العميل';
  }



  String get _customerPhone {
    final c = _customerUser;
    if (c?.phone != null && c!.phone!.isNotEmpty) return c.phone!;
    if (order.creator?.phone != null && order.creator!.phone!.isNotEmpty) return order.creator!.phone!;
    if (order.user?.phone != null && order.user!.phone!.isNotEmpty) return order.user!.phone!;
    return '';
  }

  String get _customerAddress {
    if (order.address != null && order.address!.isNotEmpty) {
      return order.address!;
    }
    final c = _customerUser;
    if (c?.address != null && c!.address!.isNotEmpty) return c.address!;
    if (order.latitude != 0 && order.longitude != 0) {
      return 'عنوان العميل على الخريطة';
    }
    return '';
  }

  String get _customerPhotoUrl {
    final c = _customerUser;
    final String? photoKey = c?.photo ?? c?.avatar ?? order.creator?.photo ?? order.creator?.avatar ?? order.user?.photo ?? order.user?.avatar;
    if (photoKey != null && photoKey.isNotEmpty) {
      return photoKey.startsWith('http') ? photoKey : '${ApiConstants.streamUrl}$photoKey';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.32,
      minChildSize: 0.08,
      maxChildSize: 0.36,
      snap: true,
      snapSizes: const [0.08, 0.32],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            boxShadow: [
              BoxShadow(
                color: colors.shadow.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                8.verticalSpace,
                Center(
                  child: Container(
                    width: 42.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
                8.verticalSpace,

                // Status bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(7.r),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.delivery_dining_rounded,
                          color: colors.primary,
                          size: 17.sp,
                        ),
                      ),
                      10.horizontalSpace,
                      Expanded(
                        child: Text(
                          _statusLabel,
                          style: AppTextStyles.text13w700(color: colors.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '#${order.id}',
                        style: AppTextStyles.text12w400(color: colors.textHint),
                      ),
                    ],
                  ),
                ),
                8.verticalSpace,

                // ListTile Customer Card with Call & Chat buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: _CustomerListTileCard(
                    customerName: _customerName,
                    customerPhone: _customerPhone,
                    customerAddress: _customerAddress,
                    photoUrl: _customerPhotoUrl,
                    colors: colors,
                    onCall: () => onTabTap(_CaptainTab.call),
                    onChat: () => onTabTap(_CaptainTab.chat),
                  ),
                ),
                8.verticalSpace,

                // Details Sheet Button & Action Button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => onTabTap(_CaptainTab.details),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: colors.primary.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_rounded,
                                    color: colors.primary, size: 17.sp),
                                8.horizontalSpace,
                                Text(
                                  'تفاصيل الطلب',
                                  style: AppTextStyles.text13w700(
                                      color: colors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (orderState < 3) ...[
                  8.verticalSpace,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: OrderActionButton(
                      orderState: orderState,
                      isLoading: isLoading,
                      onPressed: onAction,
                      distanceToCustomerMeters: distanceToCustomerMeters,
                    ),
                  ),
                ],
                16.verticalSpace,
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Customer ListTile Card ──────────────────────────────────────────────────
class _CustomerListTileCard extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String photoUrl;
  final AppColors colors;
  final VoidCallback onCall;
  final VoidCallback onChat;

  const _CustomerListTileCard({
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.photoUrl,
    required this.colors,
    required this.onCall,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final displaySubtitle = customerPhone.isNotEmpty
        ? customerPhone
        : (customerAddress.isNotEmpty ? customerAddress : 'عميل التطبيق');

    return Container(
      decoration: BoxDecoration(
        color: colors.containerBackground,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
        leading: Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: colors.primary.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: ClipOval(
            child: (photoUrl.isNotEmpty)
                ? CachedNetworkImage(
                    imageUrl: photoUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Icon(
                      Icons.person_rounded,
                      color: colors.primary,
                      size: 24.sp,
                    ),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: colors.primary,
                    size: 24.sp,
                  ),
          ),
        ),
        title: Text(
          customerName.isNotEmpty ? customerName : 'العميل',
          style: AppTextStyles.text14w700(color: colors.textPrimary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          displaySubtitle,
          style: AppTextStyles.text12w400(color: colors.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: onCall,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: colors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: colors.success.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.call_rounded,
                  color: colors.success,
                  size: 20.sp,
                ),
              ),
            ),
            8.horizontalSpace,
            InkWell(
              onTap: onChat,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(9.r),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  color: colors.primary,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



// ─── Details Bottom Sheet ────────────────────────────────────────────────────
class _DetailsSheet extends StatelessWidget {
  final OrderDto order;
  final LocationDto? vendorLocation;
  final bool isFetchingDetails;
  final int orderState;
  final bool isLoading;
  final VoidCallback onAction;
  final double? distanceToCustomerMeters;

  const _DetailsSheet({
    required this.order,
    this.vendorLocation,
    required this.isFetchingDetails,
    required this.orderState,
    required this.isLoading,
    required this.onAction,
    this.distanceToCustomerMeters,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.68,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 14.h, bottom: 8.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: colors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Row(
                  children: [
                    Text(
                      AppStrings.captainOrderDetailsTitle,
                      style: AppTextStyles.text16w700(
                          color: colors.textPrimary),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text('#${order.id}',
                          style: AppTextStyles.text13w600(
                              color: colors.primary)),
                    ),
                  ],
                ),
              ),
              Divider(color: colors.divider, height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding:
                      EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  children: [
                    OrderInfoCard(order: order),
                    16.verticalSpace,
                    _CaptainOrderItemsCard(order: order, colors: colors),
                    20.verticalSpace,
                    LocationTimeline(
                      order: order,
                      vendorLocation: vendorLocation,
                    ),
                    20.verticalSpace,
                    OrderSummaryCard(
                      order: order,
                      isFetchingDetails: isFetchingDetails,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Captain Order Items & Breakdown Card ────────────────────────────────────
class _CaptainOrderItemsCard extends StatefulWidget {
  final OrderDto order;
  final AppColors colors;

  const _CaptainOrderItemsCard({required this.order, required this.colors});

  @override
  State<_CaptainOrderItemsCard> createState() => _CaptainOrderItemsCardState();
}

class _CaptainOrderItemsCardState extends State<_CaptainOrderItemsCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final order = widget.order;
    final products = order.products;
    final subTotal = products.fold(0.0, (sum, p) => sum + (p.price * p.quantity));

    return Container(
      decoration: BoxDecoration(
        color: colors.containerBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border.withValues(alpha: 0.6)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      color: colors.primary,
                      size: 20.sp,
                    ),
                  ),
                  12.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'تفاصيل الأصناف والطلب',
                          style: AppTextStyles.text14w700(color: colors.textPrimary),
                        ),
                        4.verticalSpace,
                        Text(
                          products.isNotEmpty
                              ? '${products.length} أصناف • ${formatPrice(order.totalPrice)} ${AppStrings.currency}'
                              : 'اضغط لعرض أصناف الطلب والفاتورة',
                          style: AppTextStyles.text12w400(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: colors.textSecondary,
                    size: 24.sp,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Divider(color: colors.divider, height: 1),
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                children: [
                  if (products.isNotEmpty)
                    ...products.map((item) {
                      final rawPhoto = item.photo;
                      final photoUrl = (rawPhoto != null && rawPhoto.isNotEmpty)
                          ? (rawPhoto.startsWith('http')
                              ? rawPhoto
                              : '${ApiConstants.streamUrl}$rawPhoto')
                          : '';

                      return Padding(
                        padding: EdgeInsets.only(bottom: 10.h),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: photoUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: photoUrl,
                                      width: 40.w,
                                      height: 40.w,
                                      fit: BoxFit.cover,
                                      placeholder: (_, __) => Container(
                                        color: colors.shimmerBase,
                                      ),
                                      errorWidget: (_, __, ___) => Container(
                                        color: colors.shimmerBase,
                                        child: Icon(Icons.fastfood_rounded,
                                            size: 20.sp, color: colors.textHint),
                                      ),
                                    )
                                  : Container(
                                      width: 40.w,
                                      height: 40.w,
                                      color: colors.shimmerBase,
                                      child: Icon(Icons.fastfood_rounded,
                                          size: 20.sp, color: colors.textHint),
                                    ),
                            ),
                            10.horizontalSpace,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName ?? 'صنف',
                                    style: AppTextStyles.text13w600(
                                        color: colors.textPrimary),
                                  ),
                                  2.verticalSpace,
                                  Text(
                                    'الكمية: ${item.quantity}',
                                    style: AppTextStyles.text11w400(
                                        color: colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${formatPrice(item.price * item.quantity)} ${AppStrings.currency}',
                              style: AppTextStyles.text13w700(
                                  color: colors.textPrimary),
                            ),
                          ],
                        ),
                      );
                    })
                  else if (order.offerId != null)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Text(
                        'طلب عرض خاص كامل',
                        style: AppTextStyles.text13w600(color: colors.textPrimary),
                      ),
                    ),

                  10.verticalSpace,
                  Divider(color: colors.divider),
                  8.verticalSpace,

                  _priceRow('المجموع الفرعي', '${formatPrice(subTotal)} ${AppStrings.currency}', colors),
                  6.verticalSpace,
                  _priceRow('رسوم التوصيل (عمولتك)', '${formatPrice(order.deliveryFee)} ${AppStrings.currency}', colors),
                  8.verticalSpace,
                  Divider(color: colors.divider),
                  8.verticalSpace,
                  _priceRow('الإجمالي المطلوب تحصيله', '${formatPrice(order.totalPrice)} ${AppStrings.currency}', colors, isTotal: true),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, AppColors colors, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? AppTextStyles.text14w700(color: colors.textPrimary)
              : AppTextStyles.text12w400(color: colors.textSecondary),
        ),
        Text(
          value,
          style: isTotal
              ? AppTextStyles.text15w700(color: colors.primary)
              : AppTextStyles.text13w600(color: colors.textPrimary),
        ),
      ],
    );
  }
}

// ─── Launch call helper ───────────────────────────────────────────────────────
Future<void> _launchCall(BuildContext context, String phone) async {
  final Uri uri = Uri(scheme: 'tel', path: phone);
  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لا يمكن الاتصال بـ $phone')),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }
  }
}
