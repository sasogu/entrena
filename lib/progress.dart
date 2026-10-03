import 'dart:math' as math;

import 'models.dart';

/// Lo que se hizo de un ejercicio en una sesión concreta.
class ExerciseEntry {
  const ExerciseEntry({required this.date, required this.sets});
  final DateTime date;
  final List<WorkoutSet> sets;

  double get bestWeight => sets.map((set) => set.weight).fold(0, math.max);
  int get bestReps => sets.map((set) => set.reps).fold(0, math.max);
  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);
  double get volume => sets.fold(0, (sum, set) => sum + set.reps * set.weight);
  double get totalMinutes => sets.fold(0, (sum, set) => sum + set.minutes);
  double get totalDistance => sets.fold(0, (sum, set) => sum + set.distanceKm);
}

/// Evolución de un ejercicio a lo largo del historial, de la sesión más
/// antigua a la más reciente.
class ExerciseProgress {
  const ExerciseProgress({required this.name, required this.entries});
  final String name;
  final List<ExerciseEntry> entries;

  /// Las máquinas de cardio se siguen por minutos totales de la sesión.
  bool get isCardio => entries.any((entry) => entry.totalMinutes > 0);

  /// Los ejercicios sin peso (plancha, dead bug…) se siguen por repeticiones.
  bool get usesWeight =>
      !isCardio && entries.any((entry) => entry.bestWeight > 0);

  double metric(ExerciseEntry entry) => isCardio
      ? entry.totalMinutes
      : usesWeight
      ? entry.bestWeight
      : entry.bestReps.toDouble();

  String get metricLabel => isCardio
      ? 'Minutos por sesión'
      : usesWeight
      ? 'Mejor peso'
      : 'Mejores repeticiones';

  String formatMetric(double value) => isCardio
      ? formatMinutes(value)
      : usesWeight
      ? formatKg(value)
      : '${value.round()} rep';

  ExerciseEntry get latest => entries.last;
  double get best => entries.map(metric).reduce(math.max);

  /// Diferencia entre la última sesión y la primera.
  double get change => metric(entries.last) - metric(entries.first);
}

/// Agrupa el historial (que se guarda con la sesión más reciente primero)
/// por ejercicio. Los ejercicios trabajados más recientemente van primero.
List<ExerciseProgress> buildExerciseProgress(List<WorkoutRecord> history) {
  final byName = <String, List<ExerciseEntry>>{};
  final sorted = [...history]..sort((a, b) => a.date.compareTo(b.date));
  for (final record in sorted) {
    for (final exercise in record.exercises) {
      if (exercise.sets.isEmpty) continue;
      byName
          .putIfAbsent(exercise.name, () => [])
          .add(ExerciseEntry(date: record.date, sets: exercise.sets));
    }
  }
  final result = byName.entries
      .map((item) => ExerciseProgress(name: item.key, entries: item.value))
      .toList();
  result.sort((a, b) => b.latest.date.compareTo(a.latest.date));
  return result;
}

String _number(double value) => value == value.roundToDouble()
    ? value.toStringAsFixed(0)
    : value.toStringAsFixed(1).replaceAll('.', ',');

String formatKg(double value) => '${_number(value)} kg';

String formatMinutes(double value) => '${_number(value)} min';

String formatDistance(double value) => '${_number(value)} km';

String formatChange(ExerciseProgress progress) {
  final change = progress.change;
  if (change == 0) return 'igual que al principio';
  final sign = change > 0 ? '+' : '−';
  return '$sign${progress.formatMetric(change.abs())} desde el principio';
}
