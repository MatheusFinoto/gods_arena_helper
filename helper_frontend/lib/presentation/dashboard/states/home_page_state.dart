import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/entities/account.dart';
import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';

class HomePageState extends ChangeNotifier {
  final AccountsUsecase accountsUsecase;

  HomePageState({required this.accountsUsecase}) {
    loadAccounts();
  }

  bool isLoading = false;
  String output = 'Nenhum comando executado ainda.';

  List<Account> accounts = [];

  Future<void> loadAccounts() async {
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    final result = await accountsUsecase.loadAccounts();
    accounts = result;
    isLoading = false;
    notifyListeners();
  }

  void focusAccountWindow(int processId) {
    accountsUsecase.focusAccountWindow(processId);
  }
}
