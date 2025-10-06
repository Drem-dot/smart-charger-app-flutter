// lib/presentation/screens/info_pages/owner_guide_page.dart

import 'package:flutter/material.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';

class OwnerGuidePage extends StatelessWidget {
  const OwnerGuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.settingsOwnerGuide)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.ownerGuideTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(
                localizations.ownerGuideIntro,
              ),
              const SizedBox(height: 24),
              _buildGuideSection(
                context,
                icon: Icons.checklist,
                title: localizations.ownerGuideStep1Title,
                content: localizations.ownerGuideStep1Content,
              ),
              _buildGuideSection(
                context,
                icon: Icons.add_location_alt,
                title: localizations.ownerGuideStep2Title,
                content: localizations.ownerGuideStep2Content,
              ),
              _buildGuideSection(
                context,
                icon: Icons.hourglass_top,
                title: localizations.ownerGuideStep3Title,
                content: localizations.ownerGuideStep3Content,
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }
}
