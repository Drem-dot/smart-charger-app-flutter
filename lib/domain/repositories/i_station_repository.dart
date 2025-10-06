
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:smart_charger_app/domain/entities/filter_params.dart';
import '../entities/station_entity.dart';

abstract class IStationRepository {
  Future<List<StationEntity>> getStationsByChunkIds(List<String> chunkIds);

  // Phương thức mới để tìm các trạm xung quanh
  Future<List<StationEntity>> getNearbyStations({
    required LatLng position,
    required double radiusKm, int? limit, FilterParams? filterParams,
  });

  Future<StationEntity> createStation(Map<String, dynamic> stationData,List<XFile> images);
}