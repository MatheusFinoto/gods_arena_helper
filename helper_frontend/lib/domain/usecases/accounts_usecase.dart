import 'dart:developer';

import '../../service/py_command_service.dart';
import '../entities/account.dart';

abstract class AccountsUsecase {
  Future<List<Account>> loadAccounts();
  Future<void> focusAccountWindow(int processId);
}

AccountsUsecase newAccountsUsecase({
  required PyCommandService pyCommandService,
}) => _AccountsUsecase(pyCommandService: pyCommandService);

class _AccountsUsecase implements AccountsUsecase {
  final PyCommandService pyCommandService;

  _AccountsUsecase({required this.pyCommandService});

  @override
  Future<List<Account>> loadAccounts() async {
    try {
      List<Account> accounts = [];
      final payload = await pyCommandService.runPythonCommand(
        method: 'load_accounts',
        arguments: [],
      );
      final jsonData = payload['data'] as List<dynamic>;

      for (var item in jsonData) {
        try {
          accounts.add(Account.fromMap(item as Map<String, dynamic>));
        } catch (e) {
          log('Failed to parse account from item: $item, error: $e');
        }
      }

      return accounts;
    } catch (e) {
      log('Failed to load accounts: $e');
      return [];
    }
  }

  @override
  Future<void> focusAccountWindow(int processId) async {
    try {
      await pyCommandService.runPythonCommand(
        method: 'focus_account_window',
        arguments: [processId.toString()],
      );
    } catch (e) {
      log('Failed to focus account window: $e');
    }
  }
}
