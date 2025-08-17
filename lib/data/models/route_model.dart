import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/route_entity.dart';

class RouteModel extends RouteEntity {
  const RouteModel({
    required super.polylinePoints,
    required super.bounds,
    required super.distance,
    required super.duration,
  });

  factory RouteModel.fromDirectionsApi(Map<String, dynamic> json) {
    if ((json['routes'] as List?)?.isEmpty ?? true) {
      throw Exception('No route found in Routes API response');
    }

    final routeData = Map<String, dynamic>.from(json['routes'][0]);
    final viewport = routeData['viewport'];
    if (viewport == null) {
      throw Exception('Viewport data is missing in the API response');
    }
    final bounds = LatLngBounds(
      southwest: LatLng(viewport['low']['latitude'], viewport['low']['longitude']),
      northeast: LatLng(viewport['high']['latitude'], viewport['high']['longitude']),
    );

    final distanceMeters = routeData['distanceMeters'] as int? ?? 0;
    final distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
    
    final durationString = routeData['duration'] as String? ?? '0s';
    final seconds = int.tryParse(durationString.replaceAll('s', '')) ?? 0;
    final durationText = '${(seconds / 60).ceil()} phút'; 

    // ======================= LOGIC PARSE MỚI =======================
    // Lấy ra mảng tọa độ trực tiếp
    final coordinatesJson = routeData['polyline']?['geoJsonLinestring']?['coordinates'] as List<dynamic>? ?? [];

    // Chuyển đổi mảng [lon, lat] thành danh sách LatLng(lat, lon)
    final points = coordinatesJson.map((coordPair) {
      // GeoJSON có định dạng [longitude, latitude]
      final lon = (coordPair[0] as num).toDouble();
      final lat = (coordPair[1] as num).toDouble();
      // Constructor của LatLng là (latitude, longitude)
      return LatLng(lat, lon);
    }).toList();
    // =============================================================

    return RouteModel(
      polylinePoints: points,
      bounds: bounds,
      distance: distanceText,
      duration: durationText,
    );
  }
}