part of 'stations_on_route_bloc.dart';
abstract class StationsOnRouteState extends Equatable {
// Tất cả các state đều cần biết bán kính hiện tại
final double radius;
const StationsOnRouteState({required this.radius});
@override
List<Object> get props => [radius];
}
class StationsOnRouteInitial extends StationsOnRouteState {
const StationsOnRouteInitial({required super.radius});
}
class StationsOnRouteLoading extends StationsOnRouteState {
const StationsOnRouteLoading({required super.radius});
}
class StationsOnRouteSuccess extends StationsOnRouteState {
final List<StationEntity> stations;
const StationsOnRouteSuccess({required this.stations, required super.radius});
@override
List<Object> get props => [stations, radius];
}
class StationsOnRouteFailure extends StationsOnRouteState {
final String error;
const StationsOnRouteFailure({required this.error, required super.radius});
@override
List<Object> get props => [error, radius];
}