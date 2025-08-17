part of 'station_bloc.dart';

abstract class StationEvent extends Equatable {
  const StationEvent();
  @override
  List<Object> get props => [];
}

// Event từ UI khi camera đứng yên, yêu cầu fetch dữ liệu thô
class StationsInBoundsFetched extends StationEvent {
  final LatLngBounds visibleBounds;
  const StationsInBoundsFetched(this.visibleBounds);
  @override
  List<Object> get props => [visibleBounds];
}

// Event từ StationClusterLego, yêu cầu cập nhật Set<Marker> trong state
class StationMarkersUpdated extends StationEvent {
  final Set<Marker> markers;
  const StationMarkersUpdated(this.markers);
  @override
  List<Object> get props => [markers];
}

// Event từ StationClusterLego, báo cho BLoC biết về sự tồn tại của ClusterManager
class ClusterManagerInitialized extends StationEvent {
  final ClusterManager clusterManager;
  const ClusterManagerInitialized(this.clusterManager);
  @override
  List<Object> get props => [clusterManager];
}