import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide ClusterManager, Cluster;
import 'package:smart_charger_app/presentation/map/widgets/cluster_marker_widget.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_marker_widget.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../../bloc/map_control_bloc.dart';
import '../../bloc/station_bloc.dart';
import '../../bloc/station_selection_bloc.dart';
import '../widgets/station_cluster_item.dart';

class StationMarkerManagerController {
  // Hàm `onCameraMove` sẽ được gán từ State bên dưới
  late final void Function(CameraPosition) onCameraMove;
  // Hàm `onCameraIdle` sẽ được gán từ State bên dưới
  late final VoidCallback onCameraIdle;
}

class StationMarkerManagerLego extends StatefulWidget {
  final Function(Set<Marker>) onMarkersUpdated;
  final GoogleMapController controller;
  final StationMarkerManagerController? managerController;

  const StationMarkerManagerLego({
    super.key,
    required this.onMarkersUpdated,
    required this.controller,
    this.managerController,
  });

  @override
  State<StationMarkerManagerLego> createState() => _StationMarkerManagerLegoState();
}

class _StationMarkerManagerLegoState extends State<StationMarkerManagerLego> {
  late ClusterManager<StationClusterItem> _clusterManager;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  StreamSubscription? _stationBlocSubscription;
  StreamSubscription? _stationSelectionSubscription;

  @override
  void initState() {
    super.initState();
    _clusterManager = _initClusterManager([]);
    
    // --- THÊM MỚI: "Nối dây" các hàm từ State vào Controller ---
    if (widget.managerController != null) {
      widget.managerController!.onCameraMove = (position) {
        _clusterManager.onCameraMove(position);
      };
      widget.managerController!.onCameraIdle = () {
        _clusterManager.updateMap();
      };
    }
    
    _warmUpIconCache();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _clusterManager.setMapId(widget.controller.mapId);
        _initializeListeners();
      }
    });
  }
  

  void _initializeListeners() {
    final stationBloc = context.read<StationBloc>();
    // Cập nhật items ban đầu
    final initialItems = stationBloc.state.stationsToDisplay.values
        .map((s) => StationClusterItem(station: s))
        .toList();
    _clusterManager.setItems(initialItems);

    // Lắng nghe các thay đổi state sau này
    _stationBlocSubscription = stationBloc.stream.listen((state) {
      final clusterItems = state.stationsToDisplay.values
          .map((s) => StationClusterItem(station: s))
          .toList();
      _clusterManager.setItems(clusterItems);
    });

    _stationSelectionSubscription = context.read<StationSelectionBloc>().stream.listen((_) {
      _clusterManager.updateMap();
    });
  }
  
  // --- HÀM ĐÃ ĐƯỢC SỬA LỖI ---

  @override
  void dispose() {
    _stationBlocSubscription?.cancel();
    _stationSelectionSubscription?.cancel();
    super.dispose();
  }

  void _warmUpIconCache() {
    for (int i = 1; i <= 50; i++) {
      final normalKey = 'icon_${i}_false';
      final normalWidget = StationMarkerWidget(count: i, isFocused: false);
      normalWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
          .then((icon) => _markerIconCache[normalKey] = icon);

      final focusedKey = 'icon_${i}_true';
      final focusedWidget = StationMarkerWidget(count: i, isFocused: true);
      focusedWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
          .then((icon) => _markerIconCache[focusedKey] = icon);
    }
  }

  ClusterManager<StationClusterItem> _initClusterManager(List<StationClusterItem> items) {
    return ClusterManager<StationClusterItem>(
      items,
      widget.onMarkersUpdated,
      markerBuilder: _markerBuilder,
      stopClusteringZoom: 15.0, 
    );
  }

  // --- HÀM ĐÃ ĐƯỢỢC SỬA LỖI ---
  Future<Marker> _markerBuilder(Cluster<StationClusterItem> cluster) async {
    try {
      // Kiểm tra context còn hợp lệ trước khi sử dụng
      if (!mounted) {
        return Marker(markerId: MarkerId(cluster.getId()), position: cluster.location);
      }
    
      final selectionState = context.read<StationSelectionBloc>().state;
      final selectedStationId = selectionState is StationSelectionSuccess
          ? selectionState.selectedStation.id
          : null;
      final String cacheKey;
      final Widget markerWidget;
      bool isFocused;

      if (cluster.isMultiple) {
        cacheKey = 'cluster_${cluster.count}';
        markerWidget = ClusterMarkerWidget(count: cluster.count);
        isFocused = false;
      } else {
        final station = cluster.items.first.station;
        isFocused = station.id == selectedStationId;
        cacheKey = 'icon_${station.totalConnectors}_$isFocused';
        markerWidget = StationMarkerWidget(
          count: station.totalConnectors,
          isFocused: isFocused,
        );
      }

      BitmapDescriptor icon;
      if (_markerIconCache.containsKey(cacheKey)) {
        icon = _markerIconCache[cacheKey]!;
      } else {
        icon = await markerWidget.toBitmapDescriptor(
          logicalSize: const Size(100, 110),
          imageSize: const Size(200, 220),
        );
        _markerIconCache[cacheKey] = icon;
      }

      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: icon,
        zIndexInt: isFocused ? 1 : 0,
        onTap: () {
          if (!cluster.isMultiple && mounted) {
            try {
              final station = cluster.items.first.station;
              context.read<StationSelectionBloc>().add(StationSelected(station));
              context.read<MapControlBloc>().add(CameraMoveRequested(LatLng(station.lat, station.lon), 16.0));
            } catch (e) {
              debugPrint("Lỗi khi chọn station: $e");
            }
          }
        },
      );
    } catch (e) {
      debugPrint("Lỗi trong _markerBuilder: $e");
      // Fallback: Luôn trả về một marker hợp lệ ngay cả khi có lỗi
      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: BitmapDescriptor.defaultMarker, // Dùng marker mặc định nếu có lỗi
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}