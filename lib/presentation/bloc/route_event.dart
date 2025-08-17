part of 'route_bloc.dart';

abstract class RouteEvent extends Equatable {
  const RouteEvent();
  @override
  List<Object?> get props => [];
}

// Cập nhật điểm bắt đầu với cả vị trí và tên
class OriginUpdated extends RouteEvent {
  final LatLng position;
  final String name;
  const OriginUpdated({required this.position, required this.name});
  @override
  List<Object> get props => [position, name];
}

// Cập nhật điểm kết thúc với cả vị trí và tên
class DestinationUpdated extends RouteEvent {
  final LatLng position;
  final String name;
  const DestinationUpdated({required this.position, required this.name});
  @override
  List<Object> get props => [position, name];
}

// Đảo ngược điểm đầu và điểm cuối
class RoutePointsSwapped extends RouteEvent {}

// Bắt đầu tìm đường (sẽ sử dụng origin/destination từ state)
class DirectionsFetched extends RouteEvent {}

// Xóa mọi thứ (lộ trình, điểm đầu, điểm cuối)
class RouteCleared extends RouteEvent {}