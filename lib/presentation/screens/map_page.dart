// lib/presentation/screens/map_page.dart

import 'package:flutter/material.dart';
import '../map/map_view.dart';

/// MapPage bây giờ chỉ là một container đơn giản.
/// Toàn bộ Provider đã được chuyển lên một cấp cao hơn (trong main.dart hoặc AppShell).
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Nó chỉ cần hiển thị MapView.
    return const MapView();
  }
}