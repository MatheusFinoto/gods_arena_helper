import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/entities/app_settings.dart';
import 'package:helper_frontend/domain/usecases/settings_usecase.dart';

class SettingsState extends ChangeNotifier {
  final SettingsUsecase settingsUsecase;

  SettingsState({required this.settingsUsecase}) {
    gamePathController.addListener(_handleGamePathChange);
    loadSettings();
  }

  final TextEditingController gamePathController = TextEditingController();

  bool isLoading = true;
  bool isSavingGamePath = false;
  bool isDarkThemeEnabled = false;
  bool isBetterSearchEnabled = false;
  String savedGamePath = '';
  String? feedbackMessage;

  bool get hasConfiguredGamePath => savedGamePath.trim().isNotEmpty;

  bool get hasUnsavedGamePath {
    return gamePathController.text.trim() != savedGamePath;
  }

  Future<void> loadSettings() async {
    try {
      final AppSettings settings = await settingsUsecase.loadSettings();
      savedGamePath = settings.gamePath.trim();
      gamePathController.text = savedGamePath;
      isDarkThemeEnabled = settings.isDarkThemeEnabled;
      isBetterSearchEnabled = settings.isBetterSearchEnabled;
      feedbackMessage = null;
    } catch (_) {
      feedbackMessage = 'Nao foi possivel carregar as configuracoes.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveGamePath() async {
    if (isSavingGamePath) return;

    final normalizedGamePath = gamePathController.text.trim();

    isSavingGamePath = true;
    feedbackMessage = null;
    notifyListeners();

    try {
      await settingsUsecase.saveGamePath(normalizedGamePath);
      savedGamePath = normalizedGamePath;
      feedbackMessage = normalizedGamePath.isEmpty
          ? 'Path removido com sucesso.'
          : 'Path salvo com sucesso.';
    } catch (_) {
      feedbackMessage = 'Nao foi possivel salvar o path do jogo.';
    } finally {
      isSavingGamePath = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkTheme(bool value) async {
    final previousValue = isDarkThemeEnabled;
    isDarkThemeEnabled = value;
    feedbackMessage = null;
    notifyListeners();

    try {
      await settingsUsecase.saveDarkThemeEnabled(value);
    } catch (_) {
      isDarkThemeEnabled = previousValue;
      feedbackMessage = 'Nao foi possivel salvar o tema.';
      notifyListeners();
    }
  }

  Future<void> toggleBetterSearch(bool value) async {
    final previousValue = isBetterSearchEnabled;
    isBetterSearchEnabled = value;
    feedbackMessage = null;
    notifyListeners();

    try {
      await settingsUsecase.saveBetterSearchEnabled(value);
    } catch (_) {
      isBetterSearchEnabled = previousValue;
      feedbackMessage = 'Nao foi possivel salvar o BetterSearch.';
      notifyListeners();
    }
  }

  void _handleGamePathChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    gamePathController
      ..removeListener(_handleGamePathChange)
      ..dispose();
    super.dispose();
  }
}
