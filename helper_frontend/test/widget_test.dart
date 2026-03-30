import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:helper_frontend/domain/usecases/settings_usecase.dart';
import 'package:helper_frontend/presentation/dashboard/pages/settings_page.dart';
import 'package:helper_frontend/presentation/dashboard/states/settings_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Settings page persists game path and toggles',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider(
          create: (_) => SettingsState(settingsUsecase: newSettingsUsecase()),
          child: const SettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      r'C:\Games\GodsArena',
    );
    await tester.tap(find.text('Salvar path'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('settings.gamePath'), r'C:\Games\GodsArena');
    expect(prefs.getBool('settings.isDarkThemeEnabled'), isTrue);
    expect(prefs.getBool('settings.isBetterSearchEnabled'), isTrue);
  });
}
