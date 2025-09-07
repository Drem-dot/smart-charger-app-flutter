part of 'review_bloc.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();
  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {}
class ReviewLoading extends ReviewState {}

class ReviewLoadSuccess extends ReviewState {
  final List<ReviewEntity> reviews;
  // Thêm currentUserReview để UI biết nên hiển thị form nào
  final ReviewEntity? currentUserReview; 
  const ReviewLoadSuccess(this.reviews, {this.currentUserReview});
  @override
  List<Object?> get props => [reviews, currentUserReview];
}

class ReviewLoadFailure extends ReviewState {
  final String error;
  const ReviewLoadFailure(this.error);
  @override
  List<Object> get props => [error];
}

// State cho việc Gửi / Cập nhật / Xóa
class ReviewSubmitInProgress extends ReviewState {}
class ReviewSubmitSuccess extends ReviewState {}
class ReviewSubmitFailure extends ReviewState {
  final String error;
  const ReviewSubmitFailure(this.error);
  @override
  List<Object> get props => [error];
}