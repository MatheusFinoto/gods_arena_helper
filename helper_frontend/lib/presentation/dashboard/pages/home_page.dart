import 'package:flutter/material.dart';
import 'package:helper_frontend/domain/usecases/accounts_usecase.dart';
import 'package:provider/provider.dart';

import '../../../core/enums/faction_enum.dart';
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
                      // Container(
                      //   padding: const EdgeInsets.all(16),
                      //   decoration: BoxDecoration(
                      //     color: Colors.black12,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child: SelectableText(state.output),
                      // ),
                      Row(
                        children: [
                          Text('Logged accounts: ${state.accounts.length}'),
                          const Spacer(),
                          IconButton(
                            onPressed: state.loadAccounts,
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.builder(
                            itemCount: state.accounts.length,
                            itemBuilder: (context, index) {
                              final account = state.accounts[index];
                              return ListTile(
                                leading: Image.asset(
                                  account.faction.assetPath,
                                  width: 40,
                                  height: 40,
                                ),
                                title: Text(account.nick),
                                subtitle: Text(
                                  'PID ${account.processId} • ${account.faction.name}',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.open_in_new),
                                  onPressed: () => state.focusAccountWindow(
                                    account.processId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
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
