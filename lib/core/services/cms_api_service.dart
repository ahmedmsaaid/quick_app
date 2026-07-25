import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/network/api_constants.dart';
import 'package:base_app/core/network/dio_factory.dart';
import 'package:base_app/core/models/cms_models.dart';

final cmsApiServiceProvider = Provider<CmsApiService>((ref) {
  return CmsApiService(ref.read(dioProvider));
});

class CmsApiService {
  final Dio _dio;

  CmsApiService(this._dio);

  Future<CmsPolicyResponse?> getPolicies() async {
    try {
      final response = await _dio.get(ApiConstants.policies);
      final data = response.data;
      if (data != null && data['result'] != null) {
        return CmsPolicyResponse.fromJson(data['result']);
      }
    } catch (_) {}
    return null;
  }

  Future<CmsAboutUsResponse?> getAboutUs() async {
    try {
      final response = await _dio.get(ApiConstants.aboutUs);
      final data = response.data;
      if (data != null && data['result'] != null) {
        return CmsAboutUsResponse.fromJson(data['result']);
      }
    } catch (_) {}
    return null;
  }

  Future<CmsContactUsResponse?> getContactUs() async {
    try {
      final response = await _dio.get(ApiConstants.contactUs);
      final data = response.data;
      if (data != null && data['result'] != null) {
        return CmsContactUsResponse.fromJson(data['result']);
      }
    } catch (_) {}
    return null;
  }
}
