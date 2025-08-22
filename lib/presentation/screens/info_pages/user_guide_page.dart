// lib/presentation/screens/info_pages/user_guide_page.dart

import 'package:flutter/material.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hướng dẫn sử dụng'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // --- SẾP SẼ DÁN NỘI DUNG CHI TIẾT VÀO ĐÂY ---
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chào mừng bạn đến với Sạc Thông Minh!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Ứng dụng giúp bạn dễ dàng tìm kiếm và di chuyển đến các trạm sạc xe điện trên toàn quốc. Dưới đây là hướng dẫn các tính năng chính:',
              ),
              const SizedBox(height: 24),

              _buildGuideSection(
                context,
                icon: Icons.search,
                title: '1. Tìm kiếm và Khám phá',
                content:
                    '• Sử dụng thanh tìm kiếm ở trên cùng để nhanh chóng di chuyển bản đồ đến một địa chỉ hoặc thành phố cụ thể.\n'
                    '• Lướt và zoom bản đồ để khám phá các trạm sạc xung quanh bạn. Các trạm sẽ tự động được tải và hiển thị.',
              ),
              _buildGuideSection(
                context,
                icon: Icons.ev_station,
                title: '2. Tìm đường và Xem chi tiết',
                content:
                    '• Nhấn vào nút "Đường đi" (biểu tượng mũi tên) cạnh thanh tìm kiếm để mở giao diện tìm lộ trình.\n'
                    '• Chọn điểm bắt đầu và kết thúc bằng cách: dùng vị trí hiện tại, chọn trên bản đồ, hoặc tìm kiếm địa chỉ.\n'
                    '• Sau khi lộ trình được vẽ, nhấn nút "Tìm trạm trên đường" để lọc và chỉ hiển thị các trạm sạc dọc theo tuyến đi của bạn.',
              ),
              _buildGuideSection(
                context,
                icon: Icons.info_outline,
                title: '3. Xem Thông tin Trạm sạc',
                content:
                    '• Nhấn vào một biểu tượng trạm sạc trên bản đồ để mở bảng thông tin chi tiết.\n'
                    '• Bảng thông tin sẽ hiển thị đầy đủ: địa chỉ, số lượng cổng sạc, công suất, giờ hoạt động, và chi tiết về giá.',
              ),
              _buildGuideSection(
                context,
                icon: Icons.directions,
                title: '4. Dẫn đường đến Trạm',
                content:
                    '• Trong bảng thông tin chi tiết, nhấn nút "Dẫn đường". Ứng dụng sẽ tự động mở Google Maps để bắt đầu chỉ đường cho bạn.',
              ),
              _buildGuideSection(
                context,
                icon: Icons.report_problem,
                title: '5. Báo cáo Vấn đề',
                content:
                    '• Nếu thông tin trạm sạc không chính xác hoặc gặp vấn đề khi sạc, hãy nhấn vào "Báo cáo vấn đề" trong bảng thông tin chi tiết để giúp chúng tôi cải thiện dữ liệu.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Thêm hàm helper này vào trong widget
Widget _buildGuideSection(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String content,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
        const SizedBox(height: 8),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
