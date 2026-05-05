import 'dart:async';

import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/entities/autorace_event.dart';
import 'package:helper_frontend/domain/entities/autorace_status.dart';
import 'package:helper_frontend/domain/usecases/autorace_usecase.dart';

class AutoRaceState extends ChangeNotifier {
  final AutoRaceUsecase autoRaceUsecase;

  AutoRaceState({required this.autoRaceUsecase});

  final Set<int> _selectedProcessIds = <int>{};
  final Map<int, int> _initialManualByProcessId = <int, int>{};
  final Map<int, AutoRaceAccountStatus> _accountStatuses =
      <int, AutoRaceAccountStatus>{};

  AutoRaceRunState _runState = AutoRaceRunState.idle;
  AutoRaceStage _currentStage = AutoRaceStage.unknown;
  int _currentManual = 0;
  String? _feedbackMessage;
  AutoRaceSession? _activeSession;
  StreamSubscription<AutoRaceEvent>? _activeSubscription;
  bool _stopRequested = false;

  AutoRaceRunState get runState => _runState;
  AutoRaceStage get currentStage => _currentStage;
  int get currentManual => _currentManual;
  String? get feedbackMessage => _feedbackMessage;

  bool get isRunning => _runState == AutoRaceRunState.running;
  bool get isStopping => _runState == AutoRaceRunState.stopping;
  bool get hasSelection => _selectedProcessIds.isNotEmpty;
  int get selectedCount => _selectedProcessIds.length;
  int get readyCount => selectedCount;
  int get failedCount => _accountStatuses.values
      .where((status) => status.state == AutoRaceAccountState.failed)
      .length;
  int get completedCount => _accountStatuses.values
      .where((status) => status.state == AutoRaceAccountState.completed)
      .length;

  List<int> get selectedProcessIds {
    return _selectedProcessIds.toList()..sort();
  }

  List<AutoRaceAccountStatus> get accountStatuses {
    final statuses = _accountStatuses.values.toList();
    statuses.sort((a, b) => a.processId.compareTo(b.processId));
    return statuses;
  }

  bool isSelected(int processId) => _selectedProcessIds.contains(processId);

  int initialManualFor(int processId) {
    return _initialManualByProcessId[processId] ?? 0;
  }

  void toggleSelection(int processId, bool isSelected) {
    if (isRunning || isStopping) return;

    if (isSelected) {
      _selectedProcessIds.add(processId);
      _initialManualByProcessId.putIfAbsent(processId, () => 0);
      _accountStatuses.putIfAbsent(
        processId,
        () => AutoRaceAccountStatus.initial(processId),
      );
    } else {
      _selectedProcessIds.remove(processId);
      _initialManualByProcessId.remove(processId);
      _accountStatuses.remove(processId);
    }

    notifyListeners();
  }

  void selectAll(List<int> processIds) {
    if (isRunning || isStopping) return;

    for (final processId in processIds) {
      _selectedProcessIds.add(processId);
      _initialManualByProcessId.putIfAbsent(processId, () => 0);
      _accountStatuses.putIfAbsent(
        processId,
        () => AutoRaceAccountStatus.initial(processId),
      );
    }

    notifyListeners();
  }

  void clearSelection() {
    if (isRunning || isStopping) return;

    _selectedProcessIds.clear();
    _initialManualByProcessId.clear();
    _accountStatuses.clear();
    notifyListeners();
  }

  void setInitialManual(int processId, int manual) {
    if (isRunning || isStopping || !_selectedProcessIds.contains(processId)) {
      return;
    }

    final normalizedManual = manual.clamp(0, 17).toInt();
    _initialManualByProcessId[processId] = normalizedManual;
    _accountStatuses[processId] =
        (_accountStatuses[processId] ??
                AutoRaceAccountStatus.initial(processId))
            .copyWith(
              initialManual: normalizedManual,
              currentManual: normalizedManual,
            );
    notifyListeners();
  }

  Future<void> startAutoRace() async {
    if (_selectedProcessIds.isEmpty) {
      _feedbackMessage = 'Selecione pelo menos uma conta para iniciar.';
      notifyListeners();
      return;
    }

    _runState = AutoRaceRunState.running;
    _stopRequested = false;
    _currentStage = AutoRaceStage.preparing;
    _currentManual = 0;
    _feedbackMessage = 'Iniciando AutoRace em lote sequencial...';

    for (final processId in selectedProcessIds) {
      final initialManual = initialManualFor(processId);
      _accountStatuses[processId] = AutoRaceAccountStatus.initial(
        processId,
        initialManual: initialManual,
      ).copyWith(
        state: AutoRaceAccountState.pending,
        message: 'Aguardando vez no lote sequencial.',
      );
    }
    notifyListeners();

    var hasFailure = false;

    for (final processId in selectedProcessIds) {
      if (_stopRequested) break;

      final initialManual = initialManualFor(processId);
      _accountStatuses[processId] = AutoRaceAccountStatus(
        processId: processId,
        state: AutoRaceAccountState.running,
        stage: AutoRaceStage.preparing,
        initialManual: initialManual,
        currentManual: initialManual,
        message: 'Iniciando AutoRace para esta conta...',
      );
      _feedbackMessage = 'Executando PID $processId.';
      notifyListeners();

      final completed = await _runSingleAccount(
        processId: processId,
        initialManual: initialManual,
      );

      if (!completed) {
        hasFailure = true;
      }
    }

    if (_stopRequested) {
      _runState = AutoRaceRunState.idle;
      _feedbackMessage = 'AutoRace interrompido.';
    } else {
      _runState = hasFailure
          ? AutoRaceRunState.failed
          : AutoRaceRunState.completed;
      _feedbackMessage = hasFailure
          ? 'AutoRace finalizado com falhas.'
          : 'AutoRace concluido para todas as contas.';
    }

    _activeSession = null;
    _activeSubscription = null;
    notifyListeners();
  }

  Future<void> stopAutoRace() async {
    if (!isRunning) return;

    _runState = AutoRaceRunState.stopping;
    _stopRequested = true;
    _feedbackMessage = 'Parando AutoRace...';
    notifyListeners();

    await _activeSession?.stop();

    for (final processId in _selectedProcessIds) {
      final status = _accountStatuses[processId];
      if (status?.state == AutoRaceAccountState.running ||
          status?.state == AutoRaceAccountState.pending) {
        _accountStatuses[processId] = (status ??
                AutoRaceAccountStatus.initial(
                  processId,
                  initialManual: initialManualFor(processId),
                ))
            .copyWith(
              state: AutoRaceAccountState.stopped,
              message: 'Execucao interrompida pelo usuario.',
            );
      }
    }

    _feedbackMessage = 'AutoRace parado.';
    notifyListeners();
  }

  void resetExecution() {
    if (isRunning || isStopping) return;

    for (final processId in _selectedProcessIds) {
      _accountStatuses[processId] = AutoRaceAccountStatus.initial(
        processId,
        initialManual: initialManualFor(processId),
      );
    }

    _runState = AutoRaceRunState.idle;
    _currentStage = AutoRaceStage.unknown;
    _currentManual = 0;
    _feedbackMessage = null;
    notifyListeners();
  }

  Future<bool> _runSingleAccount({
    required int processId,
    required int initialManual,
  }) async {
    final completer = Completer<bool>();

    try {
      _activeSession = await autoRaceUsecase.startAutoRace(
        processId: processId,
        initialManual: initialManual,
      );

      _activeSubscription = _activeSession!.events.listen(
        (event) {
          _applyEvent(event, initialManual);
          if (event.isTerminal && !completer.isCompleted) {
            completer.complete(event.state == AutoRaceAccountState.completed);
          }
        },
        onError: (Object error) {
          _markAccountFailed(processId, initialManual, error.toString());
          if (!completer.isCompleted) completer.complete(false);
        },
        onDone: () {
          final state = _accountStatuses[processId]?.state;
          if (!completer.isCompleted) {
            completer.complete(state == AutoRaceAccountState.completed);
          }
        },
      );

      final completed = await completer.future;
      await _activeSubscription?.cancel();
      await _activeSession?.exitCode;
      return completed;
    } catch (error) {
      _markAccountFailed(processId, initialManual, error.toString());
      return false;
    } finally {
      _activeSubscription = null;
      _activeSession = null;
      notifyListeners();
    }
  }

  void _applyEvent(AutoRaceEvent event, int initialManual) {
    if (_stopRequested && event.state != AutoRaceAccountState.completed) {
      final previous = _accountStatuses[event.processId];
      _accountStatuses[event.processId] = (previous ??
              AutoRaceAccountStatus.initial(
                event.processId,
                initialManual: initialManual,
              ))
          .copyWith(
        state: AutoRaceAccountState.stopped,
        message: 'Execucao interrompida pelo usuario.',
      );
      notifyListeners();
      return;
    }

    final currentManual = event.currentManual ?? initialManual;
    _currentStage = event.stage;
    _currentManual = currentManual;
    _feedbackMessage = event.message;
    _accountStatuses[event.processId] = AutoRaceAccountStatus(
      processId: event.processId,
      state: event.state,
      stage: event.stage,
      initialManual: initialManual,
      currentManual: currentManual,
      message: event.message,
      error: event.error,
    );
    notifyListeners();
  }

  void _markAccountFailed(
    int processId,
    int initialManual,
    String error,
  ) {
    _accountStatuses[processId] = AutoRaceAccountStatus(
      processId: processId,
      state: AutoRaceAccountState.failed,
      stage: AutoRaceStage.unknown,
      initialManual: initialManual,
      currentManual: initialManual,
      message: 'Falha ao executar AutoRace.',
      error: error,
    );
    _feedbackMessage = 'Falha no PID $processId.';
    notifyListeners();
  }

  @override
  void dispose() {
    _activeSubscription?.cancel();
    _activeSession?.stop();
    super.dispose();
  }
}
