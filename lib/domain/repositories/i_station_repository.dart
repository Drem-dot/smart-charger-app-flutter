import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/station_entity.dart';

abstract class IStationRepository {
  Future<List<StationEntity>> getStationsByChunkIds(List<String> chunkIds);

  // Phương thức mới để tìm các trạm xung quanh
  Future<List<StationEntity>> getNearbyStations({
    required LatLng position,
    required double radiusKm,
  });

  Future<StationEntity> createStation(Map<String, dynamic> stationData);
}