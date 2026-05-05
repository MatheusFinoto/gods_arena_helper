enum AutoRaceRunState { idle, running, stopping, completed, failed }

enum AutoRaceAccountState { pending, running, completed, failed, stopped }

enum AutoRaceStage {
  unknown,
  preparing,
  goToSuburb,
  pickupManual,
  goToNpc,
  turnInManual,
  solveMath,
  retryNpc,
  specialManualRoute,
  finishRace,
}

extension AutoRaceRunStateExtension on AutoRaceRunState {
  String get label {
    switch (this) {
      case AutoRaceRunState.idle:
        return 'Parado';
      case AutoRaceRunState.running:
        return 'Em execucao';
      case AutoRaceRunState.stopping:
        return 'Parando';
      case AutoRaceRunState.completed:
        return 'Concluido';
      case AutoRaceRunState.failed:
        return 'Falhou';
    }
  }
}

extension AutoRaceAccountStateExtension on AutoRaceAccountState {
  String get label {
    switch (this) {
      case AutoRaceAccountState.pending:
        return 'Na fila';
      case AutoRaceAccountState.running:
        return 'Executando';
      case AutoRaceAccountState.completed:
        return 'Concluida';
      case AutoRaceAccountState.failed:
        return 'Falhou';
      case AutoRaceAccountState.stopped:
        return 'Interrompida';
    }
  }

  static AutoRaceAccountState fromBackend(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'running':
        return AutoRaceAccountState.running;
      case 'completed':
      case 'complete':
        return AutoRaceAccountState.completed;
      case 'failed':
      case 'error':
        return AutoRaceAccountState.failed;
      case 'stopped':
        return AutoRaceAccountState.stopped;
      case 'pending':
      default:
        return AutoRaceAccountState.pending;
    }
  }
}

extension AutoRaceStageExtension on AutoRaceStage {
  String get label {
    switch (this) {
      case AutoRaceStage.preparing:
        return 'Preparando janela';
      case AutoRaceStage.goToSuburb:
        return 'Indo para Suburb';
      case AutoRaceStage.pickupManual:
        return 'Pegando manual';
      case AutoRaceStage.goToNpc:
        return 'Indo para NPC';
      case AutoRaceStage.turnInManual:
        return 'Entregando manual';
      case AutoRaceStage.solveMath:
        return 'Resolvendo soma';
      case AutoRaceStage.retryNpc:
        return 'Tentando novamente';
      case AutoRaceStage.specialManualRoute:
        return 'Rota especial 9/10';
      case AutoRaceStage.finishRace:
        return 'Finalizando race';
      case AutoRaceStage.unknown:
        return 'Aguardando etapa';
    }
  }

  static AutoRaceStage fromBackend(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'preparing':
      case 'focus_window':
        return AutoRaceStage.preparing;
      case 'go_to_suburb':
      case 'suburb':
        return AutoRaceStage.goToSuburb;
      case 'pickup_manual':
      case 'manual_pickup':
        return AutoRaceStage.pickupManual;
      case 'go_to_npc':
      case 'manual_npc':
        return AutoRaceStage.goToNpc;
      case 'turn_in_manual':
      case 'turnin_manual':
        return AutoRaceStage.turnInManual;
      case 'solve_math':
      case 'math_question':
        return AutoRaceStage.solveMath;
      case 'retry_npc':
      case 'retry':
        return AutoRaceStage.retryNpc;
      case 'special_manual_route':
      case 'manual_9_to_10':
        return AutoRaceStage.specialManualRoute;
      case 'finish_race':
      case 'finished':
        return AutoRaceStage.finishRace;
      default:
        return AutoRaceStage.unknown;
    }
  }
}

class AutoRaceAccountStatus {
  final int processId;
  final AutoRaceAccountState state;
  final AutoRaceStage stage;
  final int initialManual;
  final int currentManual;
  final String message;
  final String? error;

  const AutoRaceAccountStatus({
    required this.processId,
    required this.state,
    required this.stage,
    required this.initialManual,
    required this.currentManual,
    required this.message,
    this.error,
  });

  factory AutoRaceAccountStatus.initial(
    int processId, {
    int initialManual = 0,
  }) {
    return AutoRaceAccountStatus(
      processId: processId,
      state: AutoRaceAccountState.pending,
      stage: AutoRaceStage.unknown,
      initialManual: initialManual,
      currentManual: initialManual,
      message: 'Aguardando inicio da race.',
    );
  }

  AutoRaceAccountStatus copyWith({
    AutoRaceAccountState? state,
    AutoRaceStage? stage,
    int? initialManual,
    int? currentManual,
    String? message,
    String? error,
    bool clearError = false,
  }) {
    return AutoRaceAccountStatus(
      processId: processId,
      state: state ?? this.state,
      stage: stage ?? this.stage,
      initialManual: initialManual ?? this.initialManual,
      currentManual: currentManual ?? this.currentManual,
      message: message ?? this.message,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
