part of 'nearby_stations_bloc.dart';

abstract class NearbyStationsEvent extends Equatable {
  const NearbyStationsEvent();
  @override
  List<Object?> get props => [];
}

class InitialStationsRequested extends NearbyStationsEvent {}

class FetchNearbyStations extends NearbyStationsEvent {
  final LatLng position;
  final int? limit;
  const FetchNearbyStations(this.position, {this.limit});
  @override
  List<Object?> get props => [position, limit];
}

class RadiusChanged extends NearbyStationsEvent {
  final double newRadius;
  const RadiusChanged(this.newRadius);
  @override
  List<Object> get props => [newRadius];
}

class RadiusChangeCompleted extends NearbyStationsEvent {
    final LatLng position;
    const RadiusChangeCompleted(this.position);
    @override
    List<Object> get props => [position];
}

class FilterApplied extends NearbyStationsEvent {
  final FilterParams filterParams;
  const FilterApplied(this.filterParams);
  @override List<Object> get props => [filterParams];
}

class FetchStationsAroundPoint extends NearbyStationsEvent {
  final LatLng point;
  const FetchStationsAroundPoint(this.point);
  @override List<Object> get props => [point];
}
