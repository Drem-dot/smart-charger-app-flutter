import 'package:flutter/material.dart';

class ClusterMarkerWidget extends StatelessWidget {
  final int count;
  const ClusterMarkerWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    // Kích thước cơ bản
    final double baseSize = count < 10 ? 40 : (count < 100 ? 45 : 50); 
    
    // Tỷ lệ cho các vòng mờ
    final double outerRingFactor = 1.3;
    final double middleRingFactor = 1.15;
    
    // Màu Cam đậm (Deep Orange)
    const Color clusterColor = Colors.deepOrange;

    // Giá trị alpha cho độ mờ (0-255)
    const int alphaOuter = 51;  // ~20% opacity
    const int alphaMiddle = 76; // ~30% opacity

    return SizedBox(
      width: baseSize * outerRingFactor * 1.1,
      height: baseSize * outerRingFactor * 1.1,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vòng tròn mờ nhất
          Container(
            width: baseSize * outerRingFactor,
            height: baseSize * outerRingFactor,
            decoration: BoxDecoration(
              color: clusterColor.withAlpha(alphaOuter), 
              shape: BoxShape.circle,
            ),
          ),
          
          // Vòng tròn mờ vừa
          Container(
            width: baseSize * middleRingFactor,
            height: baseSize * middleRingFactor,
            decoration: BoxDecoration(
              color: clusterColor.withAlpha(alphaMiddle), 
              shape: BoxShape.circle,
            ),
          ),

          // Vòng tròn chính
          Container(
            width: baseSize,
            height: baseSize,
            decoration: BoxDecoration(
              color: clusterColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [ 
                BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))
              ],
            ),
            child: Center(
              child: Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: baseSize * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}