import '../../service/py_command_service.dart';

abstract class AutoShipUsecase {
  Future<void> startAutoShip({required int processId});
  Future<void> stopAutoShip();
}

AutoShipUsecase newAutoShipUsecase({
  required PyCommandService pyCommandService,
}) => _AutoShipUsecase(pyCommandService: pyCommandService);

class _AutoShipUsecase implements AutoShipUsecase {
  final PyCommandService pyCommandService;

  _AutoShipUsecase({required this.pyCommandService});

  @override
  Future<void> startAutoShip({required int processId}) async {
    final data = await pyCommandService.runPythonCommand(
      method: 'auto_ship_start',
      arguments: [processId.toString()],
    );

    if (data['ok'] != true) {
      throw Exception('Falha ao iniciar o AutoShip: ${data['error']}');
    }
  }

  @override
  Future<void> stopAutoShip() async {}
}
