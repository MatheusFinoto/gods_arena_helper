import 'package:flutter/material.dart';
import 'package:helper_frontend/main_services.dart';
import 'package:helper_frontend/presentation/dashboard/states/settings_state.dart';
import 'package:provider/provider.dart';

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
      providers: [...MainServices.mountProvider()],
      child: Selector<SettingsState, bool>(
        selector: (_, state) => state.isDarkThemeEnabled,
        builder: (_, isDarkThemeEnabled, __) {
          return MaterialApp(
            title: 'Gods Arena Helper',
            debugShowCheckedModeBanner: false,
            themeMode: isDarkThemeEnabled ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1E6BFF),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF73C8FF),
                brightness: Brightness.dark,
              ),
            ),
            home: const DashboardView(),
          );
        },
      ),
    );
  }
}
