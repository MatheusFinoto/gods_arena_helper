import 'dart:convert';

import 'autorace_status.dart';

class AutoRaceEvent {
  final int processId;
  final AutoRaceAccountState state;
  final AutoRaceStage stage;
  final int? currentManual;
  final String message;
  final String? error;

  const AutoRaceEvent({
    required this.processId,
    required this.state,
    required this.stage,
    required this.message,
    this.currentManual,
    this.error,
  });

  bool get isTerminal {
    return state == AutoRaceAccountState.completed ||
        state == AutoRaceAccountState.failed ||
        state == AutoRaceAccountState.stopped;
  }

  factory AutoRaceEvent.fromJsonLine(String line) {
    final payload = jsonDecode(line);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('AutoRace event must be a JSON object.');
    }

    return AutoRaceEvent.fromMap(payload);
  }

  factory AutoRaceEvent.fromMap(Map<String, dynamic> map) {
    final processId = map['processId'];
    if (processId is! int) {
      throw const FormatException('AutoRace event has invalid processId.');
    }

    return AutoRaceEvent(
      processId: processId,
      state: AutoRaceAccountStateExtension.fromBackend(
        map['state']?.toString(),
      ),
      stage: AutoRaceStageExtension.fromBackend(map['stage']?.toString()),
      currentManual: _tryParseManual(map['currentManual']),
      message: map['message']?.toString() ?? 'AutoRace atualizou o status.',
      error: map['error']?.toString(),
    );
  }

  static int? _tryParseManual(Object? value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
