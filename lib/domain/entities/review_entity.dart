// lib/domain/entities/review_entity.dart
import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String comment;
  final int rating;
  final String userName;
  final DateTime createdAt;
  final bool isMine; // <-- THÊM MỚI

  const ReviewEntity({
    required this.id,
    required this.comment,
    required this.rating,
    required this.userName,
    required this.createdAt,
    this.isMine = false, // <-- THÊM MỚI
  });

  @override
  List<Object?> get props => [id, comment, rating, userName, createdAt, isMine];
}