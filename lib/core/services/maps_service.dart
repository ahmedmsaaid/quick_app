import 'dart:convert';
import 'package:base_app/core/localizations/app_strings.g.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get formattedDistance {
    if (distanceMeters >= 1000) {
      return '${(distanceMeters / 1000).toStringAsFixed(1)} كم (طريق)';
    } else if (distanceMeters > 0) {
      return '${distanceMeters.toStringAsFixed(0)} متر (طريق)';
    }
    return '';
  }

  String get formattedDuration {
    final mins = (durationSeconds / 60).round();
    if (mins >= 60) {
      final hours = mins ~/ 60;
      final remMins = mins % 60;
      return '$hours ساعة و $remMins دقيقة';
    } else if (mins > 0) {
      return '$mins دقيقة قيادة';
    }
    return '';
  }
}

class MapService {
  static const defaultCenter = LatLng(33.3152, 44.3661);
  static const double defaultZoom = 12.0;

  static final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ),
  );

  static final Map<String, RouteResult> _routeCache = {};

  /// Removes cached routes whose START point is near [newStart] (driver moved)
  static void invalidateRouteCache(LatLng newStart) {
    final prefix = '${newStart.latitude.toStringAsFixed(3)},${newStart.longitude.toStringAsFixed(3)}';
    _routeCache.removeWhere((key, _) => key.startsWith(prefix.substring(0, prefix.length - 1)));
    debugPrint('🗑️ Route cache invalidated near $prefix (${_routeCache.length} entries remaining)');
  }

  static final List<String> _osrmEndpoints = [
    'https://router.project-osrm.org/route/v1/driving',
    'https://routing.openstreetmap.de/routed-car/route/v1/driving',
  ];

  /// Fetches real driving road route using Valhalla (primary) or OSRM (fallback)
  static Future<RouteResult?> getDrivingRoute(LatLng start, LatLng end) async {
    if (start.latitude == 0 || start.longitude == 0 || end.latitude == 0 || end.longitude == 0) {
      return null;
    }

    final distanceMeters = calculateDistance(start, end) * 1000;
    if (distanceMeters < 5) {
      return RouteResult(points: [start, end], distanceMeters: distanceMeters, durationSeconds: 0);
    }

    final cacheKey =
        '${start.latitude.toStringAsFixed(4)},${start.longitude.toStringAsFixed(4)}->${end.latitude.toStringAsFixed(4)},${end.longitude.toStringAsFixed(4)}';

    if (_routeCache.containsKey(cacheKey)) {
      return _routeCache[cacheKey];
    }

    // ── 1. Try Valhalla (most reliable free routing API) ────────────────────
    try {
      final result = await _fetchValhallaRoute(start, end, distanceMeters);
      if (result != null) {
        _routeCache[cacheKey] = result;
        return result;
      }
    } catch (e) {
      debugPrint('Valhalla routing error: $e');
    }

    // ── 2. Fallback to OSRM demo servers ────────────────────────────────────
    final osrmOptions = Options(
      headers: {
        'User-Agent':
            'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
        'Accept': 'application/json',
      },
    );

    for (final baseUrl in _osrmEndpoints) {
      try {
        final url =
            '$baseUrl/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson&steps=false';

        final response = await _dio.get(url, options: osrmOptions);
        if (response.statusCode == 200 && response.data != null) {
          final data = response.data is String ? jsonDecode(response.data) : response.data;
          if (data['code'] == 'Ok' && data['routes'] != null && (data['routes'] as List).isNotEmpty) {
            final route = data['routes'][0];
            final double dist = (route['distance'] as num).toDouble();
            final double dur = (route['duration'] as num).toDouble();
            final geometry = route['geometry'];
            final coordinates = geometry['coordinates'] as List;

            if (coordinates.length >= 2) {
              final points = coordinates.map<LatLng>((coord) {
                final lng = (coord[0] as num).toDouble();
                final lat = (coord[1] as num).toDouble();
                return LatLng(lat, lng);
              }).toList();

              debugPrint('✅ OSRM route: ${points.length} pts via $baseUrl');
              final result = RouteResult(points: points, distanceMeters: dist, durationSeconds: dur);
              _routeCache[cacheKey] = result;
              return result;
            }
          }
        }
      } catch (e) {
        debugPrint('OSRM endpoint ($baseUrl) error: $e');
      }
    }

    debugPrint('⚠️ All routing providers failed. Using straight line.');
    return RouteResult(
      points: [start, end],
      distanceMeters: distanceMeters,
      durationSeconds: (distanceMeters / 6.94).roundToDouble(),
    );
  }

  /// Fetches route from Valhalla routing engine (free, OpenStreetMap-based)
  static Future<RouteResult?> _fetchValhallaRoute(LatLng start, LatLng end, double fallbackDistance) async {
    const url = 'https://valhalla.openstreetmap.de/route';

    final body = {
      'locations': [
        {'lon': start.longitude, 'lat': start.latitude},
        {'lon': end.longitude, 'lat': end.latitude},
      ],
      'costing': 'auto',
      'directions_options': {'units': 'km'},
      'shape_match': 'walk_or_snap',
    };

    final response = await _dio.post(url, data: body);

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data is String ? jsonDecode(response.data) : response.data;

      final trip = data['trip'];
      if (trip == null) return null;

      final legs = trip['legs'] as List?;
      if (legs == null || legs.isEmpty) return null;

      // Decode the encoded polyline from Valhalla
      final encodedShape = trip['legs'][0]['shape'] as String?;
      if (encodedShape == null || encodedShape.isEmpty) return null;

      final points = _decodePolyline(encodedShape, precision: 6);

      final summary = trip['summary'];
      final double dist = ((summary?['length'] as num?)?.toDouble() ?? fallbackDistance / 1000) * 1000;
      final double dur = ((summary?['time'] as num?)?.toDouble() ?? (fallbackDistance / 6.94));

      debugPrint('✅ Valhalla route: ${points.length} pts, ${(dist / 1000).toStringAsFixed(1)} km');

      return RouteResult(points: points, distanceMeters: dist, durationSeconds: dur);
    }

    return null;
  }

  /// Decode a Google-encoded polyline string to a list of LatLng points
  static List<LatLng> _decodePolyline(String encoded, {int precision = 5}) {
    final List<LatLng> points = [];
    int index = 0, lat = 0, lng = 0;
    final factor = _pow10(precision);

    while (index < encoded.length) {
      int result = 1, shift = 0, b;
      do {
        b = encoded.codeUnitAt(index++) - 63 - 1;
        result += b << shift;
        shift += 5;
      } while (b >= 0x1f);
      lat += (result & 1) != 0 ? (~result >> 1) : (result >> 1);

      result = 1;
      shift = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63 - 1;
        result += b << shift;
        shift += 5;
      } while (b >= 0x1f);
      lng += (result & 1) != 0 ? (~result >> 1) : (result >> 1);

      points.add(LatLng(lat / factor, lng / factor));
    }
    return points;
  }

  static double _pow10(int n) {
    double result = 1.0;
    for (int i = 0; i < n; i++) {
      result *= 10;
    }
    return result;
  }

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
