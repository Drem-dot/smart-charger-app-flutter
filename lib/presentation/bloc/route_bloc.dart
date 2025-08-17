import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/i_directions_repository.dart';

part 'route_event.dart';
part 'route_state.dart';

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final IDirectionsRepository _directionsRepository;

  RouteBloc(this._directionsRepository) : super(const RouteInitial()) {
    on<OriginUpdated>(_onOriginUpdated);
    on<DestinationUpdated>(_onDestinationUpdated);
    on<RoutePointsSwapped>(_onRoutePointsSwapped);
    on<DirectionsFetched>(_onDirectionsFetched);
    on<RouteCleared>((event, emit) => emit(const RouteInitial()));
  }

  void _onOriginUpdated(OriginUpdated event, Emitter<RouteState> emit) {
    emit(RouteInitial(
      originPosition: event.position,
      originName: event.name,
      destinationPosition: state.destinationPosition,
      destinationName: state.destinationName,
    ));
  }
  
  void _onDestinationUpdated(DestinationUpdated event, Emitter<RouteState> emit) {
    emit(RouteInitial(
      originPosition: state.originPosition,
      originName: state.originName,
      destinationPosition: event.position,
      destinationName: event.name,
    ));
  }
  
  void _onRoutePointsSwapped(RoutePointsSwapped event, Emitter<RouteState> emit) {
    // Chỉ hoán đổi nếu cả hai đều tồn tại
    if (state.originPosition != null && state.destinationPosition != null) {
      emit(RouteInitial(
        originPosition: state.destinationPosition,
        originName: state.destinationName,
        destinationPosition: state.originPosition,
        destinationName: state.originName,
      ));
    }
  }

  Future<void> _onDirectionsFetched(
    DirectionsFetched event,
    Emitter<RouteState> emit,
  ) async {
    if (state.originPosition == null || state.destinationPosition == null) return;
    
    emit(RouteLoading(
      originPosition: state.originPosition,
      originName: state.originName,
      destinationPosition: state.destinationPosition,
      destinationName: state.destinationName,
    ));
    try {
      final route = await _directionsRepository.getDirections(
        origin: state.originPosition!,
        destination: state.destinationPosition!,
      );
      emit(RouteSuccess(
        route: route,
        originPosition: state.originPosition,
        originName: state.originName,
        destinationPosition: state.destinationPosition,
        destinationName: state.destinationName,
      ));
    } catch (e) {
      emit(RouteFailure(
        error: e.toString(),
        originPosition: state.originPosition,
        originName: state.originName,
        destinationPosition: state.destinationPosition,
        destinationName: state.destinationName,
      ));
    }
  }
}