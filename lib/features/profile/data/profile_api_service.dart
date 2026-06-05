// lib/features/profile/data/profile_api_service.dart

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/auth/data/models/auth_models.dart';

part 'profile_api_service.g.dart';

@riverpod
ProfileApiService profileApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ProfileApiService(dio);
}

class ProfileApiService {
  final Dio _dio;

  ProfileApiService(this._dio);

  /// Fetch the authenticated user's profile.
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

  /// Update the authenticated user's profile.
  Future<ApiResult<ApiResponse<UserDto>>> updateProfile({
    String? name,
    String? email,
    String? address,
    String? photo,
    String? description,
    LocationModel? location,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'address': address,
        'photo': photo,
        'description': description,
        'location': location?.toJson() ?? {},
      };

      final response = await _dio.put(
        ApiConstants.updateProfile,
        data: data,
      );
      final apiResponse = ApiResponse<UserDto>.fromJson(
        response.data,
        (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Upload a profile photo and return the public URL.
  Future<ApiResult<String>> uploadProfilePhoto(MultipartFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
        'type': 0,
      });
      final response = await _dio.post(
        ApiConstants.streamPublic,
        data: formData,
      );
      final success = response.data['success'] as bool? ?? false;
      final result = response.data['result'] as String?;
      if (success && result != null) {
        return ApiResult.success('${ApiConstants.streamUrl}$result');
      } else {
        return ApiResult.failure(handleError(
          Exception(response.data['message'] ?? 'فشل رفع الصورة'),
        ));
      }
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
