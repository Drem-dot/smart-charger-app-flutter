import 'dart:math';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

part 'map_control_event.dart';
part 'map_control_state.dart';

class MapControlBloc extends Bloc<MapControlEvent, MapControlState> {
MapControlBloc() : super(MapControlInitial()) {
on<CameraMoveRequested>((event, emit) {
final cameraUpdate = CameraUpdate.newLatLngZoom(event.position, event.zoom);
emit(MapCameraUpdate(cameraUpdate));
});
// Thêm hàm xử lý cho event mới
on<CameraBoundsRequested>((event, emit) {
final cameraUpdate = CameraUpdate.newLatLngBounds(event.bounds, 50.0); // 50.0 là padding
emit(MapCameraUpdate(cameraUpdate));
});
}
}