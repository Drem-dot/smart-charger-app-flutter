// lib/presentation/widgets/directions_button_lego.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class DirectionsButtonLego extends StatelessWidget {
  final LatLng destination;

  const DirectionsButtonLego({super.key, required this.destination});

  Future<void> _launchDirections(BuildContext context) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${destination.latitude},${destination.longitude}'
    );
    
    // Sử dụng try-catch là cách tiếp cận hiện đại và được khuyến nghị
    // thay cho canLaunchUrl để xử lý lỗi một cách an toàn.
    try {
      // LaunchMode.externalApplication đảm bảo nó sẽ mở ứng dụng Google Maps
      // thay vì một trình duyệt web trong ứng dụng.
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Nếu có lỗi, hiển thị một thông báo thân thiện cho người dùng.
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở ứng dụng Google Maps.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      // Truyền context vào hàm để có thể hiển thị SnackBar
      onPressed: () => _launchDirections(context),
      icon: const Icon(Icons.directions),
      label: const Text('Dẫn đường'),
      style: ElevatedButton.styleFrom(
        // Sếp có thể tùy chỉnh màu sắc tại đây
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0), // Bo tròn các góc
        ),
      ),
    );
  }
}