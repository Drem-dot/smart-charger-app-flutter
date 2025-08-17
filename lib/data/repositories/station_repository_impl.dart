import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/i_station_repository.dart';

class StationRepositoryImpl implements IStationRepository {
  final Dio _dio;

  StationRepositoryImpl(this._dio);

  @override
  Future<List<StationEntity>> getStationsByChunkIds(List<String> chunkIds) async {
    // Nếu không có chunk nào để fetch, không cần gọi API
    if (chunkIds.isEmpty) {
      return [];
    }
    
    try {
      final response = await _dio.post(
        '/api/v1/stations/in-chunks', 
        data: {"chunkIds": chunkIds},
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> stationJsonList = response.data['data']['stations'];
        return stationJsonList.map((json) => StationEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<StationEntity>> getNearbyStations({
    required LatLng position,
    required double radiusKm,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/stations/nearby',
        queryParameters: {
          'lat': position.latitude,
          'lon': position.longitude,
          'radius': radiusKm * 1000, // Backend yêu cầu radius bằng mét
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
  
  @override
  Future<StationEntity> createStation(Map<String, dynamic> stationData) async {
    try {
      final response = await _dio.post(
        '/api/v1/stations',
        data: stationData,
      );

      if (response.statusCode == 201 && response.data['data']?['station'] != null) {
        return StationEntity.fromJson(response.data['data']['station']);
      } else {
        throw Exception('Failed to create station');
      }
    } catch (e) {
      rethrow;
    }
}
}