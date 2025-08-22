// lib/presentation/map/widgets/station_cluster_lego.dart

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_marker_icon.dart';
import '../../../domain/entities/station_entity.dart';
import '../../bloc/station_bloc.dart';
import '../../bloc/station_selection_bloc.dart';

class StationClusterLego extends StatelessWidget {
  final void Function(Set<Marker> markers) onMarkersUpdated;
  
  const StationClusterLego({super.key, required this.onMarkersUpdated});
  
  @override
  Widget build(BuildContext context) {
    return _StationClusterLegoView(onMarkersUpdated: onMarkersUpdated);
  }
}

class _StationClusterLegoView extends StatefulWidget {
  final void Function(Set<Marker> markers) onMarkersUpdated;
  const _StationClusterLegoView({required this.onMarkersUpdated});

  @override
  State<_StationClusterLegoView> createState() => _StationClusterLegoViewState();
}

class _StationClusterLegoViewState extends State<_StationClusterLegoView> {
  // --- THAY ĐỔI: Thêm ClusterManager trở lại ---
  // Sếp hãy đảm bảo đã import hoặc định nghĩa class ClusterManager nếu cần.
  // Giả định sếp có class ClusterManager(clusterManagerId: ...).
  // Nếu không có, hãy tạm comment dòng này và `clusterManagerId` bên dưới.
  // final ClusterManager _clusterManager = const ClusterManager(
  //   clusterManagerId: ClusterManagerId('stations_cluster_manager'),
  // );

  // Cache chỉ dành cho icon được focus (chỉ có 1 cái tại một thời điểm)
  BitmapDescriptor? _focusedIcon;
  String? _focusedIconId;

  // --- THAY ĐỔI: Tải sẵn icon mặc định siêu nhanh ---
  BitmapDescriptor? _defaultStationIcon;

  @override
  void initState() {
    super.initState();
    _loadDefaultIcon();
  }

  Future<void> _loadDefaultIcon() async {
    // Tải icon tĩnh từ assets, thao tác này rất nhanh.
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(30, 30)), // Kích thước của icon không focus
      'assets/icons/station_marker.png' // <-- Sếp hãy đảm bảo đường dẫn này đúng
    );
    if (mounted) setState(() => _defaultStationIcon = icon);
  }

  Future<BitmapDescriptor> _createFocusedMarkerIcon(BuildContext context, StationEntity station) async {
    // Chỉ tạo lại icon focus nếu trạm được chọn thay đổi
    if (_focusedIconId == station.id && _focusedIcon != null) {
      return _focusedIcon!;
    }
    
    // Logic "chụp ảnh" widget chỉ chạy cho 1 trạm duy nhất khi được chọn
    final key = GlobalKey();
    final widgetToCapture = RepaintBoundary(
      key: key,
      child: StationMarkerIcon(
        connectorCount: station.totalConnectors,
        isFocused: true,
      ),
    );

    final completer = Completer<BitmapDescriptor>();
    // Logic render và chụp ảnh không thay đổi
    OverlayEntry? entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: -1000,
        child: Material(type: MaterialType.transparency, child: widgetToCapture),
      ),
    );
    Overlay.of(context).insert(entry);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 2.5);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();
        final descriptor = BitmapDescriptor.bytes(bytes);

        _focusedIcon = descriptor;
        _focusedIconId = station.id;
        completer.complete(descriptor);
      } finally {
        entry?.remove();
      }
    });

    return completer.future;
  }

  Future<void> _updateMarkers(BuildContext context, Map<String, StationEntity> stations, String? selectedStationId) async {
    if (!mounted || _defaultStationIcon == null) return;

    final markers = <Marker>{};
    for (final station in stations.values) {
      final isFocused = station.id == selectedStationId;
      BitmapDescriptor icon;

      if (isFocused) {
        // Chỉ chạy logic TỐN KÉM cho DUY NHẤT 1 trạm được chọn
        icon = await _createFocusedMarkerIcon(context, station);
      } else {
        // Dùng icon mặc định SIÊU NHANH cho hàng trăm/ngàn trạm còn lại
        icon = _defaultStationIcon!;
      }

      markers.add(
        Marker(
          markerId: MarkerId(station.id),
          position: station.position,
          icon: icon,
          zIndexInt: isFocused ? 1 : 1,
          // --- KHÔI PHỤC: Thêm clusterManagerId để bật lại tính năng gom cụm ---
          // clusterManagerId: _clusterManager.clusterManagerId, 
          onTap: () {
            context.read<StationSelectionBloc>().add(StationSelected(station));
          },
        ),
      );
    }
    
    if (mounted) {
      widget.onMarkersUpdated(markers);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StationBloc, StationState>(
      listenWhen: (prev, curr) => prev.stations != curr.stations,
      listener: (context, stationState) {
        final selectionState = context.read<StationSelectionBloc>().state;
        final selectedId = selectionState is StationSelectionSuccess ? selectionState.selectedStation.id : null;
        _updateMarkers(context, stationState.stations, selectedId);
      },
      builder: (context, stationState) {
        return BlocListener<StationSelectionBloc, StationSelectionState>(
          listener: (context, selectionState) {
            final selectedId = selectionState is StationSelectionSuccess ? selectionState.selectedStation.id : null;
            _updateMarkers(context, stationState.stations, selectedId);
          },
          child: const SizedBox.shrink(),
        );
      },
    );
  }
}