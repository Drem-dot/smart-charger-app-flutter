import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/route_entity.dart';
import '../entities/station_entity.dart'; // Import StationEntity

abstract class IDirectionsRepository {
  Future<RouteEntity> getDirections({
    required LatLng origin,
    required LatLng destination,
  });

  // Phương thức mới để lấy các trạm sạc trên một lộ trình
  Future<List<StationEntity>> getStationsOnRoute({
    required RouteEntity route,
    required double radiusKm,
  });
}