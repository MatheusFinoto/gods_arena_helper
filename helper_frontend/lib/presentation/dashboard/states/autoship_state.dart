import 'dart:async';

import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/entities/autoship_account_config.dart';
import 'package:helper_frontend/domain/entities/autoship_event.dart';
import 'package:helper_frontend/domain/entities/autoship_status.dart';
import 'package:helper_frontend/domain/usecases/autoship_usecase.dart';

class AutoShipState extends ChangeNotifier {
  final AutoShipUsecase autoShipUsecase;

  AutoShipState({required this.autoShipUsecase});

  final Set<int> _selectedProcessIds = <int>{};
  final Map<int, AutoShipAccountStatus> _accountStatuses =
      <int, AutoShipAccountStatus>{};

  StreamSubscription<AutoShipEvent>? _runSubscription;
  AutoShipRunState _runState = AutoShipRunState.idle;
  AutoShipStage _currentStage = AutoShipStage.unknown;
  int _currentCycle = 0;
  String? _feedbackMessage;

  AutoShipRunState get runState => _runState;
  AutoShipStage get currentStage => _currentStage;
  int get currentCycle => _currentCycle;
  String? get feedbackMessage => _feedbackMessage;

  bool get isRunning => _runState == AutoShipRunState.running;
  bool get isStopping => _runState == AutoShipRunState.stopping;
  bool get hasSelection => _selectedProcessIds.isNotEmpty;
  int get selectedCount => _selectedProcessIds.length;
  int get readyCount => _selectedConfigs.length;
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

  bool get canStart => !isRunning && !isStopping && _selectedConfigs.isNotEmpty;

  void toggleSelection(int processId, bool isSelected) {
    if (isRunning || isStopping) return;

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
    if (isRunning || isStopping) return;

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
    if (isRunning || isStopping) return;

    _selectedProcessIds.clear();
    _accountStatuses.clear();
    notifyListeners();
  }

  Future<void> startAutoShip() async {
    if (!canStart) {
      _feedbackMessage = 'Selecione pelo menos uma conta para iniciar o lote.';
      notifyListeners();
      return;
    }

    await _runSubscription?.cancel();

    _currentStage = AutoShipStage.unknown;
    _currentCycle = 0;
    _runState = AutoShipRunState.running;
    _feedbackMessage = 'AutoShip iniciado. Aguardando eventos do servico...';

    for (final processId in _selectedProcessIds) {
      _accountStatuses[processId] = AutoShipAccountStatus.initial(processId);
    }

    notifyListeners();

    try {
      _runSubscription = autoShipUsecase
          .startAutoShip(accounts: _selectedConfigs)
          .listen(
            _applyEvent,
            onDone: _handleRunCompleted,
            onError: (Object error) {
              _runState = AutoShipRunState.failed;
              _feedbackMessage =
                  'Falha ao acompanhar o AutoShip: ${error.toString()}';
              notifyListeners();
            },
          );
    } catch (error) {
      _runState = AutoShipRunState.failed;
      _feedbackMessage = 'Nao foi possivel iniciar o AutoShip: $error';
      notifyListeners();
    }
  }

  Future<void> stopAutoShip() async {
    if (!isRunning) return;

    _runState = AutoShipRunState.stopping;
    _feedbackMessage = 'Solicitando parada do AutoShip...';
    notifyListeners();

    await autoShipUsecase.stopAutoShip();
  }

  void resetExecution() {
    if (isRunning || isStopping) return;

    for (final processId in _selectedProcessIds) {
      _accountStatuses[processId] = AutoShipAccountStatus.initial(processId);
    }

    _runState = AutoShipRunState.idle;
    _currentStage = AutoShipStage.unknown;
    _currentCycle = 0;
    _feedbackMessage = null;
    notifyListeners();
  }

  void _applyEvent(AutoShipEvent event) {
    if (event.message != null && event.message!.trim().isNotEmpty) {
      _feedbackMessage = event.message;
    }

    if (event.type == AutoShipEventType.error) {
      _runState = AutoShipRunState.failed;
      _feedbackMessage = event.error ?? event.message ?? 'Falha no AutoShip.';
      notifyListeners();
      return;
    }

    switch (event.type) {
      case AutoShipEventType.runStarted:
        _runState = AutoShipRunState.running;
        break;
      case AutoShipEventType.stageStarted:
        _currentStage = event.stage;
        if (event.cycle > 0) {
          _currentCycle = event.cycle;
        }
        break;
      case AutoShipEventType.accountStageStarted:
        _updateAccountStatus(
          processId: event.processId,
          state: AutoShipAccountState.running,
          stage: event.stage,
          cycle: event.cycle,
          message: event.message ?? 'Executando etapa ${event.stage.label}.',
          clearError: true,
        );
        break;
      case AutoShipEventType.accountStageCompleted:
        final isFinalStage =
            event.stage == AutoShipStage.npc1FinalTurnIn && event.cycle >= 3;

        _updateAccountStatus(
          processId: event.processId,
          state: isFinalStage
              ? AutoShipAccountState.completed
              : AutoShipAccountState.pending,
          stage: event.stage,
          cycle: event.cycle,
          message: event.message ?? 'Etapa concluida com sucesso.',
          clearError: true,
        );
        break;
      case AutoShipEventType.accountFailed:
        _updateAccountStatus(
          processId: event.processId,
          state: AutoShipAccountState.failed,
          stage: event.stage,
          cycle: event.cycle,
          message: event.message ?? 'Falha durante a execucao.',
          error: event.error,
        );
        break;
      case AutoShipEventType.runCompleted:
        _runState = failedCount > 0
            ? AutoShipRunState.failed
            : AutoShipRunState.completed;
        _feedbackMessage =
            event.message ?? 'AutoShip finalizado para o lote selecionado.';
        _markRemainingAccountsAsCompleted();
        break;
      case AutoShipEventType.runCancelled:
        _runState = AutoShipRunState.idle;
        _feedbackMessage = event.message ?? 'AutoShip interrompido.';
        _markRunningAccountsAsStopped();
        break;
      case AutoShipEventType.info:
      case AutoShipEventType.unknown:
        break;
      case AutoShipEventType.error:
        break;
    }

    if (event.cycle > 0) {
      _currentCycle = event.cycle;
    }
    if (event.stage != AutoShipStage.unknown) {
      _currentStage = event.stage;
    }

    notifyListeners();
  }

  void _handleRunCompleted() {
    if (_runState == AutoShipRunState.stopping) {
      _runState = AutoShipRunState.idle;
      _feedbackMessage = 'AutoShip interrompido pelo usuario.';
      _markRunningAccountsAsStopped();
    } else if (_runState == AutoShipRunState.running) {
      _runState = failedCount > 0
          ? AutoShipRunState.failed
          : AutoShipRunState.completed;
      _feedbackMessage ??= 'AutoShip finalizado.';
      _markRemainingAccountsAsCompleted();
    }

    notifyListeners();
  }

  void _markRemainingAccountsAsCompleted() {
    for (final processId in _selectedProcessIds) {
      final current = _accountStatuses[processId];
      if (current == null) continue;
      if (current.state == AutoShipAccountState.failed ||
          current.state == AutoShipAccountState.completed) {
        continue;
      }

      _accountStatuses[processId] = current.copyWith(
        state: AutoShipAccountState.completed,
        message: 'Lote concluido para esta conta.',
      );
    }
  }

  void _markRunningAccountsAsStopped() {
    for (final processId in _selectedProcessIds) {
      final current = _accountStatuses[processId];
      if (current == null) continue;
      if (current.state == AutoShipAccountState.failed ||
          current.state == AutoShipAccountState.completed) {
        continue;
      }

      _accountStatuses[processId] = current.copyWith(
        state: AutoShipAccountState.stopped,
        message: 'Execucao interrompida antes da conclusao.',
      );
    }
  }

  void _updateAccountStatus({
    required int? processId,
    required AutoShipAccountState state,
    required AutoShipStage stage,
    required int cycle,
    required String message,
    String? error,
    bool clearError = false,
  }) {
    if (processId == null) return;

    final current =
        _accountStatuses[processId] ?? AutoShipAccountStatus.initial(processId);

    _accountStatuses[processId] = current.copyWith(
      state: state,
      stage: stage == AutoShipStage.unknown ? current.stage : stage,
      cycle: cycle > 0 ? cycle : current.cycle,
      message: message,
      error: error,
      clearError: clearError,
    );
  }

  List<AutoShipAccountConfig> get _selectedConfigs {
    final configs = <AutoShipAccountConfig>[];

    for (final processId in _selectedProcessIds) {
      configs.add(AutoShipAccountConfig(processId: processId));
    }

    configs.sort((a, b) => a.processId.compareTo(b.processId));
    return configs;
  }

  @override
  void dispose() {
    unawaited(_runSubscription?.cancel());
    unawaited(autoShipUsecase.stopAutoShip());
    super.dispose();
  }
}
