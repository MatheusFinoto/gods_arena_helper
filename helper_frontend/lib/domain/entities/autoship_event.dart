import 'autoship_status.dart';

enum AutoShipEventType {
  runStarted,
  stageStarted,
  accountStageStarted,
  accountStageCompleted,
  accountFailed,
  runCompleted,
  runCancelled,
  info,
  error,
  unknown,
}

extension AutoShipEventTypeExtension on AutoShipEventType {
  static AutoShipEventType fromString(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'run_started':
        return AutoShipEventType.runStarted;
      case 'stage_started':
        return AutoShipEventType.stageStarted;
      case 'account_stage_started':
        return AutoShipEventType.accountStageStarted;
      case 'account_stage_completed':
        return AutoShipEventType.accountStageCompleted;
      case 'account_failed':
        return AutoShipEventType.accountFailed;
      case 'run_completed':
        return AutoShipEventType.runCompleted;
      case 'run_cancelled':
      case 'run_canceled':
        return AutoShipEventType.runCancelled;
      case 'info':
        return AutoShipEventType.info;
      case 'error':
        return AutoShipEventType.error;
      default:
        return AutoShipEventType.unknown;
    }
  }
}

class AutoShipEvent {
  final AutoShipEventType type;
  final AutoShipStage stage;
  final int? processId;
  final int cycle;
  final String? message;
  final String? error;

  const AutoShipEvent({
    required this.type,
    required this.stage,
    required this.cycle,
    this.processId,
    this.message,
    this.error,
  });

  factory AutoShipEvent.fromMap(Map<String, dynamic> map) {
    return AutoShipEvent(
      type: AutoShipEventTypeExtension.fromString(map['type'] as String?),
      stage: AutoShipStageExtension.fromBackend(map['stage'] as String?),
      processId: _readInt(map['processId'] ?? map['process_id']),
      cycle: _readInt(map['cycle']) ?? 0,
      message: map['message'] as String?,
      error: map['error'] as String?,
    );
  }

  factory AutoShipEvent.syntheticError(String message, {String? error}) {
    return AutoShipEvent(
      type: AutoShipEventType.error,
      stage: AutoShipStage.unknown,
      cycle: 0,
      message: message,
      error: error,
    );
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
