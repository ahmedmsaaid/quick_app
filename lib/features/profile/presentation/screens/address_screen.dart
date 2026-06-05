import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/features/profile/presentation/riverpod/profile_provider.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  late final TextEditingController _addressController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).user;
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(profileProvider.notifier).updateProfile(
          address: _addressController.text.trim(),
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
          AppStrings.myAddressesTitle,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Map placeholder area
              Container(
                height: 200.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colors.containerBackground,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(Icons.map, size: 80.sp, color: colors.textDisabled),
                    const Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Icon(Icons.location_on, color: Colors.red, size: 40),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      child: InkWell(
                        onTap: () async {
                          try {
                            LocationPermission permission = await Geolocator.checkPermission();
                            if (permission == LocationPermission.denied) {
                              permission = await Geolocator.requestPermission();
                            }
                            if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                              final position = await Geolocator.getCurrentPosition();
                              final address = await MapService.getAddressFromCoordsFree(position.latitude, position.longitude);
                              setState(() {
                                _addressController.text = address;
                              });
                            }
                          } catch (e) {
                            print("Location error: $e");
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: BorderRadius.circular(20.r),
                            boxShadow: [BoxShadow(color: colors.shadow, blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.my_location, color: colors.primary, size: 16.sp),
                              6.horizontalSpace,
                              Text(
                                "تحديد موقعي الحالي",
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
              24.verticalSpace,

              Text(
                AppStrings.addressDetailsLabel,
                style: AppTextStyles.text16w700(color: colors.textPrimary),
              ),
              16.verticalSpace,

              CustomTextField(
                controller: _addressController,
                hintText: AppStrings.enterAddressHint,
                prefixIcon: Icon(Icons.location_on_outlined, color: colors.textSecondary),
                maxLines: 3,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return AppStrings.pleaseEnter;
                  return null;
                },
              ),
              32.verticalSpace,

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
      ),
    );
  }
}
