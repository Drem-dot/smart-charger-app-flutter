// lib/data/repositories/review_repository_impl.dart
import 'package:dio/dio.dart';
import 'package:smart_charger_app/data/models/review_model.dart';
import 'package:smart_charger_app/domain/entities/review_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_review_repository.dart';
import 'package:smart_charger_app/domain/services/anonymous_identity_service.dart';

class ReviewRepositoryImpl implements IReviewRepository {
  final Dio _dio;
  final AnonymousIdentityService _identityService;

  ReviewRepositoryImpl(this._dio, this._identityService);

  @override
  Future<List<ReviewEntity>> getReviews({required String stationId, required String anonymousId}) async {
    try {
      final response = await _dio.get(
        '/api/v1/stations/$stationId/reviews',
        queryParameters: {'anonymousId': anonymousId},
      );
      if (response.statusCode == 200 && response.data['data']?['reviews'] != null) {
        final List<dynamic> reviewList = response.data['data']['reviews'];
        return reviewList.map((json) => ReviewModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) { rethrow; }
  }

  @override
  Future<ReviewEntity> submitReview({
    required String stationId,
    required int rating,
    required String comment,
  }) async {
    try {
      final anonymousId = await _identityService.getAnonymousId();
      final response = await _dio.post(
        '/api/v1/stations/$stationId/reviews',
        data: {
          'rating': rating,
          'comment': comment,
          'anonymousId': anonymousId,
        },
      );
      if (response.statusCode == 201 && response.data['data']?['review'] != null) {
        return ReviewModel.fromJson(response.data['data']['review']);
      } else {
        throw Exception('Gửi đánh giá thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        final errorMessage = e.response?.data?['message'] ?? 'Bạn đã đánh giá trạm này rồi.';
        throw Exception(errorMessage);
      }
      throw Exception('Không thể gửi đánh giá. Vui lòng thử lại.');
    }
  }

   @override
  Future<ReviewEntity> updateReview({
    required String reviewId,
    required int rating,
    required String comment,
  }) async {
    try {
      final anonymousId = await _identityService.getAnonymousId();
      final response = await _dio.patch(
        '/api/v1/reviews/$reviewId', // Sử dụng endpoint mới
        data: {
          'rating': rating,
          'comment': comment,
          'anonymousId': anonymousId,
        },
      );
      if (response.statusCode == 200 && response.data['data']?['review'] != null) {
        return ReviewModel.fromJson(response.data['data']['review']);
      } else {
        throw Exception('Cập nhật đánh giá thất bại');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền sửa đánh giá này.');
      }
      throw Exception('Không thể cập nhật đánh giá. Vui lòng thử lại.');
    }
  }

  // --- THÊM MỚI: Implement `deleteReview` ---
  @override
  Future<void> deleteReview({required String reviewId}) async {
    try {
      final anonymousId = await _identityService.getAnonymousId();
      await _dio.delete(
        '/api/v1/reviews/$reviewId',
        data: { 'anonymousId': anonymousId },
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Bạn không có quyền xóa đánh giá này.');
      }
      throw Exception('Không thể xóa đánh giá. Vui lòng thử lại.');
    }
  }
}