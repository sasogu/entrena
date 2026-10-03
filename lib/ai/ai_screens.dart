import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../exercise_guide_sheet.dart';
import '../models.dart';
import 'ai_client.dart';
import 'ai_settings.dart';
import 'routine_ai.dart';

/// Ajustes de IA: proveedor, modelo y clave de API propia.
class AiSettingsScreen extends StatefulWidget {
  const AiSettingsScreen({super.key, this.store, this.client});
  final AiSettingsStore? store;
  final AiClient? client;

  @override
  State<AiSettingsScreen> createState() => _AiSettingsScreenState();
}

class _AiSettingsScreenState extends State<AiSettingsScreen> {
  late final AiSettingsStore _store = widget.store ?? AiSettingsStore();
  late final AiClient _client = widget.client ?? AiClient();
  final _keyController = TextEditingController();
  final _modelController = TextEditingController();
  AiSettings? _settings;
  bool _obscure = true;
  bool _testing = false;

  @override
  void initState() {
    super.initState();
    _store.load().then(_apply);
  }

  void _apply(AiSettings settings) {
    if (!mounted) return;
    setState(() {
      _settings = settings;
      _keyController.text = settings.apiKey ?? '';
      _modelController.text = settings.model;
    });
  }

  @override
  void dispose() {
    _keyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _changeProvider(AiProvider? provider) async {
    if (provider == null) return;
    _apply(await _store.loadFor(provider));
  }

  String get _model => _modelController.text.trim().isEmpty
      ? _settings!.provider.defaultModel
      : _modelController.text.trim();

  Future<void> _save({bool quiet = false}) async {
    final key = _keyController.text.trim();
    await _store.save(
      provider: _settings!.provider,
      model: _model,
      apiKey: key.isEmpty ? null : key,
    );
    _apply(await _store.loadFor(_settings!.provider));
    if (!quiet && mounted) _message('Ajustes guardados.');
  }

  Future<void> _test() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return _message('Pega primero tu clave de API.');
    setState(() => _testing = true);
    try {
      await _save(quiet: true);
      await _client.complete(
        provider: _settings!.provider,
        model: _model,
        apiKey: key,
        system: 'Responde solo con JSON.',
        user: 'Devuelve el objeto json {"ok": true}.',
        maxTokens: 50,
      );
      _message('Conexión correcta con ${_settings!.provider.label}.');
    } on AiException catch (error) {
      _message(error.message);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  Future<void> _deleteKey() async {
    await _store.deleteKey(_settings!.provider);
    _apply(await _store.loadFor(_settings!.provider));
    _message('Clave borrada de este móvil.');
  }

  void _message(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final grey = TextStyle(color: Colors.grey.shade700);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes de IA')),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'La IA es opcional. Usa tu propia clave de API: la app llama '
                  'directamente al proveedor y cada propuesta cuesta unos '
                  'céntimos en tu cuenta. La clave se guarda cifrada en este '
                  'móvil y no se incluye al exportar los datos.',
                  style: grey,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<AiProvider>(
                  initialValue: settings.provider,
                  decoration: const InputDecoration(labelText: 'Proveedor'),
                  items: AiProvider.values
                      .map(
                        (provider) => DropdownMenuItem(
                          value: provider,
                          child: Text(provider.label),
                        ),
                      )
                      .toList(),
                  onChanged: _changeProvider,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _keyController,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Clave de API',
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(settings.provider.keyUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: Text(
                      'Conseguir una clave de ${settings.provider.label}',
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _modelController,
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Modelo',
                    helperText:
                        'Recomendado: ${settings.provider.defaultModel}. '
                        'Otros: ${settings.provider.models.skip(1).join(', ')}',
                    helperMaxLines: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _testing ? null : _test,
                        child: _testing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Probar conexión'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _save,
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
                if (settings.ready) ...[
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _deleteKey,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Borrar la clave de este móvil'),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Consejo: pon un límite de gasto mensual en la consola del '
                  'proveedor.',
                  style: grey.copyWith(fontSize: 12),
                ),
              ],
            ),
    );
  }
}

/// Pide propuestas de rutina a la IA y deja elegir una.
class RoutineAiScreen extends StatefulWidget {
  const RoutineAiScreen({
    super.key,
    required this.goal,
    required this.historySummary,
    required this.onApply,
    this.store,
    this.client,
  });
  final String goal;
  final String historySummary;

  /// Aplica la propuesta y el objetivo con el que se pidió. Devuelve false
  /// si al final no se aplica (por ejemplo, porque se cancela).
  final Future<bool> Function(RoutineProposal proposal, String goal) onApply;
  final AiSettingsStore? store;
  final AiClient? client;

  @override
  State<RoutineAiScreen> createState() => _RoutineAiScreenState();
}

class _RoutineAiScreenState extends State<RoutineAiScreen> {
  late final AiSettingsStore _store = widget.store ?? AiSettingsStore();
  late final AiClient _client = widget.client ?? AiClient();
  final _limitations = TextEditingController();
  late final _customGoal = TextEditingController(
    text: goalOptions.contains(widget.goal) ? '' : widget.goal,
  );
  late String _goalChoice = goalOptions.contains(widget.goal)
      ? widget.goal
      : _otherGoal;
  static const _otherGoal = 'Otro';
  AiSettings? _settings;
  String _level = levelOptions.first;
  int _days = 3;
  int _minutes = 60;
  String _equipment = equipmentOptions.first;
  bool _sendHistory = true;
  bool _loading = false;
  String? _error;
  List<RoutineProposal>? _proposals;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final settings = await _store.load();
    if (mounted) setState(() => _settings = settings);
  }

  @override
  void dispose() {
    _limitations.dispose();
    _customGoal.dispose();
    super.dispose();
  }

  String get _goal =>
      _goalChoice == _otherGoal ? _customGoal.text.trim() : _goalChoice;

  RoutineRequest get _request => RoutineRequest(
    goal: _goal,
    level: _level,
    daysPerWeek: _days,
    minutes: _minutes,
    equipment: _equipment,
    limitations: _limitations.text,
    history: _sendHistory ? widget.historySummary : null,
  );

  Future<bool> _askConsent(AiSettings settings) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enviar datos a ${settings.provider.label}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Para preparar las propuestas se enviará este texto, y nada '
                'más, a la API del proveedor con tu clave:',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F2EE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  buildUserPrompt(_request),
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No se envía tu nombre ni el de tus perfiles. El uso de los '
                'datos depende de la política del proveedor.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Aceptar y enviar'),
          ),
        ],
      ),
    );
    if (accepted == true) await _store.setConsent(settings.provider, true);
    return accepted == true;
  }

  Future<void> _ask() async {
    final settings = _settings;
    if (settings == null || !settings.ready) return;
    if (_goal.isEmpty) {
      setState(() => _error = 'Escribe tu objetivo.');
      return;
    }
    if (!settings.consented && !await _askConsent(settings)) return;
    setState(() {
      _loading = true;
      _error = null;
      _proposals = null;
    });
    try {
      final proposals = await requestProposals(
        client: _client,
        provider: settings.provider,
        model: settings.model,
        apiKey: settings.apiKey!,
        request: _request,
      );
      if (mounted) setState(() => _proposals = proposals);
    } on AiException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
      await _reload();
    }
  }

  Future<void> _choose(RoutineProposal proposal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Usar «${proposal.name}»?'),
        content: Text(
          'Sustituirá los ejercicios de tu rutina actual. Tu historial no se '
          'toca.'
          '${_goal == widget.goal ? '' : '\n\nTu objetivo pasará a ser «$_goal».'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Usar esta rutina'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final applied = await widget.onApply(proposal, _goal);
    if (applied && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final settings = _settings;
    final grey = TextStyle(color: Colors.grey.shade700);
    return Scaffold(
      appBar: AppBar(title: const Text('Propuestas con IA')),
      body: settings == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!settings.ready) ...[
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.key),
                      title: const Text('Configura tu clave de IA'),
                      subtitle: const Text(
                        'Elige Claude, OpenAI o DeepSeek y pega tu clave de API.',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AiSettingsScreen(
                              store: _store,
                              client: _client,
                            ),
                          ),
                        );
                        await _reload();
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                DropdownButtonFormField<String>(
                  initialValue: _goalChoice,
                  isExpanded: true,
                  menuMaxHeight: 420,
                  decoration: const InputDecoration(labelText: 'Objetivo'),
                  items: [
                    ...goalOptions.map(
                      (goal) => DropdownMenuItem(
                        value: goal,
                        child: Text(goal, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: _otherGoal,
                      child: Text('Escribir otro objetivo'),
                    ),
                  ],
                  onChanged: (v) => setState(() {
                    _goalChoice = v ?? _goalChoice;
                    _proposals = null;
                  }),
                ),
                if (_goalChoice == _otherGoal)
                  TextField(
                    controller: _customGoal,
                    maxLength: 120,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      hintText: 'Por ejemplo: preparar una ruta de montaña',
                    ),
                  ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _level,
                  decoration: const InputDecoration(labelText: 'Nivel'),
                  items: levelOptions
                      .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                      .toList(),
                  onChanged: (v) => setState(() => _level = v ?? _level),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _equipment,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Material'),
                  items: equipmentOptions
                      .map(
                        (v) => DropdownMenuItem(
                          value: v,
                          child: Text(v, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _equipment = v ?? _equipment),
                ),
                const SizedBox(height: 16),
                Text('Días por semana: $_days'),
                Slider(
                  value: _days.toDouble(),
                  min: 1,
                  max: 6,
                  divisions: 5,
                  label: '$_days',
                  onChanged: (v) => setState(() => _days = v.round()),
                ),
                Text('Minutos por sesión: $_minutes'),
                Slider(
                  value: _minutes.toDouble(),
                  min: 20,
                  max: 120,
                  divisions: 10,
                  label: '$_minutes',
                  onChanged: (v) => setState(() => _minutes = v.round()),
                ),
                TextField(
                  controller: _limitations,
                  maxLength: 200,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Molestias o limitaciones (opcional)',
                    hintText: 'Por ejemplo: me molesta el hombro derecho',
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _sendHistory,
                  onChanged: (v) => setState(() => _sendHistory = v),
                  title: const Text('Tener en cuenta mi historial'),
                  subtitle: const Text(
                    'Envía un resumen de marcas por ejercicio',
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: settings.ready && !_loading ? _ask : null,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    _loading ? 'Preparando propuestas…' : 'Pedir propuestas',
                  ),
                ),
                if (_loading) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  Text(
                    'Puede tardar hasta un minuto.',
                    style: grey,
                    textAlign: TextAlign.center,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: const Color(0xFFFDECEA),
                    child: ListTile(
                      leading: const Icon(Icons.error_outline),
                      title: Text(_error!),
                    ),
                  ),
                ],
                if (_proposals != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Elige una o conserva tu rutina actual',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._proposals!.map(_proposalCard),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Conservar mi rutina actual'),
                  ),
                ],
              ],
            ),
    );
  }

  Widget _proposalCard(RoutineProposal proposal) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            proposal.name,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          if (proposal.summary.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(proposal.summary),
          ],
          if (proposal.days.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              '${proposal.days.length} días que se alternan',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
          if (proposal.reason.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              proposal.reason,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ],
          const SizedBox(height: 8),
          for (final day in proposal.days) ...[
            if (proposal.days.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
                child: Text(
                  day.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ...day.exercises.map(
              (exercise) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(exercise.icon, size: 20),
                title: Text(exercise.name),
                subtitle: Text(exercise.detail),
                trailing: IconButton(
                  tooltip: 'Cómo se hace',
                  icon: const Icon(Icons.info_outline),
                  onPressed: () => showExerciseGuide(context, exercise.name),
                ),
              ),
            ),
          ],
          if (proposal.dropped.isNotEmpty)
            Text(
              'Se han quitado ejercicios que la app no tiene: '
              '${proposal.dropped.join(', ')}.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: () => _choose(proposal),
            child: const Text('Usar esta rutina'),
          ),
        ],
      ),
    ),
  );
}
