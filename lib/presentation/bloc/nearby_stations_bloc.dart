import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  NearbyStationsBloc(this._stationRepository, this._settingsRepository)
      : super(const NearbyStationsInitial(radius: 2.0)) {
    on<LoadInitialRadius>(_onLoadInitialRadius);
    on<FetchNearbyStations>(_onFetchStations);
    on<RadiusChanged>(_onRadiusChanged);
    on<RadiusChangeCompleted>(
      _onRadiusChangeCompleted,
      transformer: debounce(const Duration(milliseconds: 500)),
    );
  }

  Future<void> _onLoadInitialRadius(
    LoadInitialRadius event, Emitter<NearbyStationsState> emit) async {
    final savedRadius = await _settingsRepository.getSearchRadius();
    emit(NearbyStationsInitial(radius: savedRadius));
  }

  Future<void> _onFetchStations(
    FetchNearbyStations event, Emitter<NearbyStationsState> emit) async {
    emit(NearbyStationsLoading(radius: state.radius));
    try {
      final stations = await _stationRepository.getNearbyStations(
        position: event.position,
        radiusKm: state.radius,
      );
      emit(NearbyStationsSuccess(stations: stations, radius: state.radius));
    } catch (e) {
      emit(NearbyStationsFailure(error: e.toString(), radius: state.radius));
    }
  }

  void _onRadiusChanged(RadiusChanged event, Emitter<NearbyStationsState> emit) {
    if (state is NearbyStationsSuccess) {
      emit(NearbyStationsSuccess(
          stations: (state as NearbyStationsSuccess).stations, radius: event.newRadius));
    } else {
      emit(NearbyStationsInitial(radius: event.newRadius));
    }
  }
  
  Future<void> _onRadiusChangeCompleted(
    RadiusChangeCompleted event, Emitter<NearbyStationsState> emit) async {
    await _settingsRepository.saveSearchRadius(state.radius);
    add(FetchNearbyStations(event.position));
  }
}