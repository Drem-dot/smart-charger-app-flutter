// lib/data/models/route_model.dart

import 'package:flutter/foundation.dart';
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
    try {
      if ((json['routes'] as List?)?.isEmpty ?? true) {
        throw Exception('No route found in Routes API response');
      }

      final routeData = Map<String, dynamic>.from(json['routes'][0]);

      // --- 1. PARSE VIEWPORT (Đã sửa & an toàn) ---
      // --- LOGIC PARSE VIEWPORT PHÒNG THỦ ---
    final viewport = routeData['viewport'];
    if (viewport == null) {
      throw Exception('Viewport data is missing in the API response');
    }

    // Hàm helper để đọc tọa độ từ một trong hai cấu trúc
    LatLng? parseLatLng(dynamic latLngJson) {
      if (latLngJson == null) return null;
      // Trường hợp 1: Có 'latLng' lồng bên trong
      if (latLngJson['latLng'] != null) {
        final nestedLatLng = latLngJson['latLng'];
        return LatLng(
          (nestedLatLng['latitude'] as num).toDouble(),
          (nestedLatLng['longitude'] as num).toDouble(),
        );
      }
      // Trường hợp 2: Không có 'latLng' lồng bên trong
      else if (latLngJson['latitude'] != null && latLngJson['longitude'] != null) {
        return LatLng(
          (latLngJson['latitude'] as num).toDouble(),
          (latLngJson['longitude'] as num).toDouble(),
        );
      }
      return null;
    }

    final southwest = parseLatLng(viewport['low']);
    final northeast = parseLatLng(viewport['high']);

    if (southwest == null || northeast == null) {
      throw Exception('Failed to parse viewport coordinates');
    }

    final bounds = LatLngBounds(southwest: southwest, northeast: northeast);
    //

      // --- 2. PARSE POLYLINE (Logic của bạn, thêm try-catch) ---
      final coordinatesJson = routeData['polyline']?['geoJsonLinestring']?['coordinates'] as List<dynamic>? ?? [];
      final List<LatLng> points = [];
      for (var coordPair in coordinatesJson) {
          try {
              // GeoJSON là [longitude, latitude]
              final lon = (coordPair[0] as num).toDouble();
              final lat = (coordPair[1] as num).toDouble();
              // LatLng là (latitude, longitude)
              points.add(LatLng(lat, lon));
          } catch (e) {
              // Bỏ qua điểm bị lỗi và log ra để debug
              debugPrint('Skipping invalid coordinate pair: $coordPair. Error: $e');
          }
      }

      if (points.isEmpty) {
          throw Exception('Failed to parse any valid polyline points.');
      }

      // --- 3. PARSE DURATION & DISTANCE (Đã cải thiện) ---
      final distanceMeters = routeData['distanceMeters'] as int? ?? 0;
      final distanceText = '${(distanceMeters / 1000).toStringAsFixed(1)} km';
      
      final durationString = routeData['duration'] as String? ?? '0s';
      final seconds = int.tryParse(durationString.replaceAll('s', '')) ?? 0;
      String durationText;
      if (seconds < 60) {
        durationText = 'Dưới 1 phút';
      } else {
        final minutes = (seconds / 60).round();
        if (minutes < 60) {
          durationText = '$minutes phút';
        } else {
          final hours = (minutes / 60).floor();
          final remainingMinutes = minutes % 60;
          durationText = '$hours giờ $remainingMinutes phút';
        }
      }

      return RouteModel(
        polylinePoints: points,
        bounds: bounds,
        distance: distanceText,
        duration: durationText,
      );
    } catch (e) {
      debugPrint('--- ERROR in RouteModel.fromDirectionsApi ---');
      debugPrint(e.toString());
      // Ném lại lỗi để BLoC có thể bắt và chuyển sang trạng thái Failure
      rethrow;
    }
  }
}