// lib/domain/repositories/i_geocoding_repository.dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/autocomplete_prediction.dart';
import '../entities/geocoding_result_entity.dart';

abstract class IGeocodingRepository {
  Future<List<GeocodingResult>> search(String query);
  
  // --- THÊM MỚI ---
  Future<List<AutocompletePrediction>> getAutocompleteSuggestions(String query, {required String sessionToken});
  Future<LatLng?> getLatLngFromPlaceId(String placeId , {required String sessionToken});
  Future<String?> getAddressFromLatLng(LatLng position);

}