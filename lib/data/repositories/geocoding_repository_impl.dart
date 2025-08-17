import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Giả sử bạn dùng dotenv
import '../../domain/entities/geocoding_result_entity.dart';
import '../../domain/repositories/i_geocoding_repository.dart';

class GeocodingRepositoryImpl implements IGeocodingRepository {
  final Dio _dio;

  GeocodingRepositoryImpl() : _dio = Dio();

  @override
  Future<List<GeocodingResult>> search(String query) async {
    if (query.isEmpty) {
      return [];
    }

    final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (apiKey == null) {
      throw Exception('Google Maps API Key not found in .env file');
    }

    // Sử dụng Text Search endpoint của Places API v1
    const url = 'https://places.googleapis.com/v1/places:searchText';

    try {
      final response = await _dio.post(
        url,
        data: {
          "textQuery": query,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'X-Goog-Api-Key': apiKey,
            // FieldMask để chỉ lấy các trường cần thiết, tiết kiệm chi phí
            'X-Goog-FieldMask': 'places.displayName,places.formattedAddress,places.location',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['places'] != null) {
        final List<dynamic> placesJson = response.data['places'];
        return placesJson.map((json) => GeocodingResult.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}