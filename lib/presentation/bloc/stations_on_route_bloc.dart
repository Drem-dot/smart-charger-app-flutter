// lib/presentation/bloc/stations_on_route_bloc.dart

import 'dart:async'; // <-- Thêm import
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_charger_app/domain/entities/route_entity.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_directions_repository.dart';
import 'package:smart_charger_app/presentation/bloc/station_bloc.dart';
// THÊM MỚI:
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';

part 'stations_on_route_event.dart';
part 'stations_on_route_state.dart';

class StationsOnRouteBloc extends Bloc<StationsOnRouteEvent, StationsOnRouteState> {
  final IDirectionsRepository _directionsRepository;
  final StationBloc _stationBloc;
  // THÊM MỚI: StreamSubscription để lắng nghe RouteBloc
  StreamSubscription? _routeSubscription;

  // THAY ĐỔI: Constructor nhận thêm RouteBloc
  StationsOnRouteBloc({
    required IDirectionsRepository directionsRepository,
    required StationBloc stationBloc,
    required RouteBloc routeBloc,
  })  : _directionsRepository = directionsRepository,
        _stationBloc = stationBloc,
        super(const StationsOnRouteState()) {
    
    // Đăng ký lắng nghe stream của RouteBloc ngay khi được tạo
    _routeSubscription = routeBloc.stream.listen((routeState) {
      if (routeState is RouteSuccess && routeState.route != null) {
        // Nếu có tuyến đường mới, tự động bắn event để tìm trạm
        add(FindStationsForRoute(routeState.route!));
      } else {
        // Nếu không có tuyến đường (bị hủy), tự động reset
        add(ResetStationsOnRoute());
      }
    });

    on<FindStationsForRoute>(_onFindStationsForRoute);
    on<ResetStationsOnRoute>(_onReset);
  }

  // THÊM MỚI: Hủy subscription khi BLoC bị đóng
  @override
  Future<void> close() {
    _routeSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFindStationsForRoute(
    FindStationsForRoute event,
    Emitter<StationsOnRouteState> emit,
  ) async {
    // Logic cache không đổi, vẫn rất hiệu quả
    if (state.status == StationsOnRouteStatus.success && state.lastSuccessfulRoute == event.route) {
      _stationBloc.add(FilterStationsRequested(state.stations));
      emit(state.copyWith(status: StationsOnRouteStatus.success));
      return;
    }
    
    emit(state.copyWith(status: StationsOnRouteStatus.loading));
    try {
      final stations = await _directionsRepository.getStationsOnRoute(route: event.route);
      _stationBloc.add(FilterStationsRequested(stations));
      emit(state.copyWith(
        status: StationsOnRouteStatus.success, 
        stations: stations, 
        lastSuccessfulRoute: () => event.route
      ));
    } catch (e) {
      emit(state.copyWith(status: StationsOnRouteStatus.failure, error: e.toString()));
    }
  }

  void _onReset(
    ResetStationsOnRoute event,
    Emitter<StationsOnRouteState> emit,
  ) {
    emit(const StationsOnRouteState());
    _stationBloc.add(ClearStationFilter());
  }
}