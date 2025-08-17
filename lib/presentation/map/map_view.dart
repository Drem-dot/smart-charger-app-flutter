import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../bloc/map_control_bloc.dart';
import '../bloc/point_selection_bloc.dart';
import '../bloc/route_bloc.dart';
import '../bloc/station_bloc.dart';
import '../services/location_service.dart';
import 'widgets/add_station_lego.dart'; // Import Lego mới
import 'widgets/nearby_stations_lego.dart';
import 'widgets/route_polyline_lego.dart';
import 'widgets/search_lego.dart';
import 'widgets/station_cluster_lego.dart';
import 'widgets/station_details_lego.dart';
import 'widgets/user_location_lego.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // --- Controllers & Services ---
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();

  // --- State ---
  Set<Marker> _stationMarkers = {};
  Marker? _userMarker;
  Set<Polyline> _polylines = {};
  final ClusterManager _stationsClusterManager = const ClusterManager(
    clusterManagerId: ClusterManagerId('stations_cluster_manager'),
  );
  StreamSubscription<Position>? _locationSubscription;
  Position? _currentUserPosition;
  final bool _isMovingToUserLocation = false;

  @override
  void initState() {
    super.initState();
    _controllerCompleter.future.then((controller) {
      if (mounted) {
        setState(() => _mapController = controller);
        _onCameraIdle();
      }
    });
    _initializeUserLocationStream();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  void _initializeUserLocationStream() async {
    final hasPermission = await _locationService.requestPermissionAndService();
    if (!hasPermission || !mounted) return;
    _locationSubscription = _locationService.onLocationChanged.listen(
      (Position position) {
        if (mounted) {
          setState(() {
            _currentUserPosition = position;
          });
        }
      },
      onError: (error) => debugPrint("Lỗi stream vị trí: $error"),
    );
  }
  
  void _moveToMyLocation() async {
    if (_currentUserPosition == null) return;
    context.read<MapControlBloc>().add(
      CameraMoveRequested(
        LatLng(_currentUserPosition!.latitude, _currentUserPosition!.longitude), 
        16.0,
      ),
    );
  }

  void _onCameraIdle() async {
    final controller = _mapController;
    if (controller == null) return;
    final visibleBounds = await controller.getVisibleRegion();
    if (mounted) {
      context.read<StationBloc>().add(StationsInBoundsFetched(visibleBounds));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Charger Map')),
      body: MultiBlocListener(
        listeners: [
          BlocListener<MapControlBloc, MapControlState>(
            listener: (context, state) async {
              if (state is MapCameraUpdate) {
                final controller = await _controllerCompleter.future;
                controller.animateCamera(state.cameraUpdate);
              }
            },
          ),
          BlocListener<PointSelectionBloc, PointSelectionState>(
            listener: (context, state) {
              if (state is PointSelectionInProgress) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nhấn giữ (hoặc chuột phải trên web) để chọn điểm.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<RouteBloc, RouteState>(
          builder: (context, routeState) {
            final Set<Marker> routePins = {};
            if (routeState.originPosition != null) {
              routePins.add(Marker(
                markerId: const MarkerId('origin_pin'),
                position: routeState.originPosition!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(title: routeState.originName ?? 'Điểm bắt đầu'),
              ));
            }
            if (routeState.destinationPosition != null) {
              routePins.add(Marker(
                markerId: const MarkerId('destination_pin'),
                position: routeState.destinationPosition!,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                infoWindow: InfoWindow(title: routeState.destinationName ?? 'Điểm kết thúc'),
              ));
            }

            final allMarkers = { ..._stationMarkers, if (_userMarker != null) _userMarker!, ...routePins };

            return Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: const CameraPosition(target: LatLng(21.028511, 105.804817), zoom: 12),
                  markers: allMarkers,
                  clusterManagers: {_stationsClusterManager},
                  polylines: _polylines,
                  myLocationEnabled: !kIsWeb,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  onLongPress: (position) {
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
                  },
                  onMapCreated: (controller) {
                    if (!_controllerCompleter.isCompleted) {
                      _controllerCompleter.complete(controller);
                    }
                  },
                  onCameraIdle: _onCameraIdle,
                ),
                
                IgnorePointer(
                  child: StationClusterLego(
                    onMarkersUpdated: (newMarkers) {
                      setState(() {
                        _stationMarkers = newMarkers;
                      });
                    },
                  ),
                ),
                IgnorePointer(child: const StationDetailsLego()),
                IgnorePointer(
                  child: RoutePolylineLego(
                    onPolylinesUpdated: (newPolylines) {
                      setState(() => _polylines = newPolylines);
                    },
                  ),
                ),
                
                PointerInterceptor(child: SearchLego(currentUserPosition: _currentUserPosition)),

                if (_mapController != null)
                  Positioned(
                    bottom: 24,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // "Cắm" Lego mới vào đây
                        const AddStationLego(),
                        const SizedBox(height: 16),
                        NearbyStationsLego(currentUserPosition: _currentUserPosition),
                        const SizedBox(height: 16),
                        UserLocationLego(
                          onPressed: _moveToMyLocation,
                          isLoading: _isMovingToUserLocation,
                          onUserMarkerUpdated: (newUserMarker) {
                            setState(() => _userMarker = newUserMarker);
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}