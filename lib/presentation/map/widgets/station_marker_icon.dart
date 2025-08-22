// lib/presentation/widgets/station_marker_icon.dart

import 'package:flutter/material.dart';

class StationMarkerIcon extends StatelessWidget {
  final int connectorCount;
  final bool isFocused;

  const StationMarkerIcon({
    super.key,
    required this.connectorCount,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    // Kích thước như lần trước, sếp có thể điều chỉnh nếu cần
    final double baseSize = isFocused ? 38.0 : 30.0;
    final double iconSize = isFocused ? 20.0 : 16.0;

    // --- SỬA LỖI VẠCH VÀNG ---
    // Bọc toàn bộ bằng một Material widget để cung cấp context rendering đúng.
    // Dùng type: MaterialType.transparency để nó không có màu nền.
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: baseSize + 12,
        height: baseSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Container chính chứa icon (Không có animation nữa)
            Container(
              width: baseSize,
              height: baseSize,
              decoration: BoxDecoration(
                color: isFocused ? Colors.blue : Colors.green.shade700,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                ],
              ),
              child: Icon(Icons.ev_station, color: Colors.white, size: iconSize),
            ),
            
            // Badge hiển thị số lượng
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isFocused ? Colors.blue : Colors.green.shade700,
                    width: 1,
                  ),
                ),
                constraints: const BoxConstraints(minWidth: 18),
                child: Text(
                  connectorCount > 99 ? '99+' : connectorCount.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: isFocused ? 11 : 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}