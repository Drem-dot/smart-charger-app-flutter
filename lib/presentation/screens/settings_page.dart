// lib/presentation/screens/settings_page.dart
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smart_charger_app/l10n/app_localizations.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/owner_guide_page.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/partnership_page.dart';
import 'package:smart_charger_app/presentation/screens/info_pages/user_guide_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsPageTitle),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.business_center),
            title: Text(AppLocalizations.of(context)!.settingsPartnership),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PartnershipPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: Text(AppLocalizations.of(context)!.settingsUserGuide),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserGuidePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.storefront),
            title: Text(AppLocalizations.of(context)!.settingsOwnerGuide),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OwnerGuidePage()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(AppLocalizations.of(context)!.settingsShareApp),
            onTap: () {
              SharePlus.instance.share(ShareParams(text: AppLocalizations.of(context)!.settingsShareAppMessage));
            },
          ),
        ],
      ),
    );
  }
}