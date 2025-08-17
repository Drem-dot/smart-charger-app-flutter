part of 'map_control_bloc.dart';

abstract class MapControlEvent extends Equatable {
  const MapControlEvent();

  @override
  List<Object> get props => [];
}

class CameraMoveRequested extends MapControlEvent {
  final LatLng position;
  final double zoom;

  const CameraMoveRequested(this.position, this.zoom);

  @override
  List<Object> get props => [position, zoom];
}

class CameraBoundsRequested extends MapControlEvent {
  final LatLngBounds bounds;
  const CameraBoundsRequested(this.bounds);
  @override
  List<Object> get props => [bounds];
}