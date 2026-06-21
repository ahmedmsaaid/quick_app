import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/features/customer/checkout/data/models/order_models.dart';
import 'package:base_app/features/customer/orders/data/orders_api_service.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_orders_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class CaptainOrderDetailsScreen extends ConsumerStatefulWidget {
  final OrderDto order;
  const CaptainOrderDetailsScreen({super.key, required this.order});

  @override
  ConsumerState<CaptainOrderDetailsScreen> createState() => _CaptainOrderDetailsScreenState();
}

class _CaptainOrderDetailsScreenState extends ConsumerState<CaptainOrderDetailsScreen> {
  late int _orderState; // 0: Available, 1: Accepted/Going to store, 2: At Store/Picked up, 3: Delivered
  bool _isLoading = false;
  bool _isFetchingDetails = false;
  late OrderDto _order;

  double? _distanceBetweenStoreAndCustomer;
  double? _distanceToStore;
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  static const _launcherChannel = MethodChannel('com.quick.app/launcher');

  final List<String> _buttonTexts = [
    AppStrings.acceptAndGoToStoreBtn,
    AppStrings.arrivedStoreBtn,
    AppStrings.pickedUpAndOnWayBtn,
    AppStrings.deliveredDoneBtn,
  ];

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _initializeOrderState();
    _updateMarkers();
    _calculateDistances();
    Future.microtask(() => _fetchOrderDetails());
  }

  void _initializeOrderState() {
    if (_order.status == 2) {
      _orderState = 0;
    } else if (_order.status == 3) {
      _orderState = 1; // Default to Accepted / Going to store
    } else if (_order.status == 4) {
      _orderState = 3; // Delivered
    } else {
      _orderState = 0;
    }
  }

  void _updateMarkers() {
    final storeLat = _order.creator?.location?.latitude;
    final storeLng = _order.creator?.location?.longitude;
    final destLat = _order.latitude;
    final destLng = _order.longitude;

    final Set<Marker> newMarkers = {};

    if (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0) {
      newMarkers.add(
        Marker(
          markerId: const MarkerId('store'),
          position: LatLng(storeLat, storeLng),
          infoWindow: InfoWindow(
            title: _order.creator?.name ?? "المحل",
            snippet: _order.creator?.address ?? "عنوان المحل",
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
            title: _order.user?.name ?? "العميل",
            snippet: _order.address ?? "عنوان التوصيل",
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
    
    final storeLat = _order.creator?.location?.latitude;
    final storeLng = _order.creator?.location?.longitude;
    final destLat = _order.latitude;
    final destLng = _order.longitude;

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
    final storeLat = _order.creator?.location?.latitude;
    final storeLng = _order.creator?.location?.longitude;
    final destLat = _order.latitude;
    final destLng = _order.longitude;

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

  Future<void> _fetchOrderDetails() async {
    setState(() => _isFetchingDetails = true);
    final apiService = ref.read(ordersApiServiceProvider);
    final result = await apiService.getOrderById(
      orderId: widget.order.id,
      includesPath: ["User", "Creator", "OrderProducts.Product"],
    );
    result.when(
      success: (response) {
        if (response.success && response.result != null) {
          setState(() {
            _order = response.result!;
            _initializeOrderState();
          });
          _updateMarkers();
          _calculateDistances();
        }
      },
      failure: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error.message ?? 'حدث خطأ أثناء تحميل تفاصيل الطلب')),
          );
        }
      },
    );
    setState(() => _isFetchingDetails = false);
  }

  Future<void> _handleActionButton() async {
    if (_isLoading) return;

    if (_orderState == 0) {
      // Accept order -> Update status to 3
      setState(() => _isLoading = true);
      final success = await ref.read(captainOrdersProvider.notifier).acceptOrder(_order);
      setState(() => _isLoading = false);

      if (success) {
        setState(() {
          _orderState = 1; // Transition to next step locally
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم قبول الطلب بنجاح وهو الآن قيد التوصيل')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('فشل قبول الطلب، يرجى المحاولة لاحقاً')),
          );
        }
      }
    } else if (_orderState == 1) {
      // Arrived store -> Local step transition
      setState(() {
        _orderState = 2;
      });
    } else if (_orderState == 2) {
      // Picked up -> Local step transition
      setState(() {
        _orderState = 3;
      });
    } else if (_orderState == 3) {
      // Delivered -> Update status to 4
      setState(() => _isLoading = true);
      final success = await ref.read(captainOrdersProvider.notifier).updateStatus(_order, 4);
      setState(() => _isLoading = false);

      if (success) {
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
            _buildOrderInfoCard(context, order),
            20.verticalSpace,
            _buildMapAndDistanceSection(context),
            20.verticalSpace,
            _buildLocationTimeline(context, order),
            20.verticalSpace,
            _buildOrderSummary(context, order),
          ],
        ),
      ),
      bottomNavigationBar: _buildActionBtn(context),
    );
  }

  Widget _buildMapAndDistanceSection(BuildContext context) {
    final colors = AppColors(context);
    final storeLat = _order.creator?.location?.latitude;
    final storeLng = _order.creator?.location?.longitude;
    final destLat = _order.latitude;
    final destLng = _order.longitude;

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
                final targetLat = (_orderState == 0 || _orderState == 1) ? storeLat : destLat;
                final targetLng = (_orderState == 0 || _orderState == 1) ? storeLng : destLng;
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
                (_orderState == 0 || _orderState == 1)
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

  String _getImageUrl(String? photo) {
    if (photo == null || photo.isEmpty) return "";
    if (photo.startsWith("http")) return photo;
    return "${ApiConstants.streamUrl}$photo";
  }

  String _getStatusText(int status) {
    switch (status) {
      case 0:
        return "قيد الانتظار";
      case 1:
        return "مقبول";
      case 2:
        return "جاهز للاستلام";
      case 3:
        return "قيد التوصيل";
      case 4:
        return "تم التوصيل";
      default:
        return "غير معروف";
    }
  }

  Color _getStatusColor(BuildContext context, int status) {
    final colors = AppColors(context);
    switch (status) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return colors.primary;
      case 3:
        return Colors.teal;
      case 4:
        return colors.success;
      default:
        return colors.textHint;
    }
  }

  String _formatOrderDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.year}/${date.month}/${date.day}";
    } catch (_) {
      return dateStr;
    }
  }

  Widget _buildOrderInfoCard(BuildContext context, OrderDto order) {
    final colors = AppColors(context);
    final paymentMethod = order.paymentMethod == 0 ? AppStrings.cashLabel : "إلكتروني";
    final earnings = order.deliveryFee;

    return Container(
      padding: EdgeInsets.all(20.r),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "طلب #${order.id}",
                    style: AppTextStyles.text16w700(color: colors.textPrimary),
                  ),
                  5.verticalSpace,
                  Text(
                    order.createdOn != null
                        ? _formatOrderDate(order.createdOn!)
                        : "تاريخ غير متوفر",
                    style: AppTextStyles.text12w400(color: colors.textSecondary),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor(context, order.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: _getStatusColor(context, order.status).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _getStatusText(order.status),
                  style: AppTextStyles.text12w600(
                    color: _getStatusColor(context, order.status),
                  ),
                ),
              ),
            ],
          ),
          20.verticalSpace,
          Divider(color: colors.divider.withValues(alpha: 0.5)),
          15.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                AppStrings.netProfitLabel,
                "${earnings.toStringAsFixed(0)} ${AppStrings.currency}",
                colors.success,
                Icons.account_balance_wallet_outlined,
              ),
              _buildInfoItem(
                context,
                AppStrings.paymentMethodLabel,
                paymentMethod,
                Colors.orange,
                order.paymentMethod == 0 ? Icons.money : Icons.credit_card,
              ),
              _buildInfoItem(
                context,
                "نوع الطلب",
                order.type == 0 ? "مطعم" : "متجر",
                Colors.blue,
                order.type == 0 ? Icons.restaurant : Icons.shopping_bag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    final colors = AppColors(context);
    return Column(
      children: [
        Icon(icon, color: color.withValues(alpha: 0.8), size: 20.sp),
        8.verticalSpace,
        Text(
          label,
          style: AppTextStyles.text11w400(color: colors.textSecondary),
        ),
        4.verticalSpace,
        Text(
          value,
          style: AppTextStyles.text14w700(color: color),
        ),
      ],
    );
  }

  Widget _buildLocationTimeline(BuildContext context, OrderDto order) {
    final colors = AppColors(context);
    final storeLat = order.creator?.location?.latitude;
    final storeLng = order.creator?.location?.longitude;
    final destLat = order.latitude;
    final destLng = order.longitude;

    final storeName = order.creator?.name ?? "متجر غير معروف";
    final storeAddress = (order.creator?.address != null && order.creator!.address!.isNotEmpty)
        ? order.creator!.address!
        : (storeLat != null && storeLng != null && storeLat != 0 && storeLng != 0)
            ? "الموقع: ${storeLat.toStringAsFixed(5)}, ${storeLng.toStringAsFixed(5)}"
            : "عنوان غير متوفر";

    final customerName = order.user?.name ?? "زبون غير معروف";
    final customerAddress = (order.address != null && order.address!.isNotEmpty)
        ? order.address!
        : (destLat != 0 && destLng != 0)
            ? "الموقع: ${destLat.toStringAsFixed(5)}, ${destLng.toStringAsFixed(5)}"
            : "عنوان غير متوفر";

    return Container(
      padding: EdgeInsets.all(20.r),
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
        children: [
          _buildTimelineItem(
            context,
            Icons.store,
            AppStrings.pickupPointLabel,
            storeName,
            storeAddress,
            Colors.blue,
            avatarUrl: _getImageUrl(order.creator?.photo ?? order.creator?.avatar),
            phone: order.creator?.phone,
          ),
          20.verticalSpace,
          _buildTimelineItem(
            context,
            Icons.location_on,
            AppStrings.deliveryPointLabel,
            customerName,
            customerAddress,
            colors.error,
            isLast: true,
            avatarUrl: _getImageUrl(order.user?.photo ?? order.user?.avatar),
            phone: order.user?.phone,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    IconData icon,
    String type,
    String title,
    String subtitle,
    Color color, {
    bool isLast = false,
    String? phone,
    String? avatarUrl,
  }) {
    final colors = AppColors(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), 
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
              ),
              child: ClipOval(
                child: (avatarUrl != null && avatarUrl.isNotEmpty)
                    ? Image.network(
                        avatarUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(icon, color: color, size: 20.sp),
                      )
                    : Icon(icon, color: color, size: 20.sp),
              ),
            ),
            if (!isLast)
              Container(width: 2.w, height: 45.h, color: colors.divider),
          ],
        ),
        15.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(type, style: AppTextStyles.text10w500(color: color)),
              Text(title, style: AppTextStyles.text14w700(color: colors.textPrimary)),
              Text(subtitle, style: AppTextStyles.text12w400(color: colors.textSecondary)),
            ],
          ),
        ),
        if (phone != null && phone.isNotEmpty)
          Row(
            children: [
              IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("رقم الهاتف"),
                      content: SelectableText(phone),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("إغلاق"),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.call, color: colors.success, size: 22.sp),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRoutes.chatDetailsScreen, arguments: title);
                }, 
                icon: Icon(Icons.chat, color: colors.primary, size: 22.sp),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context, OrderDto order) {
    final colors = AppColors(context);
    final subtotal = order.totalPrice - order.deliveryFee - order.orderFee;

    return Container(
      padding: EdgeInsets.all(20.r),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.orderDetails, style: AppTextStyles.text14w700(color: colors.textPrimary)),
          15.verticalSpace,
          if (_isFetchingDetails)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(color: colors.primary, strokeWidth: 2),
                ),
              ),
            )
          else if (order.products.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Text(
                "لا توجد منتجات في هذا الطلب",
                style: AppTextStyles.text12w400(color: colors.textHint),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order.products.length,
              separatorBuilder: (context, index) => Divider(color: colors.divider.withValues(alpha: 0.5)),
              itemBuilder: (context, index) {
                final product = order.products[index];
                final name = product.productName ?? "منتج غير معروف";
                final quantity = product.quantity;
                final price = product.price;
                final totalPrice = product.totalPrice;
                final productPhotoUrl = _getImageUrl(product.photo);

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Row(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          color: colors.surface,
                          border: Border.all(color: colors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: productPhotoUrl.isNotEmpty
                              ? Image.network(
                                  productPhotoUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.shopping_bag_outlined, color: colors.textHint, size: 24.sp),
                                )
                              : Icon(Icons.shopping_bag_outlined, color: colors.textHint, size: 24.sp),
                        ),
                      ),
                      15.horizontalSpace,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.text14w700(color: colors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            5.verticalSpace,
                            Text(
                              "$quantity x ${price.toStringAsFixed(0)} ${AppStrings.currency}",
                              style: AppTextStyles.text12w400(color: colors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      10.horizontalSpace,
                      Text(
                        "${totalPrice.toStringAsFixed(0)} ${AppStrings.currency}",
                        style: AppTextStyles.text14w700(color: colors.textPrimary),
                      ),
                    ],
                  ),
                );
              },
            ),
          15.verticalSpace,
          Divider(color: colors.divider),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            "إجمالي المنتجات",
            "${subtotal.toStringAsFixed(0)} ${AppStrings.currency}",
          ),
          8.verticalSpace,
          _buildSummaryRow(
            context,
            "رسوم التوصيل",
            "${order.deliveryFee.toStringAsFixed(0)} ${AppStrings.currency}",
          ),
          8.verticalSpace,
          _buildSummaryRow(
            context,
            "رسوم الخدمة",
            "${order.orderFee.toStringAsFixed(0)} ${AppStrings.currency}",
          ),
          10.verticalSpace,
          Divider(color: colors.divider),
          10.verticalSpace,
          _buildSummaryRow(
            context,
            AppStrings.requiredFromCustomerLabel,
            "${order.totalPrice.toStringAsFixed(0)} ${AppStrings.currency}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String value, {bool isTotal = false}) {
    final colors = AppColors(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: isTotal ? AppTextStyles.text14w700(color: colors.textPrimary) : AppTextStyles.text14w400(color: colors.textSecondary)),
        Text(value, style: isTotal ? AppTextStyles.text16w700(color: colors.primary) : AppTextStyles.text14w600(color: colors.textPrimary)),
      ],
    );
  }

  Widget _buildActionBtn(BuildContext context) {
    final colors = AppColors(context);
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleActionButton,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          minimumSize: Size(double.infinity, 55.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _buttonTexts[_orderState],
                style: AppTextStyles.text16w700(color: Colors.white),
              ),
      ),
    );
  }
}
