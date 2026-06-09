import 'dart:io';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/widgets/custom_arrow_back.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';
import 'package:base_app/features/customer/profile/data/profile_api_service.dart';
import 'package:base_app/core/providers/image_picker_provider.dart';
import 'package:dio/dio.dart';

class PersonalInfoScreen extends ConsumerStatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  ConsumerState<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends ConsumerState<PersonalInfoScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _formKey = GlobalKey<FormState>();
  File? _pickedImage;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileProvider).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickerService = ref.read(imagePickerServiceProvider);
    final file = await pickerService.pickSingleImage();
    if (file != null) {
      setState(() => _pickedImage = file);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    String? uploadedPhotoUrl;

    // Upload photo first if a new one was picked
    if (_pickedImage != null) {
      setState(() => _isUploadingPhoto = true);
      final file = await MultipartFile.fromFile(
        _pickedImage!.path,
        filename: 'profile.jpg',
      );
      final uploadResult =
          await ref.read(profileApiServiceProvider).uploadProfilePhoto(file);

      if (!mounted) return;
      setState(() => _isUploadingPhoto = false);

      uploadResult.when(
        success: (url) => uploadedPhotoUrl = url,
        failure: (err) {
          _showError(err.message);
          return;
        },
      );
    }

    final success = await ref.read(profileProvider.notifier).updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim().isEmpty
              ? null
              : _emailController.text.trim(),
          photo: uploadedPhotoUrl,
        );

    if (!mounted) return;

    if (success) {
      CustomToast.success(context, AppStrings.accountUpdatedSuccessfully);
      Navigator.pop(context);
    } else {
      final err = ref.read(profileProvider).errorMessage;
      _showError(err ?? AppStrings.errorOccurred);
    }
  }

  void _showError(String msg) {
    CustomToast.error(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;
    final isLoading = profileState.status == ProfileStatus.updating || _isUploadingPhoto;

    // Determine which photo to show: newly picked > user photo > default
    final String? networkPhoto = user?.photo ?? user?.avatar;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        leading: const CustomArrowBack(),
        title: Text(
          AppStrings.personalInformation,
          style: AppTextStyles.text18w700(color: colors.textPrimary),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile photo with edit button
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50.r,
                      backgroundColor: colors.divider,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!) as ImageProvider
                          : (networkPhoto != null && networkPhoto.isNotEmpty
                              ? NetworkImage(networkPhoto)
                              : const AssetImage('assets/image/logo.png') as ImageProvider),
                    ),
                    if (_isUploadingPhoto)
                      Positioned.fill(
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundColor: Colors.black38,
                          child: LoadingButton(
                            size: 30.r,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20.sp),
                    ),
                  ],
                ),
              ),
              30.verticalSpace,

              // Name field
              _buildLabel(context, AppStrings.fullName),
              10.verticalSpace,
              CustomTextField(
                controller: _nameController,
                hintText: AppStrings.enterNameHint,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return AppStrings.pleaseEnterName;
                  if (v.trim().length < 2) return AppStrings.nameTooShort;
                  return null;
                },
              ),
              20.verticalSpace,

              // Phone field (read-only)
              _buildLabel(context, AppStrings.phoneNumber),
              10.verticalSpace,
              CustomTextField(
                controller: TextEditingController(text: user?.phone ?? ''),
                hintText: AppStrings.phoneNumber,
                enabled: false,
                fillColor: colors.containerBackground,
              ),
              20.verticalSpace,

              // Email field
              _buildLabel(context, AppStrings.email),
              10.verticalSpace,
              CustomTextField(
                controller: _emailController,
                hintText: 'example@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    final emailRegex = RegExp(r'^[\w\-.]+@([\w\-]+\.)+[\w]{2,4}$');
                    if (!emailRegex.hasMatch(v)) return AppStrings.emailInvalid;
                  }
                  return null;
                },
              ),
              40.verticalSpace,

              if (isLoading)
                const LoadingButton()
              else
                CustomAppButton(
                  text: AppStrings.saveChanges,
                  onPressed: _save,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String label) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        label,
        style: AppTextStyles.text14w600(color: AppColors(context).textPrimary),
      ),
    );
  }
}
