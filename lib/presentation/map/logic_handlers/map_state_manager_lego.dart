// lib/presentation/map/logic_handlers/map_state_manager_lego.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/point_selection_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/stations_on_route_bloc.dart';

/// Lego này quản lý việc lắng nghe các BLoC và cập nhật state chung của bản đồ
/// (camera, polylines, ghim tạm thời).
class MapStateManagerLego extends StatefulWidget {
  final GoogleMapController controller;
  final Function(Set<Polyline>) onPolylinesUpdated;
  final Function(Set<Marker>) onRoutePinsUpdated;
  
  const MapStateManagerLego({
    super.key,
    required this.controller,
    required this.onPolylinesUpdated,
    required this.onRoutePinsUpdated,
  });

  @override
  State<MapStateManagerLego> createState() => _MapStateManagerLegoState();
}

class _MapStateManagerLegoState extends State<MapStateManagerLego> {
  StreamSubscription? _routeBlocSubscription;

  @override
  void initState() {
    super.initState();
    _listenToRouteBloc();
  }

  // Lắng nghe RouteBloc để cập nhật Polylines và Pins
  void _listenToRouteBloc() {
    _routeBlocSubscription = context.read<RouteBloc>().stream.listen((routeState) {
      // Cập nhật Polylines
      if (routeState is RouteSuccess && routeState.route != null) {
        final newPolyline = Polyline(
          polylineId: const PolylineId('route'),
          points: routeState.route!.polylinePoints,
          color: Colors.blue,
          width: 5,
          zIndex: 1, 
        );
        widget.onPolylinesUpdated({newPolyline});
      } else {
        widget.onPolylinesUpdated({});
      }
      
      // Cập nhật Route Pins
      _updateRoutePins(routeState);
    });
  }

  void _updateRoutePins(RouteState routeState) {
    final Set<Marker> routePins = {};
    if (routeState.originPosition != null) {
      routePins.add(Marker(
        markerId: const MarkerId('origin_pin'),
        position: routeState.originPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(title: routeState.originName ?? 'Điểm bắt đầu'),
        zIndexInt: 4, 
      ));
    }
    if (routeState.destinationPosition != null) {
      routePins.add(Marker(
        markerId: const MarkerId('destination_pin'),
        position: routeState.destinationPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: InfoWindow(title: routeState.destinationName ?? 'Điểm kết thúc'),
        zIndexInt: 4, 
      ));
    }
    widget.onRoutePinsUpdated(routePins);
  }

  @override
  void dispose() {
    _routeBlocSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // MultiBlocListener xử lý các side-effect không cần setState
    return MultiBlocListener(
      listeners: [
        BlocListener<MapControlBloc, MapControlState>(
          listener: (context, state) {
            if (state is MapCameraUpdate) {
              widget.controller.animateCamera(state.cameraUpdate);
            }
          },
        ),
        BlocListener<PointSelectionBloc, PointSelectionState>(
          listener: (context, state) {
            if (state is PointSelectionInProgress) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Nhấn giữ để chọn điểm.')),
              );
            }
          },
        ),
        // Lắng nghe RouteBloc để xóa bộ lọc trạm
        BlocListener<RouteBloc, RouteState>(
          listener: (context, state) {
            if (state is! RouteSuccess) {
              context.read<StationBloc>().add(ClearStationFilter());
              context.read<StationsOnRouteBloc>().add(ResetStationsOnRoute());
            }
          },
        ),
      ],
      child: const SizedBox.shrink(),
    );
  }
}