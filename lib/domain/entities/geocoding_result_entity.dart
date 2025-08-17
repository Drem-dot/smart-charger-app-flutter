import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeocodingResult extends Equatable {
  final String name;
  final String address;
  final LatLng latLng;

  const GeocodingResult({
    required this.name,
    required this.address,
    required this.latLng,
  });

  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      name: json['displayName']?['text'] ?? 'Unknown Place',
      address: json['formattedAddress'] ?? 'No address',
      latLng: LatLng(
        json['location']?['latitude'] ?? 0.0,
        json['location']?['longitude'] ?? 0.0,
      ),
    );
  }

  @override
  List<Object?> get props => [name, address, latLng];
}