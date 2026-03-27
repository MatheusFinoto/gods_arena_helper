import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../states/home_page_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomePageState(context),
      child: Consumer<HomePageState>(
        builder: (_, state, __) {
          return const Scaffold(body: Center(child: Text('Home Page')));
        },
      ),
    );
  }
}
