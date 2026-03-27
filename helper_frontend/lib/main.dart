import 'package:flutter/material.dart';
import 'package:helper_frontend/main_services.dart';
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
      child: MaterialApp(
        title: 'Gods Arena Helper',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: const DashboardView(),
      ),
    );
  }
}
