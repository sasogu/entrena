// Prueba manual contra la API real (no se ejecuta con `flutter test`).
// Uso: AI_PROVIDER=claude|openai|deepseek AI_KEY=... flutter test test_live/live_test.dart

import 'dart:io';

import 'package:entrena/ai/ai_client.dart';
import 'package:entrena/ai/routine_ai.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('petición real', () async {
    final provider = AiProvider.fromName(Platform.environment['AI_PROVIDER']);
    final key = Platform.environment['AI_KEY'] ?? '';
    expect(key, isNotEmpty);
    final watch = Stopwatch()..start();
    try {
      final proposals = await requestProposals(
        client: AiClient(),
        provider: provider,
        model: provider.defaultModel,
        apiKey: key,
        request: RoutineRequest(
          goal: 'Ganar fuerza',
          level: 'Principiante',
          daysPerWeek: int.tryParse(Platform.environment['AI_DAYS'] ?? '') ?? 3,
          minutes: 60,
          equipment: 'Gimnasio completo (máquinas, poleas, barras y mancuernas)',
          limitations: 'Me molesta un poco la rodilla izquierda',
          history: 'Sin sesiones registradas.',
        ),
      );
      // ignore: avoid_print
      print('OK en ${watch.elapsed.inSeconds}s');
      for (final p in proposals) {
        // ignore: avoid_print
        print('* ${p.name}: ${p.summary}\n  ${p.reason}\n  ${p.days.map((d) => '[${d.name}]\n    ${d.exercises.map((e) => '${e.name} · ${e.detail}').join('\n    ')}').join('\n  ')}${p.dropped.isEmpty ? '' : '\n  QUITADOS: ${p.dropped}'}');
      }
    } on AiException catch (e) {
      // ignore: avoid_print
      print('ERROR: ${e.message}');
      rethrow;
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
