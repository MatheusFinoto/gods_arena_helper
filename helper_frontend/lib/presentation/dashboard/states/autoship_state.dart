import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/entities/autoship_status.dart';
import 'package:helper_frontend/domain/usecases/autoship_usecase.dart';

class AutoShipState extends ChangeNotifier {
  final AutoShipUsecase autoShipUsecase;

  AutoShipState({required this.autoShipUsecase});

  final Set<int> _selectedProcessIds = <int>{};
  final Map<int, AutoShipAccountStatus> _accountStatuses =
      <int, AutoShipAccountStatus>{};

  AutoShipRunState _runState = AutoShipRunState.idle;
  AutoShipStage _currentStage = AutoShipStage.unknown;
  int _currentCycle = 0;
  String? _feedbackMessage;

  AutoShipRunState get runState => _runState;
  AutoShipStage get currentStage => _currentStage;
  int get currentCycle => _currentCycle;
  String? get feedbackMessage => _feedbackMessage;

  bool get isRunning => _runState == AutoShipRunState.running;
  bool get isStopping => false;
  bool get hasSelection => _selectedProcessIds.isNotEmpty;
  int get selectedCount => _selectedProcessIds.length;
  int get readyCount => selectedCount == 1 ? 1 : 0;
  int get failedCount => _accountStatuses.values
      .where((status) => status.state == AutoShipAccountState.failed)
      .length;
  int get completedCount => _accountStatuses.values
      .where((status) => status.state == AutoShipAccountState.completed)
      .length;

  List<int> get selectedProcessIds {
    return _selectedProcessIds.toList()..sort();
  }

  List<AutoShipAccountStatus> get accountStatuses {
    final statuses = _accountStatuses.values.toList();
    statuses.sort((a, b) => a.processId.compareTo(b.processId));
    return statuses;
  }

  bool isSelected(int processId) => _selectedProcessIds.contains(processId);

  bool get canStart => !isRunning;

  void toggleSelection(int processId, bool isSelected) {
    if (isRunning) return;

    if (isSelected) {
      _selectedProcessIds.add(processId);
      _accountStatuses.putIfAbsent(
        processId,
        () => AutoShipAccountStatus.initial(processId),
      );
    } else {
      _selectedProcessIds.remove(processId);
      _accountStatuses.remove(processId);
    }

    notifyListeners();
  }

  void selectAll(List<int> processIds) {
    if (isRunning) return;

    for (final processId in processIds) {
      _selectedProcessIds.add(processId);
      _accountStatuses.putIfAbsent(
        processId,
        () => AutoShipAccountStatus.initial(processId),
      );
    }

    notifyListeners();
  }

  void clearSelection() {
    if (isRunning) return;

    _selectedProcessIds.clear();
    _accountStatuses.clear();
    notifyListeners();
  }

  Future<void> startAutoShip() async {
    if (selectedCount == 0) {
      _feedbackMessage = 'Selecione uma conta para iniciar o AutoShip.';
      notifyListeners();
      return;
    }

    if (selectedCount > 1) {
      _feedbackMessage =
          'Selecione apenas uma conta. O AutoShip simples roda uma por vez.';
      notifyListeners();
      return;
    }

    final processId = _selectedProcessIds.first;

    _runState = AutoShipRunState.running;
    _currentStage = AutoShipStage.guildQuest;
    _currentCycle = 0;
    _feedbackMessage = 'Iniciando AutoShip...';
    _accountStatuses[processId] = AutoShipAccountStatus(
      processId: processId,
      state: AutoShipAccountState.running,
      stage: AutoShipStage.guildQuest,
      cycle: 0,
      message: 'Iniciando AutoShip...',
    );
    notifyListeners();

    try {
      await autoShipUsecase.startAutoShip(processId: processId);
      _runState = AutoShipRunState.completed;
      _feedbackMessage = 'AutoShip concluido com sucesso.';
      _accountStatuses[processId] = AutoShipAccountStatus(
        processId: processId,
        state: AutoShipAccountState.completed,
        stage: AutoShipStage.guildQuest,
        cycle: 0,
        message: 'AutoShip concluido com sucesso.',
      );
    } catch (error) {
      _runState = AutoShipRunState.failed;
      _feedbackMessage = 'Falha ao iniciar AutoShip.';
      _accountStatuses[processId] = AutoShipAccountStatus(
        processId: processId,
        state: AutoShipAccountState.failed,
        stage: AutoShipStage.guildQuest,
        cycle: 0,
        message: 'Falha ao iniciar AutoShip.',
        error: error.toString(),
      );
    }

    notifyListeners();
  }

  Future<void> stopAutoShip() async {}

  void resetExecution() {
    if (isRunning) return;

    for (final processId in _selectedProcessIds) {
      _accountStatuses[processId] = AutoShipAccountStatus.initial(processId);
    }

    _runState = AutoShipRunState.idle;
    _currentStage = AutoShipStage.unknown;
    _currentCycle = 0;
    _feedbackMessage = null;
    notifyListeners();
  }
}
