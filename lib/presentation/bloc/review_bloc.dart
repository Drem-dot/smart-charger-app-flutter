import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_charger_app/domain/entities/review_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_review_repository.dart';
import 'package:smart_charger_app/domain/services/anonymous_identity_service.dart';

part 'review_event.dart';
part 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final IReviewRepository _reviewRepository;
  final String stationId;
  final AnonymousIdentityService _identityService;

  ReviewBloc({
    required IReviewRepository reviewRepository,
    required this.stationId,
    required AnonymousIdentityService identityService,
  })  : _reviewRepository = reviewRepository,
        _identityService = identityService,
        super(ReviewInitial()) {
    on<ReviewsFetched>(_onReviewsFetched);
    on<ReviewSubmitted>(_onReviewSubmitted);
    on<ReviewUpdated>(_onReviewUpdated);
    on<ReviewDeleted>(_onReviewDeleted);
  }

  Future<void> _onReviewsFetched(ReviewsFetched event, Emitter<ReviewState> emit) async {
    emit(ReviewLoading());
    try {
      final anonymousId = await _identityService.getAnonymousId();
      final reviews = await _reviewRepository.getReviews(stationId: stationId, anonymousId: anonymousId);
      ReviewEntity? currentUserReview;
      try {
        currentUserReview = reviews.firstWhere((r) => r.isMine);
      } catch (e) {
        currentUserReview = null;
      }
      emit(ReviewLoadSuccess(reviews, currentUserReview: currentUserReview));
    } catch (e) {
      emit(ReviewLoadFailure(e.toString()));
    }
  }

  Future<void> _onReviewSubmitted(ReviewSubmitted event, Emitter<ReviewState> emit) async {
    emit(ReviewSubmitInProgress());
    try {
      await _reviewRepository.submitReview(
        stationId: stationId,
        rating: event.rating,
        comment: event.comment,
      );
      emit(ReviewSubmitSuccess());
      add(ReviewsFetched());
    } catch (e) {
      emit(ReviewSubmitFailure(e.toString()));
    }
  }

  // --- THÊM MỚI: Handler cho việc cập nhật review ---
  Future<void> _onReviewUpdated(ReviewUpdated event, Emitter<ReviewState> emit) async {
    // Chỉ có thể cập nhật nếu đang ở trạng thái Success và có review của người dùng
    if (state is! ReviewLoadSuccess || (state as ReviewLoadSuccess).currentUserReview == null) {
      return;
    }
    
    final currentUserReview = (state as ReviewLoadSuccess).currentUserReview!;
    
    emit(ReviewSubmitInProgress());
    try {
      await _reviewRepository.updateReview(
        reviewId: currentUserReview.id,
        rating: event.rating,
        comment: event.comment,
      );
      emit(ReviewSubmitSuccess());
      add(ReviewsFetched()); // Làm mới danh sách
    } catch (e) {
      emit(ReviewSubmitFailure(e.toString()));
      // Nếu lỗi, quay về trạng thái hiển thị danh sách cũ
      add(ReviewsFetched());
    }
  }

  // --- THÊM MỚI: Handler cho việc xóa review ---
  Future<void> _onReviewDeleted(ReviewDeleted event, Emitter<ReviewState> emit) async {
    if (state is! ReviewLoadSuccess || (state as ReviewLoadSuccess).currentUserReview == null) {
      return;
    }
    
    final currentUserReview = (state as ReviewLoadSuccess).currentUserReview!;
    
    emit(ReviewSubmitInProgress());
    try {
      await _reviewRepository.deleteReview(reviewId: currentUserReview.id);
      emit(ReviewSubmitSuccess());
      add(ReviewsFetched()); // Làm mới danh sách
    } catch (e) {
      emit(ReviewSubmitFailure(e.toString()));
      // Nếu lỗi, quay về trạng thái hiển thị danh sách cũ
      add(ReviewsFetched());
    }
  }
}