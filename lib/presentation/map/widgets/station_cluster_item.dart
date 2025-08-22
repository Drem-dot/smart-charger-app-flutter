// lib/presentation/map/widgets/station_cluster_item.dart

import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../domain/entities/station_entity.dart'; // Đường dẫn tới StationEntity

/// Lớp này "bao bọc" một StationEntity để làm cho nó tương thích
/// với ClusterManager mà không cần phải sửa đổi class StationEntity gốc.
class StationClusterItem with ClusterItem {
  final StationEntity station;

  StationClusterItem({required this.station});

  /// Cung cấp vị trí cho ClusterManager, đây là yêu cầu bắt buộc của `ClusterItem`.
  @override
  LatLng get location => LatLng(station.lat, station.lon);
}