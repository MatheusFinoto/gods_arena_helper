import 'package:flutter/material.dart';
import 'package:helper_frontend/core/enums/dashboard_pages_enum.dart';
import 'package:provider/provider.dart';

import '../dashboard_state.dart';

class DashDrawer extends StatelessWidget {
  const DashDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardState>(
      builder: (_, state, __) {
        return Drawer(
          width: 200,
          child: ListView(
            padding: EdgeInsets.zero,
            children: DashboardEnum.values
                .map(
                  (e) => ListTile(
                    title: Text(e.name.toUpperCase()),
                    onTap: () =>
                        state.changePage(DashboardEnum.values.indexOf(e) - 1),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }
}
