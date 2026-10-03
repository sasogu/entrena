import 'package:entrena/ai/routine_ai.dart';
import 'package:entrena/exercise_guide.dart';
import 'package:entrena/models.dart';
import 'package:entrena/progress.dart';
import 'package:entrena/progress_screens.dart';
import 'package:flutter_test/flutter_test.dart';

WorkoutRecord _session(DateTime date, List<WorkoutSet> sets) => WorkoutRecord(
  date: date,
  routineName: 'Cardio y fuerza',
  exercises: [LoggedExercise(name: 'Elíptica', sets: sets)],
);

void main() {
  test('las máquinas de cardio están en el catálogo', () {
    for (final name in [
      'Cinta de correr',
      'bici estática',
      'Bicicleta elíptica',
      'Máquina de remo',
      'Stepper',
    ]) {
      expect(isCardioExercise(name), isTrue, reason: name);
      expect(exerciseIconIndex(name), 5, reason: name);
    }
    expect(isCardioExercise('Prensa de piernas'), isFalse);
    expect(exerciseIcons, hasLength(6));
  });

  test('las series antiguas siguen cargando y el cardio guarda minutos', () {
    final old = WorkoutSet.fromJson({'reps': 8, 'weight': 60});
    expect(old.isCardio, isFalse);
    expect(old.toJson(), {'reps': 8, 'weight': 60.0});

    final cardio = WorkoutSet.fromJson(
      const WorkoutSet(minutes: 20, distanceKm: 3.5).toJson(),
    );
    expect(cardio.minutes, 20);
    expect(cardio.distanceKm, 3.5);
    expect(formatSet(cardio), '20 min · 3,5 km');
    expect(formatSet(const WorkoutSet(minutes: 12.5)), '12,5 min');
  });

  test('el progreso del cardio se mide en minutos por sesión', () {
    final progress = buildExerciseProgress([
      _session(DateTime(2026, 10, 5), const [WorkoutSet(minutes: 25)]),
      _session(DateTime(2026, 10, 1), const [
        WorkoutSet(minutes: 10, distanceKm: 1.2),
        WorkoutSet(minutes: 5),
      ]),
    ]).single;
    expect(progress.isCardio, isTrue);
    expect(progress.usesWeight, isFalse);
    expect(progress.metricLabel, 'Minutos por sesión');
    expect(progress.formatMetric(progress.best), '25 min');
    expect(formatChange(progress), '+10 min desde el principio');
  });

  test('la IA pone el cardio en minutos y sin series', () {
    final proposal = parseProposals(
      '''
{"propuestas":[{"nombre":"Cardio","resumen":"","por_que":"","ejercicios":[
 {"nombre":"Cinta de correr","series":1,"repeticiones":"10 minutos caminando"},
 {"nombre":"Prensa de piernas","series":3,"repeticiones":"12"},
 {"nombre":"Remo sentado en polea","series":3,"repeticiones":"12"},
 {"nombre":"Elíptica","repeticiones":"20 minutos a ritmo moderado"}]}]}''',
    ).single;
    expect(proposal.exercises.first.detail, '10 minutos caminando');
    expect(proposal.exercises.first.iconIndex, 5);
    expect(proposal.exercises[1].detail, '3 series · 12 repeticiones');
    expect(buildSystemPrompt(), contains('- Elíptica'));
  });

  test('hay objetivos variados y una rutina con cardio', () {
    expect(goalOptions.length, greaterThanOrEqualTo(12));
    expect(goalOptions.toSet(), hasLength(goalOptions.length));
    final cardio = routineOptions.firstWhere(
      (r) => r.name == 'Cardio y fuerza',
    );
    expect(
      cardio.exercises.where((e) => isCardioExercise(e.name)),
      hasLength(2),
    );
  });
}
