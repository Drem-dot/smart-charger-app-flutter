// lib/data/models/review_model.dart
import 'package:smart_charger_app/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.comment,
    required super.rating,
    required super.userName,
    required super.createdAt,
    required super.isMine, // <-- THÊM MỚI
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] as String,
      comment: json['comment'] as String? ?? '',
      rating: (json['rating'] as num).toInt(),
      userName: json['user'] as String? ?? 'Người dùng ẩn danh',
      createdAt: DateTime.parse(json['createdAt'] as String),
      // --- YÊU CẦU CHO BACKEND ---
      // Backend sẽ trả về trường `isMine`
      isMine: json['isMine'] as bool? ?? false,
    );
  }
}