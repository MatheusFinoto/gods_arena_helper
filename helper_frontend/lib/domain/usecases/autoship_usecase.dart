import 'dart:async';
import 'dart:convert';

import '../../service/py_command_service.dart';
import '../entities/autoship_account_config.dart';
import '../entities/autoship_event.dart';

abstract class AutoShipUsecase {
  Stream<AutoShipEvent> startAutoShip({
    required List<AutoShipAccountConfig> accounts,
  });

  Future<void> stopAutoShip();
}

AutoShipUsecase newAutoShipUsecase({
  required PyCommandService pyCommandService,
}) => _AutoShipUsecase(pyCommandService: pyCommandService);

class _AutoShipUsecase implements AutoShipUsecase {
  final PyCommandService pyCommandService;

  PyCommandSession? _activeSession;
  StreamSubscription<String>? _stdoutSubscription;
  StreamSubscription<String>? _stderrSubscription;
  bool _stopRequested = false;

  _AutoShipUsecase({required this.pyCommandService});

  @override
  Stream<AutoShipEvent> startAutoShip({
    required List<AutoShipAccountConfig> accounts,
  }) {
    if (_activeSession != null) {
      throw StateError('Ja existe uma execucao de AutoShip em andamento.');
    }

    final controller = StreamController<AutoShipEvent>();
    final requestPayload = jsonEncode({
      'accounts': accounts.map((account) => account.toMap()).toList(),
    });
    _stopRequested = false;

    unawaited(
      _startSession(controller: controller, requestPayload: requestPayload),
    );

    controller.onCancel = () async {
      await stopAutoShip();
    };

    return controller.stream;
  }

  Future<void> _startSession({
    required StreamController<AutoShipEvent> controller,
    required String requestPayload,
  }) async {
    String? lastStdErrLine;

    try {
      final session = await pyCommandService.startPythonCommand(
        method: 'run_autoship',
        arguments: [requestPayload],
      );
      _activeSession = session;

      _stdoutSubscription = session.stdoutLines.listen(
        (line) {
          final trimmedLine = line.trim();
          if (trimmedLine.isEmpty) return;

          try {
            final decoded = jsonDecode(trimmedLine);
            if (decoded is! Map<String, dynamic>) {
              controller.add(
                AutoShipEvent.syntheticError(
                  'Evento invalido recebido do AutoShip.',
                  error: trimmedLine,
                ),
              );
              return;
            }

            controller.add(AutoShipEvent.fromMap(decoded));
          } catch (_) {
            controller.add(
              AutoShipEvent.syntheticError(
                'Nao foi possivel interpretar um evento do AutoShip.',
                error: trimmedLine,
              ),
            );
          }
        },
        onError: (Object error) {
          controller.add(
            AutoShipEvent.syntheticError(
              'Falha ao ler a saida do AutoShip.',
              error: error.toString(),
            ),
          );
        },
      );

      _stderrSubscription = session.stderrLines.listen((line) {
        final trimmedLine = line.trim();
        if (trimmedLine.isEmpty) return;

        lastStdErrLine = trimmedLine;
        controller.add(
          AutoShipEvent.syntheticError(
            'O servico AutoShip reportou uma falha.',
            error: trimmedLine,
          ),
        );
      });

      final exitCode = await session.exitCode;

      if (!controller.isClosed && exitCode != 0 && !_stopRequested) {
        controller.add(
          AutoShipEvent.syntheticError(
            'O processo do AutoShip foi encerrado com erro.',
            error: lastStdErrLine,
          ),
        );
      }
    } catch (error) {
      if (!controller.isClosed) {
        controller.add(
          AutoShipEvent.syntheticError(
            'Nao foi possivel iniciar o AutoShip.',
            error: error.toString(),
          ),
        );
      }
    } finally {
      await _clearActiveSession();
      if (!controller.isClosed) {
        await controller.close();
      }
    }
  }

  @override
  Future<void> stopAutoShip() async {
    final activeSession = _activeSession;
    if (activeSession == null) return;

    _stopRequested = true;
    await activeSession.kill();
    await _clearActiveSession();
  }

  Future<void> _clearActiveSession() async {
    await _stdoutSubscription?.cancel();
    await _stderrSubscription?.cancel();
    _stdoutSubscription = null;
    _stderrSubscription = null;
    _activeSession = null;
  }
}
