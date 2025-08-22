// lib/domain/entities/station_entity.dart

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Import để sử dụng LatLng

class StationEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final List<double> powerKw;
  final List<String> connectorTypes;
  final String status;

  // --- THÊM MỚI: Các thuộc tính được yêu cầu ---
  final Map<String, int> numConnectorsByPower;
  final String? operatingHours;
  final String? pricingDetails;

  const StationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.powerKw,
    required this.connectorTypes,
    required this.status,
    // Thêm vào constructor
    required this.numConnectorsByPower,
    this.operatingHours,
    this.pricingDetails,
  });

  // --- THÊM MỚI: Getter tiện ích ---
  /// Cung cấp vị trí dưới dạng đối tượng LatLng.
  LatLng get position => LatLng(lat, lon);

  /// Tính tổng số cổng sạc từ map numConnectorsByPower.
  int get totalConnectors => numConnectorsByPower.values.fold(0, (sum, count) => sum + count);

  factory StationEntity.fromJson(Map<String, dynamic> json) {
    final coordinates = json['location']?['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    final powerList = json['power_kw'] as List<dynamic>? ?? [];
    final parsedPowerKw = powerList.map((p) => (p as num).toDouble()).toList();
    final connectorList = json['connector_types'] as List<dynamic>? ?? [];
    final parsedConnectors = connectorList.map((c) => c.toString()).toList();

    return StationEntity(
      id: json['_id'] as String? ?? '', 
      name: json['name'] as String? ?? 'Unknown Station',
      address: json['address'] as String? ?? 'No address provided',
      lat: (coordinates.length > 1 ? coordinates[1] as num? : 0.0)?.toDouble() ?? 0.0,
      lon: (coordinates.isNotEmpty ? coordinates[0] as num? : 0.0)?.toDouble() ?? 0.0,
      powerKw: parsedPowerKw,
      connectorTypes: parsedConnectors,
      status: json['status'] as String? ?? 'unknown',

      // --- THÊM MỚI: Parse dữ liệu mới từ JSON ---
      // Giả định backend trả về field 'num_connectors_by_power' là một Map.
      numConnectorsByPower: Map<String, int>.from(json['num_connectors_by_power'] ?? {}),
      operatingHours: json['operating_hours'] as String?,
      pricingDetails: json['pricing_details'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id, name, address, lat, lon, powerKw, connectorTypes, status,
        // Thêm vào props để Equatable so sánh
        numConnectorsByPower, operatingHours, pricingDetails
      ];
}