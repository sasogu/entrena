import 'package:entrena/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder get _visibleList => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

void main() {
  testWidgets('elegir una rutina en Planifica la deja vigente en Rutinas', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1233, 2673);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EntrenaApp());
    await tester.pumpAndSettle();

    // Rutinas ya no muestra las rutinas de ejemplo.
    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();
    expect(find.text('Rutinas de ejemplo'), findsNothing);
    expect(find.text('Tu rutina actual'), findsOneWidget);

    await tester.tap(find.text('Planifica').last);
    await tester.pumpAndSettle();
    expect(find.text('Pedir propuestas a la IA'), findsOneWidget);

    final barbellCard = find.ancestor(
      of: find.text('Fuerza con barra'),
      matching: find.byType(Card),
    );
    await tester.scrollUntilVisible(
      find.text('Fuerza con barra'),
      300,
      scrollable: _visibleList,
    );
    final choose = find.descendant(
      of: barbellCard,
      matching: find.text('Elegir esta rutina'),
    );
    await tester.ensureVisible(choose);
    await tester.pumpAndSettle();
    await tester.tap(choose);
    await tester.pumpAndSettle();

    NavigationBar bar() => tester.widget(find.byType(NavigationBar));
    expect(bar().selectedIndex, 1);
    final current = find.ancestor(
      of: find.text('Tu rutina actual'),
      matching: find.byType(Card),
    );
    expect(
      find.descendant(of: current, matching: find.text('Fuerza con barra')),
      findsOneWidget,
    );
  });
}
