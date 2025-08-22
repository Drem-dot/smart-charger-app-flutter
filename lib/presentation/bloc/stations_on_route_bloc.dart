import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_charger_app/domain/entities/route_entity.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_directions_repository.dart';
// THÊM MỚI: Import StationBloc và các thành phần của nó
import 'package:smart_charger_app/presentation/bloc/station_bloc.dart';

part 'stations_on_route_event.dart';
part 'stations_on_route_state.dart';

class StationsOnRouteBloc extends Bloc<StationsOnRouteEvent, StationsOnRouteState> {
  final IDirectionsRepository _directionsRepository;
  // THÊM MỚI: Cần một tham chiếu đến StationBloc để "ra lệnh"
  final StationBloc _stationBloc;

  StationsOnRouteBloc(this._directionsRepository, this._stationBloc)
      : super(const StationsOnRouteState()) {
    on<FindStationsForRoute>(_onFindStationsForRoute);
    on<ResetStationsOnRoute>(_onReset);
  }

  Future<void> _onFindStationsForRoute(
    FindStationsForRoute event,
    Emitter<StationsOnRouteState> emit,
  ) async {
    // TỐI ƯU HÓA: Nếu tuyến đường mới giống hệt tuyến đường đã tìm thành công trước đó,
    // chỉ cần áp dụng lại bộ lọc và không làm gì thêm.
    if (state.status == StationsOnRouteStatus.success && state.lastSuccessfulRoute == event.route) {
      _stationBloc.add(FilterStationsRequested(state.stations));
      // Hiển thị lại sheet với dữ liệu cũ
      emit(state.copyWith(status: StationsOnRouteStatus.success));
      return;
    }
    
    emit(state.copyWith(status: StationsOnRouteStatus.loading));
    try {
      // Gọi repository (bán kính đã được cố định bên trong)
      final stations = await _directionsRepository.getStationsOnRoute(route: event.route);
      
      // "Ra lệnh" cho StationBloc chỉ hiển thị các trạm này trên bản đồ
      _stationBloc.add(FilterStationsRequested(stations));
      
      emit(state.copyWith(
        status: StationsOnRouteStatus.success, 
        stations: stations, 
        lastSuccessfulRoute: () => event.route // Lưu lại tuyến đường thành công
      ));
    } catch (e) {
      emit(state.copyWith(status: StationsOnRouteStatus.failure, error: e.toString()));
    }
  }

  void _onReset(
    ResetStationsOnRoute event,
    Emitter<StationsOnRouteState> emit,
  ) {
    // Quay BLoC này về trạng thái ban đầu
    emit(const StationsOnRouteState());
    // Đồng thời ra lệnh cho StationBloc xóa bộ lọc
    _stationBloc.add(ClearStationFilter());
  }
}