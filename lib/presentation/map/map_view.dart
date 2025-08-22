import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_cluster_manager_2/google_maps_cluster_manager_2.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' hide ClusterManager, Cluster;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:smart_charger_app/presentation/bloc/stations_on_route_bloc.dart';
import 'package:smart_charger_app/presentation/map/widgets/app_drawer.dart';
import 'package:smart_charger_app/presentation/map/widgets/cluster_marker_widget.dart';
import 'package:smart_charger_app/presentation/map/widgets/nearby_stations_lego.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_marker_widget.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

import '../bloc/map_control_bloc.dart';
import '../bloc/point_selection_bloc.dart';
import '../bloc/route_bloc.dart';
import '../bloc/station_bloc.dart';
import '../bloc/station_selection_bloc.dart';
import '../services/location_service.dart';
import 'widgets/add_station_lego.dart';
import 'widgets/route_polyline_lego.dart';
import 'widgets/search_lego.dart';
import 'widgets/station_cluster_item.dart';
import 'widgets/station_details_lego.dart';
import 'widgets/user_location_lego.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const double minFetchZoomLevel = 9.5;
  final Completer<GoogleMapController> _controllerCompleter = Completer();
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  late ClusterManager<StationClusterItem> _clusterManager;
  Set<Marker> _stationMarkers = {};
  Marker? _userMarker;
  Set<Polyline> _polylines = {};
  StreamSubscription<Position>? _locationSubscription;
  Position? _currentUserPosition;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  CameraPosition? _initialCameraPosition;
  
  // Thêm flag để theo dõi trạng thái disposed
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _clusterManager = _initClusterManager([]);
    _initializeMapAndData();
    _initializeUserLocationStream();
    _warmUpIconCache();
  }

  Future<void> _initializeMapAndData() async {
    try {
      final initialPosition = await _determineInitialCameraPosition();
      if (mounted && !_isDisposed) {
        setState(() => _initialCameraPosition = initialPosition);
      }
      
      if (!_controllerCompleter.isCompleted) {
        _mapController = await _controllerCompleter.future;
      }
      
      if (mounted && !_isDisposed && _mapController != null) {
        _clusterManager.setMapId(_mapController!.mapId);
        _onCameraIdle();
      }
    } catch (e) {
      debugPrint("Lỗi khởi tạo bản đồ: $e");
    }
  }

  void _warmUpIconCache() {
    for (int i = 1; i <= 50; i++) {
      final normalKey = 'icon_${i}_false';
      final normalWidget = StationMarkerWidget(count: i, isFocused: false);
      normalWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
          .then((icon) {
        if (!_isDisposed) {
          _markerIconCache[normalKey] = icon;
        }
      });
      
      final focusedKey = 'icon_${i}_true';
      final focusedWidget = StationMarkerWidget(count: i, isFocused: true);
      focusedWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
          .then((icon) {
        if (!_isDisposed) {
          _markerIconCache[focusedKey] = icon;
        }
      });
    }
  }

  Future<CameraPosition> _determineInitialCameraPosition() async {
    try {
      final hasPermission = await _locationService.requestPermissionAndService();
      if (hasPermission && !_isDisposed) {
        try {
          // Giảm timeout từ 10 giây xuống 5 giây
          final position = await _locationService.onLocationChanged.first.timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              debugPrint("Timeout khi lấy vị trí, sử dụng vị trí mặc định");
              throw TimeoutException('Location timeout', const Duration(seconds: 5));
            },
          );
          return CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 17.0);
        } on TimeoutException {
          debugPrint("Không thể lấy vị trí trong thời gian cho phép, sử dụng vị trí mặc định");
        } catch (e) {
          debugPrint("Lỗi khi lấy vị trí: $e");
        }
      }
    } catch (e) {
      debugPrint("Lỗi permission hoặc service: $e");
    }
    
    // Trả về vị trí mặc định (Hà Nội)
    return const CameraPosition(target: LatLng(21.028511, 105.804817), zoom: 17.0);
  }

  ClusterManager<StationClusterItem> _initClusterManager(List<StationClusterItem> items) {
    return ClusterManager<StationClusterItem>(
      items,
      (newMarkers) {
        // Chỉ gọi setState nếu widget vẫn còn "mounted"
        if (mounted) {
          setState(() => _stationMarkers = newMarkers);
        }
      },
      markerBuilder: _markerBuilder,
    );
  }

  Future<Marker> _markerBuilder(Cluster<StationClusterItem> cluster) async {
    // Kiểm tra context còn hợp lệ trước khi sử dụng
    if (_isDisposed || !mounted) {
      return Marker(markerId: MarkerId(cluster.getId()), position: cluster.location);
    }
    
    try {
      final selectionState = context.read<StationSelectionBloc>().state;
      final selectedStationId = selectionState is StationSelectionSuccess ? selectionState.selectedStation.id : null;
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
        markerWidget = StationMarkerWidget(count: station.totalConnectors, isFocused: isFocused);
      }

      BitmapDescriptor icon;
      if (_markerIconCache.containsKey(cacheKey)) {
        icon = _markerIconCache[cacheKey]!;
      } else {
        icon = await markerWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220));
        if (!_isDisposed) {
          _markerIconCache[cacheKey] = icon;
        }
      }

      return Marker(
        markerId: MarkerId(cluster.getId()),
        position: cluster.location,
        icon: icon,
        zIndexInt: isFocused ? 1 : 0,
        onTap: () {
          if (!cluster.isMultiple && mounted && !_isDisposed) {
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
      return Marker(markerId: MarkerId(cluster.getId()), position: cluster.location);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationSubscription?.cancel();
    _locationSubscription = null;
    
    // Không dispose controller vì nó có thể được sử dụng bởi các widget khác
    // _mapController?.dispose();
    _mapController = null;
    
    super.dispose();
  }

  void _initializeUserLocationStream() async {
    try {
      final hasPermission = await _locationService.requestPermissionAndService();
      if (!hasPermission || !mounted || _isDisposed) return;
      
      _locationSubscription = _locationService.onLocationChanged.listen(
        (Position position) {
          if (mounted && !_isDisposed) {
            setState(() => _currentUserPosition = position);
          }
        },
        onError: (error) {
          debugPrint("Lỗi location stream: $error");
        },
        cancelOnError: false,
      );
    } catch (e) {
      debugPrint("Lỗi khởi tạo location stream: $e");
    }
  }
  
  void _moveToMyLocation() async {
    if (_currentUserPosition == null || _isDisposed || !mounted) return;
    
    try {
      context.read<MapControlBloc>().add(CameraMoveRequested(
        LatLng(_currentUserPosition!.latitude, _currentUserPosition!.longitude), 
        16.0
      ));
    } catch (e) {
      debugPrint("Lỗi di chuyển đến vị trí hiện tại: $e");
    }
  }

  void _onCameraIdle() async {
    final controller = _mapController;
    if (controller == null || !mounted || _isDisposed) return;
    
    try {
      final zoom = await controller.getZoomLevel();
      if (zoom < minFetchZoomLevel) {
        _clusterManager.setItems([]);
        return;
      }
      
      final visibleBounds = await controller.getVisibleRegion();
      if (!mounted || _isDisposed) return;
      
      context.read<StationBloc>().add(StationsInBoundsFetched(visibleBounds));
    } catch (e) {
      debugPrint("Lỗi trong _onCameraIdle: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trạm sạc toàn quốc')),
      drawer: const AppDrawer(),
      body: _initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : MultiBlocListener(
              listeners: [
                BlocListener<StationBloc, StationState>(
                  listenWhen: (prev, curr) => prev.stationsToDisplay != curr.stationsToDisplay,
                  listener: (context, state) {
                    if (!_isDisposed) {
                      final clusterItems = state.stationsToDisplay.values
                          .map((s) => StationClusterItem(station: s))
                          .toList();
                      _clusterManager.setItems(clusterItems);
                    }
                  },
                ),
                BlocListener<RouteBloc, RouteState>(
                  listener: (context, state) {
                    if (!_isDisposed && state is! RouteSuccess) {
                      try {
                        context.read<StationBloc>().add(ClearStationFilter());
                        context.read<StationsOnRouteBloc>().add(ResetStationsOnRoute());
                      } catch (e) {
                        debugPrint("Lỗi trong RouteBloc listener: $e");
                      }
                    }
                  },
                ),
                BlocListener<StationSelectionBloc, StationSelectionState>(
                  listener: (context, state) {
                    if (!_isDisposed) {
                      _clusterManager.updateMap();
                    }
                  },
                ),
                BlocListener<MapControlBloc, MapControlState>(
                  listener: (context, state) async {
                    if (!_isDisposed && state is MapCameraUpdate) {
                      try {
                        final controller = await _controllerCompleter.future;
                        if (!_isDisposed) {
                          controller.animateCamera(state.cameraUpdate);
                        }
                      } catch (e) {
                        debugPrint("Lỗi animate camera: $e");
                      }
                    }
                  },
                ),
                BlocListener<PointSelectionBloc, PointSelectionState>(
                  listener: (context, state) {
                    if (!_isDisposed && state is PointSelectionInProgress) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nhấn giữ (hoặc chuột phải trên web) để chọn điểm.')),
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

                  final allMarkers = { 
                    ..._stationMarkers, 
                    if (_userMarker != null) _userMarker!, 
                    ...routePins 
                  };

                  return Stack(
                    children: [
                      GoogleMap(
                        initialCameraPosition: _initialCameraPosition!,
                        markers: allMarkers,
                        polylines: _polylines,
                        myLocationEnabled: !kIsWeb,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        onLongPress: (position) {
                          if (_isDisposed) return;
                          
                          try {
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
                          } catch (e) {
                            debugPrint("Lỗi onLongPress: $e");
                          }
                        },
                        onMapCreated: (controller) {
                          if (!_controllerCompleter.isCompleted && !_isDisposed) {
                            _controllerCompleter.complete(controller);
                          }
                        },
                        onCameraMove: (position) {
                          if (!_isDisposed) {
                            _clusterManager.onCameraMove(position);
                          }
                        },
                        onCameraIdle: () {
                          if (!_isDisposed) {
                            _clusterManager.updateMap();
                            _onCameraIdle();
                          }
                        },
                      ),
                      
                      IgnorePointer(child: const StationDetailsLego()),
                      IgnorePointer(
                        child: RoutePolylineLego(
                          onPolylinesUpdated: (newPolylines) {
                            if (mounted && !_isDisposed) {
                              setState(() => _polylines = newPolylines);
                            }
                          },
                        ),
                      ),
                      PointerInterceptor(child: SearchLego(currentUserPosition: _currentUserPosition)),

                      if (_mapController != null && !_isDisposed)
                        Positioned(
                          bottom: 24,
                          right: 16,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const AddStationLego(),
                              const SizedBox(height: 16),
                              NearbyStationsLego(currentUserPosition: _currentUserPosition),
                              const SizedBox(height: 16),
                              UserLocationLego(
                                onPressed: _moveToMyLocation,
                                onUserMarkerUpdated: (newUserMarker) {
                                  if (mounted && !_isDisposed) {
                                    setState(() => _userMarker = newUserMarker);
                                  }
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