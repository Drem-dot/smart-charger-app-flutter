import 'package:flutter/foundation.dart' show kIsWeb; // <-- Import hằng số kIsWeb
import 'package:flutter/material.dart';

class StationMarkerWidget extends StatelessWidget {
  final int count;
  final bool isFocused;

  const StationMarkerWidget({
    super.key,
    required this.count,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    // --- TỐI ƯU HÓA: Kích thước tùy biến theo nền tảng ---
    
    // Khai báo các biến kích thước
    final double mainCircleSize;
    final double iconSize;
    final double badgeSize;
    final double borderWidth;
    final double badgeOffset;
    final EdgeInsets padding;

    if (kIsWeb) {
      // --- Kích thước cho WEB (nhỏ bằng 50%) ---
      mainCircleSize = isFocused ? 24.0 : 20.0;
      iconSize = isFocused ? 14.0 : 11.0;
      badgeSize = isFocused ? 11.0 : 10.0;
      borderWidth = isFocused ? 1.25 : 1.0;
      badgeOffset = -2.0; // Vị trí của nhãn số
      padding = const EdgeInsets.all(2.0); // Padding cho khung vẽ
    } else {
      // --- Kích thước cho MOBILE (100% - Kích thước ban đầu) ---
      mainCircleSize = isFocused ? 48.0 : 40.0;
      iconSize = isFocused ? 28.0 : 22.0;
      badgeSize = isFocused ? 22.0 : 20.0;
      borderWidth = isFocused ? 2.5 : 2.0;
      badgeOffset = -4.0;
      padding = const EdgeInsets.all(4.0);
    }

    // Các biến màu sắc không đổi
    final Color borderColor = isFocused ? Colors.blue.shade600 : Colors.green.shade700;
    
    // Giao diện widget sử dụng các biến đã được tính toán ở trên
    return Padding(
      padding: padding,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: mainCircleSize,
            height: mainCircleSize,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: borderWidth),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 3, offset: Offset(0, 1)),
              ],
            ),
            child: Center(
              child: Icon(Icons.ev_station, color: borderColor, size: iconSize),
            ),
          ),
          Positioned(
            top: badgeOffset,
            right: badgeOffset,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5), // Viền badge có thể giữ cố định
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: badgeSize * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}