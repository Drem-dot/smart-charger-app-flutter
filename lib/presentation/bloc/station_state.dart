// station_state.dart

part of 'station_bloc.dart';

// State bây giờ chỉ chứa dữ liệu thô
class StationState extends Equatable {
  final Map<String, StationEntity> stations;
  final Set<String> loadedChunkIds;
  final Map<String, StationEntity>? filteredStations;

  const StationState({
    this.stations = const {},
    this.loadedChunkIds = const {},
    this.filteredStations,
  });

  Map<String, StationEntity> get stationsToDisplay => filteredStations ?? stations;

  StationState copyWith({
    Map<String, StationEntity>? stations,
    Set<String>? loadedChunkIds, 
    Map<String, StationEntity>? Function()? filteredStations,
  }) {
    return StationState(
      stations: stations ?? this.stations,
      loadedChunkIds: loadedChunkIds ?? this.loadedChunkIds,
      filteredStations: filteredStations != null ? filteredStations() : this.filteredStations,
    );
  }
  
  // --- XÓA BỎ `markers` và `clusterManagers` khỏi props ---
  @override
  List<Object> get props => [stations, loadedChunkIds, ?filteredStations];
}