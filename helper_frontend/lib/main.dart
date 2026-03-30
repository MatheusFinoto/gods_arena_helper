import 'package:flutter/material.dart';
import 'package:helper_frontend/core/constants/theme_constants.dart';
import 'package:helper_frontend/main_services.dart';
import 'package:provider/provider.dart';

import 'main_state.dart';
import 'presentation/dashboard/dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ...MainServices.mountProvider(),
        ListenableProvider<MainState>(create: (ctx) => MainState(context: ctx)),
      ],
      child: Consumer<MainState>(
        builder: (_, mainState, __) {
          return MaterialApp(
            title: 'Gods Arena Helper',
            debugShowCheckedModeBanner: false,
            themeMode: mainState.themeMode,
            theme: ThemeConstants.lightTheme,
            darkTheme: ThemeConstants.darkTheme,
            home: const DashboardView(),
          );
        },
      ),
    );
  }
}
