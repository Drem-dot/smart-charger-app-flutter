part of 'stations_on_route_bloc.dart';

abstract class StationsOnRouteEvent extends Equatable {
  const StationsOnRouteEvent();
  @override
  List<Object?> get props => [];
}

/// Event duy nhất: Yêu cầu tìm và hiển thị các trạm cho một tuyến đường.
class FindStationsForRoute extends StationsOnRouteEvent {
  final RouteEntity route;
  const FindStationsForRoute(this.route);
  @override
  List<Object> get props => [route];
}

/// Event để reset BLoC về trạng thái ban đầu (ví dụ: khi hủy tìm đường).
class ResetStationsOnRoute extends StationsOnRouteEvent {}