import '../../domain/entities/station_entity.dart';

abstract class IFeedbackService {
  Future<void> sendReportEmail({
    required StationEntity station,
    required String reason,
    String? details, // Thêm details vào interface
    String? phoneNumber,
  });
}