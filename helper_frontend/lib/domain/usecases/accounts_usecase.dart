import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import '../entities/account.dart';

abstract class AccountsUsecase {
  Future<List<Account>> loadAccounts();
  Future<void> focusAccountWindow(int processId);
}

AccountsUsecase newAccountsUsecase() => _AccountsUsecase();

class _AccountsUsecase implements AccountsUsecase {
  static const _pythonWorkingDirectory =
      r'C:\Users\mathe\Desktop\dev\gods_arena_helper\helper_service\src';

  Future<Map<String, dynamic>> _runPythonCommand(List<String> arguments) async {
    final scriptPath = File('..\\helper_service\\src\\main.py').absolute.path;

    final result = await Process.run(
      'python',
      [scriptPath, ...arguments],
      workingDirectory: _pythonWorkingDirectory,
    );

    final stdoutText = result.stdout.toString().trim();
    final stderrText = result.stderr.toString().trim();

    if (result.exitCode != 0) {
      throw Exception(
        stderrText.isNotEmpty
            ? 'Python script failed: $stderrText'
            : 'Python script failed with exit code ${result.exitCode}.',
      );
    }

    if (stdoutText.isEmpty) {
      throw const FormatException('Python script returned empty stdout.');
    }

    final payload = jsonDecode(stdoutText);
    if (payload is! Map<String, dynamic>) {
      throw const FormatException('Python script returned invalid JSON payload.');
    }

    if (payload['ok'] != true) {
      throw Exception(payload['error'] ?? 'Python script returned an unknown error.');
    }

    return payload;
  }

  @override
  Future<List<Account>> loadAccounts() async {
    try {
      List<Account> accounts = [];
      final payload = await _runPythonCommand(['load_accounts']);
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
      await _runPythonCommand(['focus_account_window', processId.toString()]);
    } catch (e) {
      log('Failed to focus account window: $e');
    }
  }
}
