part of 'route_bloc.dart';

abstract class RouteState extends Equatable {
  // Tất cả các state đều chứa thông tin về điểm đầu/cuối
  final LatLng? originPosition;
  final String? originName;
  final LatLng? destinationPosition;
  final String? destinationName;
  final RouteEntity? route;

  const RouteState({
    this.originPosition,
    this.originName,
    this.destinationPosition,
    this.destinationName,
    this.route,
  });

  @override
  List<Object?> get props => [originPosition, originName, destinationPosition, destinationName, route];
}

class RouteInitial extends RouteState {
  const RouteInitial({
    super.originPosition,
    super.originName,
    super.destinationPosition,
    super.destinationName,
  }) : super(route: null);
}

class RouteLoading extends RouteState {
    const RouteLoading({
    required super.originPosition,
    required super.originName,
    required super.destinationPosition,
    required super.destinationName,
  });
}

class RouteSuccess extends RouteState {
  const RouteSuccess({
    required super.route,
    required super.originPosition,
    required super.originName,
    required super.destinationPosition,
    required super.destinationName,
  });
}

class RouteFailure extends RouteState {
  final String error;
  const RouteFailure({
    required this.error,
    required super.originPosition,
    required super.originName,
    required super.destinationPosition,
    required super.destinationName,
  });
  @override
  List<Object?> get props => [error, originPosition, originName, destinationPosition, destinationName];
}