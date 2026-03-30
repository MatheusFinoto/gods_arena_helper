import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/entities/account.dart';
import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';
import 'package:helper_frontend/domain/usecases/settings_usecase.dart';

class MainState extends ChangeNotifier {
  final AccountsUsecase accountsUsecase;
  final SettingsUsecase settingsUsecase;

  MainState({
    required this.accountsUsecase,
    required this.settingsUsecase,
  }) {
    loadTheme();
    loadAccounts();
  }

  bool _isDarkThemeEnabled = false;
  bool _isLoadingAccounts = false;
  bool _hasLoadedAccounts = false;
  List<Account> _accounts = [];

  bool get isDarkThemeEnabled => _isDarkThemeEnabled;
  bool get isLoadingAccounts => _isLoadingAccounts;
  List<Account> get accounts => List.unmodifiable(_accounts);

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

  Future<void> loadAccounts({bool forceRefresh = false}) async {
    if (_isLoadingAccounts) return;
    if (_hasLoadedAccounts && !forceRefresh) return;

    _isLoadingAccounts = true;
    notifyListeners();

    try {
      _accounts = await accountsUsecase.loadAccounts();
      _hasLoadedAccounts = true;
    } finally {
      _isLoadingAccounts = false;
      notifyListeners();
    }
  }

  void focusAccountWindow(int processId) {
    accountsUsecase.focusAccountWindow(processId);
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
