enum AutoShipRunState { idle, running, stopping, completed, failed }

enum AutoShipAccountState { pending, running, completed, failed, stopped }

enum AutoShipStage {
  unknown,
  guildQuest,
  npc1PickupAndTurnIn,
  npc2PickupAndTurnIn,
  travelToOtherCity,
  npc3PickupAndTurnIn,
  returnToStartCity,
  npc1FinalTurnIn,
}

extension AutoShipRunStateExtension on AutoShipRunState {
  String get label {
    switch (this) {
      case AutoShipRunState.idle:
        return 'Parado';
      case AutoShipRunState.running:
        return 'Em execucao';
      case AutoShipRunState.stopping:
        return 'Parando';
      case AutoShipRunState.completed:
        return 'Concluido';
      case AutoShipRunState.failed:
        return 'Falhou';
    }
  }
}

extension AutoShipAccountStateExtension on AutoShipAccountState {
  String get label {
    switch (this) {
      case AutoShipAccountState.pending:
        return 'Na fila';
      case AutoShipAccountState.running:
        return 'Executando';
      case AutoShipAccountState.completed:
        return 'Concluida';
      case AutoShipAccountState.failed:
        return 'Falhou';
      case AutoShipAccountState.stopped:
        return 'Interrompida';
    }
  }
}

extension AutoShipStageExtension on AutoShipStage {
  String get label {
    switch (this) {
      case AutoShipStage.guildQuest:
        return 'Guild NPC';
      case AutoShipStage.npc1PickupAndTurnIn:
        return 'NPC 1';
      case AutoShipStage.npc2PickupAndTurnIn:
        return 'NPC 2';
      case AutoShipStage.travelToOtherCity:
        return 'Ir para outra cidade';
      case AutoShipStage.npc3PickupAndTurnIn:
        return 'NPC 3';
      case AutoShipStage.returnToStartCity:
        return 'Voltar para cidade inicial';
      case AutoShipStage.npc1FinalTurnIn:
        return 'Entrega final no NPC 1';
      case AutoShipStage.unknown:
        return 'Aguardando etapa';
    }
  }

  static AutoShipStage fromBackend(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'guild_quest':
      case 'guild_npc':
        return AutoShipStage.guildQuest;
      case 'npc1':
      case 'npc1_pickup_turnin':
      case 'npc1_pickup_and_turn_in':
        return AutoShipStage.npc1PickupAndTurnIn;
      case 'npc2':
      case 'npc2_pickup_turnin':
      case 'npc2_pickup_and_turn_in':
        return AutoShipStage.npc2PickupAndTurnIn;
      case 'travel_to_other_city':
      case 'change_city':
        return AutoShipStage.travelToOtherCity;
      case 'npc3':
      case 'npc3_pickup_turnin':
      case 'npc3_pickup_and_turn_in':
        return AutoShipStage.npc3PickupAndTurnIn;
      case 'return_to_start_city':
      case 'return_initial_city':
        return AutoShipStage.returnToStartCity;
      case 'npc1_final_turnin':
      case 'npc1_final_turn_in':
      case 'final_delivery':
        return AutoShipStage.npc1FinalTurnIn;
      default:
        return AutoShipStage.unknown;
    }
  }
}

class AutoShipAccountStatus {
  final int processId;
  final AutoShipAccountState state;
  final AutoShipStage stage;
  final int cycle;
  final String message;
  final String? error;

  const AutoShipAccountStatus({
    required this.processId,
    required this.state,
    required this.stage,
    required this.cycle,
    required this.message,
    this.error,
  });

  factory AutoShipAccountStatus.initial(int processId) {
    return AutoShipAccountStatus(
      processId: processId,
      state: AutoShipAccountState.pending,
      stage: AutoShipStage.unknown,
      cycle: 0,
      message: 'Aguardando inicio do lote.',
    );
  }

  AutoShipAccountStatus copyWith({
    AutoShipAccountState? state,
    AutoShipStage? stage,
    int? cycle,
    String? message,
    String? error,
    bool clearError = false,
  }) {
    return AutoShipAccountStatus(
      processId: processId,
      state: state ?? this.state,
      stage: stage ?? this.stage,
      cycle: cycle ?? this.cycle,
      message: message ?? this.message,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
