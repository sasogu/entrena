import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Proveedores de IA. La app llama directamente a su API con la clave de la
/// persona usuaria; no hay servidor intermedio.
enum AiProvider {
  claude(
    label: 'Claude (Anthropic)',
    keyUrl: 'https://console.anthropic.com/settings/keys',
    models: ['claude-haiku-4-5-20251001', 'claude-sonnet-5-5'],
  ),
  openai(
    label: 'OpenAI',
    keyUrl: 'https://platform.openai.com/api-keys',
    models: ['gpt-6-luna', 'gpt-6.1-sol'],
  ),
  deepseek(
    label: 'DeepSeek',
    keyUrl: 'https://platform.deepseek.com/api_keys',
    models: ['deepseek-flash', 'deepseek-v4-pro'],
  );

  const AiProvider({
    required this.label,
    required this.keyUrl,
    required this.models,
  });
  final String label;
  final String keyUrl;

  /// El primero es el recomendado: barato y suficiente para proponer rutinas.
  final List<String> models;

  String get defaultModel => models.first;

  static AiProvider fromName(String? name) => AiProvider.values.firstWhere(
    (provider) => provider.name == name,
    orElse: () => AiProvider.claude,
  );
}

class AiException implements Exception {
  const AiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AiClient {
  AiClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();
  final http.Client _http;

  static const timeout = Duration(seconds: 90);

  /// Envía una petición y devuelve el texto de la respuesta. Se pide JSON:
  /// OpenAI y DeepSeek lo garantizan con `response_format`; a Claude se le
  /// pide en las instrucciones y el texto se valida después.
  Future<String> complete({
    required AiProvider provider,
    required String model,
    required String apiKey,
    required String system,
    required String user,
    int maxTokens = 4000,
  }) async {
    final request = switch (provider) {
      AiProvider.claude => _claudeRequest(
        model,
        apiKey,
        system,
        user,
        maxTokens,
      ),
      AiProvider.openai || AiProvider.deepseek => _chatRequest(
        provider,
        model,
        apiKey,
        system,
        user,
        maxTokens,
      ),
    };
    final http.Response response;
    try {
      response = await _http
          .post(request.uri, headers: request.headers, body: request.body)
          .timeout(timeout);
    } on TimeoutException {
      throw const AiException(
        'La IA ha tardado demasiado en responder. Inténtalo de nuevo.',
      );
    } on SocketException {
      throw const AiException('Sin conexión a Internet.');
    } on http.ClientException {
      throw const AiException('No se ha podido conectar con la IA.');
    }
    if (response.statusCode != 200) {
      throw AiException(_errorMessage(provider, response));
    }
    final Map<String, dynamic> data;
    try {
      data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      throw const AiException('La respuesta de la IA no se ha podido leer.');
    }
    final text = provider == AiProvider.claude
        ? (data['content'] as List<dynamic>? ?? [])
              .whereType<Map<String, dynamic>>()
              .where((block) => block['type'] == 'text')
              .map((block) => block['text'] as String)
              .join()
        : ((data['choices'] as List<dynamic>?)?.firstOrNull
                      as Map<String, dynamic>?)?['message']?['content']
                  as String? ??
              '';
    if (text.trim().isEmpty) {
      throw const AiException('La IA ha devuelto una respuesta vacía.');
    }
    return text;
  }

  _Request _claudeRequest(
    String model,
    String apiKey,
    String system,
    String user,
    int maxTokens,
  ) => _Request(
    Uri.parse('https://api.anthropic.com/v1/messages'),
    {
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
      'content-type': 'application/json',
    },
    jsonEncode({
      'model': model,
      'max_tokens': maxTokens,
      'system': system,
      'messages': [
        {'role': 'user', 'content': user},
      ],
    }),
  );

  _Request _chatRequest(
    AiProvider provider,
    String model,
    String apiKey,
    String system,
    String user,
    int maxTokens,
  ) => _Request(
    Uri.parse(
      provider == AiProvider.openai
          ? 'https://api.openai.com/v1/chat/completions'
          : 'https://api.deepseek.com/chat/completions',
    ),
    {'authorization': 'Bearer $apiKey', 'content-type': 'application/json'},
    jsonEncode({
      'model': model,
      'messages': [
        {'role': 'system', 'content': system},
        {'role': 'user', 'content': user},
      ],
      'response_format': {'type': 'json_object'},
      if (provider == AiProvider.openai)
        'max_completion_tokens': maxTokens
      else ...{
        'max_tokens': maxTokens,
        // Sin modo «pensar»: responde antes y basta para esta tarea.
        'thinking': {'type': 'disabled'},
      },
    }),
  );

  String _errorMessage(AiProvider provider, http.Response response) {
    String? detail;
    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final error = data is Map<String, dynamic> ? data['error'] : null;
      detail = error is Map<String, dynamic>
          ? error['message'] as String?
          : error?.toString();
    } catch (_) {}
    final reason = switch (response.statusCode) {
      401 || 403 => 'La clave de ${provider.label} no es válida.',
      402 => 'No queda saldo en la cuenta de ${provider.label}.',
      404 => 'El modelo no existe o tu cuenta no tiene acceso a él.',
      429 => 'Has superado el límite de uso o no queda saldo.',
      >= 500 =>
        '${provider.label} tiene problemas ahora mismo. Prueba más tarde.',
      _ => 'Error ${response.statusCode} de ${provider.label}.',
    };
    return detail == null || detail.isEmpty ? reason : '$reason\n($detail)';
  }
}

class _Request {
  const _Request(this.uri, this.headers, this.body);
  final Uri uri;
  final Map<String, String> headers;
  final String body;
}
