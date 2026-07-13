import 'package:flutter/material.dart';
import 'package:vac_dashboard_app/component/header.dart';
import 'package:vac_dashboard_app/component/grouped_list.dart';
import 'package:vac_dashboard_app/main.dart';
import 'package:vac_dashboard_app/asset/color_tokens.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We rely on Theme.of(context).scaffoldBackgroundColor for dark/light support
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
            AppGroupedList(
              children: [
                ValueListenableBuilder<ThemeMode>(
                  valueListenable: appThemeMode,
                  builder: (context, currentMode, _) {
                    return AppGroupedListTile(
                      title: 'Dark Mode',
                      leading: const Icon(Icons.dark_mode_rounded),
                      trailing: Switch(
                        value: currentMode == ThemeMode.dark,
                        activeColor: context.colors.accentsBlue,
                        onChanged: (isDark) {
                          appThemeMode.value = isDark
                              ? ThemeMode.dark
                              : ThemeMode.light;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
