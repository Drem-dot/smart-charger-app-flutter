// lib/presentation/map/widgets/station_cluster_lego.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../bloc/station_bloc.dart';
import '../../bloc/station_selection_bloc.dart'; // Import để bắn event

class StationClusterLego extends StatefulWidget {
  // Sửa đổi: Callback bây giờ chỉ cần trả về Set<Marker>
  // Map dữ liệu không còn cần thiết ở tầng cha nữa.
  final void Function(Set<Marker> markers) onMarkersUpdated;
  
  const StationClusterLego({super.key, required this.onMarkersUpdated});
  
  @override
  State<StationClusterLego> createState() => _StationClusterLegoState();
}

class _StationClusterLegoState extends State<StationClusterLego> {
  final ClusterManager _clusterManager = const ClusterManager(
    clusterManagerId: ClusterManagerId('stations_cluster_manager'),
  );
  BitmapDescriptor? _stationIcon;

  @override
  void initState() {
    super.initState();
    _loadStationIcon();
  }

  Future<void> _loadStationIcon() async {
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), 'assets/icons/station_marker.png');
    if (mounted) setState(() => _stationIcon = icon);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StationBloc, StationState>(
      listenWhen: (previous, current) => previous.stations != current.stations,
      listener: (context, state) {
        if (_stationIcon == null) return;

        final newMarkers = state.stations.values.map((station) {
          final markerId = MarkerId(station.id);
          return Marker(
            markerId: markerId,
            position: LatLng(station.lat, station.lon),
            icon: _stationIcon!,
            clusterManagerId: _clusterManager.clusterManagerId,
            infoWindow: InfoWindow(title: station.name),
            // SỬA LỖI: Xử lý sự kiện tap ngay tại đây
            onTap: () {
              // Gửi event trực tiếp đến StationSelectionBloc
              context.read<StationSelectionBloc>().add(StationSelected(station));
            },
          );
        }).toSet();
        
        // Gọi callback chỉ với Set<Marker>
        widget.onMarkersUpdated(newMarkers);
      },
      child: const SizedBox.shrink(),
    );
  }
}