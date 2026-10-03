import 'dart:convert';

import 'package:entrena/ai/routine_ai.dart';
import 'package:entrena/main.dart';
import 'package:entrena/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La lista vertical de la página visible (hay además un PageView horizontal).
final _verticalList = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

void main() {
  test('las rutinas de ejemplo tienen días y «Fuerza con barra» usa barra', () {
    final barbell = routineOptions.singleWhere(
      (r) => r.name == 'Fuerza con barra',
    );
    expect(barbell.days.map((d) => d.name), ['Día A', 'Día B']);
    expect(barbell.days[0].exercises.first.name, 'Sentadilla con barra');
    expect(barbell.days[1].exercises.first.name, 'Peso muerto');
    expect(barbell.keepsDetails, isTrue);
    expect(routineOptions.first.days, hasLength(2));
  });

  test('un perfil con el formato anterior se convierte en un día', () {
    final profile = Profile.fromJson({
      'name': 'Samuel',
      'exercises': [
        {'name': 'Peso muerto', 'detail': '3 series', 'iconIndex': 3},
      ],
    });
    expect(profile.days, hasLength(1));
    expect(profile.days.single.exercises.single.name, 'Peso muerto');
    final again = Profile.fromJson(profile.toJson());
    expect(again.days.single.name, 'Día A');
  });

  test('la IA devuelve rutinas de varios días', () {
    final proposal = parseProposals('''
{"propuestas":[{"nombre":"Torso / Pierna","resumen":"","por_que":"",
 "dias":[
  {"nombre":"Torso","ejercicios":[{"nombre":"Press de banca","series":3,"repeticiones":"8"},
    {"nombre":"Jalón al pecho","series":3,"repeticiones":"10"},
    {"nombre":"Press militar","series":3,"repeticiones":"8"}]},
  {"nombre":"Pierna","ejercicios":[{"nombre":"Sentadilla con barra","series":3,"repeticiones":"5"},
    {"nombre":"Peso muerto","series":3,"repeticiones":"5"},
    {"nombre":"Curl femoral","series":3,"repeticiones":"10"},
    {"nombre":"Patada de burro"}]},
  {"nombre":"Corto","ejercicios":[{"nombre":"Plancha"}]}]}]}''').single;
    // El día con un solo ejercicio válido se descarta.
    expect(proposal.days.map((d) => d.name), ['Torso', 'Pierna']);
    expect(proposal.dropped, ['Patada de burro']);
    expect(proposal.exercises, hasLength(6));
    expect(buildSystemPrompt(), contains('"dias"'));
  });

  test('si la IA devuelve una sola lista, es un único día', () {
    final proposal = parseProposals(
      '''
{"propuestas":[{"nombre":"Simple","ejercicios":[
 {"nombre":"Prensa de piernas"},{"nombre":"Jalón al pecho"},{"nombre":"Plancha"}]}]}''',
    ).single;
    expect(proposal.days.single.name, 'Día A');
  });

  testWidgets('al guardar el entrenamiento toca el día siguiente', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EntrenaApp());
    await tester.pumpAndSettle();

    expect(find.text('Hoy toca: Día A'), findsOneWidget);
    expect(find.text('Sentadilla goblet'), findsOneWidget);

    // Apunta una serie del primer ejercicio.
    await tester.tap(find.byTooltip('Añadir serie').first);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '10');
    await tester.enterText(find.byType(TextField).at(1), '12');
    await tester.tap(find.text('Guardar serie'));
    await tester.pumpAndSettle();

    // Con series apuntadas no se puede cambiar de día.
    expect(find.textContaining('para cambiar de día'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Guardar entrenamiento'),
      300,
      scrollable: _verticalList,
    );
    await tester.tap(find.text('Guardar entrenamiento'));
    await tester.pumpAndSettle();

    // Progreso muestra la sesión con su día.
    expect(find.textContaining('Día A'), findsWidgets);

    await tester.tap(find.text('Hoy'));
    await tester.pumpAndSettle();
    expect(find.text('Hoy toca: Día B'), findsOneWidget);
    expect(find.text('Prensa de piernas'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    final saved =
        (jsonDecode(prefs.getString('profiles_v1')!) as List).single
            as Map<String, dynamic>;
    expect(saved['nextDay'], 1);
    expect((saved['history'] as List).single['dayName'], 'Día A');
  });
}
