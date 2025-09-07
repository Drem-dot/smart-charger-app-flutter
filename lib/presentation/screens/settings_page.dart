// lib/presentation/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/owner_guide_page.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/partnership_page.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/user_guide_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt & Thông tin'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.business_center),
            title: const Text('Giới thiệu hợp tác'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnershipPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Hướng dẫn sử dụng'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserGuidePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: const Text('Hướng dẫn chủ trạm sạc'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerGuidePage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Chia sẻ ứng dụng'),
            onTap: () {
              SharePlus.instance.share(ShareParams(text: 'Hãy thử Sạc Thông Minh!'));
            },
          ),
        ],
      ),
    );
  }
}