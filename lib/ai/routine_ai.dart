import 'dart:convert';

import '../exercise_guide.dart';
import '../models.dart';
import '../progress.dart';
import 'ai_client.dart';

const levelOptions = ['Principiante', 'Intermedio', 'Avanzado'];
const equipmentOptions = [
  'Gimnasio completo (máquinas, cardio, poleas, barras y mancuernas)',
  'Solo mancuernas y banco',
  'Sin material (peso corporal)',
];

/// Lo que la persona pide. Es exactamente lo que se envía a la IA.
class RoutineRequest {
  const RoutineRequest({
    required this.goal,
    required this.level,
    required this.daysPerWeek,
    required this.minutes,
    required this.equipment,
    this.limitations = '',
    this.history,
  });
  final String goal;
  final String level;
  final int daysPerWeek;
  final int minutes;
  final String equipment;
  final String limitations;

  /// Resumen del progreso por ejercicio; null si no se quiere enviar.
  final String? history;
}

class RoutineProposal {
  const RoutineProposal({
    required this.name,
    required this.summary,
    required this.reason,
    required this.exercises,
    required this.dropped,
  });
  final String name;
  final String summary;
  final String reason;
  final List<Exercise> exercises;

  /// Ejercicios que la IA propuso pero no están en el catálogo de la app.
  final List<String> dropped;
}

String summarizeHistory(List<WorkoutRecord> history) {
  final progress = buildExerciseProgress(history);
  if (progress.isEmpty) return 'Sin sesiones registradas.';
  return [
    '${history.length} sesiones registradas.',
    ...progress.map(
      (item) =>
          '- ${item.name}: ${item.entries.length} sesiones, '
          'última ${item.formatMetric(item.metric(item.latest))}, '
          'mejor ${item.formatMetric(item.best)}',
    ),
  ].join('\n');
}

String buildSystemPrompt() {
  final catalog = exerciseGuides.map((guide) => '- ${guide.name}').join('\n');
  return '''
Eres un entrenador personal titulado. Propones rutinas de gimnasio seguras, sencillas y adecuadas al nivel de la persona. Escribes en español de España, con frases cortas.

Reglas:
- Propón 3 rutinas distintas entre sí (por ejemplo, más máquinas o más peso libre, más volumen o más intensidad).
- Cada rutina es UNA sesión de cuerpo completo que se repite los días indicados, de 4 a 7 ejercicios y ajustada al tiempo disponible.
- Usa SOLO ejercicios de este catálogo, con el nombre escrito exactamente igual:
$catalog
- Respeta el material disponible y las limitaciones. Ante dolor o lesión, elige opciones más suaves y recomienda consultar a un profesional; no hagas diagnósticos.
- Ajusta series y repeticiones al objetivo y al nivel. En plancha, indica segundos en lugar de repeticiones.
- Las máquinas de cardio (cinta de correr, bicicleta estática, elíptica, remo ergómetro y escaladora) se indican en minutos y ritmo en "repeticiones" (por ejemplo "15 minutos a ritmo moderado"), sin series. Úsalas para calentar (5–10 minutos) o como bloque propio cuando el objetivo sea resistencia, corazón, perder grasa o correr. Solo si el material incluye un gimnasio completo.
- Si hay historial, tenlo en cuenta para la progresión.

Responde solo con un objeto JSON válido, sin texto antes ni después, con este formato:
{"propuestas":[{"nombre":"Nombre corto","resumen":"Una frase","por_que":"Dos o tres frases sobre en qué se diferencia y para quién es mejor","ejercicios":[{"nombre":"Nombre exacto del catálogo","series":3,"repeticiones":"8–10","nota":"Opcional, muy breve"}]}]}''';
}

String buildUserPrompt(RoutineRequest request) => [
  'Objetivo: ${request.goal}',
  'Nivel: ${request.level}',
  'Días por semana: ${request.daysPerWeek}',
  'Minutos por sesión: ${request.minutes}',
  'Material: ${request.equipment}',
  'Limitaciones o molestias: ${request.limitations.trim().isEmpty ? 'ninguna' : request.limitations.trim()}',
  if (request.history != null) 'Historial:\n${request.history}',
].join('\n');

/// Extrae el JSON aunque venga envuelto en ```json ... ``` o con texto.
Map<String, dynamic> _extractJson(String text) {
  final start = text.indexOf('{');
  final end = text.lastIndexOf('}');
  if (start < 0 || end <= start) {
    throw const AiException('La IA no ha devuelto propuestas válidas.');
  }
  try {
    return jsonDecode(text.substring(start, end + 1)) as Map<String, dynamic>;
  } catch (_) {
    throw const AiException('La IA no ha devuelto propuestas válidas.');
  }
}

/// Convierte la respuesta en propuestas. Descarta los ejercicios que no están
/// en el catálogo y las rutinas que se quedan con menos de 3 ejercicios.
List<RoutineProposal> parseProposals(String text) {
  final data = _extractJson(text);
  final raw = data['propuestas'];
  if (raw is! List) {
    throw const AiException('La IA no ha devuelto propuestas válidas.');
  }
  final proposals = <RoutineProposal>[];
  for (final item in raw.whereType<Map<String, dynamic>>()) {
    final exercises = <Exercise>[];
    final dropped = <String>[];
    for (final entry
        in (item['ejercicios'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()) {
      final name = '${entry['nombre'] ?? ''}'.trim();
      final guide = findExerciseGuide(name);
      if (guide == null) {
        if (name.isNotEmpty) dropped.add(name);
        continue;
      }
      if (exercises.any((exercise) => exercise.name == guide.name)) continue;
      final sets = entry['series'];
      final reps = '${entry['repeticiones'] ?? ''}'.trim();
      final note = '${entry['nota'] ?? ''}'.trim();
      final detail = [
        if (sets != null && !guide.cardio) '$sets series',
        if (reps.isNotEmpty)
          RegExp(r'[a-zA-Z]').hasMatch(reps) ? reps : '$reps repeticiones',
        if (note.isNotEmpty) note,
      ].join(' · ');
      exercises.add(
        Exercise(guide.name, detail, exerciseIconIndex(guide.name)),
      );
    }
    if (exercises.length < 3) continue;
    proposals.add(
      RoutineProposal(
        name: '${item['nombre'] ?? 'Propuesta'}'.trim(),
        summary: '${item['resumen'] ?? ''}'.trim(),
        reason: '${item['por_que'] ?? ''}'.trim(),
        exercises: exercises,
        dropped: dropped,
      ),
    );
  }
  if (proposals.isEmpty) {
    throw const AiException(
      'Las propuestas de la IA no usaban ejercicios de la app. '
      'Inténtalo de nuevo.',
    );
  }
  return proposals;
}

Future<List<RoutineProposal>> requestProposals({
  required AiClient client,
  required AiProvider provider,
  required String model,
  required String apiKey,
  required RoutineRequest request,
}) async {
  final text = await client.complete(
    provider: provider,
    model: model,
    apiKey: apiKey,
    system: buildSystemPrompt(),
    user: buildUserPrompt(request),
  );
  return parseProposals(text);
}
