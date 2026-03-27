import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';

class HomePageState extends ChangeNotifier {
  final AccountsUsecase accountsUsecase;

  HomePageState({required this.accountsUsecase}) {
    loadAccounts();
  }

  bool isLoading = false;
  String output = 'Nenhum comando executado ainda.';

  // Future<void> getPyData() async {
  //   isLoading = true;
  //   output = 'Executando Python...';
  //   notifyListeners();

  //   try {
  //     final scriptPath = File('..\\helper_service\\src\\main.py').absolute.path;

  //     final result = await Process.run('python', [scriptPath]);
  //     final stdoutText = result.stdout.toString().trim();
  //     final stderrText = result.stderr.toString().trim();

  //     output = [
  //       'Exit code: ${result.exitCode}',
  //       if (stdoutText.isNotEmpty) 'STDOUT:\n$stdoutText',
  //       if (stderrText.isNotEmpty) 'STDERR:\n$stderrText',
  //     ].join('\n\n');
  //   } catch (e) {
  //     output = 'Falha ao executar o comando Python:\n$e';
  //   } finally {
  //     isLoading = false;
  //     notifyListeners();
  //   }
  // }

  Future<void> loadAccounts() async {
    final result = await accountsUsecase.loadAccounts();

    output = 'Contas carregadas: ${result.length}';
    notifyListeners();
  }
}
