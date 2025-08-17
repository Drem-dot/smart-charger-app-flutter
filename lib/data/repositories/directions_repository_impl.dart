import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';

import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/i_directions_repository.dart';
import '../models/route_model.dart';

class DirectionsRepositoryImpl implements IDirectionsRepository {
  final Dio _dio;

  DirectionsRepositoryImpl({required Dio dio}) : _dio = dio;

  @override
  Future<RouteEntity> getDirections({
    required LatLng origin,
    required LatLng destination,
  }) async {
    // URL này trỏ đến backend proxy của bạn
    const url = '/api/v1/directions';

    try {
      final response = await _dio.post(
        url,
        data: {
          'origin': {'lat': origin.latitude, 'lon': origin.longitude},
          'destination': {'lat': destination.latitude, 'lon': destination.longitude},
        },
      );

      // ================= SỬA LỖI KIỂM TRA RESPONSE =================
      // API Routes v2 không có trường 'status'.
      // Một response thành công là khi statusCode = 200 và có chứa dữ liệu 'routes'.
      if (response.statusCode == 200 && response.data['routes'] != null) {
        return RouteModel.fromDirectionsApi(response.data);
      } else {
        // Nếu không thành công, cố gắng lấy thông báo lỗi từ cấu trúc mới
        final errorDetails = response.data['error']?['message'] ?? 'Unknown API error';
        throw Exception('Failed to get directions: $errorDetails');
      }
      // ==========================================================

    } on DioException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

   @override
  Future<List<StationEntity>> getStationsOnRoute({
    required RouteEntity route,
    required double radiusKm,
  }) async {
    // Chuyển đổi List<LatLng> thành một cấu trúc GeoJSON LineString
    final routeGeometry = {
      'type': 'LineString',
      'coordinates': route.polylinePoints.map((p) => [p.longitude, p.latitude]).toList(),
    };

    try {
      final response = await _dio.post(
        '/api/v1/routes/stations', // Endpoint đã có sẵn trên backend
        data: {
          'routeGeometry': routeGeometry,
          'radius': radiusKm,
        },
      );

      if (response.statusCode == 200 && response.data['data']?['stations'] != null) {
        final List<dynamic> stationJsonList = response.data['data']['stations'];
        return stationJsonList.map((json) => StationEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}
