// lib/presentation/map/widgets/user_location_lego.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/location_service.dart';

class UserLocationLego extends StatefulWidget {
  // SỬA ĐỔI: Các tham số được truyền từ MapView
  final Function(Marker?) onUserMarkerUpdated;
  final VoidCallback onPressed;
  final bool isLoading;

  const UserLocationLego({
    super.key, 
    required this.onUserMarkerUpdated,
    required this.onPressed,
    this.isLoading = false,
  });
  
  @override
  State<UserLocationLego> createState() => _UserLocationLegoState();
}

class _UserLocationLegoState extends State<UserLocationLego> {
  // SỬA LỖI: Chỉ giữ lại logic liên quan đến stream cho web marker
  final LocationService _locationService = LocationService();
  StreamSubscription<Position>? _locationSubscription;
  BitmapDescriptor? _userIcon;

  @override
  void initState() {
    super.initState();
    _initializeUserLocationStream();
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  // Logic này vẫn đúng vì nó chỉ giao tiếp ngược lên cha
  Future<void> _initializeUserLocationStream() async {
    if (kIsWeb) {
      _userIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(24, 24)), 'assets/icons/user_marker.png');
        
      // Xin quyền trước khi lắng nghe
      final hasPermission = await _locationService.requestPermissionAndService();
      if (!hasPermission || !mounted) return;

      _locationSubscription = _locationService.onLocationChanged.listen((position) {
        if (!mounted || _userIcon == null) return;
        final userMarker = Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: _userIcon!,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 1,
        );
        widget.onUserMarkerUpdated(userMarker);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // SỬA LỖI: Trả về trực tiếp FloatingActionButton, không bọc trong PointerInterceptor
    return FloatingActionButton(
      onPressed: widget.onPressed,
      child: widget.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Icon(Icons.my_location),
    );
  }
}