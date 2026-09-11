import 'dart:async';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:geolocator/geolocator.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final LocationDto? locationToEdit;
  const AddAddressScreen({super.key, this.locationToEdit});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen>
    with SingleTickerProviderStateMixin {
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController();
  final FocusNode _searchFocusNode = FocusNode();

  // Default center: Baghdad
  ll.LatLng _selectedPoint = const ll.LatLng(33.3152, 44.3661);
  bool _hasSelectedLocation = false;
  bool _isDefault = false;
  bool _isLocating = false;
  bool _isReverseGeocoding = false;

  // Search state
  bool _isSearchingPlaces = false;
  List<dynamic> _searchResults = [];
  Timer? _debounceTimer;

  late final AnimationController _pinAnimCtrl;
  late final Animation<double> _pinBounce;

  @override
  void initState() {
    super.initState();
    _pinAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pinBounce = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _pinAnimCtrl, curve: Curves.easeOut),
    );

    if (widget.locationToEdit != null) {
      final loc = widget.locationToEdit!;
      _titleController.text = loc.name ?? '';
      _addressController.text = loc.address ?? '';
      if (loc.latitude != 0 && loc.longitude != 0) {
        _selectedPoint = ll.LatLng(loc.latitude, loc.longitude);
        _hasSelectedLocation = true;
      }
      _isDefault = loc.base;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    _pinAnimCtrl.dispose();
    super.dispose();
  }

  void _onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      setState(() {
        _searchResults = [];
        _isSearchingPlaces = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      setState(() => _isSearchingPlaces = true);
      try {
        final results = await MapService.searchPlacesFree(trimmed);
        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearchingPlaces = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isSearchingPlaces = false);
      }
    });
  }

  void _selectSearchResult(dynamic place) {
    final latStr = place['lat'];
    final lonStr = place['lon'];
    final displayName = place['display_name'] ?? place['name'] ?? '';

    if (latStr != null && lonStr != null) {
      final lat = double.tryParse(latStr.toString());
      final lon = double.tryParse(lonStr.toString());
      if (lat != null && lon != null) {
        final point = ll.LatLng(lat, lon);
        setState(() {
          _selectedPoint = point;
          _hasSelectedLocation = true;
          _searchResults = [];
          _searchController.text = displayName.split(',').first;
          _addressController.text = displayName;
        });
        _searchFocusNode.unfocus();
        _mapController.move(point, 16.0);
        CustomToast.success(context, "تم التوجه إلى الموقع المحدد");
      }
    }
  }

  Future<void> _onMapTap(ll.LatLng point) async {
    _searchFocusNode.unfocus();
    setState(() {
      _selectedPoint = point;
      _hasSelectedLocation = true;
      _searchResults = [];
    });
    _mapController.move(point, _mapController.camera.zoom);
    _reverseGeocode(point.latitude, point.longitude);
  }

  Future<void> _onMapPositionChanged(MapCamera camera, bool hasGesture) async {
    if (hasGesture) {
      _pinAnimCtrl.forward(from: 0);
      setState(() {
        _selectedPoint = camera.center;
        _hasSelectedLocation = true;
      });
    }
  }

  Future<void> _onMapMoveEnd(MapCamera camera, bool hasGesture) async {
    if (hasGesture) {
      _pinAnimCtrl.reverse();
      _reverseGeocode(camera.center.latitude, camera.center.longitude);
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    setState(() => _isReverseGeocoding = true);
    try {
      final address = await MapService.getAddressFromCoordsFree(lat, lng);
      if (mounted) {
        setState(() {
          _addressController.text = address;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isReverseGeocoding = false);
    }
  }

  Future<void> _detectCurrentLocation() async {
    _searchFocusNode.unfocus();
    setState(() {
      _isLocating = true;
      _searchResults = [];
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // ignore: check_permission_before_requesting
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final point = ll.LatLng(position.latitude, position.longitude);
        setState(() {
          _selectedPoint = point;
          _hasSelectedLocation = true;
        });
        _mapController.move(point, 16.0);
        _reverseGeocode(position.latitude, position.longitude);
        if (mounted) {
          CustomToast.success(context, "تم تحديد موقعك الحالي بنجاح");
        }
      } else {
        if (mounted) {
          CustomToast.error(context, "يرجى تفعيل صلاحية الوصول للموقع");
        }
      }
    } catch (e) {
      if (mounted) {
        CustomToast.error(context, "فشل تحديد موقعك الحالي");
      }
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_hasSelectedLocation) {
      CustomToast.error(context, "يرجى تحديد الموقع على الخريطة أولاً");
      return;
    }

    final titleText = _titleController.text.trim();
    final addressText = _addressController.text.trim();

    final bool success;
    if (widget.locationToEdit != null) {
      success = await ref.read(profileProvider.notifier).updateAddress(
            id: widget.locationToEdit!.id,
            name: titleText.isNotEmpty ? titleText : addressText,
            address: addressText,
            latitude: _selectedPoint.latitude,
            longitude: _selectedPoint.longitude,
            base: _isDefault,
          );
    } else {
      success = await ref.read(profileProvider.notifier).addAddress(
            name: titleText.isNotEmpty ? titleText : addressText,
            address: addressText,
            latitude: _selectedPoint.latitude,
            longitude: _selectedPoint.longitude,
            base: _isDefault,
          );
    }

    if (!mounted) return;

    if (success) {
      CustomToast.success(
        context,
        widget.locationToEdit != null ? "تم تعديل العنوان بنجاح" : AppStrings.addressSavedSuccessMsg,
      );
      Navigator.pop(context);
    } else {
      final err = ref.read(profileProvider).errorMessage;
      CustomToast.error(context, err ?? AppStrings.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState.status == ProfileStatus.updating;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: const CustomArrowBack(),
        title: Text(
          widget.locationToEdit != null ? "تعديل العنوان" : AppStrings.addNewAddressBtn,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: colors.divider),
        ),
      ),
      body: Stack(
        children: [
          // ── Interactive Map (Full Screen Layer) ──────────────────────
          Positioned.fill(
            child: Stack(
              children: [
                // Map widget
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedPoint,
                    initialZoom: 13.0,
                    onTap: (tapPos, point) => _onMapTap(point),
                    onPositionChanged: _onMapPositionChanged,
                    onMapEvent: (event) {
                      if (event is MapEventMoveEnd) {
                        _onMapMoveEnd(event.camera, event.source != MapEventSource.nonRotatedSizeChange);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                      userAgentPackageName: 'com.quick.app',
                    ),
                  ],
                ),

                // ── Center Pin (always centered, moves with map) ────────
                IgnorePointer(
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _pinBounce,
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _pinBounce.value - 24),
                        child: child,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.w,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colors.primary.withValues(alpha: 0.45),
                                  blurRadius: 14,
                                  spreadRadius: 3,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          // Pin needle
                          Container(
                            width: 3,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors.primary,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(4),
                                bottomRight: Radius.circular(4),
                              ),
                            ),
                          ),
                          // Shadow dot
                          Container(
                            width: 8,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Search Bar Overlay (Top Center) ──────────────────────
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  right: 12.w,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: colors.shadow.withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onChanged: _onSearchQueryChanged,
                          style: AppTextStyles.text14w500(color: colors.textPrimary),
                          decoration: InputDecoration(
                            hintText: "ابحث عن منطقة، شارع أو مدينة...",
                            hintStyle: AppTextStyles.text13w600(color: colors.textHint),
                            prefixIcon: Icon(Icons.search_rounded, color: colors.primary, size: 22.sp),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear_rounded, color: colors.textSecondary, size: 18.sp),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _searchResults = []);
                                    },
                                  )
                                : (_isSearchingPlaces
                                    ? Padding(
                                        padding: EdgeInsets.all(12.r),
                                        child: LoadingButton(size: 16.w, color: colors.primary),
                                      )
                                    : null),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                          ),
                        ),
                      ),

                      // ── Search Results Dropdown List ───────────────────
                      if (_searchResults.isNotEmpty)
                        Container(
                          margin: EdgeInsets.only(top: 6.h),
                          constraints: BoxConstraints(maxHeight: 200.h),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(14.r),
                            boxShadow: [
                              BoxShadow(
                                color: colors.shadow.withValues(alpha: 0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14.r),
                            child: ListView.separated(
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemCount: _searchResults.length,
                              separatorBuilder: (_, __) => Divider(height: 1, color: colors.divider),
                              itemBuilder: (context, index) {
                                final place = _searchResults[index];
                                final name = place['display_name'] ?? '';
                                return ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
                                  leading: Container(
                                    padding: EdgeInsets.all(6.r),
                                    decoration: BoxDecoration(
                                      color: colors.primary.withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(Icons.place_outlined, color: colors.primary, size: 18.sp),
                                  ),
                                  title: Text(
                                    name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.text12w500(color: colors.textPrimary),
                                  ),
                                  onTap: () => _selectSearchResult(place),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // ── Zoom controls (positioned below search bar on right) ───
                Positioned(
                  top: 76.h,
                  right: 12.w,
                  child: Column(
                    children: [
                      _MapIconButton(
                        icon: Icons.add_rounded,
                        colors: colors,
                        onTap: () {
                          final z = (_mapController.camera.zoom + 1).clamp(1.0, 19.0);
                          _mapController.move(_mapController.camera.center, z);
                        },
                        topRadius: true,
                        bottomRadius: false,
                      ),
                      Container(height: 1, width: 38.w, color: colors.divider),
                      _MapIconButton(
                        icon: Icons.remove_rounded,
                        colors: colors,
                        onTap: () {
                          final z = (_mapController.camera.zoom - 1).clamp(1.0, 19.0);
                          _mapController.move(_mapController.camera.center, z);
                        },
                        topRadius: false,
                        bottomRadius: true,
                      ),
                    ],
                  ),
                ),

                // ── Prominent My Location Button ─────────────────────────
                Positioned(
                  top: 140.h,
                  right: 14.w,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 6,
                    shadowColor: colors.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(30.r),
                    child: InkWell(
                      onTap: _isLocating ? null : _detectCurrentLocation,
                      borderRadius: BorderRadius.circular(30.r),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(30.r),
                          border: Border.all(color: colors.primary, width: 1.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isLocating)
                              LoadingButton(size: 16.w, color: colors.primary)
                            else ...[
                              Icon(Icons.my_location_rounded, color: colors.primary, size: 20.sp),
                              8.horizontalSpace,
                              Text(
                                "تحديد موقعي تلقائياً",
                                style: AppTextStyles.text13w700(color: colors.primary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Drag hint label (shown when search results are empty) ─
                if (!_hasSelectedLocation && _searchResults.isEmpty)
                  Positioned(
                    top: 140.h,
                    left: 14.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        "اسحب الخريطة لتحديد الموقع",
                        style: AppTextStyles.text11w500(color: Colors.white),
                      ),
                    ),
                  ),

                // ── Reverse geocoding loading indicator ────────────────
                if (_isReverseGeocoding && _searchResults.isEmpty)
                  Positioned(
                    top: 140.h,
                    left: 14.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8)],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LoadingButton(size: 14.w, color: colors.primary),
                          8.horizontalSpace,
                          Text(
                            "جاري تحديد العنوان...",
                            style: AppTextStyles.text11w500(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Draggable & Collapsible Bottom Sheet Panel ─────────────────
          DraggableScrollableSheet(
            initialChildSize: 0.26,
            minChildSize: 0.12,
            maxChildSize: 0.48,
            snap: true,
            snapSizes: const [0.12, 0.26, 0.48],
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h + MediaQuery.of(context).viewInsets.bottom),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Drag handle ──────────────────────────────────
                        Center(
                          child: Container(
                            width: 44.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: colors.divider,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ),
                        10.verticalSpace,

                        // ── Section title with Drag Hint Icon ───────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    color: colors.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Icon(Icons.edit_location_alt_rounded,
                                      color: colors.primary, size: 18.sp),
                                ),
                                10.horizontalSpace,
                                Text(
                                  AppStrings.addressDetailsLabel,
                                  style: AppTextStyles.text15w700(color: colors.textPrimary),
                                ),
                              ],
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded,
                                color: colors.textHint, size: 22.sp),
                          ],
                        ),
                        10.verticalSpace,

                        // ── Address title field ─────────────────────────────
                        CustomTextField(
                          controller: _titleController,
                          hintText: "اسم العنوان (مثال: المنزل، العمل...)",
                          prefixIcon: Icon(Icons.bookmark_outline_rounded, color: colors.textSecondary, size: 20.sp),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return "يرجى إدخال اسم العنوان";
                            }
                            return null;
                          },
                        ),
                        10.verticalSpace,

                        // ── Address text field ───────────────────────────
                        CustomTextField(
                          controller: _addressController,
                          hintText: AppStrings.enterAddressHint,
                          prefixIcon: Icon(Icons.location_on_outlined, color: colors.textSecondary, size: 20.sp),
                          maxLines: 2,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return AppStrings.pleaseEnter;
                            }
                            return null;
                          },
                        ),

                        10.verticalSpace,

                        // ── Default address switch ───────────────────────
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: colors.containerBackground,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.home_rounded, color: colors.primary, size: 18.sp),
                              10.horizontalSpace,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "العنوان الافتراضي",
                                      style: AppTextStyles.text13w600(color: colors.textPrimary),
                                    ),
                                    Text(
                                      "سيُستخدم هذا العنوان تلقائياً عند الطلب",
                                      style: AppTextStyles.text11w400(color: colors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _isDefault,
                                onChanged: (val) => setState(() => _isDefault = val),
                                activeThumbColor: colors.primary,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ),

                        14.verticalSpace,

                        // ── Save button ──────────────────────────────────
                        if (isLoading)
                          const Center(child: LoadingButton())
                        else
                          CustomAppButton(
                            text: widget.locationToEdit != null ? "حفظ التعديلات" : AppStrings.saveAddressBtn,
                            onPressed: _save,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Reusable Map Icon Button ────────────────────────────────────────────────
class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final AppColors colors;
  final VoidCallback onTap;
  final bool topRadius;
  final bool bottomRadius;

  const _MapIconButton({
    required this.icon,
    required this.colors,
    required this.onTap,
    required this.topRadius,
    required this.bottomRadius,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.only(
        topLeft: topRadius ? const Radius.circular(12) : Radius.zero,
        topRight: topRadius ? const Radius.circular(12) : Radius.zero,
        bottomLeft: bottomRadius ? const Radius.circular(12) : Radius.zero,
        bottomRight: bottomRadius ? const Radius.circular(12) : Radius.zero,
      ),
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.only(
            topLeft: topRadius ? Radius.circular(12.r) : Radius.zero,
            topRight: topRadius ? Radius.circular(12.r) : Radius.zero,
            bottomLeft: bottomRadius ? Radius.circular(12.r) : Radius.zero,
            bottomRight: bottomRadius ? Radius.circular(12.r) : Radius.zero,
          ),
          boxShadow: topRadius
              ? [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.15),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Icon(icon, color: colors.textPrimary, size: 20.sp),
      ),
    );
  }
}
