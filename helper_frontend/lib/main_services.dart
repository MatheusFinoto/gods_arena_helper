import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';
import 'package:helper_frontend/domain/usecases/autoship_usecase.dart';
import 'package:helper_frontend/domain/usecases/settings_usecase.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'service/py_command_service.dart';

class MainServices {
  static List<SingleChildWidget> mountProvider() {
    final PyCommandService pyCommandService = newPyCommandService();

    final AccountsUsecase accountUsecase = newAccountsUsecase(
      pyCommandService: pyCommandService,
    );
    final AutoShipUsecase autoShipUsecase = newAutoShipUsecase(
      pyCommandService: pyCommandService,
    );
    final SettingsUsecase settingsUsecase = newSettingsUsecase(
      pyCommandService: pyCommandService,
    );

    return [
      Provider<AccountsUsecase>(create: (_) => accountUsecase),
      Provider<AutoShipUsecase>(create: (_) => autoShipUsecase),
      Provider<SettingsUsecase>(create: (_) => settingsUsecase),
    ];
  }
}
