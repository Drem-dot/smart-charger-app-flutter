part of 'nearby_stations_bloc.dart';

abstract class NearbyStationsEvent extends Equatable {
  const NearbyStationsEvent();
  @override
  List<Object?> get props => [];
}

class LoadInitialRadius extends NearbyStationsEvent {}

class FetchNearbyStations extends NearbyStationsEvent {
  final LatLng position;
  const FetchNearbyStations(this.position);
  @override
  List<Object> get props => [position];
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