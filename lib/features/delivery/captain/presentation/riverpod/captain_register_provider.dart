import 'dart:io';

import 'package:dio/dio.dart' as dio_pkg;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:base_app/features/customer/profile/presentation/riverpod/profile_provider.dart';

import '../../../../shared/auth/data/auth_api_service.dart' show authApiServiceProvider;

part 'captain_register_provider.g.dart';

// ─── Enums ──────────────────────────────────────────────────────────────────

enum CaptainRegisterStatus { initial, loading, success, error }

enum VehicleType {
  bicycle(1, 'دراجة هوائية', '🚲'),
  motorcycle(2, 'دراجة نارية', '🏍️'),
  car(3, 'سيارة', '🚗');

  final int value;
  final String label;
  final String emoji;
  const VehicleType(this.value, this.label, this.emoji);
}

enum WalletType {
  vodafoneCash(1, 'فودافون كاش'),
  orangeCash(2, 'أورنج كاش'),
  etisalatCash(3, 'اتصالات كاش'),
  weCash(4, 'WE كاش'),
  instaPay(5, 'InstaPay');

  final int value;
  final String label;
  const WalletType(this.value, this.label);
}

enum WorkAvailability {
  partTime(1, 'دوام جزئي'),
  fullTime(2, 'دوام كامل');

  final int value;
  final String label;
  const WorkAvailability(this.value, this.label);
}

// ─── State ───────────────────────────────────────────────────────────────────

class CaptainRegisterState {
  final CaptainRegisterStatus status;
  final String? errorMessage;

  // Upload states: key = field name, value = uploaded key/url
  final Map<String, String?> uploadedImages; // field -> uploaded key
  final Map<String, bool> uploadingImages;   // field -> isUploading

  const CaptainRegisterState({
    this.status = CaptainRegisterStatus.initial,
    this.errorMessage,
    this.uploadedImages = const {},
    this.uploadingImages = const {},
  });

  CaptainRegisterState copyWith({
    CaptainRegisterStatus? status,
    String? errorMessage,
    Map<String, String?>? uploadedImages,
    Map<String, bool>? uploadingImages,
  }) {
    return CaptainRegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedImages: uploadedImages ?? this.uploadedImages,
      uploadingImages: uploadingImages ?? this.uploadingImages,
    );
  }

  bool get isAnyUploading => uploadingImages.values.any((v) => v);
  String? uploadedKey(String field) => uploadedImages[field];
  bool isUploading(String field) => uploadingImages[field] ?? false;
}

// ─── Notifier ────────────────────────────────────────────────────────────────

@riverpod
class CaptainRegisterNotifier extends _$CaptainRegisterNotifier {
  @override
  CaptainRegisterState build() => const CaptainRegisterState();

  /// Upload an image and store its key under [fieldName].
  Future<bool> uploadImage({
    required String fieldName,
    required File file,
    required bool isPublic,
  }) async {
    final uploading = Map<String, bool>.from(state.uploadingImages);
    uploading[fieldName] = true;
    state = state.copyWith(uploadingImages: uploading);

    final filename = file.path.split('/').last.split('\\').last;
    final multipart = await dio_pkg.MultipartFile.fromFile(
      file.path,
      filename: filename,
    );

    final service = ref.read(authApiServiceProvider);
    final result = isPublic
        ? await service.uploadProfileImage(multipart)
        : await service.uploadDocumentImage(multipart);

    final updated = Map<String, String?>.from(state.uploadedImages);
    final updatedUploading = Map<String, bool>.from(state.uploadingImages);
    updatedUploading[fieldName] = false;

    return result.when(
      success: (key) {
        updated[fieldName] = key;
        state = state.copyWith(
          uploadedImages: updated,
          uploadingImages: updatedUploading,
        );
        return true;
      },
      failure: (error) {
        state = state.copyWith(
          uploadingImages: updatedUploading,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  /// Submit the full captain registration form.
  Future<bool> register({
    required String countryCode,
    required String rawPhone,
    required String name,
    required String password,
    required String confirmedPassword,
    String? email,
    String? description,
    required VehicleType vehicleType,
    required String nationalIdNumber,
    required String drivingLicenseNumber,
    required String walletNumber,
    required String walletOwnerName,
    required WalletType walletType,
    required WorkAvailability availability,
  }) async {
    // Validate all images are uploaded
    final nationalIdFront = state.uploadedKey('nationalIdFront');
    final nationalIdBack = state.uploadedKey('nationalIdBack');
    final drivingLicense = state.uploadedKey('drivingLicense');
    final profilePhoto = state.uploadedKey('profilePhoto');

    if (nationalIdFront == null || nationalIdBack == null || drivingLicense == null) {
      state = state.copyWith(
        status: CaptainRegisterStatus.error,
        errorMessage: 'يرجى رفع جميع المستندات المطلوبة',
      );
      return false;
    }

    // uploadProfileImage returns full URL, but API expects only the relative key.
    // Strip the streamUrl prefix to get the raw key (e.g. "File/uuid.png")
    String? photoKey = profilePhoto;
    if (photoKey != null && photoKey.startsWith(ApiConstants.streamUrl)) {
      photoKey = photoKey.substring(ApiConstants.streamUrl.length);
    }

    state = state.copyWith(status: CaptainRegisterStatus.loading);

    var normalizedPhone = rawPhone.trim();
    if (normalizedPhone.startsWith('0')) {
      normalizedPhone = normalizedPhone.substring(1);
    }
    final fullPhone = '+$countryCode$normalizedPhone';

    await CacheHelper.setString('temp_phone', fullPhone);

    final service = ref.read(authApiServiceProvider);
    final result = await service.captainSignup(
      phone: fullPhone,
      name: name,
      password: password,
      confirmedPassword: confirmedPassword,
      email: email?.isEmpty == true ? null : email,
      photo: photoKey,
      description: description?.isEmpty == true ? null : description,
      vehicleType: vehicleType.value,
      nationalIdNumber: nationalIdNumber,
      nationalIdFrontImage: nationalIdFront,
      nationalIdBackImage: nationalIdBack,
      drivingLicenseNumber: drivingLicenseNumber,
      drivingLicenseImage: drivingLicense,
      walletNumber: walletNumber,
      walletOwnerName: walletOwnerName,
      walletType: walletType.value,
      availability: availability.value,
    );

    return result.when(
      success: (response) async {
        if (response.success && response.result != null) {
          final tokenDto = response.result!;
          if (tokenDto.accessToken != null) {
            await CacheHelper.setString('tempToken', tokenDto.accessToken!);
          }
          await CacheHelper.setInt('userRole', 3);
          ref.invalidate(profileProvider);
          state = state.copyWith(status: CaptainRegisterStatus.success);
          return true;
        } else {
          state = state.copyWith(
            status: CaptainRegisterStatus.error,
            errorMessage: response.message ?? 'فشل التسجيل',
          );
          return false;
        }
      },
      failure: (error) {
        state = state.copyWith(
          status: CaptainRegisterStatus.error,
          errorMessage: error.message,
        );
        return false;
      },
    );
  }

  void resetError() {
    state = state.copyWith(status: CaptainRegisterStatus.initial);
  }
}
