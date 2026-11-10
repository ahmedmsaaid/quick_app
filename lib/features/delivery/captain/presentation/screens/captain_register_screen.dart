import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:base_app/core/providers/image_picker_provider.dart';
import 'package:base_app/core/routes/app_routes.dart';
import 'package:base_app/core/styles/app_colors.dart';
import 'package:base_app/core/utils/extensions.dart';
import 'package:base_app/core/widgets/custom_toast.dart';
import 'package:base_app/features/delivery/captain/presentation/riverpod/captain_register_provider.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_register_bottom_bar_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_register_header_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_register_page1_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_register_page2_widget.dart';
import 'package:base_app/features/delivery/captain/presentation/widgets/captain_register_page3_widget.dart';

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
  final _invitationCodeCtrl = TextEditingController();
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
    _invitationCodeCtrl.dispose();
    _nationalIdCtrl.dispose();
    _licenseNumCtrl.dispose();
    _walletNumCtrl.dispose();
    _walletOwnerCtrl.dispose();
    super.dispose();
  }

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = ref.read(captainRegisterProvider.notifier);
    final state = ref.read(captainRegisterProvider);

    if (state.isAnyUploading) {
      CustomToast.warning(context, AppStrings.waitUploadImagesMsg);
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
      invitationCode: _invitationCodeCtrl.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    final colors = AppColors(context);
    final regState = ref.watch(captainRegisterProvider);

    ref.listen(captainRegisterProvider, (_, next) {
      if (next.status == CaptainRegisterStatus.error &&
          next.errorMessage != null) {
        CustomToast.error(context, next.errorMessage!);
        ref.read(captainRegisterProvider.notifier).resetError();
      }
    });

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Column(
          children: [
            CaptainRegisterHeaderWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
              onBack: () {
                if (_currentPage > 0) {
                  _prevPage();
                } else {
                  Navigator.pop(context);
                }
              },
            ),
            LinearProgressIndicator(
              value: (_currentPage + 1) / _totalPages,
              backgroundColor: colors.border,
              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
              minHeight: 3,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    CaptainRegisterPage1Widget(
                      nameCtrl: _nameCtrl,
                      phoneCtrl: _phoneCtrl,
                      emailCtrl: _emailCtrl,
                      passwordCtrl: _passwordCtrl,
                      confirmPwCtrl: _confirmPwCtrl,
                      descriptionCtrl: _descriptionCtrl,
                      invitationCodeCtrl: _invitationCodeCtrl,
                      profileImage: _profileImage,
                      selectedVehicle: _selectedVehicle,
                      state: regState,
                      onPickProfilePhoto: () => _pickAndUpload(
                        fieldName: 'profilePhoto',
                        isPublic: true,
                        onPicked: (f) => setState(() => _profileImage = f),
                      ),
                      onCountryChanged: (code) => _countryCode = code,
                      onVehicleChanged: (v) =>
                          setState(() => _selectedVehicle = v),
                    ),
                    CaptainRegisterPage2Widget(
                      nationalIdCtrl: _nationalIdCtrl,
                      licenseNumCtrl: _licenseNumCtrl,
                      nationalIdFront: _nationalIdFront,
                      nationalIdBack: _nationalIdBack,
                      drivingLicense: _drivingLicense,
                      state: regState,
                      onPickNationalIdFront: () => _pickAndUpload(
                        fieldName: 'nationalIdFront',
                        isPublic: false,
                        onPicked: (f) =>
                            setState(() => _nationalIdFront = f),
                      ),
                      onPickNationalIdBack: () => _pickAndUpload(
                        fieldName: 'nationalIdBack',
                        isPublic: false,
                        onPicked: (f) =>
                            setState(() => _nationalIdBack = f),
                      ),
                      onPickDrivingLicense: () => _pickAndUpload(
                        fieldName: 'drivingLicense',
                        isPublic: false,
                        onPicked: (f) => setState(() => _drivingLicense = f),
                      ),
                    ),
                    CaptainRegisterPage3Widget(
                      walletNumCtrl: _walletNumCtrl,
                      walletOwnerCtrl: _walletOwnerCtrl,
                      selectedWallet: _selectedWallet,
                      selectedAvailability: _selectedAvailability,
                      selectedVehicle: _selectedVehicle,
                      state: regState,
                      onWalletChanged: (w) =>
                          setState(() => _selectedWallet = w),
                      onAvailabilityChanged: (a) =>
                          setState(() => _selectedAvailability = a),
                    ),
                  ],
                ),
              ),
            ),
            CaptainRegisterBottomBarWidget(
              currentPage: _currentPage,
              totalPages: _totalPages,
              state: regState,
              onNext: _nextPage,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
