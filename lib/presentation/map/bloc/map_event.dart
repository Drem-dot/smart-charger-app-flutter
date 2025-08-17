part of 'map_bloc.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();
  @override
  List<Object> get props => [];
}

// Event để cập nhật danh sách các marker trên bản đồ
class MapMarkersUpdated extends MapEvent {
  final Set<Marker> markers;
  const MapMarkersUpdated(this.markers);
  @override
  List<Object> get props => [markers];
}

// Event để cập nhật các cluster manager
class MapClusterManagersUpdated extends MapEvent {
  final Set<ClusterManager> clusterManagers;
  const MapClusterManagersUpdated(this.clusterManagers);
  @override
  List<Object> get props => [clusterManagers];
}

// Event để bật/tắt lớp vị trí người dùng
class MapMyLocationToggled extends MapEvent {
  final bool isEnabled;
  const MapMyLocationToggled(this.isEnabled);
  @override
  List<Object> get props => [isEnabled];
}