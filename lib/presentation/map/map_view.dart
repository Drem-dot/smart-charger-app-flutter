// lib/presentation/map/map_view.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/nearby_stations_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';
import 'package:smart_charger_app/presentation/map/widgets/station_marker_widget.dart';
import 'package:widget_to_marker/widget_to_marker.dart';
import '../bloc/visibility_cubit.dart';
import '../services/location_service.dart';
// Import các Lego UI
import 'widgets/search_lego.dart';
import 'widgets/map_control_buttons_lego.dart';
import 'widgets/user_location_lego.dart';
import 'widgets/nearby_stations_carousel_lego.dart';
import 'widgets/station_details_lego.dart';
// Import các Lego Logic
import 'logic_handlers/map_state_manager_lego.dart';
import 'logic_handlers/map_interaction_lego.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp VisibilityCubit cho các widget con
    return BlocProvider(
      create: (context) => VisibilityCubit(),
      child: const _MapViewContent(),
    );
  }
}

class _MapViewContent extends StatefulWidget {
  const _MapViewContent();
  @override
  State<_MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<_MapViewContent> {
  // --- BIẾN CŨ GIỮ LẠI ---
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  CameraPosition? _initialCameraPosition;
  Position? _currentUserPosition;
  StreamSubscription<Position>? _locationSubscription;
  bool _isDisposed = false;
  final Map<String, BitmapDescriptor> _markerIconCache = {};
  CameraPosition? _currentCameraPosition;
  // --- BIẾN QUẢN LÝ MAP OBJECTS ---
  final Map<MarkerId, Marker> _allMarkers =
      {}; // Một map duy nhất quản lý tất cả marker
  Set<Polyline> _polylines = {};

  // --- BIẾN QUẢN LÝ GOM CỤM (NATIVE) ---
  final Map<ClusterManagerId, ClusterManager> _clusterManagers = {};

  @override
void initState() {
  super.initState();
  _addNativeClusterManager();
  _initializeMapAndData();
  _initializeUserLocationStream();
  _warmUpIconCache();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && _mapController != null) {
      // Kích hoạt load stations với bounds hiện tại của map
      _triggerStationsLoad();
    }
  });
}

void _warmUpIconCache() {
    for (int i = 1; i <= 10; i++) {
      // --- CẬP NHẬT CACHE KEY VÀ WIDGET ---
      // Icon ô tô thường
      final carNormalKey = 'station_${i}_false_${StationType.car.name}';
      final carNormalWidget = StationMarkerWidget(count: i, isFocused: false, stationType: StationType.car);
      carNormalWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
         .then((icon) => _markerIconCache[carNormalKey] = icon);

      // Icon ô tô focus
      final carFocusedKey = 'station_${i}_true_${StationType.car.name}';
      final carFocusedWidget = StationMarkerWidget(count: i, isFocused: true, stationType: StationType.car);
      carFocusedWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
         .then((icon) => _markerIconCache[carFocusedKey] = icon);
      
      // Icon xe máy thường
      final bikeNormalKey = 'station_${i}_false_${StationType.bike.name}';
      final bikeNormalWidget = StationMarkerWidget(count: i, isFocused: false, stationType: StationType.bike);
      bikeNormalWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
         .then((icon) => _markerIconCache[bikeNormalKey] = icon);

      // Icon xe máy focus
      final bikeFocusedKey = 'station_${i}_true_${StationType.bike.name}';
      final bikeFocusedWidget = StationMarkerWidget(count: i, isFocused: true, stationType: StationType.bike);
      bikeFocusedWidget.toBitmapDescriptor(logicalSize: const Size(100, 110), imageSize: const Size(200, 220))
         .then((icon) => _markerIconCache[bikeFocusedKey] = icon);
    }
  }

  // --- THAY THẾ HOÀN TOÀN HÀM _updateStationMarkers ---
   void _updateStationMarkers(Map<String, StationEntity> stationsToDisplay) async {
    if (_clusterManagers.isEmpty) return;

    final clusterManagerId = _clusterManagers.values.first.clusterManagerId;
    final Map<MarkerId, Marker> newStationMarkers = {};
    
    final selectionState = context.read<StationSelectionBloc>().state;
    final selectedStationId = selectionState is StationSelectionSuccess
        ? selectionState.selectedStation.id
        : null;

    await Future.wait(stationsToDisplay.values.map((station) async {
      final isFocused = station.id == selectedStationId;
      // --- CẬP NHẬT CACHE KEY ĐỂ PHÂN BIỆT CẢ LOẠI TRẠM ---
      final cacheKey = 'station_${station.totalConnectors}_${isFocused}_${station.stationType.name}';

      BitmapDescriptor icon;
      if (_markerIconCache.containsKey(cacheKey)) {
        icon = _markerIconCache[cacheKey]!;
      } else {
        // --- TRUYỀN stationType VÀO WIDGET ---
        final widget = StationMarkerWidget(
          count: station.totalConnectors,
          isFocused: isFocused,
          stationType: station.stationType, // <-- TRUYỀN VÀO ĐÂY
        );
        icon = await widget.toBitmapDescriptor(
          logicalSize: const Size(100, 110),
          imageSize: const Size(200, 220),
        );
        _markerIconCache[cacheKey] = icon;
      }
      
      final markerId = MarkerId('station_${station.id}');
      final marker = Marker(
        markerId: markerId,
        clusterManagerId: clusterManagerId,
        position: station.position,
        icon: icon,
        zIndexInt: isFocused ? 2 : 1, // <-- SỬA zIndexInt THÀNH zIndex
        anchor: const Offset(0.5, 0.5),
        onTap: () {
          if (mounted) {
            context.read<StationSelectionBloc>().add(StationSelected(station));
          }
        },
      );
      newStationMarkers[markerId] = marker;
    }));

    if (mounted) {
      setState(() {
        _allMarkers.removeWhere((key, value) => key.value.startsWith('station_'));
        _allMarkers.addAll(newStationMarkers);
      });
    }
  }

// Hàm mới: Trigger load stations với bounds hiện tại
void _triggerStationsLoad() async {
  if (_mapController == null) return;
  
  
    final bounds = await _mapController!.getVisibleRegion();
    
    if (!mounted) return; // Guard against BuildContext across async gaps
    context.read<StationBloc>().add(StationsInBoundsFetched(bounds));
  
}

  // --- HÀM MỚI: KHỞI TẠO CLUSTER MANAGER NATIVE ---
  void _addNativeClusterManager() {
    const String clusterManagerIdVal = 'stations_cluster';
    final ClusterManagerId clusterManagerId = ClusterManagerId(
      clusterManagerIdVal,
    );

    final ClusterManager clusterManager = ClusterManager(
      clusterManagerId: clusterManagerId,
      onClusterTap: (Cluster cluster) {
        // Khi nhấn vào cụm, zoom vào
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(cluster.bounds, 50.0),
        );
      },
    );

    setState(() {
      _clusterManagers[clusterManagerId] = clusterManager;
    });
  }

  // HÀM MỚI: CẬP NHẬT MARKER CHO CLUSTER MANAGER
  void _safeUpdateUserMarker(Marker? marker) {
    if (!mounted || _isDisposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _allMarkers.removeWhere((id, m) => id.value == 'user_marker');
        if (marker != null) {
          _allMarkers[marker.markerId] = marker;
        }
      });
    });
  }

  void _safeUpdateRoutePins(Set<Marker> pins) {
    if (!mounted || _isDisposed) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isDisposed) return;
      setState(() {
        _allMarkers.removeWhere((id, m) => id.value.endsWith('_pin'));
        for (var pin in pins) {
          _allMarkers[pin.markerId] = pin;
        }
      });
    });
  }

  Future<void> _initializeMapAndData() async {
    // --- SỬA LẠI HÀM NÀY ĐỂ KHÔNG DÙNG COMPLETER NỮA ---
    final initialPosition = await _determineInitialCameraPosition();
    if (!mounted) return;
    setState(() => _initialCameraPosition = initialPosition);
  }

  Future<CameraPosition> _determineInitialCameraPosition() async {
    try {
      final hasPermission = await _locationService
          .requestPermissionAndService();
      if (hasPermission && mounted) {
        // <-- Thêm kiểm tra `mounted` ở đây
        try {
          final position = await _locationService.onLocationChanged.first
              .timeout(
                const Duration(seconds: 5),
                onTimeout: () {
                  throw TimeoutException('Location timeout');
                },
              );
          return CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 17,
          );
        } catch (e) {
          debugPrint("Lỗi khi lấy vị trí: $e");
        }
      }
    } catch (e) {
      debugPrint("Lỗi permission hoặc service: $e");
    }

    return const CameraPosition(
      target: LatLng(21.028511, 105.804817),
      zoom: 17.0,
    );
  }

   Future<void> _moveCameraForSheet(LatLng markerPosition) async {
    if (_mapController == null || !mounted || _isDisposed) return;
    
    // Sử dụng _currentCameraPosition đã được lưu lại, hoặc dùng giá trị mặc định nếu null
    final cameraPosition = _currentCameraPosition ?? _initialCameraPosition;
    if (cameraPosition == null) return; // Không thể thực hiện nếu chưa có camera position

    try {
      final double currentZoom = cameraPosition.zoom;
      final double currentBearing = cameraPosition.bearing;

      final screenHeight = MediaQuery.of(context).size.height;
      final double sheetHeight = 400.0;
      final double scrollPixelDistance = (sheetHeight / 2.0) + 20;

      final LatLngBounds visibleRegion = await _mapController!.getVisibleRegion();
      final double latPerPixel = (visibleRegion.northeast.latitude - visibleRegion.southwest.latitude).abs() / screenHeight;

      final double latDegreeOffset = scrollPixelDistance * latPerPixel;
      final double bearingRad = currentBearing * (pi / 180.0);

      final double deltaLat = -latDegreeOffset * cos(bearingRad);
      final double deltaLon = -latDegreeOffset * sin(bearingRad) / cos(markerPosition.latitude * (pi / 180.0));

      final LatLng newCenter = LatLng(
        markerPosition.latitude + deltaLat,
        markerPosition.longitude + deltaLon,
      );

      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newCenter,
            zoom: currentZoom,
            bearing: currentBearing,
            tilt: cameraPosition.tilt,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Lỗi khi di chuyển camera cho sheet (tính toán): $e");
    }
  }

  void _initializeUserLocationStream() async {
    try {
      final hasPermission = await _locationService
          .requestPermissionAndService();
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
      final myLocation = LatLng(
        _currentUserPosition!.latitude,
        _currentUserPosition!.longitude,
      );

      // 1. (Giữ nguyên) Yêu cầu di chuyển camera đến vị trí của tôi
      context.read<MapControlBloc>().add(CameraMoveRequested(myLocation, 17));

      // 2. (THÊM MỚI) Yêu cầu NearbyStationsBloc cập nhật dữ liệu
      // Dùng event FetchNearbyStations, event này tính toán khoảng cách
      // dựa trên vị trí GPS nên phù hợp hơn trong trường hợp này.
      context.read<NearbyStationsBloc>().add(FetchNearbyStations(myLocation));
    } catch (e) {
      debugPrint("Lỗi di chuyển đến vị trí hiện tại: $e");
    }
  }

  void _safeUpdatePolylines(Set<Polyline> polylines) {
    if (mounted && !_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _polylines = polylines);
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapInteractionLego = _mapController != null
        ? MapInteractionLego(controller: _mapController!)
        : null;

    return BlocListener<StationSelectionBloc, StationSelectionState>(
      listener: (context, state) {
        if (state is StationSelectionSuccess) {
          Future.delayed(const Duration(milliseconds: 150), () {
            _moveCameraForSheet(state.selectedStation.position);
          });
          // KHI CHỌN/BỎ CHỌN, CHÚNG TA CẦN VẼ LẠI MARKER ĐỂ CẬP NHẬT ICON
          // Lấy state hiện tại của StationBloc và gọi _updateStationMarkers
          final currentStationState = context.read<StationBloc>().state;
          _updateStationMarkers(currentStationState.stationsToDisplay);

        } else if (state is NoStationSelected) {
          // Tương tự, vẽ lại để bỏ focus
          final currentStationState = context.read<StationBloc>().state;
          _updateStationMarkers(currentStationState.stationsToDisplay);
        }
      },
      child: Scaffold(
        body: _initialCameraPosition == null
            ? const Center(child: CircularProgressIndicator())
            : BlocListener<StationBloc, StationState>(
                listener: (context, state) {
                  _updateStationMarkers(state.stationsToDisplay);
                },
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: _initialCameraPosition!,
                      markers: Set<Marker>.of(_allMarkers.values),
                      clusterManagers: Set<ClusterManager>.of(
                        _clusterManagers.values,
                      ),
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) {
                        if (!mounted || _isDisposed) return;
                        setState(() {
                          _mapController = controller;
                        });
                        // Load stations ngay khi map được tạo
                        _triggerStationsLoad();
                      },
                      onCameraMove: (CameraPosition position) {
                        // Lưu lại vị trí camera mỗi khi nó di chuyển
                        _currentCameraPosition = position;
                      },
                      onCameraIdle: () {
                        // Load stations mới khi người dùng ngừng di chuyển map
                        _triggerStationsLoad();
                      },
                      onLongPress: (pos) =>
                          mapInteractionLego?.onLongPress(context, pos),
                    ),

                    // --- CẮM CÁC LEGO LOGIC (CHỈ KHI CONTROLLER SẴN SÀNG) ---
                    if (_mapController != null) ...[
                      UserLocationLego(
                        onUserMarkerUpdated: _safeUpdateUserMarker,
                      ),
                      MapStateManagerLego(
                        controller: _mapController!,
                        onPolylinesUpdated: _safeUpdatePolylines,
                        onRoutePinsUpdated: _safeUpdateRoutePins,
                      ),
                      // KHÔNG CẦN StationMarkerManagerLego NỮA
                    ],

                    // --- CẮM CÁC LEGO GIAO DIỆN ---
                    Positioned(
                      top: MediaQuery.of(context).padding.top + 8.0,
                      left: 8.0,
                      right: 8.0,
                      // Bọc toàn bộ khối UI trên cùng bằng PointerInterceptor
                      child: PointerInterceptor(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 1. Thanh tìm kiếm / Panel tìm đường
                            SearchLego(
                              currentUserPosition: _currentUserPosition,
                            ),

                            // 2. Các nút điều khiển bản đồ
                            // Align sẽ đẩy các nút này sang phải
                            Align(
                              alignment: Alignment.topRight,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 16.0,
                                  right: 8.0,
                                ),
                                child: MapControlButtonsLego(
                                  onMoveToLocationPressed: _moveToMyLocation,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                   BlocBuilder<StationSelectionBloc, StationSelectionState>(
  builder: (context, selectionState) {
    return BlocBuilder<VisibilityCubit, bool>(
      builder: (context, isVisible) {
        if (selectionState is NoStationSelected && isVisible) {
          // --- ĐẢO NGƯỢC THỨ TỰ: POSITIONED BÊN NGOÀI ---
          return Positioned(
            bottom: 16.0,
            left: 0,
            right: 0,
            // --- GESTUREDETECTOR BÊN TRONG ---
            child: GestureDetector(
              onVerticalDragEnd: (details) {
                // Vuốt xuống để ẩn
                if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                  context.read<VisibilityCubit>().hide();
                }
              },
              // Thêm hành vi này để GestureDetector "bắt" được cử chỉ vuốt
              // ngay cả khi widget con của nó (carousel) cũng đang xử lý scroll
              behavior: HitTestBehavior.translucent,
              child: NearbyStationsCarouselLego(
                currentUserPosition: _currentUserPosition,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  },
),
                    StationDetailsLego(
                      currentUserPosition: _currentUserPosition,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
