import 'package:entrena/exercise_catalog_screen.dart';
import 'package:entrena/exercise_guide.dart';
import 'package:entrena/main.dart';
import 'package:entrena/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _verticalList = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

void main() {
  test('todos los ejercicios caen en una zona del catálogo', () {
    for (final guide in exerciseGuides) {
      final group = exerciseIconIndex(guide.name);
      expect(group, inInclusiveRange(0, catalogGroups.length - 1));
    }
    expect(
      defaultDetailFor(findExerciseGuide('Elíptica')!),
      contains('minutos'),
    );
    expect(
      defaultDetailFor(findExerciseGuide('Plancha lateral')!),
      contains('segundos'),
    );
  });

  testWidgets('el catálogo busca y añade varios ejercicios', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    final added = <Exercise>[];
    await tester.pumpWidget(
      MaterialApp(
        home: ExerciseCatalogScreen(
          dayName: 'Día A',
          alreadyAdded: const {'Peso muerto'},
          onAdd: (exercise) async => added.add(exercise),
          onCustom: () {},
        ),
      ),
    );
    expect(find.text('Pierna'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'peso muerto');
    await tester.pumpAndSettle();
    expect(find.text('Peso muerto rumano con mancuernas'), findsOneWidget);
    expect(find.byTooltip('Ya está en este día'), findsOneWidget);

    await tester.tap(
      find.byTooltip('Añadir Peso muerto rumano con mancuernas'),
    );
    await tester.pumpAndSettle();
    expect(added.single.name, 'Peso muerto rumano con mancuernas');
    expect(find.byTooltip('Ya está en este día'), findsNWidgets(2));

    // También busca por músculo.
    await tester.enterText(find.byType(TextField), 'aductores');
    await tester.pumpAndSettle();
    expect(find.text('Aductores en máquina'), findsOneWidget);
    expect(find.text('Press de banca'), findsNothing);
  });

  testWidgets('Añadir en Rutinas abre el catálogo y lo añade al día', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EntrenaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();
    // La lista de la página visible (el PageView construye también las
    // páginas vecinas fuera de la pantalla).
    final routinesList = find
        .byWidgetPredicate(
          (widget) =>
              widget is Scrollable &&
              widget.axisDirection == AxisDirection.down,
        )
        .hitTestable()
        .first;
    await tester.scrollUntilVisible(
      find.text('Añadir ejercicios del catálogo a Día A'),
      300,
      scrollable: routinesList,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('Añadir ejercicios del catálogo a Día A').hitTestable(),
    );
    await tester.pumpAndSettle();
    expect(find.text('Añadir a Día A'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'elíptica');
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Añadir Elíptica'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Hoy'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Elíptica'),
      300,
      scrollable: _verticalList,
    );
    expect(find.text('10–15 minutos a ritmo moderado'), findsOneWidget);
  });
}
