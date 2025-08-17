import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc() : super(const MapState()) {
    on<MapMarkersUpdated>((event, emit) {
      emit(state.copyWith(markers: event.markers));
    });
    on<MapClusterManagersUpdated>((event, emit) {
      emit(state.copyWith(clusterManagers: event.clusterManagers));
    });
    on<MapMyLocationToggled>((event, emit) {
      emit(state.copyWith(isMyLocationEnabled: event.isEnabled));
    });
  }
}