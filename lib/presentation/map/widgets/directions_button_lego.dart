// lib/presentation/widgets/directions_button_lego.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';
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
          SnackBar(content: Text(AppLocalizations.of(context)!.cannotOpenMaps)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      // Truyền context vào hàm để có thể hiển thị SnackBar
      onPressed: () => _launchDirections(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        minimumSize: const Size(0, 36),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0), // Bo tròn nhẹ giống OutlinedButton
        ),
      ),
      child: Text(AppLocalizations.of(context)!.directionsButton),
    );
  }
}