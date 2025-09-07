import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/filter_params.dart';
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
    int? limit,
    FilterParams? filterParams, // Nhận tham số mới
  }) async {
    try {
      // --- XÂY DỰNG QUERY PARAMETERS ĐỘNG ---
      final Map<String, dynamic> queryParameters = {
        'lat': position.latitude,
        'lon': position.longitude,
        'radius': radiusKm * 1000,
        if (limit != null) 'limit': limit,
      };

      // Thêm các tham số lọc nếu chúng tồn tại
      if (filterParams != null) {
        if (filterParams.availableNow == true) {
          queryParameters['status'] = 'available';
        }
        if (filterParams.connectorTypes.isNotEmpty) {
          // Gửi dưới dạng chuỗi được nối bằng dấu phẩy, ví dụ: "CCS2,TYPE_2"
          queryParameters['connector_types'] = filterParams.connectorTypes.join(',');
        }
        // Gửi dải công suất, ví dụ: "50-150"
        queryParameters['power_level'] = '${filterParams.powerLevel.start.toInt()}-${filterParams.powerLevel.end.toInt()}';
        
        if (filterParams.minRating > 0) {
          queryParameters['min_rating'] = filterParams.minRating;
        }
      }
      // ------------------------------------

      final response = await _dio.get(
        '/api/v1/stations/nearby',
        queryParameters: queryParameters, // Sử dụng map đã được xây dựng
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