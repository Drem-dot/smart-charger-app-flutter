// lib/presentation/bloc/route_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/route_entity.dart';
import '../../domain/repositories/i_directions_repository.dart';

part 'route_event.dart';
part 'route_state.dart';

// Event này bây giờ chỉ dùng nội bộ trong BLoC
class _DirectionsFetched extends RouteEvent {}

class RouteBloc extends Bloc<RouteEvent, RouteState> {
  final IDirectionsRepository _directionsRepository;
  StreamSubscription? _stateSubscription;

  RouteBloc(this._directionsRepository) : super(const RouteInitial()) {
    // Lắng nghe mọi sự thay đổi state của chính BLoC này
    _stateSubscription = stream.listen((_) => _triggerAutoFetch());

    on<OriginUpdated>(_onOriginUpdated);
    on<DestinationUpdated>(_onDestinationUpdated);
    on<RoutePointsSwapped>(_onRoutePointsSwapped);
    on<_DirectionsFetched>(_onDirectionsFetched); // Lắng nghe event private
    on<RouteCleared>((event, emit) => emit(const RouteInitial()));
  }

  // Hàm tự động kích hoạt tìm đường
  void _triggerAutoFetch() {
    // Chỉ tìm đường khi đang ở trạng thái RouteInitial
    // và có đủ cả điểm đầu và điểm cuối
    if (state is RouteInitial && state.originPosition != null && state.destinationPosition != null) {
      add(_DirectionsFetched());
    }
  }

  @override
  Future<void> close() {
    _stateSubscription?.cancel();
    return super.close();
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
    _DirectionsFetched event,
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