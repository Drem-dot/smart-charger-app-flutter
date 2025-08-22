// lib/presentation/widgets/app_drawer.dart

import 'package:flutter/material.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/owner_guide_page.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/partnership_page.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/user_guide_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  // URL tới trang web
  final String _websiteUrl = 'https://sacthongminh.com';

  // Hàm để mở URL
  Future<void> _launchUrl() async {
    final Uri url = Uri.parse(_websiteUrl);
    if (!await launchUrl(url)) {
      // Có thể hiển thị một thông báo lỗi ở đây nếu cần
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white, // Hoặc màu nền phù hợp với logo
            ),
            child: Center(
              // Giả sử logo được lưu tại 'assets/images/logo.png'
              child: Image.asset('assets/icons/logo1.png'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.business_center),
            title: const Text('Giới thiệu hợp tác'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context); // Đóng Drawer trước
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PartnershipPage())); // Đóng Drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Tới trang sacthongminh.com'),
            onTap: () {
              _launchUrl(); // Gọi hàm mở link
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Hướng dẫn sử dụng'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const UserGuidePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Hướng dẫn chủ trạm sạc'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const OwnerGuidePage()));
            },
          ),
          const Divider(),
          // Thông tin liên hệ và mã số thuế
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thông tin liên hệ:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('Email: contact@sacthongminh.com'),
                const Text('Hotline: 1900 1234'),
                const SizedBox(height: 12),
                 Text(
                  'Mã số thuế:',
                   style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text('0123456789'), // Thay bằng MST thực tế
              ],
            ),
          ),
        ],
      ),
    );
  }
}