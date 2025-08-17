import '../entities/geocoding_result_entity.dart';

abstract class IGeocodingRepository {
  Future<List<GeocodingResult>> search(String query);
}