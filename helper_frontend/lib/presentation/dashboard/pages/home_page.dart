import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';
import 'package:provider/provider.dart';

import '../states/home_page_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          HomePageState(accountsUsecase: ctx.read<AccountsUsecase>()),
      child: Consumer<HomePageState>(
        builder: (_, state, __) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: state.isLoading
                            ? null
                            : () => state.loadAccounts(),
                        child: Text(
                          state.isLoading
                              ? 'Executando...'
                              : 'Executar comando Python',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SelectableText(state.output),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
