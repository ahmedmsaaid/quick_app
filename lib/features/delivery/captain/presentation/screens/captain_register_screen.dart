import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/providers/image_picker_provider.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/styles/app_text_style.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/widgets/custom_button.dart';
import 'package:base_app/core/widgets/custom_text_field.dart';
import 'package:base_app/core/widgets/lading_button.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_password_text_field.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_password_guidelines_widget.dart';
import 'package:base_app/features/shared/auth/presentation/widgets/custom_phone_text_field.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_register_provider.dart';

class CaptainRegisterScreen extends ConsumerStatefulWidget {
  const CaptainRegisterScreen({super.key});

  @override
  ConsumerState<CaptainRegisterScreen> createState() =>
      _CaptainRegisterScreenState();
}

class _CaptainRegisterScreenState
    extends ConsumerState<CaptainRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  static const int _totalPages = 3;

  // Controllers – Page 1: Personal Info
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  String _countryCode = '20';

  // Controllers – Page 2: Documents
  final _nationalIdCtrl = TextEditingController();
  final _licenseNumCtrl = TextEditingController();

  // Controllers – Page 3: Wallet & Availability
  final _walletNumCtrl = TextEditingController();
  final _walletOwnerCtrl = TextEditingController();

  // Selections
  VehicleType _selectedVehicle = VehicleType.motorcycle;
  WalletType _selectedWallet = WalletType.vodafoneCash;
  WorkAvailability _selectedAvailability = WorkAvailability.fullTime;

  // Local image files (preview)
  File? _profileImage;
  File? _nationalIdFront;
  File? _nationalIdBack;
  File? _drivingLicense;

  @override
  void dispose() {
    _pageController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPwCtrl.dispose();
    _descriptionCtrl.dispose();
    _nationalIdCtrl.dispose();
    _licenseNumCtrl.dispose();
    _walletNumCtrl.dispose();
    _walletOwnerCtrl.dispose();
    super.dispose();
  }

  // ─── Navigation ────────────────────────────────────────────────────────────

  void _nextPage() {
    if (!_formKey.currentState!.validate()) return;
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  // ─── Image Picker ──────────────────────────────────────────────────────────

  Future<void> _pickAndUpload({
    required String fieldName,
    required bool isPublic,
    required void Function(File) onPicked,
  }) async {
    final picker = ref.read(imagePickerServiceProvider);
    final file = await picker.pickSingleImage();
    if (file == null) return;
    onPicked(file);
    await ref.read(captainRegisterProvider.notifier).uploadImage(
          fieldName: fieldName,
          file: file,
          isPublic: isPublic,
        );
  }

  // ─── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(captainRegisterProvider.notifier);
    final state = ref.read(captainRegisterProvider);

    if (state.isAnyUploading) {
      _showSnack('يرجى الانتظار حتى تكتمل رفع الصور...', isError: false);
      return;
    }

    final success = await notifier.register(
      countryCode: _countryCode,
      rawPhone: _phoneCtrl.text.trim(),
      name: _nameCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
      confirmedPassword: _confirmPwCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      vehicleType: _selectedVehicle,
      nationalIdNumber: _nationalIdCtrl.text.trim(),
      drivingLicenseNumber: _licenseNumCtrl.text.trim(),
      walletNumber: _walletNumCtrl.text.trim(),
      walletOwnerName: _walletOwnerCtrl.text.trim(),
      walletType: _selectedWallet,
      availability: _selectedAvailability,
    );

    if (success && mounted) {
      context.pushNamed(AppRoutes.otpScreen, arguments: false);
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.orange,
    ));
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final regState = ref.watch(captainRegisterProvider);

    ref.listen(captainRegisterProvider, (_, next) {
      if (next.status == CaptainRegisterStatus.error &&
          next.errorMessage != null) {
        _showSnack(next.errorMessage!);
        ref.read(captainRegisterProvider.notifier).resetError();
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(colors),
            _buildProgressBar(colors),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPage1(colors, regState),
                    _buildPage2(colors, regState),
                    _buildPage3(colors, regState),
                  ],
                ),
              ),
            ),
            _buildBottomBar(colors, regState),
          ],
        ),
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppColors colors) {
    const titles = ['المعلومات الشخصية', 'المستندات الرسمية', 'المحفظة والتوفر'];
    const subtitles = [
      'بيانات حسابك الأساسية',
      'هوية وطنية ورخصة القيادة',
      'بيانات الدفع وجدول العمل',
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            GestureDetector(
              onTap: _prevPage,
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: colors.containerBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.arrow_back_ios_rounded,
                    size: 18.sp, color: colors.textPrimary),
              ),
            )
          else
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: colors.containerBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.close_rounded,
                    size: 18.sp, color: colors.textPrimary),
              ),
            ),
          16.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[_currentPage],
                  style: AppTextStyles.text18w700(color: colors.textPrimary),
                ),
                2.verticalSpace,
                Text(
                  subtitles[_currentPage],
                  style:
                      AppTextStyles.text12w400(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '${_currentPage + 1}/$_totalPages',
              style:
                  AppTextStyles.text12w600(color: colors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AppColors colors) {
    return LinearProgressIndicator(
      value: (_currentPage + 1) / _totalPages,
      backgroundColor: colors.border,
      valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
      minHeight: 3,
    );
  }

  // ─── Page 1: Personal Info ─────────────────────────────────────────────────

  Widget _buildPage1(AppColors colors, CaptainRegisterState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image
          Center(
            child: GestureDetector(
              onTap: () => _pickAndUpload(
                fieldName: 'profilePhoto',
                isPublic: true,
                onPicked: (f) => setState(() => _profileImage = f),
              ),
              child: Stack(
                children: [
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: colors.containerBackground,
                      border: Border.all(
                        color: state.uploadedKey('profilePhoto') != null
                            ? Colors.green
                            : state.isUploading('profilePhoto')
                                ? colors.primary
                                : colors.border,
                        width: 2.5,
                      ),
                      image: _profileImage != null
                          ? DecorationImage(
                              image: FileImage(_profileImage!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _profileImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person_add_alt_1_rounded,
                                  size: 32.sp, color: colors.textHint),
                              4.verticalSpace,
                              Text('صورة شخصية',
                                  style: AppTextStyles.text10w500(
                                      color: colors.textHint)),
                            ],
                          )
                        : null,
                  ),
                  if (state.isUploading('profilePhoto'))
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.black26, shape: BoxShape.circle),
                        child: Center(
                            child: LoadingButton(
                                size: 28.w, color: Colors.white)),
                      ),
                    ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: EdgeInsets.all(5.r),
                      decoration: BoxDecoration(
                        color: state.uploadedKey('profilePhoto') != null
                            ? Colors.green
                            : colors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: colors.background, width: 1.5),
                      ),
                      child: Icon(
                        state.uploadedKey('profilePhoto') != null
                            ? Icons.check
                            : Icons.camera_alt_rounded,
                        size: 12.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          24.verticalSpace,

          _sectionLabel(colors, 'البيانات الأساسية', Icons.person_outline),
          12.verticalSpace,

          CustomTextField(
            controller: _nameCtrl,
            hintText: AppStrings.fullName,
            prefixIcon:
                Icon(Icons.badge_outlined, color: colors.primary),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? AppStrings.pleaseEnterName : null,
          ),
          14.verticalSpace,

          CustomPhoneTextField(
            controller: _phoneCtrl,
            onCountryChanged: (c) => _countryCode = c.phoneCode,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? AppStrings.pleaseEnterPhone : null,
          ),
          14.verticalSpace,

          CustomTextField(
            controller: _emailCtrl,
            hintText: AppStrings.email,
            keyboardType: TextInputType.emailAddress,
            prefixIcon:
                Icon(Icons.email_outlined, color: colors.primary),
          ),
          14.verticalSpace,

          CustomTextField(
            controller: _descriptionCtrl,
            hintText: 'نبذة عنك (اختياري)',
            prefixIcon: Icon(Icons.info_outline, color: colors.primary),
            maxLines: 2,
          ),
          20.verticalSpace,

          _sectionLabel(colors, 'كلمة المرور', Icons.lock_outline),
          12.verticalSpace,

          CustomPasswordTextField(
            controller: _passwordCtrl,
            hintText: AppStrings.password,
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.pleaseEnterPassword;
              if (v.length < 6) return AppStrings.passwordTooShort;
              return null;
            },
          ),
          CustomPasswordGuidelinesWidget(
            controller: _passwordCtrl,
          ),
          10.verticalSpace,

          CustomPasswordTextField(
            controller: _confirmPwCtrl,
            hintText: AppStrings.confirmPassword,
            validator: (v) {
              if (v == null || v.isEmpty) return AppStrings.pleaseEnterPassword;
              if (v != _passwordCtrl.text) return AppStrings.passwordNotMatch;
              return null;
            },
          ),
          20.verticalSpace,

          _sectionLabel(colors, 'نوع المركبة', Icons.directions_car_outlined),
          12.verticalSpace,

          _buildVehicleSelector(colors),
          20.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildVehicleSelector(AppColors colors) {
    return Row(
      children: VehicleType.values.map((v) {
        final isSelected = _selectedVehicle == v;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedVehicle = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: v != VehicleType.values.last ? 8.w : 0),
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : colors.containerBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(v.emoji,
                      style: TextStyle(fontSize: 24.sp)),
                  6.verticalSpace,
                  Text(
                    v.label,
                    style: AppTextStyles.text11w600(
                      color: isSelected
                          ? Colors.white
                          : colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Page 2: Documents ─────────────────────────────────────────────────────

  Widget _buildPage2(AppColors colors, CaptainRegisterState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(colors, 'الهوية الوطنية', Icons.credit_card_outlined),
          12.verticalSpace,

          CustomTextField(
            controller: _nationalIdCtrl,
            hintText: 'رقم الهوية الوطنية',
            keyboardType: TextInputType.number,
            prefixIcon: Icon(Icons.numbers, color: colors.primary),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'يرجى إدخال رقم الهوية'
                : null,
          ),
          16.verticalSpace,

          Row(
            children: [
              Expanded(
                child: _buildDocUploadCard(
                  colors: colors,
                  label: 'الوجه الأمامي',
                  icon: Icons.credit_card,
                  fieldName: 'nationalIdFront',
                  imageFile: _nationalIdFront,
                  state: state,
                  onTap: () => _pickAndUpload(
                    fieldName: 'nationalIdFront',
                    isPublic: false,
                    onPicked: (f) =>
                        setState(() => _nationalIdFront = f),
                  ),
                ),
              ),
              12.horizontalSpace,
              Expanded(
                child: _buildDocUploadCard(
                  colors: colors,
                  label: 'الوجه الخلفي',
                  icon: Icons.credit_card_outlined,
                  fieldName: 'nationalIdBack',
                  imageFile: _nationalIdBack,
                  state: state,
                  onTap: () => _pickAndUpload(
                    fieldName: 'nationalIdBack',
                    isPublic: false,
                    onPicked: (f) =>
                        setState(() => _nationalIdBack = f),
                  ),
                ),
              ),
            ],
          ),
          24.verticalSpace,

          _sectionLabel(
              colors, 'رخصة القيادة', Icons.card_membership_outlined),
          12.verticalSpace,

          CustomTextField(
            controller: _licenseNumCtrl,
            hintText: 'رقم رخصة القيادة',
            keyboardType: TextInputType.number,
            prefixIcon:
                Icon(Icons.confirmation_number_outlined, color: colors.primary),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'يرجى إدخال رقم الرخصة'
                : null,
          ),
          16.verticalSpace,

          _buildDocUploadCard(
            colors: colors,
            label: 'صورة رخصة القيادة',
            icon: Icons.card_membership,
            fieldName: 'drivingLicense',
            imageFile: _drivingLicense,
            state: state,
            fullWidth: true,
            onTap: () => _pickAndUpload(
              fieldName: 'drivingLicense',
              isPublic: false,
              onPicked: (f) => setState(() => _drivingLicense = f),
            ),
          ),
          24.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildDocUploadCard({
    required AppColors colors,
    required String label,
    required IconData icon,
    required String fieldName,
    required File? imageFile,
    required CaptainRegisterState state,
    required VoidCallback onTap,
    bool fullWidth = false,
  }) {
    final isUploaded = state.uploadedKey(fieldName) != null;
    final isUploading = state.isUploading(fieldName);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: fullWidth ? double.infinity : null,
        height: 120.h,
        decoration: BoxDecoration(
          color: isUploaded
              ? Colors.green.withValues(alpha: 0.08)
              : colors.containerBackground,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isUploaded
                ? Colors.green
                : isUploading
                    ? colors.primary
                    : colors.border,
            width: 1.5,
          ),
        ),
        child: imageFile != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(13.r),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(imageFile, fit: BoxFit.cover),
                    if (isUploading)
                      Container(
                        color: Colors.black45,
                        child: Center(
                            child: LoadingButton(
                                size: 30.w, color: Colors.white)),
                      ),
                    if (isUploaded)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: EdgeInsets.all(4.r),
                          decoration: const BoxDecoration(
                              color: Colors.green, shape: BoxShape.circle),
                          child: Icon(Icons.check,
                              size: 12.sp, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUploaded ? Icons.check_circle : icon,
                    size: 30.sp,
                    color: isUploaded ? Colors.green : colors.textHint,
                  ),
                  8.verticalSpace,
                  Text(
                    isUploaded ? 'تم الرفع ✓' : label,
                    style: AppTextStyles.text11w500(
                      color: isUploaded
                          ? Colors.green
                          : colors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (!isUploaded) ...[
                    4.verticalSpace,
                    Text(
                      'اضغط للرفع',
                      style: AppTextStyles.text10w400(
                          color: colors.textHint),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  // ─── Page 3: Wallet & Availability ────────────────────────────────────────

  Widget _buildPage3(AppColors colors, CaptainRegisterState state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel(colors, 'بيانات المحفظة', Icons.account_balance_wallet_outlined),
          12.verticalSpace,

          _buildWalletTypeSelector(colors),
          14.verticalSpace,

          CustomTextField(
            controller: _walletNumCtrl,
            hintText: 'رقم المحفظة',
            keyboardType: TextInputType.phone,
            prefixIcon: Icon(Icons.phone_android, color: colors.primary),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'يرجى إدخال رقم المحفظة'
                : null,
          ),
          14.verticalSpace,

          CustomTextField(
            controller: _walletOwnerCtrl,
            hintText: 'اسم صاحب المحفظة',
            prefixIcon: Icon(Icons.person_pin_outlined, color: colors.primary),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'يرجى إدخال اسم صاحب المحفظة'
                : null,
          ),
          24.verticalSpace,

          _sectionLabel(
              colors, 'نوع الدوام', Icons.schedule_outlined),
          12.verticalSpace,

          _buildAvailabilitySelector(colors),
          32.verticalSpace,

          // Summary card before submit
          _buildSummaryCard(colors, state),
          20.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildWalletTypeSelector(AppColors colors) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: WalletType.values.map((w) {
        final isSelected = _selectedWallet == w;
        return GestureDetector(
          onTap: () => setState(() => _selectedWallet = w),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? colors.primary
                  : colors.containerBackground,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: isSelected ? colors.primary : colors.border,
              ),
            ),
            child: Text(
              w.label,
              style: AppTextStyles.text12w600(
                color: isSelected ? Colors.white : colors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilitySelector(AppColors colors) {
    return Row(
      children: WorkAvailability.values.map((a) {
        final isSelected = _selectedAvailability == a;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedAvailability = a),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  right: a != WorkAvailability.values.last ? 10.w : 0),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary
                    : colors.containerBackground,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? colors.primary : colors.border,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    a == WorkAvailability.fullTime
                        ? Icons.access_time_filled
                        : Icons.access_time_outlined,
                    color: isSelected ? Colors.white : colors.textHint,
                    size: 24.sp,
                  ),
                  6.verticalSpace,
                  Text(
                    a.label,
                    style: AppTextStyles.text13w600(
                      color: isSelected
                          ? Colors.white
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummaryCard(AppColors colors, CaptainRegisterState state) {
    final uploaded = [
      'nationalIdFront',
      'nationalIdBack',
      'drivingLicense',
    ];
    final allDocsUploaded =
        uploaded.every((f) => state.uploadedKey(f) != null);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: allDocsUploaded
            ? Colors.green.withValues(alpha: 0.05)
            : colors.containerBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: allDocsUploaded
              ? Colors.green.withValues(alpha: 0.4)
              : colors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                allDocsUploaded ? Icons.check_circle : Icons.info_outline,
                color: allDocsUploaded ? Colors.green : colors.textSecondary,
                size: 18.sp,
              ),
              8.horizontalSpace,
              Text(
                allDocsUploaded
                    ? 'كل المستندات جاهزة!'
                    : 'حالة المستندات',
                style: AppTextStyles.text14w600(
                  color:
                      allDocsUploaded ? Colors.green : colors.textPrimary,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          _summaryRow('الهوية الوطنية (أمامي)',
              state.uploadedKey('nationalIdFront') != null, colors),
          _summaryRow('الهوية الوطنية (خلفي)',
              state.uploadedKey('nationalIdBack') != null, colors),
          _summaryRow('رخصة القيادة',
              state.uploadedKey('drivingLicense') != null, colors),
          _summaryRow(
              'المركبة: ${_selectedVehicle.label}', true, colors,
              alwaysGreen: true),
          _summaryRow(
              'محفظة: ${_selectedWallet.label}', true, colors,
              alwaysGreen: true),
          _summaryRow(
              'الدوام: ${_selectedAvailability.label}', true, colors,
              alwaysGreen: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, bool isReady, AppColors colors,
      {bool alwaysGreen = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle_outline : Icons.radio_button_unchecked,
            size: 16.sp,
            color: isReady ? Colors.green : colors.textHint,
          ),
          8.horizontalSpace,
          Text(
            label,
            style: AppTextStyles.text12w400(
              color: isReady ? colors.textPrimary : colors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(AppColors colors, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(6.r),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 16.sp, color: colors.primary),
        ),
        10.horizontalSpace,
        Text(title,
            style: AppTextStyles.text14w700(color: colors.textPrimary)),
      ],
    );
  }

  // ─── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(AppColors colors, CaptainRegisterState state) {
    final isLoading = state.status == CaptainRegisterStatus.loading ||
        state.isAnyUploading;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: isLoading
          ? const Center(child: LoadingButton())
          : CustomAppButton(
              text: _currentPage < _totalPages - 1
                  ? 'التالي'
                  : 'إنشاء الحساب',
              onPressed: _currentPage < _totalPages - 1 ? _nextPage : _submit,
            ),
    );
  }
}
