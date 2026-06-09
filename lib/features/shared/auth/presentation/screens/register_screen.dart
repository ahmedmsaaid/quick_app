import 'dart:io';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/core/services/maps_service.dart';
import 'package:base_app/core/providers/image_picker_provider.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:dio/dio.dart' as dio_pkg;

import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_app_bar.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_password_text_field.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_phone_text_field.dart';
import 'package:base_app/features/shared/auth/presentation/riverpod/auth_provider.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:base_app/features/shared/auth/data/auth_api_service.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final bool isUser;

  const RegisterScreen({super.key, this.isUser = true});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  final _formKey = GlobalKey<FormState>();
  
  LocationModel? _selectedLocation;
  File? _profileImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;
  bool _uploadSuccess = false;
  String _countryCode = "20"; // Default to Egypt phone code

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showLocationPicker() {
    final colors = AppColors(context);
    final searchController = TextEditingController();
    List<dynamic> searchResults = [];
    bool isSearching = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20.w,
                right: 20.w,
                top: 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 50.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: colors.divider,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  20.verticalSpace,
                  Text(
                    "تحديد موقعك الجغرافي",
                    style: AppTextStyles.text18w700(color: colors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  15.verticalSpace,
                  ElevatedButton.icon(
                    onPressed: () async {
                      setModalState(() {
                        isSearching = true;
                      });
                      try {
                        LocationPermission permission = await Geolocator.checkPermission();
                        if (permission == LocationPermission.denied) {
                          permission = await Geolocator.requestPermission();
                        }
                        if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
                          final position = await Geolocator.getCurrentPosition();
                          final address = await MapService.getAddressFromCoordsFree(position.latitude, position.longitude);
                          setState(() {
                            _selectedLocation = LocationModel(latitude: position.latitude, longitude: position.longitude);
                            _addressController.text = address;
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم تحديد موقعك الحالي تلقائياً بنجاح!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } else {
                          final mockLat = 33.3152;
                          final mockLng = 44.3661;
                          final address = await MapService.getAddressFromCoordsFree(mockLat, mockLng);
                          setState(() {
                            _selectedLocation = LocationModel(latitude: mockLat, longitude: mockLng);
                            _addressController.text = address;
                          });
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم استخدام الموقع الافتراضي لعدم توفر صلاحية الموقع"),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        final mockLat = 33.3152;
                        final mockLng = 44.3661;
                        final address = await MapService.getAddressFromCoordsFree(mockLat, mockLng);
                        setState(() {
                          _selectedLocation = LocationModel(latitude: mockLat, longitude: mockLng);
                          _addressController.text = address;
                        });
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } finally {
                        setModalState(() {
                          isSearching = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.gps_fixed, color: Colors.white),
                    label: Text(
                      "تحديد موقعي الحالي تلقائياً",
                      style: AppTextStyles.text14w600(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                  15.verticalSpace,
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Text(
                          "أو ابحث عن عنوانك",
                          style: AppTextStyles.text12w400(color: colors.textSecondary),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  15.verticalSpace,
                  CustomTextField(
                    controller: searchController,
                    hintText: "ابحث عن المنطقة، الشارع، أو المدينة...",
                    prefixIcon: const Icon(Icons.search),
                    onChanged: (val) async {
                      if (val.trim().length < 3) return;
                      setModalState(() {
                        isSearching = true;
                      });
                      try {
                        final results = await MapService.searchPlacesFree(val);
                        setModalState(() {
                          searchResults = results;
                          isSearching = false;
                        });
                      } catch (e) {
                        setModalState(() {
                          isSearching = false;
                        });
                      }
                    },
                  ),
                  15.verticalSpace,
                  if (isSearching)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (searchResults.isEmpty && searchController.text.trim().length >= 3)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text(
                        "لا توجد نتائج بحث، جرب كتابة اسم منطقة أو شارع آخر",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.text14w400(color: colors.textSecondary),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 220.h),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final item = searchResults[index];
                          final displayName = item['display_name'] ?? '';
                          return ListTile(
                            leading: Icon(Icons.location_on, color: colors.primary),
                            title: Text(
                              displayName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.text12w500(color: colors.textPrimary),
                            ),
                            onTap: () {
                              final lat = double.parse(item['lat']);
                              final lon = double.parse(item['lon']);
                              setState(() {
                                _selectedLocation = LocationModel(latitude: lat, longitude: lon);
                                _addressController.text = displayName;
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("تم اختيار الموقع: $displayName"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final password = _passwordController.text;
    final confirmedPassword = _confirmPasswordController.text;
    final email = _emailController.text.trim();
    final address = _addressController.text.trim();

    if (password != confirmedPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.passwordNotMatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("يرجى اختيار موقعك الجغرافي لتتمكن من إتمام التسجيل"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if profile image is still uploading or failed in background
    if (_profileImage != null && _uploadedImageUrl == null) {
      if (_isUploadingImage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("يرجى الانتظار حتى يكتمل رفع الصورة الشخصية..."),
            backgroundColor: Colors.orange,
          ),
        );
        return; // Abort registration
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("فشل رفع الصورة الشخصية، يرجى المحاولة مرة أخرى أو اختيار صورة أخرى."),
            backgroundColor: Colors.red,
          ),
        );
        return; // Abort registration
      }
    }

    final success = await ref.read(authProvider.notifier).register(
      countryCode: _countryCode,
      rawPhone: _phoneController.text.trim(),
      name: name,
      password: password,
      confirmedPassword: confirmedPassword,
      role: widget.isUser ? 2 : 3, // 2: customer, 3: delivery/captain
      email: email.isNotEmpty ? email : null,
      address: address.isNotEmpty ? address : null,
      location: _selectedLocation,
      photo: _uploadedImageUrl,
    );

    if (success) {
      if (mounted) {
        context.pushNamed(AppRoutes.otpScreen, arguments: widget.isUser);
      }
    } else {
      if (mounted) {
        final state = ref.read(authProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? AppStrings.errorOccurred),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: CustomAppBar(title: AppStrings.registerNow),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // PROFILE IMAGE PICKER
                GestureDetector(
                  onTap: () async {
                    if (_isUploadingImage) return; // Prevent picking while uploading
                    final picker = ref.read(imagePickerServiceProvider);
                    final pickedFile = await picker.pickSingleImage();
                    if (pickedFile != null) {
                      setState(() {
                        _profileImage = pickedFile;
                        _isUploadingImage = true;
                        _uploadSuccess = false;
                        _uploadedImageUrl = null;
                      });

                      try {
                        final filename = pickedFile.path.split('/').last;
                        final file = await dio_pkg.MultipartFile.fromFile(
                          pickedFile.path,
                          filename: filename,
                        );

                        final authService = ref.read(authApiServiceProvider);
                        final uploadResult = await authService.uploadProfileImage(file);

                        uploadResult.when(
                          success: (imageUrl) {
                            setState(() {
                              _uploadedImageUrl = imageUrl;
                              _isUploadingImage = false;
                              _uploadSuccess = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("تم رفع الصورة الشخصية بنجاح!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          failure: (error) {
                            setState(() {
                              _isUploadingImage = false;
                              _uploadSuccess = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("فشل رفع الصورة: ${error.message}"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          },
                        );
                      } catch (e) {
                        setState(() {
                          _isUploadingImage = false;
                          _uploadSuccess = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("حدث خطأ أثناء رفع الصورة: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          color: colors.divider,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _uploadSuccess 
                                ? Colors.green 
                                : (_isUploadingImage ? colors.primary : colors.divider),
                            width: 3.w,
                          ),
                          image: _profileImage != null
                              ? DecorationImage(
                                  image: FileImage(_profileImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _profileImage == null
                            ? Icon(
                                Icons.person,
                                size: 80.w,
                                color: colors.textSecondary.withOpacity(0.5),
                              )
                            : null,
                      ),
                      if (_isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3.w,
                                valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: _uploadSuccess ? Colors.green : colors.textPrimary,
                            shape: BoxShape.circle,
                            border: Border.all(color: colors.background, width: 2),
                          ),
                          child: Icon(
                            _uploadSuccess ? Icons.check : Icons.camera_alt, 
                            size: 20.w, 
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                30.verticalSpace,
                
                CustomTextField(
                  controller: _nameController,
                  hintText: AppStrings.fullName,
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: colors.primary,
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.pleaseEnterName;
                    }
                    return null;
                  },
                ),
                20.verticalSpace,
                
                CustomPhoneTextField(
                  controller: _phoneController,
                  onCountryChanged: (country) {
                    _countryCode = country.phoneCode;
                  },
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return AppStrings.pleaseEnterPhone;
                    }
                    return null;
                  },
                ),
                20.verticalSpace,
                
                CustomTextField(
                  controller: _emailController,
                  hintText: AppStrings.email,
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: colors.primary,
                  ),
                ),
                20.verticalSpace,
                
                CustomTextField(
                  controller: _addressController,
                  hintText: AppStrings.addressDetailsLabel,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: colors.primary,
                  ),
                  maxLines: 3,
                ),
                20.verticalSpace,
                
                // GORGEOUS INTERACTIVE LOCATION PICKER
                InkWell(
                  onTap: _showLocationPicker,
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.primary.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(12.r),
                      color: colors.primary.withOpacity(0.05),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: colors.primary,
                        ),
                        12.horizontalSpace,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedLocation == null 
                                  ? AppStrings.setLocOnMapLabel 
                                  : "الموقع الجغرافي المحدد",
                                style: AppTextStyles.text14w600(color: colors.textPrimary),
                              ),
                              if (_selectedLocation != null) ...[
                                4.verticalSpace,
                                Text(
                                  _addressController.text,
                                  style: AppTextStyles.text12w400(color: colors.textSecondary),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16.sp,
                          color: colors.textSecondary,
                        ),
                      ],
                    ),
                  ),
                ),
                20.verticalSpace,

                CustomPasswordTextField(
                  controller: _passwordController,
                  hintText: AppStrings.password,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppStrings.pleaseEnterPassword;
                    }
                    if (val.length < 6) {
                      return AppStrings.passwordTooShort;
                    }
                    return null;
                  },
                ),
                20.verticalSpace,
                CustomPasswordTextField(
                  controller: _confirmPasswordController,
                  hintText: AppStrings.confirmPassword,
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return AppStrings.pleaseEnterPassword;
                    }
                    return null;
                  },
                ),
                40.verticalSpace,
                if (authState.status == AuthStatus.loading)
                  const CircularProgressIndicator()
                else
                  CustomAppButton(
                    text: AppStrings.completeRegistration,
                    onPressed: _handleRegister,
                  ),
                30.verticalSpace,
                Row(
                  children: [
                    Expanded(child: Divider(color: colors.divider)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Text(
                        AppStrings.orContinueWith,
                        style: AppTextStyles.text12w400(color: colors.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider(color: colors.divider)),
                  ],
                ),
                20.verticalSpace,
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(FontAwesomeIcons.google, color: Colors.red, size: 20.sp),
                  label: Text(
                    AppStrings.registerWithGoogle,
                    style: AppTextStyles.text14w600(color: colors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    side: BorderSide(color: colors.divider),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                ),
                20.verticalSpace,
                const LoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);

    return InkWell(
      onTap: () => context.pop(),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: AppStrings.haveAccount,
              style: AppTextStyles.text14w400(color: colors.textPrimary),
            ),
            TextSpan(
              text: ' ${AppStrings.loginNow}',
              style: AppTextStyles.text14w600(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
