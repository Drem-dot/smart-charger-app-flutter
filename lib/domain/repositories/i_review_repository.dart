// lib/domain/repositories/i_review_repository.dart
import 'package:smart_charger_app/domain/entities/review_entity.dart';

abstract class IReviewRepository {
  // THAY ĐỔI:
  Future<List<ReviewEntity>> getReviews({required String stationId, required String anonymousId});

  Future<ReviewEntity> submitReview({
    required String stationId,
    required int rating,
    required String comment,
    // Xóa userName, thay bằng anonymousId
  });

   Future<ReviewEntity> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  });

  Future<void> deleteReview({required String reviewId});
}