// lib/features/profile/data/profile_api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/api_result.dart';
import 'package:base_app/core/error/error_handler.dart';
import 'package:base_app/features/shared/auth/data/models/auth_models.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

part 'profile_api_service.g.dart';

@riverpod
ProfileApiService profileApiService(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ProfileApiService(dio);
}

/// Model for the application settings (deliveryFee, orderFee, etc.)
class UserSettingDto {
  final int id;
  final double orderFee;
  final double orderMinFee;
  final double orderMaxFee;
  final double deliveryFee;
  final double? deliveryMinFee;

  const UserSettingDto({
    required this.id,
    required this.orderFee,
    required this.orderMinFee,
    required this.orderMaxFee,
    required this.deliveryFee,
    this.deliveryMinFee,
  });

  factory UserSettingDto.fromJson(Map<String, dynamic> json) => UserSettingDto(
    id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    orderFee: (json['orderFee'] as num?)?.toDouble() ?? 0.0,
    orderMinFee: (json['orderMinFee'] as num?)?.toDouble() ?? 0.0,
    orderMaxFee: (json['orderMaxFee'] as num?)?.toDouble() ?? 0.0,
    deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
    deliveryMinFee: (json['deliveryMinFee'] as num?)?.toDouble(),
  );
}

/// Cached provider — fetched once and shared across screens.
final settingsProvider = FutureProvider<UserSettingDto?>((ref) async {
  final service = ref.read(profileApiServiceProvider);
  final result = await service.getSettings();
  return result.when(
    success: (response) => response?.result,
    failure: (_) => null,
  );
});

/// Provider to fetch locations for a given creatorId (e.g. vendor/restaurant branches)
final vendorLocationsProvider = FutureProvider.family<List<LocationDto>, int?>((ref, vendorId) async {
  if (vendorId == null || vendorId <= 0) return [];
  final service = ref.read(profileApiServiceProvider);
  final result = await service.getLocations(creatorId: vendorId);
  return result.when(
    success: (res) => res?.result ?? [],
    failure: (_) => [],
  );
});

/// Default fallback settings if API response is null or loading
const defaultAppSettings = UserSettingDto(
  id: 1,
  orderFee: 15.0,
  orderMinFee: 5.0,
  orderMaxFee: 50.0,
  deliveryFee: 15.0,
  deliveryMinFee: 15.0,
);

/// Calculate the service/order fee based on backend logic:
///   raw = subtotal × orderFee% ÷ 100
///   final = clamp(raw, orderMinFee, orderMaxFee)
double calcOrderFee(double subtotal, UserSettingDto settings) {
  final raw = subtotal * settings.orderFee / 100;
  final minFee = settings.orderMinFee;
  final maxFee = settings.orderMaxFee > 0 ? settings.orderMaxFee : double.infinity;
  return raw.clamp(minFee, maxFee);
}

/// Distance formula in Kilometers using Geolocator
double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  if (lat1 == 0.0 || lon1 == 0.0 || lat2 == 0.0 || lon2 == 0.0) return 0.0;
  final meters = Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  return meters / 1000.0;
}

/// Calculate delivery fee based on distance (km) and backend settings logic:
/// - If distanceKm <= 0 (unknown/not computed yet): return base deliveryFee or deliveryMinFee
/// - If distanceKm > 0: calculatedDeliveryFee = distanceKm * setting.deliveryFee
/// - final deliveryFee = max(calculatedDeliveryFee, setting.deliveryMinFee)
double calcDeliveryFee(double distanceKm, UserSettingDto settings) {
  final minDelivery = settings.deliveryMinFee ?? 0.0;
  if (distanceKm <= 0) {
    return math.max(settings.deliveryFee > 0 ? settings.deliveryFee : minDelivery, minDelivery);
  }
  final calculatedDeliveryFee = settings.deliveryFee > 0
      ? distanceKm * settings.deliveryFee
      : settings.deliveryFee;
  return math.max(calculatedDeliveryFee, minDelivery);
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
      String? cleanPhoto = photo;
      if (cleanPhoto != null && cleanPhoto.startsWith(ApiConstants.streamUrl)) {
        cleanPhoto = cleanPhoto.substring(ApiConstants.streamUrl.length);
      }

      final Map<String, dynamic> data = {
        'name': name,
        'email': email,
        'address': address,
        'photo': cleanPhoto,
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
        'type': 1,
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

  /// Change the authenticated user's password.
  Future<ApiResult<ApiResponse<void>>> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmedNewPassword,
  }) async {
    try {
      final response = await _dio.patch(
        ApiConstants.changePassword,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
          'confirmedNewPassword': confirmedNewPassword,
        },
      );
      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Add a new location for the authenticated user.
  Future<ApiResult<ApiResponse<LocationDto>>> addLocation({
    required String address,
    required double latitude,
    required double longitude,
    required bool base,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.locations,
        data: {
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'base': base,
        },
      );
      final apiResponse = ApiResponse<LocationDto>.fromJson(
        response.data,
        (json) => LocationDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Get user locations.
  Future<ApiResult<ApiResponse<List<LocationDto>>>> getLocations({int? creatorId}) async {
    try {
      final Map<String, dynamic> requestData = {
        'pageNumber': 1,
        'pageSize': 100,
        'enablePagination': true,
      };
      if (creatorId != null) {
        requestData['filters'] = {"creatorId":creatorId};
      }

      final response = await _dio.patch(
        ApiConstants.locations,
        data: requestData,
      );
      final apiResponse = ApiResponse<List<LocationDto>>.fromJson(
        response.data,
        (json) {
          if (json is List) {
            return json.map((e) => LocationDto.fromJson(e as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Update user location information.
  Future<ApiResult<ApiResponse<LocationDto>>> updateLocation({
    required int id,
    required String address,
    required double latitude,
    required double longitude,
    required bool base,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.locations,
        data: {
          'id': id,
          'address': address,
          'latitude': latitude,
          'longitude': longitude,
          'base': base,
        },
      );
      final apiResponse = ApiResponse<LocationDto>.fromJson(
        response.data,
        (json) => LocationDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Delete a location by ID.
  Future<ApiResult<ApiResponse<void>>> deleteLocation(int id) async {
    try {
      final response = await _dio.delete(
        '${ApiConstants.locations}/$id',
      );
      final apiResponse = ApiResponse<void>.fromJson(
        response.data,
        (_) {},
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Get a single location by ID.
  Future<ApiResult<ApiResponse<LocationDto>>> getLocationById(int id) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.locations}/$id',
        data: {},
      );
      final apiResponse = ApiResponse<LocationDto>.fromJson(
        response.data,
        (json) => LocationDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Fetch application settings (deliveryFee, orderFee, etc.)
  Future<ApiResult<ApiResponse<UserSettingDto>>> getSettings() async {
    try {
      final response = await _dio.get(ApiConstants.settings);
      final apiResponse = ApiResponse<UserSettingDto>.fromJson(
        response.data,
        (json) => UserSettingDto.fromJson(json as Map<String, dynamic>),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }

  /// Toggle the user's active/activity status.
  Future<ApiResult<ApiResponse<bool>>> toggleActivityStatus(int userId) async {
    try {
      final response = await _dio.patch('${ApiConstants.toggleActivity}/$userId');
      final apiResponse = ApiResponse<bool>.fromJson(
        response.data,
        (json) => json is bool ? json : (json == true),
      );
      return ApiResult.success(apiResponse);
    } catch (e) {
      return ApiResult.failure(handleError(e));
    }
  }
}
