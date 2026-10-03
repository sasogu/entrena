import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai_client.dart';

class AiSettings {
  const AiSettings({
    required this.provider,
    required this.model,
    required this.apiKey,
    required this.consented,
  });
  final AiProvider provider;
  final String model;
  final String? apiKey;

  /// Si la persona aceptó enviar sus datos a este proveedor.
  final bool consented;

  bool get ready => apiKey != null && apiKey!.isNotEmpty;
}

/// Guarda la configuración de IA. La clave va al almacén cifrado de Android
/// (nunca a las preferencias normales ni a la copia de datos exportada).
class AiSettingsStore {
  AiSettingsStore({FlutterSecureStorage? secure})
    : _secure = secure ?? const FlutterSecureStorage();
  final FlutterSecureStorage _secure;

  static const _providerKey = 'ai_provider';
  static String _modelKey(AiProvider p) => 'ai_model_${p.name}';
  static String _consentKey(AiProvider p) => 'ai_consent_${p.name}';
  static String _apiKeyKey(AiProvider p) => 'ai_api_key_${p.name}';

  Future<AiSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = AiProvider.fromName(prefs.getString(_providerKey));
    return loadFor(provider);
  }

  Future<AiSettings> loadFor(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    String? apiKey;
    try {
      apiKey = await _secure.read(key: _apiKeyKey(provider));
    } catch (_) {
      apiKey = null;
    }
    return AiSettings(
      provider: provider,
      model: prefs.getString(_modelKey(provider)) ?? provider.defaultModel,
      apiKey: apiKey,
      consented: prefs.getBool(_consentKey(provider)) ?? false,
    );
  }

  Future<void> save({
    required AiProvider provider,
    required String model,
    String? apiKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_providerKey, provider.name);
    await prefs.setString(_modelKey(provider), model);
    if (apiKey != null) {
      await _secure.write(key: _apiKeyKey(provider), value: apiKey);
    }
  }

  Future<void> deleteKey(AiProvider provider) async {
    final prefs = await SharedPreferences.getInstance();
    await _secure.delete(key: _apiKeyKey(provider));
    await prefs.remove(_consentKey(provider));
  }

  Future<void> setConsent(AiProvider provider, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_consentKey(provider), value);
  }
}
