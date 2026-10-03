import 'dart:convert';

import 'package:entrena/backup.dart';
import 'package:entrena/main.dart';
import 'package:entrena/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Finder get _visibleList => find
    .byWidgetPredicate(
      (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
    )
    .hitTestable()
    .first;

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 250, scrollable: _visibleList);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Un perfil con una rutina personalizada de 3 días, sin guardar.
Profile _custom() {
  final profile = Profile('Samuel');
  profile.routineName = 'Mi rutina personalizada';
  profile.days = [
    RoutineDay('Lunes', const [Exercise('Sentadilla con barra', '3 × 5', 0)]),
    RoutineDay('Miércoles', const [Exercise('Press de banca', '3 × 5', 1)]),
    RoutineDay('Viernes', const [Exercise('Peso muerto', '3 × 5', 3)]),
  ];
  return profile;
}

Future<void> _start(WidgetTester tester, Profile profile) async {
  SharedPreferences.setMockInitialValues({
    'profiles_v1': jsonEncode([profile.toJson()]),
  });
  tester.view.physicalSize = const Size(1233, 2673);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const EntrenaApp());
  await tester.pumpAndSettle();
}

void main() {
  test('las favoritas se guardan en el perfil y en la copia exportada', () {
    final profile = _custom()
      ..savedRoutines = [
        SavedRoutine(
          name: 'Mi semana',
          days: _custom().days,
          savedAt: DateTime(2026, 10, 3),
        ),
      ];
    final restored = decodeBackup(encodeBackup([profile])).single;
    expect(restored.savedRoutines.single.name, 'Mi semana');
    expect(restored.savedRoutines.single.days.map((d) => d.name), [
      'Lunes',
      'Miércoles',
      'Viernes',
    ]);
    expect(
      sameRoutineDays(restored.savedRoutines.single.days, profile.days),
      isTrue,
    );
  });

  testWidgets('cambiar de rutina avisa, guarda en favoritas y se recupera', (
    tester,
  ) async {
    await _start(tester, _custom());

    // Ir a Planifica y elegir una rutina de ejemplo.
    await tester.tap(find.text('Planifica').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('Todavía no tienes ninguna'), findsOneWidget);
    final barbellCard = find.ancestor(
      of: find.text('Fuerza con barra'),
      matching: find.byType(Card),
    );
    await tester.scrollUntilVisible(
      find.text('Fuerza con barra'),
      250,
      scrollable: _visibleList,
    );
    await _tapVisible(
      tester,
      find.descendant(
        of: barbellCard,
        matching: find.text('Elegir esta rutina'),
      ),
    );

    // Aviso: la rutina actual no está guardada.
    expect(find.text('¿Guardar tu rutina actual?'), findsOneWidget);
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Mi semana de 3 días');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    // Ahora usa Fuerza con barra (en Rutinas).
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

    // La favorita aparece en Planifica y se recupera con sus 3 días.
    await tester.tap(find.text('Planifica').last);
    await tester.pumpAndSettle();
    expect(find.text('Mi semana de 3 días'), findsOneWidget);
    await _tapVisible(tester, find.text('Usar esta rutina'));
    expect(bar().selectedIndex, 1);
    expect(
      find.descendant(of: current, matching: find.text('Mi semana de 3 días')),
      findsOneWidget,
    );
    expect(find.text('En favoritas'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final saved = Profile.fromJson(
      (jsonDecode(prefs.getString('profiles_v1')!) as List).single
          as Map<String, dynamic>,
    );
    expect(saved.days.map((d) => d.name), ['Lunes', 'Miércoles', 'Viernes']);
    expect(saved.savedRoutines.single.name, 'Mi semana de 3 días');
  });

  testWidgets('una rutina de ejemplo sin cambios se sustituye sin preguntar', (
    tester,
  ) async {
    await _start(tester, Profile('Samuel'));
    await tester.tap(find.text('Planifica').last);
    await tester.pumpAndSettle();
    final card = find.ancestor(
      of: find.text('Torso / Pierna'),
      matching: find.byType(Card),
    );
    await tester.scrollUntilVisible(
      find.text('Torso / Pierna'),
      250,
      scrollable: _visibleList,
    );
    await _tapVisible(
      tester,
      find.descendant(of: card, matching: find.text('Elegir esta rutina')),
    );
    expect(find.text('¿Guardar tu rutina actual?'), findsNothing);
  });
}
