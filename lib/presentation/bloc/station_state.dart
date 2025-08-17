part of 'station_bloc.dart';

// State sẽ chứa mọi thứ mà GoogleMap cần để build
class StationState extends Equatable {
  // Dữ liệu thô
  final Map<String, StationEntity> stations;
  final Set<String> loadedChunkIds;

  // Dữ liệu đã được xử lý để hiển thị
  final Set<Marker> markers;
  final Set<ClusterManager> clusterManagers;

  const StationState({
    this.stations = const {},
    this.loadedChunkIds = const {},
    this.markers = const {},
    this.clusterManagers = const {},
  });

  StationState copyWith({
    Map<String, StationEntity>? stations,
    Set<String>? loadedChunkIds,
    Set<Marker>? markers,
    Set<ClusterManager>? clusterManagers,
  }) {
    return StationState(
      stations: stations ?? this.stations,
      loadedChunkIds: loadedChunkIds ?? this.loadedChunkIds,
      markers: markers ?? this.markers,
      clusterManagers: clusterManagers ?? this.clusterManagers,
    );
  }
  
  @override
  List<Object> get props => [stations, loadedChunkIds, markers, clusterManagers];
}