import 'package:entrena/exercise_catalog_screen.dart';
import 'package:entrena/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Anchura de un móvil Android típico (411 × 891 puntos).
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1233, 2673);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Recorre la lista visible hasta el final, fallando si algo se desborda.
Future<void> _scrollToEnd(WidgetTester tester) async {
  final list = find
      .byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      )
      .hitTestable()
      .first;
  for (var i = 0; i < 12; i++) {
    await tester.drag(list, const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }
}

void main() {
  testWidgets('las cuatro pestañas caben en un móvil', (tester) async {
    _phone(tester);
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const EntrenaApp());
    await tester.pumpAndSettle();
    for (final tab in ['Hoy', 'Rutinas', 'Planifica', 'Progreso']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: tab);
      await _scrollToEnd(tester);
    }
  });

  testWidgets('el catálogo cabe en un móvil', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      MaterialApp(
        home: ExerciseCatalogScreen(
          dayName: 'Día A · Fuerza y prevención',
          alreadyAdded: const {},
          onAdd: (_) async {},
          onCustom: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await _scrollToEnd(tester);
  });
}
