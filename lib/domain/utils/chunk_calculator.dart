import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChunkCalculator {
  static const double gridSize = 0.05;

  /// Tính toán chunkId từ một vị trí LatLng.
  /// Công thức phải khớp với công thức trên backend.
  static String calculateChunkId(LatLng position) {
    final latChunk = (position.latitude / gridSize).floor();
    final lonChunk = (position.longitude / gridSize).floor();
    return 'chunk_${latChunk}_$lonChunk';
  }
}