// lib/domain/entities/station_entity.dart

import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// --- THÊM ENUM ĐỂ QUẢN LÝ LOẠI TRẠM ---
enum StationType { car, bike, unknown }

class StationEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final List<double> powerKw;
  final List<String> connectorTypes;
  final String status;
  final double ratingsAverage;
  final int ratingsQuantity;
  final Map<String, int> numConnectorsByPower;
  final String? operatingHours;
  final String? pricingDetails;
  final String? chunkId;
  final List<String> imageUrls;
  final double? distanceInKm;

  // --- THÊM TRƯỜNG MỚI ---
  final StationType stationType;

  const StationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.powerKw,
    required this.connectorTypes,
    required this.status,
    required this.numConnectorsByPower,
    this.operatingHours,
    this.pricingDetails,
    this.chunkId,
    required this.ratingsAverage,
    required this.ratingsQuantity,
    this.distanceInKm,
    this.imageUrls = const [],
    // --- THÊM VÀO CONSTRUCTOR VỚI GIÁ TRỊ MẶC ĐỊNH ---
    this.stationType = StationType.unknown, 
  });

  LatLng get position => LatLng(lat, lon);

  int get totalConnectors {
    // Sửa lại logic tính tổng cho Map<String, int>
    if (numConnectorsByPower.isEmpty) return 0;
    return numConnectorsByPower.values.fold(0, (sum, count) => sum + count);
  }

  // --- CẬP NHẬT `copyWith` ---
  StationEntity copyWith({
    double? distanceInKm,
    List<String>? imageUrls,
    StationType? stationType, // Thêm vào đây
  }) {
    return StationEntity(
      id: id,
      name: name,
      address: address,
      lat: lat,
      lon: lon,
      powerKw: powerKw,
      connectorTypes: connectorTypes,
      status: status,
      numConnectorsByPower: numConnectorsByPower,
      operatingHours: operatingHours,
      pricingDetails: pricingDetails,
      chunkId: chunkId,
      ratingsAverage: ratingsAverage,
      ratingsQuantity: ratingsQuantity,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      imageUrls: imageUrls ?? this.imageUrls,
      stationType: stationType ?? this.stationType, // Thêm vào đây
    );
  }

  // --- CẬP NHẬT `factory fromJson` ---
  factory StationEntity.fromJson(Map<String, dynamic> json) {
    final coordinates = json['location']?['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    final powerList = json['power_kw'] as List<dynamic>? ?? [];
    final parsedPowerKw = powerList.map((p) => (p as num).toDouble()).toList();
    final connectorList = json['connector_types'] as List<dynamic>? ?? [];
    final parsedConnectors = connectorList.map((c) => c.toString()).toList();

    // Logic để parse stationType từ chuỗi 'car' hoặc 'bike'
    StationType typeFromString(String? typeStr) {
      switch (typeStr) {
        case 'car':
          return StationType.car;
        case 'bike':
          return StationType.bike;
        default:
          return StationType.unknown;
      }
    }

    return StationEntity(
      id: json['_id'] as String? ?? json['sourceId'] as String? ?? '', // Hỗ trợ cả _id và sourceId
      name: json['name'] as String? ?? 'Unknown Station',
      address: json['address'] as String? ?? 'No address provided',
      lat: (coordinates.length > 1 ? coordinates[1] as num? : 0.0)?.toDouble() ?? 0.0,
      lon: (coordinates.isNotEmpty ? coordinates[0] as num? : 0.0)?.toDouble() ?? 0.0,
      powerKw: parsedPowerKw,
      connectorTypes: parsedConnectors,
      status: json['status'] as String? ?? 'unknown',
      // Sửa lại logic parse cho Map<String, int>
      numConnectorsByPower: Map<String, int>.from(json['num_connectors_by_power'] ?? {}),
      operatingHours: json['operating_hours'] as String?,
      pricingDetails: json['pricing_details'] as String?,
      chunkId: json['chunkId'] as String?,
      ratingsAverage: (json['ratingsAverage'] as num?)?.toDouble() ?? 4.5,
      ratingsQuantity: json['ratingsQuantity'] as int? ?? 0,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      stationType: typeFromString(json['stationType'] as String?), // <-- GÁN GIÁ TRỊ MỚI
    );
  }

  // --- CẬP NHẬT `props` ---
  @override
  List<Object?> get props => [
    id, name, address, lat, lon, powerKw, connectorTypes, status,
    numConnectorsByPower,
    operatingHours,
    pricingDetails,
    chunkId,
    ratingsAverage,
    ratingsQuantity,
    imageUrls,
    stationType, // <-- THÊM VÀO ĐÂY
  ];
}