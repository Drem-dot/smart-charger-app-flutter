part of 'nearby_stations_bloc.dart';

abstract class NearbyStationsState extends Equatable {
  final double radius;
  const NearbyStationsState({required this.radius});
  @override
  List<Object> get props => [radius];
}

class NearbyStationsInitial extends NearbyStationsState {
  const NearbyStationsInitial({required super.radius});
}

class NearbyStationsLoading extends NearbyStationsState {
  const NearbyStationsLoading({required super.radius});
}

class NearbyStationsSuccess extends NearbyStationsState {
  final List<StationEntity> stations;
  const NearbyStationsSuccess({required this.stations, required super.radius});
  @override
  List<Object> get props => [stations, radius];
}

class NearbyStationsFailure extends NearbyStationsState {
  final String error;
  const NearbyStationsFailure({required this.error, required super.radius});
  @override
  List<Object> get props => [error, radius];
}