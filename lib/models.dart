import 'package:flutter/material.dart';

class Profile {
  Profile(this.name, {this.workouts = 0, this.lastWorkout})
    : exercises = List<Exercise>.of(defaultRoutine);
  final String name;
  int workouts;
  DateTime? lastWorkout;
  List<Exercise> exercises;
  List<WorkoutRecord> history = [];
  String goal = 'Empezar a entrenar';
  String routineName = 'Cuerpo completo A';

  Map<String, dynamic> toJson() => {
    'name': name,
    'workouts': workouts,
    'lastWorkout': lastWorkout?.toIso8601String(),
    'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    'history': history.map((record) => record.toJson()).toList(),
    'goal': goal,
    'routineName': routineName,
  };

  factory Profile.fromJson(Map<String, dynamic> json) {
    final profile = Profile(
      json['name'] as String,
      workouts: (json['workouts'] as num?)?.toInt() ?? 0,
      lastWorkout: json['lastWorkout'] == null
          ? null
          : DateTime.tryParse(json['lastWorkout'] as String),
    );
    final exercises = json['exercises'] as List<dynamic>?;
    if (exercises != null) {
      profile.exercises = exercises
          .map((item) => Exercise.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    final history = json['history'] as List<dynamic>?;
    if (history != null) {
      profile.history = history
          .map((item) => WorkoutRecord.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    profile.goal = json['goal'] as String? ?? profile.goal;
    profile.routineName = json['routineName'] as String? ?? profile.routineName;
    return profile;
  }
}

class Exercise {
  const Exercise(this.name, this.detail, this.iconIndex);
  final String name;
  final String detail;
  final int iconIndex;
  IconData get icon =>
      exerciseIcons[iconIndex.clamp(0, exerciseIcons.length - 1).toInt()];

  Map<String, dynamic> toJson() => {
    'name': name,
    'detail': detail,
    'iconIndex': iconIndex,
  };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    json['name'] as String,
    json['detail'] as String? ?? '3 series · 8–12 repeticiones',
    (json['iconIndex'] as num?)?.toInt() ?? 0,
  );
}

const exerciseIcons = [
  Icons.fitness_center,
  Icons.sports_gymnastics,
  Icons.cable,
  Icons.sports_handball,
  Icons.self_improvement,
  Icons.directions_run,
];

const defaultRoutine = [
  Exercise('Sentadilla goblet', '3 series · 8–10 repeticiones', 0),
  Exercise('Press de pecho en máquina', '3 series · 8–12 repeticiones', 1),
  Exercise('Jalón al pecho', '3 series · 10–12 repeticiones', 2),
  Exercise(
    'Peso muerto rumano con mancuernas',
    '2 series · 10 repeticiones',
    3,
  ),
  Exercise('Plancha', '3 series · 20–30 segundos', 4),
];

class RoutineOption {
  const RoutineOption({
    required this.name,
    required this.summary,
    required this.exercises,
    this.sport,
  });
  final String name;
  final String summary;
  final List<Exercise> exercises;

  /// Deporte al que va dirigida. Solo se muestra con objetivos de ese deporte
  /// y conserva sus series y repeticiones.
  final String? sport;
}

const routineOptions = [
  RoutineOption(
    name: 'Cuerpo completo A',
    summary: 'Máquinas y movimientos básicos · sencilla para empezar',
    exercises: defaultRoutine,
  ),
  RoutineOption(
    name: 'Cuerpo completo B',
    summary: 'Alternativa con otros movimientos y un ritmo tranquilo',
    exercises: [
      Exercise('Prensa de piernas', '3 series · 8–12 repeticiones', 0),
      Exercise('Press inclinado en máquina', '3 series · 8–12 repeticiones', 1),
      Exercise('Remo sentado en polea', '3 series · 10–12 repeticiones', 2),
      Exercise('Puente de glúteos', '2 series · 10–12 repeticiones', 3),
      Exercise('Dead bug', '3 series · 8 por lado', 4),
    ],
  ),
  RoutineOption(
    name: 'Cardio y fuerza',
    summary: 'Calentamiento en cinta, máquinas básicas y elíptica al final',
    exercises: [
      Exercise('Cinta de correr', '10 minutos caminando a ritmo vivo', 5),
      Exercise('Prensa de piernas', '3 series · 10–12 repeticiones', 0),
      Exercise('Press de pecho en máquina', '3 series · 10–12 repeticiones', 1),
      Exercise('Remo sentado en polea', '3 series · 10–12 repeticiones', 2),
      Exercise('Elíptica', '15–20 minutos a esfuerzo moderado', 5),
    ],
  ),
  RoutineOption(
    name: 'Hockey línea',
    summary:
        'Empuje lateral, piernas a una pierna, aductores y estabilidad del tronco',
    sport: 'Hockey línea',
    exercises: [
      Exercise('Bicicleta estática', '8 minutos subiendo el ritmo', 5),
      Exercise('Saltos de patinador', '3 series · 6 por lado', 0),
      Exercise('Sentadilla búlgara', '3 series · 8 por pierna', 0),
      Exercise('Zancada lateral', '3 series · 8 por lado', 0),
      Exercise(
        'Peso muerto rumano con mancuernas',
        '3 series · 8 repeticiones',
        3,
      ),
      Exercise(
        'Plancha de Copenhague',
        '2 series · 15–20 segundos por lado',
        4,
      ),
      Exercise('Pallof press', '3 series · 10 por lado', 4),
    ],
  ),
];

const goalOptions = [
  'Empezar a entrenar',
  'Ganar fuerza',
  'Aumentar masa muscular',
  'Tonificar',
  'Perder grasa',
  'Mejorar resistencia',
  'Cuidar la salud del corazón',
  'Preparar una carrera popular',
  'Cuidar la espalda y la postura',
  'Volver a entrenar tras una pausa',
  'Entrenar en poco tiempo',
  'Mantenerme en forma a partir de los 50',
  'Moverme y sentirme mejor',
  'Hockey línea: potencia y velocidad de patinaje',
  'Hockey línea: aguantar todo el partido',
  'Hockey línea: prevenir lesiones de ingle, cadera y espalda',
  'Hockey línea: mantenerme durante la temporada',
];

/// Qué implica cada objetivo deportivo. Se envía a la IA junto al objetivo.
const goalContext = {
  'Hockey línea: potencia y velocidad de patinaje':
      'Deporte de patinaje con arrancadas, frenadas y cambios de dirección. '
      'Prioriza fuerza de piernas a una pierna, empuje lateral, potencia '
      '(saltos) y estabilidad del tronco.',
  'Hockey línea: aguantar todo el partido':
      'Esfuerzos intermitentes de 40–90 segundos con descansos cortos. '
      'Combina cardio por intervalos con fuerza de piernas y tronco.',
  'Hockey línea: prevenir lesiones de ingle, cadera y espalda':
      'Las lesiones típicas del patinaje son de aductores (ingle), flexores '
      'de cadera y zona lumbar. Prioriza aductores (plancha de Copenhague, '
      'máquina de aductores), glúteo medio, estabilidad del tronco y '
      'movimientos controlados.',
  'Hockey línea: mantenerme durante la temporada':
      'Hay entrenos de pista y partidos cada semana: sesiones cortas, pocas '
      'series y sin llegar al agotamiento, para mantener la fuerza sin '
      'cansar las piernas.',
};

class WorkoutSet {
  const WorkoutSet({
    this.reps = 0,
    this.weight = 0,
    this.minutes = 0,
    this.distanceKm = 0,
  });
  final int reps;
  final double weight;

  /// Solo en máquinas de cardio.
  final double minutes;
  final double distanceKm;

  bool get isCardio => minutes > 0;

  Map<String, dynamic> toJson() => {
    'reps': reps,
    'weight': weight,
    if (minutes > 0) 'minutes': minutes,
    if (distanceKm > 0) 'distanceKm': distanceKm,
  };

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    reps: (json['reps'] as num?)?.toInt() ?? 0,
    weight: (json['weight'] as num?)?.toDouble() ?? 0,
    minutes: (json['minutes'] as num?)?.toDouble() ?? 0,
    distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
  );
}

class LoggedExercise {
  const LoggedExercise({required this.name, required this.sets});
  final String name;
  final List<WorkoutSet> sets;

  Map<String, dynamic> toJson() => {
    'name': name,
    'sets': sets.map((set) => set.toJson()).toList(),
  };

  factory LoggedExercise.fromJson(Map<String, dynamic> json) => LoggedExercise(
    name: json['name'] as String,
    sets: (json['sets'] as List<dynamic>)
        .map((item) => WorkoutSet.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
}

class WorkoutRecord {
  const WorkoutRecord({
    required this.date,
    required this.routineName,
    required this.exercises,
    this.note = '',
  });
  final DateTime date;
  final String routineName;
  final List<LoggedExercise> exercises;
  final String note;

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'routineName': routineName,
    'exercises': exercises.map((exercise) => exercise.toJson()).toList(),
    if (note.isNotEmpty) 'note': note,
  };

  factory WorkoutRecord.fromJson(Map<String, dynamic> json) => WorkoutRecord(
    date: DateTime.tryParse(json['date'] as String) ?? DateTime.now(),
    routineName: json['routineName'] as String? ?? 'Rutina anterior',
    exercises: (json['exercises'] as List<dynamic>)
        .map((item) => LoggedExercise.fromJson(item as Map<String, dynamic>))
        .toList(),
    note: json['note'] as String? ?? '',
  );
}
