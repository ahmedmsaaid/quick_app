import 'dart:async';
import 'package:base_app/core/network/api_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_location_stream_provider.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

// Import refactored widgets
import 'package:base_app/features/delivery/captain/presentation/widgets/order_info_card.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/map_distance_section.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/location_timeline.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/order_summary_card.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/order_action_button.dart';

class CaptainOrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderDto order;
  const CaptainOrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<CaptainOrderDetailsScreen> createState() => _CaptainOrderDetailsScreenState();
}

class _CaptainOrderDetailsScreenState extends ConsumerState<CaptainOrderDetailsScreen> {
  late int _orderState; // 0: قبول الطلب, 1: استلام الطلب, 2: تم التوصيل, 3: Completed
  bool _isLoading = false;
  bool _isFetchingDetails = false;
  late OrderDto _order;
  LocationDto? _vendorLocation;
  Position? _currentCaptainPosition;
  StreamSubscription<Position>? _positionSubscription;

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
      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final initialPos = await Geolocator.getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentCaptainPosition = initialPos;
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
          }
        });
      }
    } catch (e) {
      debugPrint("Error listening to captain location: $e");
    }
  }

  double? get _distanceToCustomerMeters {
    final pos = _currentCaptainPosition;
    final destLat = _order.latitude;
    final destLng = _order.longitude;
    if (pos == null || destLat == 0 || destLng == 0) return null;
    return Geolocator.distanceBetween(pos.latitude, pos.longitude, destLat, destLng);
  }

  void _initializeOrderState() {
    if (_order.deliveryId == null || _order.status == 2) {
      _orderState = 0; // Available to accept (قبول الطلب)
    } else if (_order.status == 3 || _order.status == 4 || _order.status == 5) {
      _orderState = 1; // Accepted / Assigned / Preparing -> (استلام الطلب)
    } else if (_order.status == 6) {
      _orderState = 2; // Out for delivery -> (تم التوصيل)
    } else {
      _orderState = 3; // Delivered / Cancelled / Completed
    }
  }

  Future<void> _fetchOrderDetails() async {
    setState(() => _isFetchingDetails = true);
    final updatedOrder = await ref.read(captainOrdersProvider.notifier).getOrderDetails(widget.order.id);

    if (updatedOrder != null) {
      if (updatedOrder.userLocationId != null) {
        final locResult = await ref.read(profileApiServiceProvider).getLocationById(updatedOrder.userLocationId!);
        switch (locResult) {
          case Success(data: final locResponse):
            if (locResponse.success && locResponse.result != null) {
              if (mounted) {
                setState(() {
                  _vendorLocation = locResponse.result;
                });
              }
            }
            break;
          case Failure(appError: final error):
            debugPrint("Error fetching location by ID: ${error.message}");
            break;
        }
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل جلب تفاصيل الطلب")),
      );
    }

    if (updatedOrder != null && mounted) {
      setState(() {
        _order = updatedOrder!;
        _initializeOrderState();
      });
    }
    
    if (mounted) {
      setState(() => _isFetchingDetails = false);
    }
  }

  Future<void> _handleActionButton() async {
    if (_isLoading) return;

    if (_orderState == 0) {
      // Step 1: Accept Order -> Status 3
      setState(() => _isLoading = true);
      final success = await ref.read(captainOrdersProvider.notifier).acceptOrder(_order);
      setState(() => _isLoading = false);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم قبول الطلب بنجاح وهو الآن قيد التوصيل')),
          );
        }
        _fetchOrderDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل قبول الطلب، يرجى المحاولة لاحقاً')),
          );
        }
      }
    } else if (_orderState == 1) {
      // Step 2: Pickup Order -> Directly transition to OutForDelivery (Status 6), bypassing "وصلت للمتجر"
      setState(() => _isLoading = true);
      final success = await ref.read(captainOrdersProvider.notifier).updateStatus(_order, 6);
      setState(() => _isLoading = false);

      if (success) {
        ref.read(captainLocationStreamNotifierProvider.notifier).startStreaming(
          orderId: _order.id,
          deliveryId: _order.deliveryId ?? 0,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم استلام الطلب وبدء رحلة التوصيل مع التتبع المباشر')),
          );
        }
        _fetchOrderDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل تحديث حالة الاستلام، يرجى المحاولة لاحقاً')),
          );
        }
      }
    } else if (_orderState == 2) {
      // Step 3: Delivered (Status 7) -> Enforce 100-meter proximity to Customer Location
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
                'لا يمكنك تأكيد التوصيل! يجب التواجد على بعد 100 متر أو أقل من موقع العميل (أنت حالياً على بعد $formattedDist)',
              ),
            ),
          );
        }
        return;
      }

      setState(() => _isLoading = true);
      final success = await ref.read(captainOrdersProvider.notifier).updateStatus(_order, 7);
      setState(() => _isLoading = false);

      if (success) {
        await ref.read(captainLocationStreamNotifierProvider.notifier).sendDeliveredSignal(
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
            const SnackBar(content: Text('فشل تحديث حالة الطلب إلى تم التوصيل')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final order = _order;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          '${AppStrings.captainOrderDetailsTitle} #${order.id}',
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            OrderInfoCard(order: order),
            20.verticalSpace,
            MapDistanceSection(
              order: order,
              vendorLocation: _vendorLocation,
              orderState: _orderState,
            ),
            20.verticalSpace,
            LocationTimeline(
              order: order,
              vendorLocation: _vendorLocation,
            ),
            20.verticalSpace,
            OrderSummaryCard(
              order: order,
              isFetchingDetails: _isFetchingDetails,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _orderState >= 3
          ? null
          : OrderActionButton(
              orderState: _orderState,
              isLoading: _isLoading,
              onPressed: _handleActionButton,
              distanceToCustomerMeters: _distanceToCustomerMeters,
            ),
    );
  }
}
