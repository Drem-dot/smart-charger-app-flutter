// station_bloc.dart

import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/station_entity.dart';
import '../../domain/repositories/i_station_repository.dart';

part 'station_event.dart';
part 'station_state.dart';

class StationBloc extends Bloc<StationEvent, StationState> {
  final IStationRepository _stationRepository;
  static const double _gridSize = 0.05; // Giả định

  StationBloc(this._stationRepository) : super(const StationState()) {
    // Chỉ xử lý event fetch dữ liệu
    on<StationsInBoundsFetched>(_onStationsInBoundsFetched);
    on<FilterStationsRequested>(_onFilterStationsRequested);
    on<ClearStationFilter>(_onClearStationFilter);
  }

  Future<void> _onStationsInBoundsFetched(
    StationsInBoundsFetched event,
    Emitter<StationState> emit,
  ) async {
    // --- Logic chunk-loading của sếp được GIỮ NGUYÊN HOÀN TOÀN ---
    final bufferedBounds = _getBufferedBounds(event.visibleBounds, 1.5);
    final requiredChunkIds = _calculateChunksInBounds(bufferedBounds);
    final chunkIdsToFetch = requiredChunkIds.difference(state.loadedChunkIds).toList();

    if (chunkIdsToFetch.isEmpty) return;

    // In ra để debug (tùy chọn)
    // print("Fetching chunks: $chunkIdsToFetch");

    final newStations = await _stationRepository.getStationsByChunkIds(chunkIdsToFetch);
    if (newStations.isEmpty && chunkIdsToFetch.isNotEmpty) {
        // Nếu không có trạm mới, vẫn đánh dấu chunk đã được load để tránh gọi lại
        final updatedLoadedChunks = Set<String>.from(state.loadedChunkIds)
            ..addAll(chunkIdsToFetch);
        emit(state.copyWith(loadedChunkIds: updatedLoadedChunks));
        return;
    }
    
    final newStationsMap = {for (var s in newStations) s.id: s};
    
    final updatedStations = Map<String, StationEntity>.from(state.stations)
      ..addAll(newStationsMap);
    final updatedLoadedChunks = Set<String>.from(state.loadedChunkIds)
      ..addAll(chunkIdsToFetch);

    emit(state.copyWith(
      stations: updatedStations,
      loadedChunkIds: updatedLoadedChunks,
    ));
  }
  
  void _onFilterStationsRequested(FilterStationsRequested event, Emitter<StationState> emit) {
    final filteredMap = {for (var s in event.stationsToShow) s.id: s};
    emit(state.copyWith(filteredStations: () => filteredMap));
  }

  void _onClearStationFilter(ClearStationFilter event, Emitter<StationState> emit) {
    emit(state.copyWith(filteredStations: () => null));
  }

  Set<String> _calculateChunksInBounds(LatLngBounds bounds) {
    // ... (giữ nguyên)
    final int minLatChunk = (bounds.southwest.latitude / _gridSize).floor();
    final int maxLatChunk = (bounds.northeast.latitude / _gridSize).floor();
    final int minLonChunk = (bounds.southwest.longitude / _gridSize).floor();
    final int maxLonChunk = (bounds.northeast.longitude / _gridSize).floor();

    final Set<String> chunks = {};
    for (int lat = minLatChunk; lat <= maxLatChunk; lat++) {
      for (int lon = minLonChunk; lon <= maxLonChunk; lon++) {
        chunks.add('chunk_${lat}_$lon');
      }
    }
    return chunks;
  }
  
  LatLngBounds _getBufferedBounds(LatLngBounds bounds, double factor) {
    // ... (giữ nguyên)
     final double latDelta = (bounds.northeast.latitude - bounds.southwest.latitude).abs();
    final double lonDelta = (bounds.northeast.longitude - bounds.southwest.longitude).abs();
    final double latPadding = latDelta * (factor - 1) / 2;
    final double lonPadding = lonDelta * (factor - 1) / 2;
    return LatLngBounds(
      southwest: LatLng(bounds.southwest.latitude - latPadding, bounds.southwest.longitude - lonPadding),
      northeast: LatLng(bounds.northeast.latitude + latPadding, bounds.northeast.longitude + lonPadding),
    );
  }
}