// lib/presentation/widgets/cluster_marker_widget.dart

import 'package:flutter/material.dart';

class ClusterMarkerWidget extends StatelessWidget {
  final int count;
  const ClusterMarkerWidget({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    const double size = 50;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}