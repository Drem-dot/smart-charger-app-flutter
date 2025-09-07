import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_station_repository.dart';
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';

part 'station_event.dart';
part 'station_state.dart';

class StationBloc extends Bloc<StationEvent, StationState> {
  final IStationRepository _stationRepository;
  StreamSubscription? _routeSubscription;

  static const double _gridSize = 0.05;

  // Constructor đã được cập nhật để nhận Stream<RouteState>
  StationBloc({
    required IStationRepository stationRepository,
    required Stream<RouteState> routeStream,
  })  : _stationRepository = stationRepository,
        super(const StationState()) {
    
    // Đăng ký lắng nghe stream của RouteBloc
    _routeSubscription = routeStream.listen((routeState) {
      // Logic này hoạt động như một lớp bảo vệ dự phòng.
      // Nếu vì lý do nào đó mà StationsOnRouteBloc không kịp reset,
      // việc RouteBloc chuyển về trạng thái không phải RouteSuccess
      // cũng sẽ kích hoạt việc xóa bộ lọc.
      if (state.filteredStations != null && routeState is! RouteSuccess) {
        add(ClearStationFilter());
      }
    });

    // Đăng ký các handler cho event của chính BLoC này
    on<StationsInBoundsFetched>(_onStationsInBoundsFetched);
    on<FilterStationsRequested>(_onFilterStationsRequested);
    on<ClearStationFilter>(_onClearStationFilter);
  }

  @override
  Future<void> close() {
    // Hủy đăng ký lắng nghe để tránh rò rỉ bộ nhớ
    _routeSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStationsInBoundsFetched(
    StationsInBoundsFetched event,
    Emitter<StationState> emit,
  ) async {
    final bufferedBounds = _getBufferedBounds(event.visibleBounds, 1.5);
    final requiredChunkIds = _calculateChunksInBounds(bufferedBounds);

    // Logic loại bỏ (eviction)
    final Set<String> evictableChunkIds = state.loadedChunkIds.difference(requiredChunkIds);
    final Map<String, StationEntity> stationsAfterEviction = Map.from(state.stations);

    if (evictableChunkIds.isNotEmpty) {
      stationsAfterEviction.removeWhere(
        // Giả định StationEntity có thuộc tính chunkId.
        // Sếp cần đảm bảo điều này khi parse dữ liệu.
        (stationId, station) => evictableChunkIds.contains(station.chunkId) 
      );
    }
    
    final chunkIdsToFetch = requiredChunkIds.difference(state.loadedChunkIds).toList();
    if (chunkIdsToFetch.isEmpty) {
      if (evictableChunkIds.isNotEmpty) {
        emit(state.copyWith(
          stations: stationsAfterEviction,
          loadedChunkIds: requiredChunkIds,
        ));
      }
      return;
    }

    final newStations = await _stationRepository.getStationsByChunkIds(chunkIdsToFetch);
    
    // Xử lý trường hợp không có trạm nào được trả về
    if (newStations.isEmpty) {
        final updatedLoadedChunks = Set<String>.from(state.loadedChunkIds)..addAll(chunkIdsToFetch);
        emit(state.copyWith(
          stations: stationsAfterEviction,
          loadedChunkIds: updatedLoadedChunks.difference(evictableChunkIds)
        ));
        return;
    }
    
    final newStationsMap = {for (var s in newStations) s.id: s};
    final updatedStations = stationsAfterEviction..addAll(newStationsMap);
    
    emit(state.copyWith(
      stations: updatedStations,
      loadedChunkIds: requiredChunkIds,
    ));
  }
  
  void _onFilterStationsRequested(FilterStationsRequested event, Emitter<StationState> emit) {
    final filteredMap = {for (var s in event.stationsToShow) s.id: s};
    emit(state.copyWith(filteredStations: () => filteredMap));
  }

  void _onClearStationFilter(ClearStationFilter event, Emitter<StationState> emit) {
    emit(state.copyWith(filteredStations: () => null));
  }

  // --- Các hàm Helper ---
  Set<String> _calculateChunksInBounds(LatLngBounds bounds) {
    final int minLatChunk = (bounds.southwest.latitude / _gridSize).floor();
    final int maxLatChunk = (bounds.northeast.latitude / _gridSize).floor();
    final int minLonChunk = (bounds.southwest.longitude / _gridSize).floor();
    final int maxLonChunk  = (bounds.northeast.longitude / _gridSize).floor();

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