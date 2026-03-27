import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../entities/account.dart';

abstract class AccountsUsecase {
  Future<List<Account>> loadAccounts();
}

AccountsUsecase newAccountsUsecase() => _AccountsUsecase();

class _AccountsUsecase implements AccountsUsecase {
  @override
  Future<List<Account>> loadAccounts() async {
    try {
      List<Account> accounts = [];

      final scriptPath = File('..\\helper_service\\src\\main.py').absolute.path;

      final result = await Process.run(
        'python',
        [scriptPath, 'load_accounts'],
        workingDirectory:
            r'C:\Users\mathe\Desktop\dev\gods_arena_helper\helper_service\src',
      );

      final stdoutText = result.stdout.toString().trim();
      final stderrText = result.stderr.toString().trim();

      log('Python script output: $stdoutText');
      log('Python script error: $stderrText');

      if (stderrText.isNotEmpty) {
        throw Exception('Error from Python script: $stderrText');
      }

      var jsonData = jsonDecode(stdoutText) as List<dynamic>;

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
}
