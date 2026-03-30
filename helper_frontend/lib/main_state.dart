import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/usecases/settings_usecase.dart';
import 'package:provider/provider.dart';

class MainState extends ChangeNotifier {
  final BuildContext context;
  late final SettingsUsecase settingsUsecase;

  MainState({required this.context}) {
    settingsUsecase = context.read<SettingsUsecase>();
    loadTheme();
  }

  bool _isDarkThemeEnabled = false;

  bool get isDarkThemeEnabled => _isDarkThemeEnabled;

  ThemeMode get themeMode {
    return _isDarkThemeEnabled ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> loadTheme() async {
    try {
      final settings = await settingsUsecase.loadSettings();
      _isDarkThemeEnabled = settings.isDarkThemeEnabled;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> setDarkThemeEnabled(bool value) async {
    final previousValue = _isDarkThemeEnabled;
    _isDarkThemeEnabled = value;
    notifyListeners();

    try {
      await settingsUsecase.saveDarkThemeEnabled(value);
      return true;
    } catch (_) {
      _isDarkThemeEnabled = previousValue;
      notifyListeners();
      return false;
    }
  }
}
