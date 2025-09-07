part of 'review_bloc.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();
  @override
  List<Object?> get props => [];
}

class ReviewsFetched extends ReviewEvent {}

class ReviewSubmitted extends ReviewEvent {
  final int rating;
  final String comment;
  const ReviewSubmitted({required this.rating, required this.comment});
  @override
  List<Object> get props => [rating, comment];
}

// --- THÊM MỚI ---
/// Bắn khi người dùng nhấn nút "Cập nhật"
class ReviewUpdated extends ReviewEvent {
  final int rating;
  final String comment;
  const ReviewUpdated({required this.rating, required this.comment});
  @override
  List<Object> get props => [rating, comment];
}

/// Bắn khi người dùng nhấn nút "Xóa"
class ReviewDeleted extends ReviewEvent {}