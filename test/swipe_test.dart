import 'package:entrena/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('deslizar cambia entre Hoy, Rutinas, Planifica y Progreso', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EntrenaApp());
    await tester.pumpAndSettle();

    NavigationBar bar() => tester.widget(find.byType(NavigationBar));
    expect(bar().selectedIndex, 0);

    Future<void> swipe(double dx) async {
      await tester.fling(find.byType(PageView), Offset(dx, 0), 1500);
      await tester.pumpAndSettle();
    }

    await swipe(-400);
    expect(bar().selectedIndex, 1);
    expect(find.text('Tu rutina actual'), findsOneWidget);

    await swipe(-400);
    expect(bar().selectedIndex, 2);
    expect(find.text('Cambiar objetivo'), findsOneWidget);

    await swipe(-400);
    expect(bar().selectedIndex, 3);
    expect(find.text('Tu progreso'), findsOneWidget);

    await swipe(400);
    expect(bar().selectedIndex, 2);

    // La barra sigue funcionando y salta directamente.
    await tester.tap(find.text('Hoy'));
    await tester.pumpAndSettle();
    expect(bar().selectedIndex, 0);
    expect(find.textContaining('Hoy toca'), findsOneWidget);
  });
}
