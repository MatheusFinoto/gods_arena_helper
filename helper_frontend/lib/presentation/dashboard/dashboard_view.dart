import 'package:flutter/material.dart';
import 'package:helper_frontend/presentation/dashboard/dashboard_state.dart';
import 'package:helper_frontend/presentation/dashboard/pages/home_page.dart';
import 'package:provider/provider.dart';

import 'components/dash_drawer.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardState(context),
      child: Consumer<DashboardState>(
        builder: (_, state, __) {
          return Scaffold(
            body: Row(
              children: [
                DashDrawer(),
                Expanded(child: PageView(children: const [HomePage()])),
              ],
            ),
          );
        },
      ),
    );
  }
}
