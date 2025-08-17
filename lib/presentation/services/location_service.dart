// lib/presentation/services/location_service.dart
import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Cung cấp một stream vị trí thay đổi liên tục.
  /// Đây sẽ là nguồn dữ liệu vị trí chính cho toàn bộ ứng dụng.
  Stream<Position> get onLocationChanged => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Cập nhật sau mỗi 10 mét
    ),
  );

  /// Yêu cầu quyền và kiểm tra dịch vụ vị trí.
  /// Đây là bước cần thực hiện trước khi bắt đầu lắng nghe stream.
  Future<bool> requestPermissionAndService() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Có thể yêu cầu người dùng bật dịch vụ ở đây
      return Future.error('Dịch vụ định vị đã bị tắt.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      // Hướng dẫn người dùng vào cài đặt
      return false;
    } 
    
    return true;
  }
}