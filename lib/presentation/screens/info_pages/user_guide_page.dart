// lib/presentation/screens/info_pages/user_guide_page.dart

import 'package:flutter/material.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';

class UserGuidePage extends StatelessWidget {
  const UserGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsUserGuide),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          // --- SẾP SẼ DÁN NỘI DUNG CHI TIẾT VÀO ĐÂY ---
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.userGuideWelcome,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context)!.userGuideIntro,
              ),
              const SizedBox(height: 24),

              _buildGuideSection(
                context,
                icon: Icons.search,
                title: AppLocalizations.of(context)!.userGuideSection1Title,
                content: AppLocalizations.of(context)!.userGuideSection1Content,
              ),
              _buildGuideSection(
                context,
                icon: Icons.ev_station,
                title: AppLocalizations.of(context)!.userGuideSection2Title,
                content: AppLocalizations.of(context)!.userGuideSection2Content,
              ),
              _buildGuideSection(
                context,
                icon: Icons.info_outline,
                title: AppLocalizations.of(context)!.userGuideSection3Title,
                content: AppLocalizations.of(context)!.userGuideSection3Content,
              ),
              _buildGuideSection(
                context,
                icon: Icons.directions,
                title: AppLocalizations.of(context)!.userGuideSection4Title,
                content: AppLocalizations.of(context)!.userGuideSection4Content,
              ),
              _buildGuideSection(
                context,
                icon: Icons.report_problem,
                title: AppLocalizations.of(context)!.userGuideSection5Title,
                content: AppLocalizations.of(context)!.userGuideSection5Content,
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
