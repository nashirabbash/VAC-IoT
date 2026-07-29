import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

extension ThemeModeX on ThemeMode {
  String toStorageString() {
    switch (this) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode fromStorageString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

class SettingsRepository {
  static const String _themeModeKey = 'theme_mode';
  final FlutterSecureStorage _storage;

  const SettingsRepository({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write(key: _themeModeKey, value: mode.toStorageString());
  }

  Future<ThemeMode> getThemeMode() async {
    final rawValue = await _storage.read(key: _themeModeKey);
    return ThemeModeX.fromStorageString(rawValue);
  }
}
