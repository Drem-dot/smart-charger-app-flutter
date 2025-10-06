
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
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
  Future<StationEntity> createStation(Map<String, dynamic> data, List<XFile> images) async {
    try {
      List<MultipartFile> imageFiles = [];

      for (var image in images) {
        String fileName = image.name; // Dùng image.name thay vì path

        if (kIsWeb) {
          // --- XỬ LÝ CHO WEB ---
          // Đọc dữ liệu ảnh dưới dạng bytes
          var bytes = await image.readAsBytes();
          // Tạo MultipartFile từ bytes
          imageFiles.add(MultipartFile.fromBytes(bytes, filename: fileName));
        } else {
          // --- XỬ LÝ CHO MOBILE (NHƯ CŨ) ---
          imageFiles.add(await MultipartFile.fromFile(image.path, filename: fileName));
        }
      }

      final formData = FormData.fromMap({
      // Gửi toàn bộ dữ liệu text dưới dạng một chuỗi JSON
      'stationData': jsonEncode(data), 
      
      if (imageFiles.isNotEmpty) 'images': imageFiles,
    });

      final response = await _dio.post(
        '/api/v1/stations',
        data: formData,
        onSendProgress: (int sent, int total) {
          debugPrint('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
        },
      );

      if (response.statusCode == 201) {
        return StationEntity.fromJson(response.data['data']['station']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          error: 'Failed to create station'
        );
      }
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      debugPrint('DioException in createStation: $errorMessage');
      rethrow;
    } catch (e) {
      debugPrint('Unknown error in createStation: $e');
      rethrow;
    }
  }
}
