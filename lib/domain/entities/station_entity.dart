import 'package:equatable/equatable.dart';

class StationEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lon;
  final List<double> powerKw;
  final List<String> connectorTypes;
  final String status;
  // Các trường khác có thể thêm vào đây nếu cần, ví dụ: operating_hours

  const StationEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lon,
    required this.powerKw,
    required this.connectorTypes,
    required this.status,
  });

  /// Hàm factory này đã được cập nhật đầy đủ để khớp với cấu trúc JSON từ backend.
  factory StationEntity.fromJson(Map<String, dynamic> json) {
    // Lấy tọa độ từ mảng coordinates [longitude, latitude]
    final coordinates = json['location']?['coordinates'] as List<dynamic>? ?? [0.0, 0.0];
    
    // Xử lý danh sách power_kw một cách an toàn
    final powerList = json['power_kw'] as List<dynamic>? ?? [];
    final parsedPowerKw = powerList.map((p) => (p as num).toDouble()).toList();
    
    // Xử lý danh sách connector_types một cách an toàn
    final connectorList = json['connector_types'] as List<dynamic>? ?? [];
    final parsedConnectors = connectorList.map((c) => c.toString()).toList();

    return StationEntity(
      // MongoDB sử dụng "_id"
      id: json['_id'] as String? ?? '', 
      name: json['name'] as String? ?? 'Unknown Station',
      address: json['address'] as String? ?? 'No address provided',
      
      // Vĩ độ (latitude) là phần tử thứ 2 (index 1)
      lat: (coordinates.length > 1 ? coordinates[1] as num? : 0.0)?.toDouble() ?? 0.0,
      // Kinh độ (longitude) là phần tử thứ 1 (index 0)
      lon: (coordinates.isNotEmpty ? coordinates[0] as num? : 0.0)?.toDouble() ?? 0.0,

      powerKw: parsedPowerKw,
      connectorTypes: parsedConnectors,
      status: json['status'] as String? ?? 'unknown',
    );
  }

  @override
  List<Object?> get props => [id, name, address, lat, lon, powerKw, connectorTypes, status];
}