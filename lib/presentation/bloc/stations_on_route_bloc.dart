import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/route_entity.dart';
import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/i_directions_repository.dart';
import '../../domain/repositories/i_settings_repository.dart';

part 'stations_on_route_event.dart';
part 'stations_on_route_state.dart';

/// Debounce transformer để tránh gọi API liên tục khi người dùng
/// thay đổi giá trị của Slider một cách nhanh chóng.
EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) {
    return events.debounce(duration).switchMap(mapper);
  };
}

class StationsOnRouteBloc extends Bloc<StationsOnRouteEvent, StationsOnRouteState> {
  final IDirectionsRepository _directionsRepository;
  final ISettingsRepository _settingsRepository;

  StationsOnRouteBloc(this._directionsRepository, this._settingsRepository)
      // Khởi tạo state với bán kính mặc định (sẽ được cập nhật sau)
      : super(const StationsOnRouteInitial(radius: 2.0)) {
    
    // Đăng ký các hàm xử lý cho từng event
    on<LoadInitialRadius>(_onLoadInitialRadius);
    on<FetchStationsOnRoute>(_onFetchStations);
    on<RadiusChanged>(_onRadiusChanged);
    on<RadiusChangeCompleted>(
      _onRadiusChangeCompleted, 
      // Áp dụng debounce chỉ cho event này
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }

  /// Tải bán kính đã lưu từ SharedPreferences và cập nhật state.
  /// Event này nên được gọi một lần khi Lego được khởi tạo.
  Future<void> _onLoadInitialRadius(
    LoadInitialRadius event,
    Emitter<StationsOnRouteState> emit,
  ) async {
    final savedRadius = await _settingsRepository.getSearchRadius();
    emit(StationsOnRouteInitial(radius: savedRadius));
  }

  /// Fetch danh sách các trạm sạc dựa trên một lộ trình và bán kính hiện tại.
  Future<void> _onFetchStations(
    FetchStationsOnRoute event,
    Emitter<StationsOnRouteState> emit,
  ) async {
    emit(StationsOnRouteLoading(radius: state.radius));
    try {
      final stations = await _directionsRepository.getStationsOnRoute(
        route: event.route,
        radiusKm: state.radius,
      );
      emit(StationsOnRouteSuccess(stations: stations, radius: state.radius));
    } catch (e) {
      emit(StationsOnRouteFailure(error: e.toString(), radius: state.radius));
    }
  }

  /// Cập nhật giá trị bán kính trong state ngay lập tức khi người dùng đang kéo Slider.
  /// Điều này giúp giao diện (ví dụ: text hiển thị giá trị) được cập nhật theo thời gian thực.
  void _onRadiusChanged(
    RadiusChanged event,
    Emitter<StationsOnRouteState> emit,
  ) {
    // Giữ lại danh sách trạm cũ (nếu có) và chỉ cập nhật bán kính
    if (state is StationsOnRouteSuccess) {
      emit(StationsOnRouteSuccess(stations: (state as StationsOnRouteSuccess).stations, radius: event.newRadius));
    } else {
      emit(StationsOnRouteInitial(radius: event.newRadius));
    }
  }
  
  /// Được gọi sau khi người dùng đã thả tay khỏi Slider (nhờ debounce).
  /// Lưu giá trị bán kính mới và sau đó fetch lại danh sách trạm.
  Future<void> _onRadiusChangeCompleted(
    RadiusChangeCompleted event,
    Emitter<StationsOnRouteState> emit,
  ) async {
    // Lưu bán kính mới vào SharedPreferences
    await _settingsRepository.saveSearchRadius(state.radius);
    // Bắn một event khác để fetch lại dữ liệu với bán kính mới
    add(FetchStationsOnRoute(event.route));
  }
}