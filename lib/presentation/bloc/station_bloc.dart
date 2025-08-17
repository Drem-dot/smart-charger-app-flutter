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
  static const double _gridSize = 0.05;

  StationBloc(this._stationRepository) : super(const StationState()) {
    on<StationsInBoundsFetched>(_onStationsInBoundsFetched);
    on<StationMarkersUpdated>(_onStationMarkersUpdated);
    on<ClusterManagerInitialized>(_onClusterManagerInitialized);
  }

  // Xử lý việc fetch dữ liệu thô
  Future<void> _onStationsInBoundsFetched(
    StationsInBoundsFetched event,
    Emitter<StationState> emit,
  ) async {
    // ... logic tính toán chunk và gọi repository như cũ ...
    final bufferedBounds = _getBufferedBounds(event.visibleBounds, 1.5);
    final requiredChunkIds = _calculateChunksInBounds(bufferedBounds);
    final chunkIdsToFetch = requiredChunkIds.difference(state.loadedChunkIds).toList();

    if (chunkIdsToFetch.isEmpty) return;

    final newStations = await _stationRepository.getStationsByChunkIds(chunkIdsToFetch);
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

  // Xử lý yêu cầu cập nhật marker từ Lego
  void _onStationMarkersUpdated(
    StationMarkersUpdated event,
    Emitter<StationState> emit,
  ) {
    emit(state.copyWith(markers: event.markers));
  }
  
  // Xử lý yêu cầu khởi tạo cluster manager từ Lego
  void _onClusterManagerInitialized(
    ClusterManagerInitialized event,
    Emitter<StationState> emit,
  ) {
    final updatedManagers = Set<ClusterManager>.from(state.clusterManagers)
      ..add(event.clusterManager);
    emit(state.copyWith(clusterManagers: updatedManagers));
  }
  
  // --- Helper Functions ---
  Set<String> _calculateChunksInBounds(LatLngBounds bounds) {
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