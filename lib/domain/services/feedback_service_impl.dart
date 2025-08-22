import 'package:dio/dio.dart'; // <-- THÊM MỚI: Cần Dio để thực hiện HTTP request
import '../../domain/entities/station_entity.dart';
import '../../domain/services/i_feedback_service.dart';

class FeedbackServiceImpl implements IFeedbackService {
  // --- XÓA BỎ: Các hằng số cho mailto không còn cần thiết nữa ---
  // static const String _recipientEmail = '...'; 

  @override
  Future<void> sendReportEmail({ // Tên hàm vẫn giữ nguyên để không phải sửa BLoC
    required StationEntity station,
    required String reason,
    String? details,
    String? phoneNumber,
  }) async {
    // --- BƯỚC 1: Thay thế URL này bằng URL thật của Cloud Function của sếp ---
    // Sếp sẽ lấy URL này sau khi deploy Firebase Function thành công (Giai đoạn C, Bước 8)
    const String cloudFunctionUrl = 'https://us-central1-smart-charger-app-468817.cloudfunctions.net/submitReport';

    // --- BƯỚC 2: Chuẩn bị dữ liệu dưới dạng JSON (payload) ---
    // Dữ liệu này sẽ được gửi trong body của HTTP POST request
    final Map<String, dynamic> reportData = {
      'stationId': station.id,
      'reason': reason,
      'details': details ?? '', // Gửi chuỗi rỗng nếu null
      'phoneNumber': phoneNumber ?? '', // Gửi chuỗi rỗng nếu null
      'timestamp': DateTime.now().toIso8601String(),
      // Thêm các thông tin hữu ích khác vào payload để ghi vào Sheet
      'stationName': station.name,
      'stationAddress': station.address,
    };
    
    // --- BƯỚC 3: Gửi dữ liệu đến Cloud Function ---
    try {
      // Sử dụng một instance Dio mới để gọi đến URL tuyệt đối của Cloud Function.
      // Điều này đảm bảo nó không bị ảnh hưởng bởi baseUrl đã cấu hình cho các API khác.
      final response = await Dio().post(
        cloudFunctionUrl,
        data: reportData,
      );

      // (Tùy chọn) Kiểm tra xem server có trả về mã thành công không
      if (response.statusCode != 200) {
        throw Exception('Server đã phản hồi với lỗi: ${response.statusCode}');
      }
      // Nếu không có lỗi, quá trình gửi đã thành công.

    } on DioException {
      // Xử lý các lỗi liên quan đến mạng (không có kết nối, timeout...)
      throw Exception('Không thể gửi báo cáo. Vui lòng kiểm tra kết nối mạng và thử lại.');
    } catch (e) {
      // Bắt các lỗi không mong muốn khác
      throw Exception('Đã có lỗi không mong muốn xảy ra. Vui lòng thử lại sau.');
    }
  }
}