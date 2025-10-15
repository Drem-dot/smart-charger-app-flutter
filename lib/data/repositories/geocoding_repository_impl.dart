// lib/data/repositories/geocoding_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/autocomplete_prediction.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/geocoding_result_entity.dart';
import '../../domain/repositories/i_geocoding_repository.dart';

class GeocodingRepositoryImpl implements IGeocodingRepository {
  final Dio _dio;

  GeocodingRepositoryImpl(this._dio);

  // --- HÀM `search` ĐÃ ĐƯỢC NÂNG CẤP ---
  @override
  Future<List<GeocodingResult>> search(String query) async {
    if (query.isEmpty) return [];

    const url = '/api/v1/places/autocomplete';
    try {
      // --- SỬA LỖI Ở ĐÂY ---
      // Vì hàm `search` không được thiết kế để nhận session token,
      // chúng ta sẽ tạo một token mới cho mỗi lần tìm kiếm autocomplete
      // và một token khác cho mỗi lần lấy details.
      // LƯU Ý: Cách này KHÔNG TỐI ƯU CHI PHÍ. Các widget nên chuyển sang dùng
      // `getAutocompleteSuggestions` và `getLatLngFromPlaceId` riêng biệt.
      final autocompleteToken = const Uuid().v4();
      final response = await _dio.get(
        url,
        queryParameters: {'query': query, 'sessiontoken': autocompleteToken},
      );

      if (response.statusCode == 200 && response.data['predictions'] != null) {
        final List<dynamic> predictions = response.data['predictions'];
        
        final List<GeocodingResult> results = [];
        for (var p in predictions) {
          // Tạo token mới cho mỗi lần gọi getLatLngFromPlaceId
          final detailsToken = const Uuid().v4();
          final latLng = await getLatLngFromPlaceId(p['place_id'], sessionToken: detailsToken); // <-- TRUYỀN TOKEN VÀO
          if (latLng != null) {
            results.add(GeocodingResult(
              name: p['structured_formatting']?['main_text'] ?? p['description'],
              address: p['structured_formatting']?['secondary_text'] ?? '',
              latLng: latLng,
            ));
          }
        }
        return results;
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<String?> getAddressFromLatLng(LatLng position) async {
    const url = '/api/v1/places/reverse-geocode';
    try {
      final response = await _dio.get(url, queryParameters: {
        'lat': position.latitude,
        'lon': position.longitude,
      });
      if (response.statusCode == 200 && response.data['address'] != null) {
        return response.data['address'] as String;
      }
      return null;
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      return null;
    }
  }

  
  @override
  Future<List<AutocompletePrediction>> getAutocompleteSuggestions(String query,{required String sessionToken}) async {
    if (query.isEmpty) return [];
    const url = '/api/v1/places/autocomplete';
    try {
      final response = await _dio.get(url, queryParameters: {'query': query,'sessiontoken': sessionToken,});
      if (response.statusCode == 200 && response.data['predictions'] != null) {
        final List<dynamic> predictions = response.data['predictions'];
        return predictions.map((p) => AutocompletePrediction(
          description: p['description'],
          placeId: p['place_id'],
        )).toList();
      }
      return [];
    } catch (e) { rethrow; }
  }

  @override
  Future<LatLng?> getLatLngFromPlaceId(String placeId,{required String sessionToken}) async {
    const url = '/api/v1/places/details';
    try {
      final response = await _dio.get(url, queryParameters: {'placeId': placeId,'sessiontoken': sessionToken,});
      if (response.statusCode == 200 && response.data['location'] != null) {
        final location = response.data['location'];
        return LatLng(location['lat'], location['lng']);
      }
      return null;
    } catch (e) { rethrow; }
  }
}