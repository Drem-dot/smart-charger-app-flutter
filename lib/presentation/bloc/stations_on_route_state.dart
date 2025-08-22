part of 'stations_on_route_bloc.dart';

enum StationsOnRouteStatus { initial, loading, success, failure }

class StationsOnRouteState extends Equatable {
  final StationsOnRouteStatus status;
  final List<StationEntity> stations;
  final String? error;
  // Lưu lại tuyến đường đã tìm kiếm thành công để so sánh
  final RouteEntity? lastSuccessfulRoute;

  const StationsOnRouteState({
    this.status = StationsOnRouteStatus.initial,
    this.stations = const [],
    this.error,
    this.lastSuccessfulRoute,
  });

  StationsOnRouteState copyWith({
    StationsOnRouteStatus? status,
    List<StationEntity>? stations,
    String? error,
    // Dùng hàm để cho phép set giá trị null
    RouteEntity? Function()? lastSuccessfulRoute,
  }) {
    return StationsOnRouteState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      error: error ?? this.error,
      lastSuccessfulRoute: lastSuccessfulRoute != null ? lastSuccessfulRoute() : this.lastSuccessfulRoute,
    );
  }

  @override
  List<Object?> get props => [status, stations, error, lastSuccessfulRoute];
}