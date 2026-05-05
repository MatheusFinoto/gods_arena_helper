import 'dart:async';

import 'package:helper_frontend/domain/entities/autorace_event.dart';
import 'package:helper_frontend/domain/entities/autorace_status.dart';

import '../../service/py_command_service.dart';

abstract class AutoRaceUsecase {
  Future<AutoRaceSession> startAutoRace({
    required int processId,
    required int initialManual,
  });
}

abstract class AutoRaceSession {
  Stream<AutoRaceEvent> get events;
  Future<int> get exitCode;
  Future<void> stop();
}

AutoRaceUsecase newAutoRaceUsecase({
  required PyCommandService pyCommandService,
}) => _AutoRaceUsecase(pyCommandService: pyCommandService);

class _AutoRaceUsecase implements AutoRaceUsecase {
  final PyCommandService pyCommandService;

  _AutoRaceUsecase({required this.pyCommandService});

  @override
  Future<AutoRaceSession> startAutoRace({
    required int processId,
    required int initialManual,
  }) async {
    final session = await pyCommandService.startPythonCommand(
      method: 'auto_race_start',
      arguments: [processId.toString(), initialManual.toString()],
    );

    return _ProcessAutoRaceSession(
      processId: processId,
      session: session,
    );
  }
}

class _ProcessAutoRaceSession implements AutoRaceSession {
  final int processId;
  final PyCommandSession session;
  final StreamController<AutoRaceEvent> _eventsController =
      StreamController<AutoRaceEvent>.broadcast();

  String? _lastErrorLine;
  bool _closed = false;

  _ProcessAutoRaceSession({
    required this.processId,
    required this.session,
  }) {
    session.stdoutLines.listen(
      _handleStdoutLine,
      onError: (Object error) => _emitFailure(error.toString()),
    );

    session.stderrLines.listen((line) {
      if (line.trim().isNotEmpty) {
        _lastErrorLine = line.trim();
      }
    });

    session.exitCode.then((code) {
      if (code != 0 && !_closed) {
        _emitFailure(
          _lastErrorLine ?? 'AutoRace finalizou com exit code $code.',
        );
      }
      _closeEvents();
    });
  }

  @override
  Stream<AutoRaceEvent> get events => _eventsController.stream;

  @override
  Future<int> get exitCode => session.exitCode;

  @override
  Future<void> stop() => session.kill();

  void _handleStdoutLine(String line) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || _closed) return;

    try {
      _eventsController.add(AutoRaceEvent.fromJsonLine(trimmed));
    } catch (error) {
      _emitFailure('Evento invalido do AutoRace: $trimmed');
    }
  }

  void _emitFailure(String message) {
    if (_closed) return;

    _eventsController.add(
      AutoRaceEvent(
        processId: processId,
        state: AutoRaceAccountState.failed,
        stage: AutoRaceStage.unknown,
        message: 'Falha no AutoRace.',
        error: message,
      ),
    );
  }

  void _closeEvents() {
    if (_closed) return;
    _closed = true;
    _eventsController.close();
  }
}
