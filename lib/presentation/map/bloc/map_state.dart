part of 'map_bloc.dart';

class MapState extends Equatable {
  final Set<Marker> markers;
  final Set<ClusterManager> clusterManagers;
  final bool isMyLocationEnabled;

  const MapState({
    this.markers = const {},
    this.clusterManagers = const {},
    this.isMyLocationEnabled = false,
  });

  MapState copyWith({
    Set<Marker>? markers,
    Set<ClusterManager>? clusterManagers,
    bool? isMyLocationEnabled,
  }) {
    return MapState(
      markers: markers ?? this.markers,
      clusterManagers: clusterManagers ?? this.clusterManagers,
      isMyLocationEnabled: isMyLocationEnabled ?? this.isMyLocationEnabled,
    );
  }

  @override
  List<Object> get props => [markers, clusterManagers, isMyLocationEnabled];
}