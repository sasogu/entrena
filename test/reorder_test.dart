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

Future<void> _start(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(1233, 2673);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const EntrenaApp());
  await tester.pumpAndSettle();
}

/// Un ejercicio dentro de la lista reordenable de Personaliza.
Finder _inRoutine(String name) => find.descendant(
  of: find.byType(ReorderableListView),
  matching: find.text(name),
);

/// Posición vertical de un ejercicio (en Hoy o en Personaliza).
double _y(WidgetTester tester, String name, {bool routine = true}) =>
    tester.getTopLeft(routine ? _inRoutine(name) : find.text(name)).dy;

Future<void> _scrollTo(WidgetTester tester, String name) async {
  await tester.scrollUntilVisible(
    _inRoutine(name),
    200,
    scrollable: _visibleList,
  );
  // Deja visibles los dos primeros ejercicios del día.
  await tester.ensureVisible(_inRoutine('Sentadilla goblet'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('«Bajar» cambia el orden y las series siguen a su ejercicio', (
    tester,
  ) async {
    await _start(tester);

    // Apunta una serie de Sentadilla goblet (primer ejercicio del Día A).
    await tester.tap(find.byTooltip('Añadir serie').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '10');
    await tester.enterText(find.byType(TextField).at(1), '16');
    await tester.tap(find.text('Guardar serie'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, 'Press de pecho en máquina');
    expect(
      _y(tester, 'Sentadilla goblet'),
      lessThan(_y(tester, 'Press de pecho en máquina')),
    );

    final goblet = find.ancestor(
      of: _inRoutine('Sentadilla goblet'),
      matching: find.byType(ListTile),
    );
    await tester.tap(
      find.descendant(
        of: goblet,
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Subir'), findsNothing); // ya es el primero
    await tester.tap(find.text('Bajar'));
    await tester.pumpAndSettle();
    expect(
      _y(tester, 'Press de pecho en máquina'),
      lessThan(_y(tester, 'Sentadilla goblet')),
    );

    // En Hoy, la serie sigue en Sentadilla goblet, ahora en segundo lugar.
    await tester.tap(find.text('Hoy'));
    await tester.pumpAndSettle();
    final todayGoblet = find.ancestor(
      of: find.text('Sentadilla goblet'),
      matching: find.byType(ListTile),
    );
    expect(
      find.descendant(
        of: todayGoblet,
        matching: find.textContaining('1 series'),
      ),
      findsOneWidget,
    );
    expect(
      _y(tester, 'Press de pecho en máquina', routine: false),
      lessThan(_y(tester, 'Sentadilla goblet', routine: false)),
    );
  });

  testWidgets('arrastrar desde el asa reordena', (tester) async {
    await _start(tester);
    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();
    await _scrollTo(tester, 'Jalón al pecho');

    final handle = find.descendant(
      of: find.ancestor(
        of: _inRoutine('Sentadilla goblet'),
        matching: find.byType(ListTile),
      ),
      matching: find.byIcon(Icons.drag_indicator),
    );
    final gesture = await tester.startGesture(tester.getCenter(handle));
    await tester.pump(const Duration(milliseconds: 100));
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, 25));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      _y(tester, 'Press de pecho en máquina'),
      lessThan(_y(tester, 'Sentadilla goblet')),
    );
  });
}
