import 'package:entrena/models.dart';
import 'package:entrena/progress.dart';
import 'package:entrena/progress_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutRecord _session(DateTime date, Map<String, List<WorkoutSet>> sets) =>
    WorkoutRecord(
      date: date,
      routineName: 'Cuerpo completo A',
      exercises: sets.entries
          .map((item) => LoggedExercise(name: item.key, sets: item.value))
          .toList(),
    );

void main() {
  // El historial se guarda con la sesión más reciente primero.
  final history = [
    _session(DateTime(2026, 10, 3), {
      'Sentadilla': const [
        WorkoutSet(reps: 8, weight: 62.5),
        WorkoutSet(reps: 6, weight: 65),
      ],
      'Plancha': const [WorkoutSet(reps: 40, weight: 0)],
    }),
    _session(DateTime(2026, 9, 28), {
      'Sentadilla': const [WorkoutSet(reps: 8, weight: 60)],
      'Remo': const [],
    }),
    _session(DateTime(2026, 9, 25), {
      'Sentadilla': const [WorkoutSet(reps: 10, weight: 55)],
      'Plancha': const [WorkoutSet(reps: 30, weight: 0)],
    }),
  ];

  test('agrupa por ejercicio en orden cronológico', () {
    final progress = buildExerciseProgress(history);
    final squat = progress.firstWhere((item) => item.name == 'Sentadilla');

    expect(squat.entries.map((entry) => entry.date.day), [25, 28, 3]);
    expect(squat.usesWeight, isTrue);
    expect(squat.metric(squat.latest), 65);
    expect(squat.best, 65);
    expect(squat.change, 10);
    expect(squat.latest.volume, 8 * 62.5 + 6 * 65);
  });

  test('los ejercicios sin peso se siguen por repeticiones', () {
    final plank = buildExerciseProgress(
      history,
    ).firstWhere((item) => item.name == 'Plancha');

    expect(plank.usesWeight, isFalse);
    expect(plank.formatMetric(plank.best), '40 rep');
    expect(formatChange(plank), '+10 rep desde el principio');
  });

  test('ignora ejercicios sin series registradas', () {
    final names = buildExerciseProgress(history).map((item) => item.name);
    expect(names, isNot(contains('Remo')));
  });

  test('formatea los kilos sin decimales innecesarios', () {
    expect(formatKg(60), '60 kg');
    expect(formatKg(62.5), '62,5 kg');
  });

  testWidgets('la pantalla de un ejercicio muestra récord y sesiones', (
    tester,
  ) async {
    final squat = buildExerciseProgress(
      history,
    ).firstWhere((item) => item.name == 'Sentadilla');
    await tester.pumpWidget(
      MaterialApp(home: ExerciseProgressScreen(progress: squat)),
    );

    expect(find.text('Récord'), findsOneWidget);
    expect(find.text('+10 kg desde el principio'), findsOneWidget);
    expect(find.text('3/10/2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
