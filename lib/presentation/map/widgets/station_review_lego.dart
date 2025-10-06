import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_charger_app/config/constants.dart';
import 'package:smart_charger_app/domain/entities/review_entity.dart';
import 'package:smart_charger_app/domain/entities/station_entity.dart';
import 'package:smart_charger_app/domain/repositories/i_review_repository.dart';
import 'package:smart_charger_app/domain/services/anonymous_identity_service.dart';
import 'package:smart_charger_app/presentation/bloc/review_bloc.dart';

/// Lego chính, chịu trách nhiệm cung cấp ReviewBloc và điều phối
/// việc hiển thị các thành phần con.
class StationReviewLego extends StatelessWidget {
  final StationEntity station;
  const StationReviewLego({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReviewBloc(
        reviewRepository: context.read<IReviewRepository>(),
        identityService: context.read<AnonymousIdentityService>(),
        stationId: station.id,
      )..add(ReviewsFetched()),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 32),
          StationImages(imageUrls: station.imageUrls),
          const Divider(height: 32),
          Text(
            'Đánh giá & Bình luận',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Widget này sẽ tự quyết định hiển thị form nào
          _ReviewFormManager(station: station),

          const SizedBox(height: 24),
          const _ReviewList(),
        ],
      ),
    );
  }
}

/// Widget điều phối, quyết định hiển thị form Tạo mới hay Sửa/Xóa
class _ReviewFormManager extends StatelessWidget {
  final StationEntity station;
  const _ReviewFormManager( {required this.station});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      // Chỉ build lại khi currentUserReview thay đổi để tối ưu
      buildWhen: (previous, current) {
        if (previous is ReviewLoadSuccess && current is ReviewLoadSuccess) {
          return previous.currentUserReview != current.currentUserReview;
        }
        // Build lại cho các trạng thái khác như loading, initial...
        return true;
      },
      builder: (context, state) {
        if (state is ReviewLoadSuccess) {
          // Nếu có review của người dùng -> Hiển thị form Sửa/Xóa
          if (state.currentUserReview != null) {
            return _EditReviewForm(review: state.currentUserReview!,station: station);
          }
        }
        // Mặc định hoặc khi chưa có review -> Hiển thị form Tạo mới
        return const _NewReviewForm();
      },
    );
  }
}

/// Widget chứa form để TẠO MỚI một review
class _NewReviewForm extends StatefulWidget {
  const _NewReviewForm();
  @override
  State<_NewReviewForm> createState() => _NewReviewFormState();
}

class _NewReviewFormState extends State<_NewReviewForm> {
  final _commentController = TextEditingController();
  int _selectedRating = 0;

  void _submitReview() {
    if (_selectedRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn số sao.')));
      return;
    }
    context.read<ReviewBloc>().add(
      ReviewSubmitted(
        rating: _selectedRating,
        comment: _commentController.text,
      ),
    );
    _commentController.clear();
    setState(() => _selectedRating = 0);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final isSubmitting = state is ReviewSubmitInProgress;
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _selectedRating > index ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () => setState(() => _selectedRating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Viết bình luận của bạn...',
              ),
              maxLines: 1,
              readOnly: isSubmitting,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReview,
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Gửi đánh giá'),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Widget chứa form để SỬA hoặc XÓA một review đã có
class _EditReviewForm extends StatefulWidget {
  final ReviewEntity review;
  final StationEntity station;
  const _EditReviewForm({required this.review, required this.station});
  @override
  State<_EditReviewForm> createState() => __EditReviewFormState();
}

class __EditReviewFormState extends State<_EditReviewForm> {
  late final TextEditingController _commentController;
  late int _selectedRating;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController(text: widget.review.comment);
    _selectedRating = widget.review.rating;
  }

  void _updateReview() {
    context.read<ReviewBloc>().add(
      ReviewUpdated(rating: _selectedRating, comment: _commentController.text),
    );
    FocusScope.of(context).unfocus();
  }

  void _deleteReview() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa đánh giá?'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<ReviewBloc>().add(ReviewDeleted());
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        final isSubmitting = state is ReviewSubmitInProgress;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'Đánh giá của bạn:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _selectedRating > index ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () => setState(() => _selectedRating = index + 1),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Sửa bình luận của bạn...',
              ),
              maxLines: 3,
              readOnly: isSubmitting,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isSubmitting ? null : _deleteReview,
                    child: const Text('Xóa'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : _updateReview,
                    child: const Text('Cập nhật'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ... bên trong class _SheetCollapsedContent

class StationImages extends StatelessWidget {
  final List<String> imageUrls;
  const StationImages({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const SizedBox.shrink(); // Không có ảnh thì không hiển thị gì
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hình ảnh', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SizedBox(
          height: 100, // Chiều cao của hàng ảnh
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              final String fullImageUrl = AppConfig.baseUrl + imageUrls[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    fullImageUrl,
                    width: 150,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 150,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 150,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(Icons.broken_image, color: Colors.grey),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
/// Widget chỉ chịu trách nhiệm hiển thị danh sách các review
class _ReviewList extends StatelessWidget {
  const _ReviewList();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ReviewBloc, ReviewState>(
      listener: (context, state) {
        if (state is ReviewSubmitFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      builder: (context, state) {
        if (state is ReviewLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is ReviewLoadSuccess) {
          final otherReviews = state.reviews.where((r) => !r.isMine).toList();
          if (otherReviews.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Chưa có đánh giá nào khác.'),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: otherReviews.length,
            itemBuilder: (context, index) {
              final review = otherReviews[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(review.userName),
                  subtitle: Text(review.comment),
                  leading: CircleAvatar(child: Text(review.rating.toString())),
                ),
              );
            },
          );
        }
        if (state is ReviewLoadFailure) {
          return Center(child: Text('Lỗi tải đánh giá: ${state.error}'));
        }
        return const SizedBox.shrink();
      },
    );
  }
}
