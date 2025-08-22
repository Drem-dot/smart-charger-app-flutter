// station_event.dart

part of 'station_bloc.dart';

abstract class StationEvent extends Equatable {
  const StationEvent();
  @override
  List<Object> get props => [];
}

// Giữ lại event này, nó là cốt lõi của logic chunk-loading
class StationsInBoundsFetched extends StationEvent {
  final LatLngBounds visibleBounds;
  const StationsInBoundsFetched(this.visibleBounds);
  @override
  List<Object> get props => [visibleBounds];
}

class FilterStationsRequested extends StationEvent {
  final List<StationEntity> stationsToShow;
  const FilterStationsRequested(this.stationsToShow);
  @override List<Object> get props => [stationsToShow];
}

/// Yêu cầu BLoC quay trở lại hiển thị tất cả các trạm đã được tải.
class ClearStationFilter extends StationEvent {}