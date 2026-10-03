import 'dart:convert';

import 'package:entrena/ai/ai_client.dart';
import 'package:entrena/ai/routine_ai.dart';
import 'package:entrena/exercise_guide.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _proposalJson = '''
{"propuestas":[
 {"nombre":"Máquinas guiadas","resumen":"Para empezar seguro","por_que":"Usa máquinas.",
  "ejercicios":[
   {"nombre":"Prensa de piernas","series":3,"repeticiones":"10–12"},
   {"nombre":"press de pecho en maquina","series":3,"repeticiones":"10"},
   {"nombre":"Jalón al pecho","series":3,"repeticiones":"10–12","nota":"Sin balanceo"},
   {"nombre":"Remo con kettlebell","series":3,"repeticiones":"10"},
   {"nombre":"Plancha","series":3,"repeticiones":"30 segundos"}]},
 {"nombre":"Inventada","resumen":"","por_que":"",
  "ejercicios":[{"nombre":"Burpees"},{"nombre":"Prensa de piernas","series":2,"repeticiones":"12"}]}
]}''';

void main() {
  late http.Request captured;
  AiClient clientReturning(int status, Object body) => AiClient(
    httpClient: MockClient((request) async {
      captured = request;
      return http.Response.bytes(
        utf8.encode(body is String ? body : jsonEncode(body)),
        status,
      );
    }),
  );

  Future<String> call(AiClient client, AiProvider provider) => client.complete(
    provider: provider,
    model: provider.defaultModel,
    apiKey: 'clave-de-prueba',
    system: 'sistema',
    user: 'usuario',
  );

  group('peticiones', () {
    test('Claude usa la API de mensajes con x-api-key', () async {
      final text = await call(
        clientReturning(200, {
          'content': [
            {'type': 'text', 'text': '{"ok":true}'},
          ],
        }),
        AiProvider.claude,
      );
      expect(text, '{"ok":true}');
      expect(captured.url.toString(), 'https://api.anthropic.com/v1/messages');
      expect(captured.headers['x-api-key'], 'clave-de-prueba');
      expect(captured.headers['anthropic-version'], '2023-06-01');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['model'], 'claude-haiku-4-5-20251001');
      expect(body['system'], 'sistema');
      expect(body['messages'], [
        {'role': 'user', 'content': 'usuario'},
      ]);
      expect(body['max_tokens'], 4000);
    });

    test(
      'OpenAI usa chat completions con JSON y max_completion_tokens',
      () async {
        final text = await call(
          clientReturning(200, {
            'choices': [
              {
                'message': {'content': '{"ok":true}'},
              },
            ],
          }),
          AiProvider.openai,
        );
        expect(text, '{"ok":true}');
        expect(
          captured.url.toString(),
          'https://api.openai.com/v1/chat/completions',
        );
        expect(captured.headers['authorization'], 'Bearer clave-de-prueba');
        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['model'], 'gpt-6-luna');
        expect(body['response_format'], {'type': 'json_object'});
        expect(body['max_completion_tokens'], 4000);
        expect(body.containsKey('thinking'), isFalse);
      },
    );

    test('DeepSeek desactiva el modo pensar', () async {
      await call(
        clientReturning(200, {
          'choices': [
            {
              'message': {'content': '{}'},
            },
          ],
        }),
        AiProvider.deepseek,
      );
      expect(
        captured.url.toString(),
        'https://api.deepseek.com/chat/completions',
      );
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body['model'], 'deepseek-flash');
      expect(body['thinking'], {'type': 'disabled'});
      expect(body['max_tokens'], 4000);
    });

    test('una clave mala da un mensaje claro', () async {
      expect(
        () => call(
          clientReturning(401, {
            'error': {'message': 'invalid x-api-key'},
          }),
          AiProvider.claude,
        ),
        throwsA(
          isA<AiException>().having(
            (e) => e.message,
            'message',
            startsWith('La clave de Claude (Anthropic) no es válida.'),
          ),
        ),
      );
    });

    test('una respuesta vacía es un error', () async {
      expect(
        () => call(clientReturning(200, {'content': []}), AiProvider.claude),
        throwsA(isA<AiException>()),
      );
    });
  });

  group('propuestas', () {
    test('solo usa ejercicios del catálogo, con su nombre exacto', () {
      final proposals = parseProposals('```json\n$_proposalJson\n```');
      // La segunda se queda con un solo ejercicio válido y se descarta.
      expect(proposals, hasLength(1));
      final first = proposals.single;
      expect(first.exercises.map((e) => e.name), [
        'Prensa de piernas',
        'Press de pecho en máquina',
        'Jalón al pecho',
        'Plancha',
      ]);
      expect(first.dropped, ['Remo con kettlebell']);
      expect(
        first.exercises[2].detail,
        '3 series · 10–12 repeticiones · Sin balanceo',
      );
      expect(first.exercises[3].detail, '3 series · 30 segundos');
    });

    test('rechaza respuestas sin propuestas válidas', () {
      for (final text in ['', 'no sé', '{"propuestas": []}', '{"x":1}']) {
        expect(
          () => parseProposals(text),
          throwsA(isA<AiException>()),
          reason: text,
        );
      }
    });

    test('las instrucciones incluyen todo el catálogo y piden JSON', () {
      final system = buildSystemPrompt();
      for (final guide in exerciseGuides) {
        expect(system, contains('- ${guide.name}'));
      }
      expect(system.toLowerCase(), contains('json'));
    });

    test('lo que se envía no incluye el historial si no se quiere', () {
      const base = RoutineRequest(
        goal: 'Ganar fuerza',
        level: 'Principiante',
        daysPerWeek: 3,
        minutes: 60,
        equipment: 'Gimnasio completo',
      );
      expect(buildUserPrompt(base), isNot(contains('Historial')));
      expect(
        buildUserPrompt(base),
        contains('Limitaciones o molestias: ninguna'),
      );
    });

    test('la petición completa devuelve propuestas', () async {
      final proposals = await requestProposals(
        client: clientReturning(200, {
          'content': [
            {'type': 'text', 'text': _proposalJson},
          ],
        }),
        provider: AiProvider.claude,
        model: 'claude-haiku-4-5-20251001',
        apiKey: 'clave-de-prueba',
        request: const RoutineRequest(
          goal: 'Empezar a entrenar',
          level: 'Principiante',
          daysPerWeek: 2,
          minutes: 45,
          equipment: 'Gimnasio completo',
          history: 'Sin sesiones registradas.',
        ),
      );
      expect(proposals.single.name, 'Máquinas guiadas');
      expect(captured.body, contains('Historial'));
    });
  });
}
