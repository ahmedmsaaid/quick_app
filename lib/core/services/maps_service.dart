import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// MapService handles all map-related operations using OpenStreetMap / Nominatim.
class MapService {
  static const defaultCenter = LatLng(33.3152, 44.3661);
  static const double defaultZoom = 12.0;

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {'User-Agent': 'QuickApp'},
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Search for a place by name using OpenStreetMap (Free)
  static Future<List<dynamic>> searchPlacesFree(String query) async {
    final url =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data as List<dynamic>;
        }
      }
    } catch (e) {
      debugPrint('Map Search Error: $e');
    }
    return [];
  }

  /// Get address from Coordinates using OpenStreetMap (Free)
  static Future<String> getAddressFromCoordsFree(
      double lat, double lng) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json';

    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map) {
          return data['display_name'] ?? AppStrings.unknownAddressLabel;
        }
      }
    } catch (e) {
      debugPrint('Geocoding Error: $e');
    }
    return AppStrings.failedToDetermineAddress;
  }

  /// Calculate distance between two points in kilometers
  static double calculateDistance(LatLng start, LatLng end) {
    const Distance distance = Distance();
    return distance.as(LengthUnit.Kilometer, start, end);
  }
}
