import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// MapService handles all map-related operations.
/// 
/// Strategy:
/// 1. Use Google Maps for visual rendering (Widget).
/// 2. Use Free APIs (like OpenStreetMap/Nominatim) for Geocoding and Search to save costs.
class MapService {
  static const String googleMapsApiKey = "YOUR_GOOGLE_MAPS_API_KEY_HERE";

  // --- Visuals (Google Maps) ---
  
  static CameraPosition getInitialCameraPosition() {
    // Default to Baghdad/Iraq center for Quick App
    return const CameraPosition(
      target: LatLng(33.3152, 44.3661),
      zoom: 12,
    );
  }

  // --- Free Alternatives (OpenStreetMap / Nominatim) ---

  /// Search for a place by name using OpenStreetMap (Free)
  static Future<List<dynamic>> searchPlacesFree(String query) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1');
    
    try {
      final response = await http.get(url, headers: {'User-Agent': 'QuickApp'});
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print('Map Search Error: $e');
    }
    return [];
  }

  /// Get address from Coordinates using OpenStreetMap (Free)
  static Future<String> getAddressFromCoordsFree(double lat, double lng) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json');
    
    try {
      final response = await http.get(url, headers: {'User-Agent': 'QuickApp'});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? AppStrings.unknownAddressLabel;
      }
    } catch (e) {
      print('Geocoding Error: $e');
    }
    return AppStrings.failedToDetermineAddress;
  }

  /// Calculate distance between two points (Simple Mathematical Haversine) - Free
  static double calculateDistance(LatLng start, LatLng end) {
    // Logic for straight line distance calculation
    return 0.0; // Placeholder for logic
  }
}
