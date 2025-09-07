// lib/data/repositories/geocoding_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/autocomplete_prediction.dart';
import '../../domain/entities/geocoding_result_entity.dart';
import '../../domain/repositories/i_geocoding_repository.dart';

class GeocodingRepositoryImpl implements IGeocodingRepository {
  final Dio _dio;

  GeocodingRepositoryImpl(this._dio);

  // --- HÀM `search` ĐÃ ĐƯỢC NÂNG CẤP ---
  @override
  Future<List<GeocodingResult>> search(String query) async {
    if (query.isEmpty) return [];
    
    // Sử dụng lại endpoint Autocomplete qua proxy
    const url = '/api/v1/places/autocomplete';
    try {
      final response = await _dio.get(url, queryParameters: {'query': query});

      if (response.statusCode == 200 && response.data['predictions'] != null) {
        final List<dynamic> predictions = response.data['predictions'];
        
        // Chuyển đổi AutocompletePrediction sang GeocodingResult
        // Chúng ta cần gọi thêm getLatLngFromPlaceId để có tọa độ
        final List<GeocodingResult> results = [];
        for (var p in predictions) {
          final latLng = await getLatLngFromPlaceId(p['place_id']);
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
  Future<List<AutocompletePrediction>> getAutocompleteSuggestions(String query) async {
    if (query.isEmpty) return [];
    const url = '/api/v1/places/autocomplete';
    try {
      final response = await _dio.get(url, queryParameters: {'query': query});
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
  Future<LatLng?> getLatLngFromPlaceId(String placeId) async {
    const url = '/api/v1/places/details';
    try {
      final response = await _dio.get(url, queryParameters: {'placeId': placeId});
      if (response.statusCode == 200 && response.data['location'] != null) {
        final location = response.data['location'];
        return LatLng(location['lat'], location['lng']);
      }
      return null;
    } catch (e) { rethrow; }
  }
}