// lib/presentation/utils/formatters.dart

String formatDistance(double distanceInKm) {
  if (distanceInKm < 1) {
    final meters = (distanceInKm * 1000).round();
    return '$meters m';
  } else {
    return '${distanceInKm.toStringAsFixed(1)} km';
  }
}