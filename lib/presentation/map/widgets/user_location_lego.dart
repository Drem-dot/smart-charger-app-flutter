// lib/presentation/map/widgets/user_location_lego.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/location_service.dart';

class UserLocationLego extends StatefulWidget {
  // --- THAY ĐỔI: Chỉ cần một callback để trả về marker ---
  final Function(Marker?) onUserMarkerUpdated;

  const UserLocationLego({
    super.key, 
    required this.onUserMarkerUpdated,
  });
  
  @override
  State<UserLocationLego> createState() => _UserLocationLegoState();
}

class _UserLocationLegoState extends State<UserLocationLego> {
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

  Future<void> _initializeUserLocationStream() async {
    // Logic này chỉ chạy trên Web để hiển thị marker tùy chỉnh
    if (kIsWeb) {
      _userIcon = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(24, 24)), 'assets/icons/user_marker.png');
        
      final hasPermission = await _locationService.requestPermissionAndService();
      if (!hasPermission || !mounted) return;

      _locationSubscription = _locationService.onLocationChanged.listen((position) {
        if (!mounted || _userIcon == null) return;
        final userMarker = Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: _userIcon!,
          anchor: const Offset(0.5, 0.5),
          zIndexInt: 1, // zIndex là double, không phải zIndexInt
        );
        widget.onUserMarkerUpdated(userMarker);
      });
    } else {
      // Trên mobile, myLocationEnabled=true đã hiển thị chấm xanh mặc định,
      // không cần marker tùy chỉnh, nên không cần làm gì cả.
      widget.onUserMarkerUpdated(null);
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- THAY ĐỔI: Widget này bây giờ là một "Lego chìm", không có giao diện ---
    // Nó chỉ tồn tại để quản lý logic và giao tiếp với MapView.
    return const SizedBox.shrink();
  }
}