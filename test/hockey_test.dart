import 'dart:convert';

import 'package:entrena/ai/routine_ai.dart';
import 'package:entrena/exercise_guide.dart';
import 'package:entrena/main.dart';
import 'package:entrena/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _openRoutines(WidgetTester tester, String goal) async {
  final profile = Profile('Samuel')..goal = goal;
  SharedPreferences.setMockInitialValues({
    'profiles_v1': jsonEncode([profile.toJson()]),
  });
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(const EntrenaApp());
  await tester.pumpAndSettle();
  await tester.tap(find.text('Planifica').last);
  await tester.pumpAndSettle();
}

/// La lista vertical de la página visible (hay además un PageView horizontal).
final _verticalList = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

void main() {
  test('hay objetivos de hockey línea con contexto para la IA', () {
    final hockey = goalOptions.where((g) => g.startsWith('Hockey línea'));
    expect(hockey, hasLength(4));
    for (final goal in hockey) {
      expect(goalContext[goal], isNotNull, reason: goal);
    }
    const request = RoutineRequest(
      goal: 'Hockey línea: prevenir lesiones de ingle, cadera y espalda',
      level: 'Intermedio',
      daysPerWeek: 2,
      minutes: 45,
      equipment: 'Gimnasio completo',
    );
    expect(buildUserPrompt(request), contains('Qué implica: Las lesiones'));
  });

  test('los ejercicios de la rutina de hockey tienen ficha', () {
    final hockey = routineOptions.singleWhere((r) => r.sport != null);
    for (final exercise in hockey.exercises) {
      expect(
        findExerciseGuide(exercise.name),
        isNotNull,
        reason: exercise.name,
      );
    }
    expect(
      findExerciseGuide('copenhagen plank')?.name,
      'Plancha de Copenhague',
    );
  });

  testWidgets('la rutina de hockey sale primero con un objetivo de hockey', (
    tester,
  ) async {
    await _openRoutines(tester, 'Hockey línea: aguantar todo el partido');
    expect(find.text('Hockey línea'), findsOneWidget);
    final hockey = tester.getTopLeft(find.text('Hockey línea')).dy;
    await tester.scrollUntilVisible(
      find.text('Fuerza con barra'),
      300,
      scrollable: _verticalList,
    );
    final generic = tester.getTopLeft(find.text('Fuerza con barra')).dy;
    expect(find.text('Hockey línea'), findsOneWidget);
    expect(hockey, lessThan(generic + 1000));
    expect(tester.getTopLeft(find.text('Hockey línea')).dy, lessThan(generic));
    // Conserva sus ejercicios propios.
    expect(find.textContaining('Saltos de patinador'), findsWidgets);
  });

  testWidgets('con otro objetivo no aparece la rutina de hockey', (
    tester,
  ) async {
    await _openRoutines(tester, 'Ganar fuerza');
    expect(find.text('Hockey línea'), findsNothing);
  });
}
