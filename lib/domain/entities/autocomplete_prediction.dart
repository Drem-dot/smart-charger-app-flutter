// lib/domain/entities/autocomplete_prediction.dart
import 'package:equatable/equatable.dart';

class AutocompletePrediction extends Equatable {
  /// Tên gợi ý, ví dụ: "Vincom Bà Triệu, Hai Bà Trưng, Hà Nội"
  final String description;
  /// ID của địa điểm, dùng để lấy tọa độ chi tiết
  final String placeId;

  const AutocompletePrediction({
    required this.description,
    required this.placeId,
  });
  
  @override
  List<Object?> get props => [description, placeId];
}