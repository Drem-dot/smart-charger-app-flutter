// lib/presentation/map/map_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:provider/provider.dart';
import 'package:smart_charger_app/presentation/bloc/map_control_bloc.dart';
import 'package:smart_charger_app/presentation/bloc/sheet_drag_state.dart';
import 'package:smart_charger_app/presentation/bloc/station_selection_bloc.dart';

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
import 'logic_handlers/station_marker_manager_lego.dart';
import 'logic_handlers/map_interaction_lego.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    // Cung cấp VisibilityCubit cho các widget con
    return BlocProvider(
      create: (context) => VisibilityCubit(),
      // Dùng Provider để truyền GoogleMapController Completer xuống cho các Lego Logic
      child: Provider<Completer<GoogleMapController>>(
        create: (_) => Completer<GoogleMapController>(),
        child: const _MapViewContent(),
      ),
    );
  }
}

class _MapViewContent extends StatefulWidget {
  const _MapViewContent();
  @override
  State<_MapViewContent> createState() => _MapViewContentState();
}

class _MapViewContentState extends State<_MapViewContent> {
  GoogleMapController? _mapController;
  final LocationService _locationService = LocationService();
  final StationMarkerManagerController _markerManagerController = StationMarkerManagerController();
  CameraPosition? _initialCameraPosition;
  Position? _currentUserPosition;
  StreamSubscription<Position>? _locationSubscription;

  // Các state cho UI
  Set<Marker> _stationMarkers = {};
  Set<Marker> _routePins = {};
  Marker? _userMarker;
  Set<Polyline> _polylines = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializeMapAndData();
    _initializeUserLocationStream();
  }

  Future<void> _initializeMapAndData() async {
    final initialPosition = await _determineInitialCameraPosition();

    // BẢO VỆ 1: Kiểm tra `mounted` ngay sau `await` đầu tiên
    if (!mounted) return;

    setState(() => _initialCameraPosition = initialPosition);

    // Bây giờ việc sử dụng context ở đây là an toàn
    final completer = context.read<Completer<GoogleMapController>>();
    final controller = await completer.future;

    // BẢO VỆ 2: Kiểm tra `mounted` sau `await` thứ hai
    if (!mounted) return;

    setState(() => _mapController = controller);
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
            zoom: 17.0,
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
      context.read<MapControlBloc>().add(
        CameraMoveRequested(
          LatLng(
            _currentUserPosition!.latitude,
            _currentUserPosition!.longitude,
          ),
          16.0,
        ),
      );
    } catch (e) {
      debugPrint("Lỗi di chuyển đến vị trí hiện tại: $e");
    }
  }

  // SAFE STATE UPDATE METHODS - These use post-frame callbacks to avoid setState during build
  void _safeUpdateUserMarker(Marker? marker) {
    if (mounted && !_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _userMarker = marker);
        }
      });
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

  void _safeUpdateRoutePins(Set<Marker> pins) {
    if (mounted && !_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _routePins = pins);
        }
      });
    }
  }

  void _safeUpdateStationMarkers(Set<Marker> markers) {
    if (mounted && !_isDisposed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isDisposed) {
          setState(() => _stationMarkers = markers);
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mapInteractionLego = _mapController != null
        ? MapInteractionLego(controller: _mapController!)
        : null;

    return Scaffold(
      body: _initialCameraPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // --- SỬ DỤNG CONSUMER ĐỂ BUILD LẠI BẢN ĐỒ ---
                Consumer<SheetDragState>(
                  builder: (context, dragState, child) {
                    return GoogleMap(
                      initialCameraPosition: _initialCameraPosition!,
                      markers: {
                        ..._stationMarkers,
                        ..._routePins,
                        if (_userMarker != null) _userMarker!,
                      },
                      polylines: _polylines,
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: !dragState.isDragging,
                      zoomGesturesEnabled: !dragState.isDragging,
                      rotateGesturesEnabled: !dragState.isDragging,
                      tiltGesturesEnabled: !dragState.isDragging,
                      onMapCreated: (controller) {
                        if (!context
                            .read<Completer<GoogleMapController>>()
                            .isCompleted) {
                          context
                              .read<Completer<GoogleMapController>>()
                              .complete(controller);
                        }
                      },
                      onCameraMove: (position) {
                        // Gọi đến hàm của StationMarkerManagerLego
                        _markerManagerController.onCameraMove(position);
                      },
                      onCameraIdle: () {
                        mapInteractionLego?.onCameraIdle(context);
                        _markerManagerController.onCameraIdle();
                      },
                      onLongPress: (pos) =>
                          mapInteractionLego?.onLongPress(context, pos),
                    );
                  },
                ),

                // --- CẮM CÁC LEGO LOGIC (CHỈ KHI CONTROLLER SẴN SÀNG) ---
                if (_mapController != null) ...[
                  // Use the safe update methods to avoid setState during build
                  UserLocationLego(
                    onUserMarkerUpdated: _safeUpdateUserMarker,
                  ),
                  MapStateManagerLego(
                    controller: _mapController!,
                    onPolylinesUpdated: _safeUpdatePolylines,
                    onRoutePinsUpdated: _safeUpdateRoutePins,
                  ),
                  StationMarkerManagerLego(
                    managerController: _markerManagerController, 
                    controller: _mapController!,
                    onMarkersUpdated: _safeUpdateStationMarkers,
                  ),
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
                        SearchLego(currentUserPosition: _currentUserPosition),

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
                    // Kết hợp với VisibilityCubit
                    return BlocBuilder<VisibilityCubit, bool>(
                      builder: (context, isVisible) {
                        // Chỉ hiển thị khi cả hai điều kiện đều đúng
                        if (selectionState is NoStationSelected && isVisible) {
                          return Positioned(
                            bottom: 16.0,
                            left: 0,
                            right: 0,
                            child: NearbyStationsCarouselLego(
                              currentUserPosition: _currentUserPosition,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    );
                  },
                ),

                StationDetailsLego(currentUserPosition: _currentUserPosition),
              ],
            ),
    );
  }
}