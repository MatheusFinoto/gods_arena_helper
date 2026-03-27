import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';
import 'package:provider/provider.dart';

class MainServices {
  static List<Provider> mountProvider() {
    AccountsUsecase accountUsecase = newAccountsUsecase();

    return [Provider<AccountsUsecase>(create: (_) => accountUsecase)];
  }
}
