// lib/features/auth/data/auth_api_service.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/core/error/app_error.dart';
import 'models/auth_models.dart';

part 'auth_api_service.g.dart';

@riverpod
AuthApiService authApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthApiService(dio);
}

class AuthApiService {
  final Dio _dio;

  AuthApiService(this._dio);

  /// Authenticate a user with phone and password.
  Future<ApiResult<ApiResponse<TokenDto>>> login({
    required String phone,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'identifier': phone, 'password': password},
      );

      final apiResponse = ApiResponse<TokenDto>.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Authenticate a user using Google authentication token.
  Future<ApiResult<ApiResponse<TokenDto>>> googleAuth({
    required String idToken,
    required int role,
  }) async {
    try {
      final response = await _dio.post(
        'users/google-auth',
        data: {
          'idToken': idToken,
          'role': role,
        },
      );

      final apiResponse = ApiResponse<TokenDto>.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Register a new user account (Customer or Driver).
  Future<ApiResult<ApiResponse<TokenDto>>> signup({
    required String phone,
    required String name,
    required String password,
    required String confirmedPassword,
    required int role, // 0: customer, 1: driver
    String? email,
    String? photo,
    String? address,
    LocationModel? location,
    String? description,
  }) async {
    try {
      String? cleanPhoto = photo;
      if (cleanPhoto != null && cleanPhoto.startsWith(ApiConstants.streamUrl)) {
        cleanPhoto = cleanPhoto.substring(ApiConstants.streamUrl.length);
      }

      final response = await _dio.post(
        ApiConstants.signup,
        data: {
          'phone': phone,
          'name': name,
          'password': password,
          'confirmedPassword': confirmedPassword,
          'role': role,
          'email': email,
          'photo': cleanPhoto,
          'address': address,
          if (location != null) 'location': location.toJson(),
          'description': description,
        },
      );

      final apiResponse = ApiResponse<TokenDto>.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Upload a public profile image for registration
  Future<ApiResult<String>> uploadProfileImage(MultipartFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
        'type': 1, // FormPart matching type=1
      });
      final response = await _dio.post(
        ApiConstants.streamPublic,
        data: formData,
      );
      final success = response.data['success'] as bool? ?? false;
      final result = response.data['result'] as String?;
      if (success && result != null) {
        return ApiResult.success("${ApiConstants.streamUrl}$result");
      } else {
        return ApiResult.failure(
          GenericError(
            message: response.data['message'] ?? "فشل رفع الصورة الشخصية",
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Sends a verification OTP code to the user's phone.
  /// type: 0 = ResetPassword, 1 = Register, 2 = Recover
  Future<ApiResult<ApiResponse<SendOTPResult>>> sendOtp({
    required String phone,
    required int type,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.sendOtp,
        data: {'phone': phone, 'type': type},
      );

      final apiResponse = ApiResponse<SendOTPResult>.fromJson(
        response.data,
        (json) => SendOTPResult.fromJson(json as Map<String, dynamic>),
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Verifies the OTP code received on the user's phone.
  Future<ApiResult<ApiResponse<Map<String, dynamic>>>> verifyOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.verifyOtp,
        data: {'phone': phone, 'code': code},
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch authenticated user's profile details.
  Future<ApiResult<ApiResponse<UserDto>>> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);

      final apiResponse = ApiResponse<UserDto>.fromJson(
        response.data,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Changes the user's password (used in forgot password flow).
  Future<ApiResult<ApiResponse<Map<String, dynamic>>>> changePassword({
    required String token,
    required String newPassword,
    required String confirmedNewPassword,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.resetPassword,
        data: {
          'token': token,
          'newPassword': newPassword,
          'confirmedNewPassword': confirmedNewPassword,
        },
      );

      final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
        response.data,
        (json) => json as Map<String, dynamic>,
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Logs out the user and invalidates the session on the backend.
  Future<ApiResult<ApiResponse<void>>> logout() async {
    try {
      final response = await _dio.delete(ApiConstants.logout);

      final apiResponse = ApiResponse<void>.fromJson(response.data, (_) {});

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Register a new Captain/Delivery account with full delivery-specific data.
  Future<ApiResult<ApiResponse<TokenDto>>> captainSignup({
    required String phone,
    required String name,
    required String password,
    required String confirmedPassword,
    String? email,
    String? photo,
    String? description,
    required int vehicleType,
    required String nationalIdNumber,
    required String nationalIdFrontImage,
    required String nationalIdBackImage,
    required String drivingLicenseNumber,
    required String drivingLicenseImage,
    required String walletNumber,
    required String walletOwnerName,
    required int walletType,
    required int availability,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.captainSignup,
        data: {
          'phone': phone,
          'name': name,
          'password': password,
          'confirmedPassword': confirmedPassword,
          'email': email,
          'photo': photo,
          'description': description,
          'vehicleType': vehicleType,
          'nationalIdNumber': nationalIdNumber,
          'nationalIdFrontImage': nationalIdFrontImage,
          'nationalIdBackImage': nationalIdBackImage,
          'drivingLicenseNumber': drivingLicenseNumber,
          'drivingLicenseImage': drivingLicenseImage,
          'walletNumber': walletNumber,
          'walletOwnerName': walletOwnerName,
          'walletType': walletType,
          'availability': availability,
        },
      );

      final apiResponse = ApiResponse<TokenDto>.fromJson(
        response.data,
        (json) => TokenDto.fromJson(json as Map<String, dynamic>),
      );

      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Upload a private document image (national ID, driving license, etc.)
  Future<ApiResult<String>> uploadDocumentImage(MultipartFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
        'type': 1, // private type
      });
      final response = await _dio.post(
        ApiConstants.stream,
        data: formData,
      );
      final success = response.data['success'] as bool? ?? false;
      final result = response.data['result'] as String?;
      if (success && result != null) {
        return ApiResult.success(result);
      } else {
        return ApiResult.failure(
          GenericError(
            message: response.data['message'] ?? 'فشل رفع الصورة',
          ),
        );
      }
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
