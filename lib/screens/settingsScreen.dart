import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/component/text.dart';
import 'package:vac_dashboard_app/main.dart';
import 'package:vac_dashboard_app/repositories/auth_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _updateThemeMode(ThemeMode mode) {
    appThemeMode.value = mode;
    final authRepo = AuthRepository();
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    authRepo.saveThemeMode(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader(
        title: 'Settings',
        variant: AppHeaderVariant.compactTitle3,
        titleTextAlign: TextAlign.center,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: AppText(
                'TAMPILAN & TEMA',
                type: AppTextType.caption1,
                color: AppTextColor.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: appThemeMode,
              builder: (context, currentMode, _) {
                return AppGroupedList(
                  children: [
                    AppGroupedListTile(
                      title: 'Otomatis (Sistem)',
                      subtitle: 'Mengikuti pengaturan tema perangkat',
                      leading: const Icon(Icons.brightness_auto_rounded),
                      showCheckmark: currentMode == ThemeMode.system,
                      showChevron: false,
                      onTap: () => _updateThemeMode(ThemeMode.system),
                    ),
                    AppGroupedListTile(
                      title: 'Mode Terang',
                      subtitle: 'Tampilan tema terang',
                      leading: const Icon(Icons.light_mode_rounded),
                      showCheckmark: currentMode == ThemeMode.light,
                      showChevron: false,
                      onTap: () => _updateThemeMode(ThemeMode.light),
                    ),
                    AppGroupedListTile(
                      title: 'Mode Gelap',
                      subtitle: 'Tampilan tema gelap',
                      leading: const Icon(Icons.dark_mode_rounded),
                      showCheckmark: currentMode == ThemeMode.dark,
                      showChevron: false,
                      onTap: () => _updateThemeMode(ThemeMode.dark),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
