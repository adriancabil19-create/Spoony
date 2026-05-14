import 'dart:math';
import 'api_service.dart';

class DistanceService {
  static double _radians(double degree) => degree * pi / 180;

  // Haversine straight-line distance (offline, no API key needed)
  static double calculateHaversineDistance(
    double lat1, double lng1, double lat2, double lng2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _radians(lat2 - lat1);
    final dLng = _radians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_radians(lat1)) * cos(_radians(lat2)) *
            sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double calculateTotalRouteDistance(List<Map<String, double>> coordinates) {
    if (coordinates.length < 2) return 0;
    var total = 0.0;
    for (var i = 0; i < coordinates.length - 1; i++) {
      total += calculateHaversineDistance(
        coordinates[i]['lat']!,
        coordinates[i]['lng']!,
        coordinates[i + 1]['lat']!,
        coordinates[i + 1]['lng']!,
      );
    }
    return total;
  }

  static String estimateTravelTime(double kilometers, {String transport = 'van'}) {
    final speedKmh = transport.contains('private_sedan')
        ? 50
        : transport.contains('suv')
            ? 55
            : 42;
    final hours = kilometers / speedKmh;
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    if (h >= 1) return '${h}h ${m}m';
    return '$m min';
  }

  // Road distance via OSRM through the backend (OpenStreetMap, free)
  static Future<Map<String, dynamic>?> getRoadDistance(
    double originLat, double originLng,
    double destLat, double destLng,
  ) async {
    try {
      return await ApiService.post('/destinations/road-distance', {
        'origin': {'lat': originLat, 'lng': originLng},
        'destination': {'lat': destLat, 'lng': destLng},
      });
    } catch (_) {
      return null;
    }
  }

  // Full route calculation via backend
  static Future<Map<String, dynamic>?> getRouteInfo(
    List<Map<String, double>> coordinates,
  ) async {
    try {
      return await ApiService.post('/destinations/distance', {
        'coordinates': coordinates,
      });
    } catch (_) {
      return null;
    }
  }
}
