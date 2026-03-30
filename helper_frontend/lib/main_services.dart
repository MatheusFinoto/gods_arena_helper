import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';
import 'package:helper_frontend/domain/usecases/settings_usecase.dart';
import 'package:helper_frontend/presentation/dashboard/states/settings_state.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class MainServices {
  static List<SingleChildWidget> mountProvider() {
    final AccountsUsecase accountUsecase = newAccountsUsecase();
    final SettingsUsecase settingsUsecase = newSettingsUsecase();

    return [
      Provider<AccountsUsecase>(create: (_) => accountUsecase),
      Provider<SettingsUsecase>(create: (_) => settingsUsecase),
      ChangeNotifierProvider<SettingsState>(
        create: (context) => SettingsState(
          settingsUsecase: context.read<SettingsUsecase>(),
        ),
      ),
    ];
  }
}
