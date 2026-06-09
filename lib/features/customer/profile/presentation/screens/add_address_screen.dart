import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double? _latitude;
  double? _longitude;
  bool _isDefault = false;
  bool _isLocating = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _detectCurrentLocation() async {
    setState(() {
      _isLocating = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        // ignore: check_permission_before_requesting
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition();
        final address = await MapService.getAddressFromCoordsFree(position.latitude, position.longitude);
        setState(() {
          _addressController.text = address;
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
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
      if (mounted) {
        setState(() {
          _isLocating = false;
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null) {
      CustomToast.error(context, "يرجى تحديد الموقع على الخريطة أولاً");
      return;
    }

    final success = await ref.read(profileProvider.notifier).addAddress(
          address: _addressController.text.trim(),
          latitude: _latitude!,
          longitude: _longitude!,
          base: _isDefault,
        );

    if (!mounted) return;

    if (success) {
      CustomToast.success(context, AppStrings.addressSavedSuccessMsg);
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
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.addNewAddressBtn,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Map Placeholder Area
              Container(
                height: 220.h,
                width: double.infinity,
                color: colors.containerBackground,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.map, size: 90.sp, color: colors.textDisabled),
                    if (_latitude != null && _longitude != null)
                      const Icon(Icons.location_on, color: Colors.red, size: 40)
                    else
                      Icon(Icons.location_searching, color: colors.textHint, size: 40),
                    Positioned(
                      bottom: 20,
                      child: InkWell(
                        onTap: _isLocating ? null : _detectCurrentLocation,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [
                              BoxShadow(color: colors.shadow, blurRadius: 10, offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(
                            children: [
                              _isLocating
                                  ? SizedBox(
                                      width: 16.w,
                                      height: 16.w,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
                                    )
                                  : Icon(Icons.my_location, color: colors.primary, size: 18.sp),
                              8.horizontalSpace,
                              Text(
                                _isLocating ? "جاري تحديد موقعك..." : AppStrings.setLocOnMapLabel,
                                style: AppTextStyles.text12w600(color: colors.textPrimary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.addressDetailsLabel,
                      style: AppTextStyles.text16w700(color: colors.textPrimary),
                    ),
                    20.verticalSpace,
                    CustomTextField(
                      controller: _addressController,
                      hintText: AppStrings.enterAddressHint,
                      prefixIcon: Icon(Icons.location_on_outlined, color: colors.textSecondary),
                      maxLines: 3,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return AppStrings.pleaseEnter;
                        }
                        return null;
                      },
                    ),
                    20.verticalSpace,
                    
                    // Coordinates Display
                    if (_latitude != null && _longitude != null)
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: colors.containerBackground,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.gps_fixed, color: colors.primary, size: 18.sp),
                            10.horizontalSpace,
                            Expanded(
                              child: Text(
                                "الموقع الجغرافي: (${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)})",
                                style: AppTextStyles.text12w400(color: colors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    20.verticalSpace,

                    // Set as Default switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "تعيين كالعنوان الافتراضي لتوصيل الطلبات",
                          style: AppTextStyles.text14w600(color: colors.textPrimary),
                        ),
                        Switch(
                          value: _isDefault,
                          onChanged: (val) {
                            setState(() {
                              _isDefault = val;
                            });
                          },
                          activeColor: colors.primary,
                        ),
                      ],
                    ),

                    30.verticalSpace,
                    if (isLoading)
                      const LoadingButton()
                    else
                      CustomAppButton(
                        text: AppStrings.saveAddressBtn,
                        onPressed: _save,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
