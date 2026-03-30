import 'package:helper_frontend/core/constants/shared_preferences_constants.dart';
import 'package:helper_frontend/domain/entities/app_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SettingsUsecase {
  Future<AppSettings> loadSettings();
  Future<void> saveGamePath(String gamePath);
  Future<void> saveDarkThemeEnabled(bool value);
  Future<void> saveBetterSearchEnabled(bool value);
}

SettingsUsecase newSettingsUsecase() => _SettingsUsecase();

class _SettingsUsecase implements SettingsUsecase {
  Future<SharedPreferences> _sharedPreferences() {
    return SharedPreferences.getInstance();
  }

  @override
  Future<AppSettings> loadSettings() async {
    final prefs = await _sharedPreferences();

    return AppSettings(
      gamePath: prefs.getString(SharedPreferencesConstants.gamePath) ?? '',
      isDarkThemeEnabled:
          prefs.getBool(SharedPreferencesConstants.isDarkThemeEnabled) ?? false,
      isBetterSearchEnabled:
          prefs.getBool(SharedPreferencesConstants.isBetterSearchEnabled) ??
          false,
    );
  }

  @override
  Future<void> saveGamePath(String gamePath) async {
    final prefs = await _sharedPreferences();
    final normalizedGamePath = gamePath.trim();

    if (normalizedGamePath.isEmpty) {
      await prefs.remove(SharedPreferencesConstants.gamePath);
      return;
    }

    await prefs.setString(
      SharedPreferencesConstants.gamePath,
      normalizedGamePath,
    );
  }

  @override
  Future<void> saveDarkThemeEnabled(bool value) async {
    final prefs = await _sharedPreferences();
    await prefs.setBool(SharedPreferencesConstants.isDarkThemeEnabled, value);
  }

  @override
  Future<void> saveBetterSearchEnabled(bool value) async {
    final prefs = await _sharedPreferences();
    await prefs.setBool(
      SharedPreferencesConstants.isBetterSearchEnabled,
      value,
    );
  }
}
