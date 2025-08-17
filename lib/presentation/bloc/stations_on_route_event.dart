part of 'stations_on_route_bloc.dart';

abstract class StationsOnRouteEvent extends Equatable {
  const StationsOnRouteEvent();

  @override
  List<Object?> get props => [];
}

// Bắn khi người dùng nhấn nút "Tìm trạm", mang theo lộ trình hiện tại
class FetchStationsOnRoute extends StationsOnRouteEvent {
  final RouteEntity route;
  const FetchStationsOnRoute(this.route);

  @override
  List<Object> get props => [route];
}

class LoadInitialRadius extends StationsOnRouteEvent {}

// Bắn khi người dùng thay đổi giá trị của Slider
class RadiusChanged extends StationsOnRouteEvent {
  final double newRadius;
  const RadiusChanged(this.newRadius);

  @override
  List<Object> get props => [newRadius];
}

// Bắn khi người dùng đã chọn xong (thả tay khỏi Slider) để lưu giá trị
class RadiusChangeCompleted extends StationsOnRouteEvent {
    final RouteEntity route; // Cần route để fetch lại dữ liệu
    const RadiusChangeCompleted(this.route);

    @override
    List<Object> get props => [route];
}