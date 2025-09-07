// lib/presentation/bloc/nearby_stations_state.dart

part of 'nearby_stations_bloc.dart';

enum NearbyStationsStatus { initial, loading, success, failure }

class NearbyStationsState extends Equatable {
  final NearbyStationsStatus status;
  final List<StationEntity> stations;
  final double radius;
  final Position? currentUserPosition;
  final String? error;
  final FilterParams filterParams;

  const NearbyStationsState({
    this.status = NearbyStationsStatus.initial,
    this.stations = const [],
    required this.radius,
    this.currentUserPosition,
    this.error,
    this.filterParams = const FilterParams.empty(),
  });

  // --- HÀM copyWith ĐÃ ĐƯỢC SỬA LỖI ---
  NearbyStationsState copyWith({
    NearbyStationsStatus? status,
    List<StationEntity>? stations,
    double? radius,
    Position? currentUserPosition,
    String? error,
    FilterParams? filterParams, // <-- Thêm tham số này
  }) {
    return NearbyStationsState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      radius: radius ?? this.radius,
      currentUserPosition: currentUserPosition ?? this.currentUserPosition,
      error: error ?? this.error,
      filterParams: filterParams ?? this.filterParams, // <-- Gán giá trị
    );
  }

  @override
  // --- Thêm filterParams vào props ---
  List<Object?> get props => [status, stations, radius, currentUserPosition, error, filterParams];
}