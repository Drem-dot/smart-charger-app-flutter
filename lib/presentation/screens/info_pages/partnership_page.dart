import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Import NavigationHelper nếu tạo file riêng
// import '../../../utils/navigation_helper.dart';

// Hoặc định nghĩa inline NavigationHelper
class NavigationHelper {
  static void safeNavigateBack(BuildContext context) {
    if (!context.mounted) return;
    
    try {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
        return;
      }
      
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      
    } catch (e) {
      debugPrint('Lỗi navigation: $e');
      
      try {
        Navigator.of(context).maybePop();
      } catch (e2) {
        debugPrint('Lỗi fallback navigation: $e2');
      }
    }
  }
}

class PartnershipPage extends StatelessWidget {
  const PartnershipPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hợp tác cùng Sạc Thông Minh')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset('assets/icons/logo.png', height: 80), 
              ),
              const SizedBox(height: 16),
              Text(
                'Hợp tác cùng Sạc Thông Minh - Phát triển Tương lai Di chuyển Xanh',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              const Text(
                'Chúng tôi không chỉ là một ứng dụng, chúng tôi là một nền tảng kết nối các chủ trạm sạc với cộng đồng người dùng xe điện đang phát triển mạnh mẽ tại Việt Nam. Bằng cách hợp tác với Sạc Thông Minh, bạn sẽ nhận được:',
              ),
              const SizedBox(height: 16),

              _buildBenefit(
                context,
                icon: Icons.people,
                title: 'Tiếp cận Hàng ngàn Khách hàng',
                description:
                    'Đưa trạm sạc của bạn lên bản đồ, tiếp cận trực tiếp đến những người dùng đang có nhu cầu sạc xe mỗi ngày.',
              ),
              _buildBenefit(
                context,
                icon: Icons.analytics,
                title: 'Nền tảng Dữ liệu Thông minh',
                description:
                    'Hiểu rõ hơn về tần suất sử dụng và hiệu quả hoạt động của trạm sạc thông qua các công cụ phân tích của chúng tôi trong tương lai.',
              ),
              _buildBenefit(
                context,
                icon: Icons.verified,
                title: 'Thương hiệu Tin cậy',
                description:
                    'Trở thành một phần của mạng lưới trạm sạc được xác minh và tin cậy, nâng cao uy tín cho doanh nghiệp của bạn.',
              ),

              const Divider(height: 40),

              Text(
                'Thông tin liên hệ',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              const SelectableText(
                'CÔNG TY TNHH ĐẦU TƯ VÀ PHÁT TRIỂN PHẦN MỀM TRƯỜNG HẬU',
              ),
              const SizedBox(height: 8),
              const SelectableText('Mã số thuế: 0105884437'),
              const SizedBox(height: 8),
              const SelectableText('Số điện thoại: 0776.54.54.54'),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Quay lại bản đồ'),
                    onPressed: () => NavigationHelper.safeNavigateBack(context),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.call),
                    label: const Text('Liên hệ ngay'),
                    onPressed: () async {
                      final uri = Uri.parse('tel:0776545454');
                      try {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          // Hiển thị snackbar nếu không thể mở
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Không thể mở ứng dụng gọi điện'),
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        debugPrint('Lỗi khi gọi điện: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Có lỗi xảy ra khi gọi điện'),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefit(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 40, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(description, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}