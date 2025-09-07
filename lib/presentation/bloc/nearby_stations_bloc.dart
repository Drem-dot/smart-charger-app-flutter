// lib/presentation/bloc/nearby_stations_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/filter_params.dart';
import 'package:smart_charger_app/presentation/services/location_service.dart';
import 'package:stream_transform/stream_transform.dart';
import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/repositories/i_station_repository.dart';

part 'nearby_stations_event.dart';
part 'nearby_stations_state.dart';

EventTransformer<E> debounce<E>(Duration duration) {
  return (events, mapper) => events.debounce(duration).switchMap(mapper);
}

class NearbyStationsBloc extends Bloc<NearbyStationsEvent, NearbyStationsState> {
  final IStationRepository _stationRepository;
  final ISettingsRepository _settingsRepository;
  final LocationService _locationService;

  NearbyStationsBloc({
    required IStationRepository stationRepository,
    required ISettingsRepository settingsRepository,
    required LocationService locationService,
  })  : _stationRepository = stationRepository,
        _settingsRepository = settingsRepository,
        _locationService = locationService,
        super(const NearbyStationsState(radius: 2.0)) {
    
    on<InitialStationsRequested>(_onInitialStationsRequested);
    on<FetchNearbyStations>(_onFetchStations);
    on<FetchStationsAroundPoint>(_onFetchStationsAroundPoint);
    on<RadiusChanged>(_onRadiusChanged);
    on<RadiusChangeCompleted>(
      _onRadiusChangeCompleted,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
    on<FilterApplied>(_onFilterApplied);
  }

  Future<void> _onInitialStationsRequested(
    InitialStationsRequested event, Emitter<NearbyStationsState> emit
  ) async {
    try {
      final savedRadius = await _settingsRepository.getSearchRadius();
      emit(state.copyWith(radius: savedRadius));

      final hasPermission = await _locationService.requestPermissionAndService();
      if (!hasPermission) {
        throw Exception('Quyền truy cập vị trí bị từ chối.');
      }
      final position = await _locationService.onLocationChanged.first.timeout(const Duration(seconds: 10));
      
      emit(state.copyWith(currentUserPosition: position));
      // Bắn event fetch lần đầu, chỉ lấy 3 trạm cho carousel
      add(FetchNearbyStations(LatLng(position.latitude, position.longitude), limit: 3)); 

    } catch (e) {
      emit(state.copyWith(
        status: NearbyStationsStatus.failure, 
        error: e.toString()
      ));
    }
  }

  Future<void> _onFetchStations(
    FetchNearbyStations event, Emitter<NearbyStationsState> emit) async {
    emit(state.copyWith(status: NearbyStationsStatus.loading));
    try {
      final stationsFromRepo = await _stationRepository.getNearbyStations(
        position: event.position,
        radiusKm: state.radius,
        limit: event.limit,
        filterParams: state.filterParams,
      );
      
      // Tạo một danh sách mới với các đối tượng StationEntity đã được cập nhật
      final stationsWithDistance = stationsFromRepo.map((station) {
        final distanceInMeters = Geolocator.distanceBetween(
          event.position.latitude,
          event.position.longitude,
          station.lat,
          station.lon,
        );
        // Sử dụng `copyWith` để tạo một bản sao mới với thông tin khoảng cách
        return station.copyWith(distanceInKm: distanceInMeters / 1000);
      }).toList();

      emit(state.copyWith(
        status: NearbyStationsStatus.success, 
        stations: stationsWithDistance
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NearbyStationsStatus.failure, 
        error: e.toString()
      ));
    }
  }
  void _onRadiusChanged(RadiusChanged event, Emitter<NearbyStationsState> emit) {
    emit(state.copyWith(radius: event.newRadius));
  }
  
  // --- HÀM ĐÃ ĐƯỢC SỬA LỖI ---
  void _onFilterApplied(FilterApplied event, Emitter<NearbyStationsState> emit) {
    // 1. Cập nhật bộ lọc trong state
    emit(state.copyWith(filterParams: event.filterParams));
    
    // 2. Tự động fetch lại dữ liệu với bộ lọc mới
    // Lần fetch này sẽ lấy tất cả các trạm, không còn limit = 3 nữa.
    if (state.currentUserPosition != null) {
      add(FetchNearbyStations(
        LatLng(state.currentUserPosition!.latitude, state.currentUserPosition!.longitude),
        // KHÔNG còn truyền filterParams vào đây
      ));
    }
  }

  Future<void> _onRadiusChangeCompleted(
    RadiusChangeCompleted event, Emitter<NearbyStationsState> emit) async {
    await _settingsRepository.saveSearchRadius(state.radius);
    add(FetchNearbyStations(event.position));
  }

  Future<void> _onFetchStationsAroundPoint(
    FetchStationsAroundPoint event, Emitter<NearbyStationsState> emit
  ) async {
    // Không cần set status là loading để UI mượt hơn khi tìm kiếm
    try {
      final stationsFromRepo = await _stationRepository.getNearbyStations(
        position: event.point,
        radiusKm: state.radius,
        filterParams: state.filterParams,
      );

      // Tạo một danh sách mới với các đối tượng StationEntity đã được cập nhật
      final stationsWithDistance = stationsFromRepo.map((station) {
        final distanceInMeters = Geolocator.distanceBetween(
          event.point.latitude,
          event.point.longitude,
          station.lat,
          station.lon,
        );
        // Sử dụng `copyWith` để tạo một bản sao mới với thông tin khoảng cách
        return station.copyWith(distanceInKm: distanceInMeters / 1000);
      }).toList();
      
      emit(state.copyWith(
        status: NearbyStationsStatus.success, 
        stations: stationsWithDistance
      ));
    } catch (e) {
      emit(state.copyWith(
        status: NearbyStationsStatus.failure, 
        error: e.toString()
      ));
    }
  }
}