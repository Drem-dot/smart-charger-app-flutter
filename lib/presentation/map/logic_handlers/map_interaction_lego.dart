// lib/presentation/map/logic_handlers/map_interaction_lego.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/presentation/bloc/point_selection_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/route_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_bloc.dart';

/// Lego này quản lý các tương tác trực tiếp của người dùng lên bản đồ
class MapInteractionLego extends StatelessWidget {
  static const double minFetchZoomLevel = 9.5;
  final GoogleMapController controller;
  
  const MapInteractionLego({super.key, required this.controller});

   void onCameraIdle(BuildContext context) async {
    try {
      final zoom = await controller.getZoomLevel();
      
      // --- BẢO VỆ CONTEXT ---
      // Kiểm tra xem context có còn hợp lệ không SAU khi await
      if (!context.mounted) return;

      if (zoom < minFetchZoomLevel) {
        // Có thể thêm logic xóa trạm ở đây nếu cần
        return;
      }
      
      final visibleBounds = await controller.getVisibleRegion();
      
      // --- BẢO VỆ CONTEXT (Lần 2) ---
      if (!context.mounted) return;
      
      context.read<StationBloc>().add(StationsInBoundsFetched(visibleBounds));
    } catch (e) {
      debugPrint("Lỗi trong onCameraIdle: $e");
    }
  }
  
  void onLongPress(BuildContext context, LatLng position) {
    final pointSelectionBloc = context.read<PointSelectionBloc>();
    if (pointSelectionBloc.state is PointSelectionInProgress) {
      final type = (pointSelectionBloc.state as PointSelectionInProgress).type;
      final name = '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
      
      if (type == PointType.origin) {
        context.read<RouteBloc>().add(OriginUpdated(position: position, name: name));
      } else {
        context.read<RouteBloc>().add(DestinationUpdated(position: position, name: name));
      }
      pointSelectionBloc.add(SelectionFinalized());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Widget này không build UI, nó chỉ chứa logic để truyền vào GoogleMap
    return const SizedBox.shrink();
  }
}