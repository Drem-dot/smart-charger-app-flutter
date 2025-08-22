// lib/presentation/screens/info_pages/owner_guide_page.dart

import 'package:flutter/material.dart';

class OwnerGuidePage extends StatelessWidget {
  const OwnerGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hướng dẫn cho Chủ trạm')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // --- SẾP SẼ DÁN NỘI DUNG CHI TIẾT VÀO ĐÂY ---
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đưa Trạm sạc của bạn lên Bản đồ',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                'Cảm ơn bạn đã quan tâm đến việc đóng góp vào mạng lưới Sạc Thông Minh. Việc thêm trạm sạc của bạn lên hệ thống là hoàn toàn miễn phí và chỉ mất vài phút.',
              ),
              const SizedBox(height: 24),

              _buildGuideSection(
                context,
                icon: Icons.checklist,
                title: 'Bước 1: Chuẩn bị Thông tin',
                content:
                    'Để quá trình thêm trạm diễn ra nhanh chóng, vui lòng chuẩn bị sẵn các thông tin sau:\n'
                    '• Tên chính xác của trạm sạc.\n'
                    '• Địa chỉ chi tiết.\n'
                    '• Vị trí chính xác trên bản đồ (bạn sẽ chọn bằng cách thả ghim).\n'
                    '• Số lượng và loại cổng sạc (ví dụ: CCS2, Type 2...).\n'
                    '• Công suất của từng loại cổng (ví dụ: 60kW, 120kW...).\n'
                    '• Giờ hoạt động (ví dụ: 24/7, 8h-22h).\n'
                    '• Chi tiết về giá hoặc phí đỗ xe (nếu có).',
              ),
              _buildGuideSection(
                context,
                icon: Icons.add_location_alt,
                title: 'Bước 2: Sử dụng tính năng "Thêm trạm"',
                content:
                    '• Từ màn hình bản đồ chính, nhấn vào nút "Thêm trạm" (biểu tượng dấu cộng).\n'
                    '• Một bản đồ nhỏ sẽ hiện ra, hãy di chuyển và nhấn giữ để "thả ghim" vào đúng vị trí trạm sạc của bạn, sau đó nhấn "Xác nhận".\n'
                    '• Điền đầy đủ các thông tin đã chuẩn bị ở Bước 1 vào biểu mẫu.\n'
                    '• Kiểm tra lại lần cuối và nhấn "Gửi".',
              ),
              _buildGuideSection(
                context,
                icon: Icons.hourglass_top,
                title: 'Bước 3: Chờ duyệt',
                content:
                    '• Sau khi bạn gửi thông tin, đội ngũ của chúng tôi sẽ tiến hành xác minh.\n'
                    '• Quá trình này có thể mất từ 1-3 ngày làm việc.\n'
                    '• Sau khi được duyệt, trạm sạc của bạn sẽ chính thức xuất hiện trên bản đồ cho hàng ngàn người dùng xe điện thấy.\n\n'
                    'Cảm ơn sự đóng góp của bạn!',
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
