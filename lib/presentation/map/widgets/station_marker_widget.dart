import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';

class StationMarkerWidget extends StatelessWidget {
  final int count;
  final bool isFocused;
  final StationType stationType;

  const StationMarkerWidget({
    super.key,
    required this.count,
    this.isFocused = false,
    this.stationType = StationType.car,
  });

  @override
  Widget build(BuildContext context) {
    // Luôn lấy theme để có màu sắc đồng bộ
    final theme = Theme.of(context);

    // --- LOGIC MÀU SẮC ĐÚNG CHUẨN ---
    // Sử dụng ColorScheme thay vì primaryColor deprecated
    final Color primary = Color(0xFF14A800); // Màu xanh lá cây từ AppTheme
    final Color onPrimary = theme.colorScheme.onPrimary; // Màu trắng từ AppTheme
    final Color surface = theme.colorScheme.surface; // Nền trắng từ AppTheme

    // isFocused: Giống FilledButton (nền màu chính, nội dung màu trắng)
    // !isFocused: Giống OutlinedButton (nền trắng, viền và nội dung màu chính)
    final Color backgroundColor = isFocused ? primary : surface;
    final Color foregroundColor = isFocused ? onPrimary : primary;
    final double borderWidth = isFocused ? 0 : 1.5;

    // Kích thước tùy biến theo nền tảng
    final double mainCircleSize = kIsWeb ? (isFocused ? 24.0 : 20.0) : (isFocused ? 48.0 : 40.0);
    final double iconSize = kIsWeb ? (isFocused ? 14.0 : 11.0) : (isFocused ? 28.0 : 22.0);
    final double badgeSize = kIsWeb ? (isFocused ? 11.0 : 10.0) : (isFocused ? 22.0 : 20.0);
    final double badgeOffset = kIsWeb ? -2.0 : -4.0;
    final EdgeInsets padding = kIsWeb ? const EdgeInsets.all(2.0) : const EdgeInsets.all(4.0);

    return Padding(
      padding: padding,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // HÌNH TRÒN CHÍNH
          Container(
            width: mainCircleSize,
            height: mainCircleSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: primary, width: borderWidth),
              boxShadow: [
                BoxShadow(
                  color: isFocused ? Colors.black.withValues(alpha: .3) : Colors.black.withValues(alpha: .15),
                  blurRadius: isFocused ? 8 : 4,
                  offset: isFocused ? const Offset(0, 4) : const Offset(0, 2),
                ),
              ],
            ),
            // ICON `ev_station`
            child: Center(
              child: Icon(
                stationType == StationType.bike
                    ? Icons.two_wheeler // Icon cho xe máy
                    : Icons.ev_station,
                color: foregroundColor,
                size: iconSize,
              ),
            ),
          ),

          // NHÃN SỐ
          Positioned(
            top: badgeOffset,
            right: badgeOffset,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: foregroundColor, width: 1.0), 
              ),
              child: Center(
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    color: foregroundColor,
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