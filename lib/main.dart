import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ai/ai_screens.dart';
import 'ai/routine_ai.dart';
import 'backup.dart';
import 'credits_screen.dart';
import 'exercise_catalog_screen.dart';
import 'exercise_guide.dart';
import 'exercise_guide_sheet.dart';
import 'models.dart';
import 'progress.dart';
import 'progress_screens.dart';

void main() => runApp(const EntrenaApp());

class EntrenaApp extends StatelessWidget {
  const EntrenaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Entrena',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF156B5B),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F6F2),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE7EAE5)),
        ),
      ),
    ),
    home: const HomeScreen(),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _profilesKey = 'profiles_v1';
  static const _selectedKey = 'selected_profile_v1';
  List<Profile> _profiles = [Profile('Mi perfil')];
  int _selected = 0;
  int _tab = 0;
  final _pages = PageController();
  bool _animatingToTab = false;
  final Map<int, List<WorkoutSet>> _sessionSets = {};
  String _sessionNote = '';
  bool _loaded = false;

  /// Día de la rutina que se está viendo en Hoy y en Personaliza.
  int _day = 0;

  Profile get _profile => _profiles[_selected];

  RoutineDay get _currentDay {
    if (_profile.days.isEmpty) {
      _profile.days.add(RoutineDay(dayLetterName(0), []));
    }
    return _profile.days[_day.clamp(0, _profile.days.length - 1)];
  }

  List<Exercise> get _exercises => _currentDay.exercises;

  bool get _multiDay => _profile.days.length > 1;

  String _dayTitle(int index) => _profile.days[index].name;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  /// Cambia de pestaña desde la barra o un botón, con animación.
  Future<void> _goToTab(int index) async {
    setState(() => _tab = index);
    if (!_pages.hasClients) return;
    // Mientras dura la animación se ignoran las páginas intermedias, para que
    // el indicador de la barra no parpadee al saltar de Hoy a Progreso.
    _animatingToTab = true;
    await _pages.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    _animatingToTab = false;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profilesKey);
    final selected = prefs.getInt(_selectedKey) ?? 0;
    if (!mounted) return;
    setState(() {
      if (raw != null) {
        try {
          _profiles = (jsonDecode(raw) as List<dynamic>)
              .map((e) => Profile.fromJson(e as Map<String, dynamic>))
              .toList();
          if (_profiles.isEmpty) _profiles = [Profile('Mi perfil')];
        } catch (_) {
          _profiles = [Profile('Mi perfil')];
        }
      }
      _selected = selected.clamp(0, _profiles.length - 1).toInt();
      _day = _profile.safeNextDay;
      _loaded = true;
    });
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _profilesKey,
      jsonEncode(_profiles.map((profile) => profile.toJson()).toList()),
    );
    await prefs.setInt(_selectedKey, _selected);
  }

  Future<void> _addProfile() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Añadir perfil'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Nombre'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Crear'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    setState(() {
      _profiles.add(Profile(name));
      _selected = _profiles.length - 1;
      _day = _profile.safeNextDay;
      _sessionSets.clear();
      _sessionNote = '';
    });
    await _save();
  }

  Future<void> _selectProfile(int? index) async {
    if (index == null) return;
    if (index == 99999) {
      await _addProfile();
      return;
    }
    setState(() {
      _selected = index;
      _day = _profile.safeNextDay;
      _sessionSets.clear();
      _sessionNote = '';
    });
    await _save();
  }

  void _showMessage(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _exportData() async {
    final now = DateTime.now();
    final name = backupFileName(now);
    final bytes = Uint8List.fromList(
      utf8.encode(encodeBackup(_profiles, now: now)),
    );
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text(
                'Exportar datos',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                '${_profiles.length} ${_profiles.length == 1 ? 'perfil' : 'perfiles'} · '
                '${sessionCount(_profiles)} sesiones. Guarda el fichero fuera '
                'de la app para no perder nada si cambias de móvil.',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Guardar en el móvil'),
              subtitle: const Text('Descargas, Drive u otra carpeta'),
              onTap: () => Navigator.pop(context, 'save'),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Enviar…'),
              subtitle: const Text('Correo, Telegram, Drive…'),
              onTap: () => Navigator.pop(context, 'share'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    try {
      if (action == 'save') {
        final path = await FilePicker.saveFile(
          dialogTitle: 'Guardar copia de Entrena',
          fileName: name,
          bytes: bytes,
        );
        if (path != null && mounted) _showMessage('Copia guardada: $name');
      } else {
        await SharePlus.instance.share(
          ShareParams(
            subject: 'Copia de Entrena',
            files: [
              XFile.fromData(bytes, name: name, mimeType: 'application/json'),
            ],
            fileNameOverrides: [name],
          ),
        );
      }
    } catch (_) {
      if (mounted) _showMessage('No se ha podido exportar la copia.');
    }
  }

  Future<void> _importData() async {
    final List<Profile> imported;
    try {
      final picked = await FilePicker.pickFiles(withData: true);
      final bytes = picked?.files.single.bytes;
      if (bytes == null) return;
      imported = decodeBackup(utf8.decode(bytes, allowMalformed: true));
    } on BackupException catch (error) {
      if (mounted) _showMessage(error.message);
      return;
    } catch (_) {
      if (mounted) _showMessage('No se ha podido leer el fichero.');
      return;
    }
    if (!mounted) return;
    final names = imported.map((profile) => profile.name).join(', ');
    final mode = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar datos'),
        content: Text(
          'La copia tiene ${imported.length} '
          '${imported.length == 1 ? 'perfil' : 'perfiles'} ($names) con '
          '${sessionCount(imported)} sesiones.\n\n'
          '«Añadir» los suma a los perfiles que ya tienes. '
          '«Reemplazar» borra los datos actuales de este móvil y deja solo '
          'los de la copia.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'replace'),
            child: const Text('Reemplazar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'merge'),
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
    if (mode == null || !mounted) return;
    if (mode == 'replace') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('¿Reemplazar todos los datos?'),
          content: Text(
            'Se borrarán ${_profiles.length} '
            '${_profiles.length == 1 ? 'perfil' : 'perfiles'} y '
            '${sessionCount(_profiles)} sesiones de este móvil. '
            'Si no los tienes exportados, no se podrán recuperar.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Reemplazar'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    setState(() {
      if (mode == 'replace') {
        _profiles = imported;
        _selected = 0;
      } else {
        _profiles = mergeProfiles(_profiles, imported);
      }
      _day = _profile.safeNextDay;
      _sessionSets.clear();
      _sessionNote = '';
    });
    await _save();
    if (mounted) _showMessage('Datos importados.');
  }

  Future<void> _chooseGoal() async {
    var selected = goalOptions.contains(_profile.goal) ? _profile.goal : 'Otro';
    final customController = TextEditingController(
      text: goalOptions.contains(_profile.goal) ? '' : _profile.goal,
    );
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('¿Qué quieres conseguir?'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selected,
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
                      value: 'Otro',
                      child: Text('Escribir otro objetivo'),
                    ),
                  ],
                  onChanged: (value) =>
                      setDialogState(() => selected = value ?? selected),
                ),
                if (selected == 'Otro')
                  TextField(
                    controller: customController,
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Mi objetivo'),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final goal = selected == 'Otro'
                    ? customController.text.trim()
                    : selected;
                if (goal.isNotEmpty) Navigator.pop(context, goal);
              },
              child: const Text('Guardar objetivo'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _profile.goal = result);
    await _save();
  }

  Future<void> _selectRoutine(RoutineOption option) async {
    setState(() {
      _profile.routineName = option.name;
      _profile.days = option.copyDays();
      _profile.nextDay = 0;
      _day = 0;
      _sessionSets.clear();
    });
    await _save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${option.name} añadida a tu rutina')),
      );
    }
  }

  Future<void> _applyProposal(RoutineProposal proposal, String goal) {
    _profile.goal = goal;
    return _selectRoutine(
      RoutineOption(
        name: proposal.name,
        summary: proposal.summary,
        days: [
          for (final day in proposal.days) TemplateDay(day.name, day.exercises),
        ],
      ),
    );
  }

  @visibleForTesting
  Future<void> applyProposalForTest(RoutineProposal proposal, String goal) =>
      _applyProposal(proposal, goal);

  Future<void> _openRoutineAi() => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => RoutineAiScreen(
        goal: _profile.goal,
        historySummary: summarizeHistory(_profile.history),
        onApply: _applyProposal,
      ),
    ),
  );

  List<RoutineOption> _optionsForGoal() {
    final prescription = switch (_profile.goal) {
      'Ganar fuerza' => '3 series · 6–8 repeticiones',
      'Aumentar masa muscular' => '3 series · 8–12 repeticiones',
      'Tonificar' ||
      'Perder grasa' ||
      'Entrenar en poco tiempo' => '2–3 series · 10–15 repeticiones',
      'Mejorar resistencia' ||
      'Preparar una carrera popular' ||
      'Cuidar la salud del corazón' => '2–3 series · 12–15 repeticiones',
      'Hockey línea: potencia y velocidad de patinaje' =>
        '3 series · 5–8 repeticiones',
      'Hockey línea: aguantar todo el partido' =>
        '2–3 series · 12–15 repeticiones',
      'Hockey línea: mantenerme durante la temporada' =>
        '2 series · 6–10 repeticiones',
      _ => '2–3 series · 8–12 repeticiones',
    };
    final sport = goalOptions.contains(_profile.goal)
        ? routineOptions
              .map((option) => option.sport)
              .whereType<String>()
              .where((sport) => _profile.goal.startsWith(sport))
              .firstOrNull
        : null;
    final options = [
      ...routineOptions.where(
        (option) => option.sport == sport && sport != null,
      ),
      ...routineOptions.where((option) => option.sport == null),
    ];
    return options
        .map(
          (option) => option.keepsDetails
              ? option
              : RoutineOption(
                  name: option.name,
                  summary: '${option.summary} · ${_profile.goal.toLowerCase()}',
                  days: [
                    for (final day in option.days)
                      TemplateDay(day.name, [
                        for (final exercise in day.exercises)
                          Exercise(
                            exercise.name,
                            exercise.name == 'Plancha' ||
                                    exercise.name == 'Plancha lateral' ||
                                    exercise.name == 'Dead bug' ||
                                    isCardioExercise(exercise.name)
                                ? exercise.detail
                                : prescription,
                            exercise.iconIndex,
                          ),
                      ]),
                  ],
                ),
        )
        .toList();
  }

  Future<void> _finishWorkout() async {
    final now = DateTime.now();
    setState(() {
      _profile.workouts++;
      _profile.lastWorkout = now;
      _profile.history.insert(
        0,
        WorkoutRecord(
          date: now,
          routineName: _profile.routineName,
          dayName: _multiDay ? _currentDay.name : '',
          exercises: _sessionSets.entries
              .where((entry) => entry.value.isNotEmpty)
              .map(
                (entry) => LoggedExercise(
                  name: _exercises[entry.key].name,
                  sets: List.of(entry.value),
                ),
              )
              .toList(),
          note: _sessionNote,
        ),
      );
      _profile.nextDay = (_day + 1) % _profile.days.length;
      _day = _profile.nextDay;
      _sessionSets.clear();
      _sessionNote = '';
    });
    _goToTab(2);
    await _save();
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('¡Entrenamiento guardado!')));
    }
  }

  Future<void> _editSessionNote() async {
    final controller = TextEditingController(text: _sessionNote);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nota de la sesión'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            hintText: 'Cómo te has sentido, molestias, técnica…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar nota'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _sessionNote = result);
  }

  Future<void> _logSet(int index) async {
    final exercise = _exercises[index];
    if (isCardioExercise(exercise.name)) return _logCardio(index);
    final repsController = TextEditingController();
    final weightController = TextEditingController();
    final result = await showDialog<WorkoutSet>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Añadir serie · ${exercise.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              autofocus: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Repeticiones'),
            ),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Peso (kg)',
                hintText: '0 para peso corporal',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final reps = int.tryParse(repsController.text.trim());
              final weight = double.tryParse(
                weightController.text.trim().replaceAll(',', '.'),
              );
              if (reps == null || reps < 1 || weight == null || weight < 0) {
                return;
              }
              Navigator.pop(context, WorkoutSet(reps: reps, weight: weight));
            },
            child: const Text('Guardar serie'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    setState(() => (_sessionSets[index] ??= []).add(result));
  }

  Future<void> _logCardio(int index) async {
    final exercise = _exercises[index];
    final minutesController = TextEditingController();
    final distanceController = TextEditingController();
    double? parse(TextEditingController c) =>
        double.tryParse(c.text.trim().replaceAll(',', '.'));
    final result = await showDialog<WorkoutSet>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Registrar · ${exercise.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minutesController,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Minutos'),
            ),
            TextField(
              controller: distanceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Distancia (km, opcional)',
                hintText: 'La que marque la máquina',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final minutes = parse(minutesController);
              final distance = distanceController.text.trim().isEmpty
                  ? 0.0
                  : parse(distanceController);
              if (minutes == null ||
                  minutes <= 0 ||
                  distance == null ||
                  distance < 0) {
                return;
              }
              Navigator.pop(
                context,
                WorkoutSet(minutes: minutes, distanceKm: distance),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    setState(() => (_sessionSets[index] ??= []).add(result));
  }

  Future<void> _openCatalog() {
    final day = _currentDay;
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseCatalogScreen(
          dayName: day.name,
          alreadyAdded: {for (final exercise in day.exercises) exercise.name},
          onAdd: (exercise) async {
            setState(() {
              day.exercises.add(exercise);
              _profile.routineName = 'Mi rutina personalizada';
              _sessionSets.clear();
            });
            await _save();
          },
          onCustom: () => _editExercise(),
        ),
      ),
    );
  }

  Future<void> _editExercise([int? index]) async {
    final existing = index == null ? null : _exercises[index];
    final nameController = TextEditingController(text: existing?.name ?? '');
    final detailController = TextEditingController(
      text: existing?.detail ?? '3 series · 8–12 repeticiones',
    );
    final result = await showDialog<Exercise>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Añadir ejercicio' : 'Editar ejercicio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Ejercicio'),
            ),
            TextField(
              controller: detailController,
              decoration: const InputDecoration(
                labelText: 'Series y repeticiones',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              final detail = detailController.text.trim();
              if (name.isEmpty || detail.isEmpty) return;
              Navigator.pop(
                context,
                Exercise(
                  name,
                  detail,
                  existing?.iconIndex ?? exerciseIconIndex(name),
                ),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      if (index == null) {
        _exercises.add(result);
      } else {
        _exercises[index] = result;
      }
      _profile.routineName = 'Mi rutina personalizada';
      _sessionSets.clear();
    });
    await _save();
  }

  Future<void> _addDay() async {
    setState(() {
      _profile.days.add(RoutineDay(dayLetterName(_profile.days.length), []));
      _day = _profile.days.length - 1;
      _profile.routineName = 'Mi rutina personalizada';
      _sessionSets.clear();
    });
    await _save();
  }

  Future<void> _renameDay() async {
    final controller = TextEditingController(text: _currentDay.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nombre del día'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Por ejemplo: Torso'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    setState(() => _currentDay.name = name);
    await _save();
  }

  Future<void> _removeDay() async {
    final day = _currentDay;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('¿Quitar «${day.name}»?'),
        content: Text(
          'Se quitarán sus ${day.exercises.length} ejercicios de la rutina. '
          'Tu historial no se toca.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _profile.days.remove(day);
      _day = _day.clamp(0, _profile.days.length - 1);
      _profile.nextDay = _profile.safeNextDay;
      _profile.routineName = 'Mi rutina personalizada';
      _sessionSets.clear();
    });
    await _save();
  }

  /// Mueve un ejercicio dentro del día. Las series ya apuntadas hoy se mueven
  /// con él, porque se guardan por posición.
  Future<void> _moveExercise(int from, int to) async {
    if (from == to || to < 0 || to >= _exercises.length) return;
    setState(() {
      final sets = [
        for (var i = 0; i < _exercises.length; i++) _sessionSets[i],
      ];
      _exercises.insert(to, _exercises.removeAt(from));
      sets.insert(to, sets.removeAt(from));
      _sessionSets
        ..clear()
        ..addAll({
          for (var i = 0; i < sets.length; i++)
            if (sets[i] != null) i: sets[i]!,
        });
    });
    await _save();
  }

  Future<void> _removeExercise(int index) async {
    final exercise = _exercises[index];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quitar ejercicio'),
        content: Text('¿Quieres quitar ${exercise.name} de esta rutina?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _exercises.removeAt(index);
      _profile.routineName = 'Mi rutina personalizada';
      _sessionSets.clear();
    });
    await _save();
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Hoy', 'Rutinas', 'Progreso'];
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              titles[_tab],
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Más opciones',
            onSelected: (value) => switch (value) {
              'export' => _exportData(),
              'import' => _importData(),
              'ai' => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AiSettingsScreen()),
              ),
              _ => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreditsScreen()),
              ),
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'export',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.upload_file),
                  title: Text('Exportar datos'),
                ),
              ),
              PopupMenuItem(
                value: 'import',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.download),
                  title: Text('Importar datos'),
                ),
              ),
              PopupMenuItem(
                value: 'ai',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.auto_awesome_outlined),
                  title: Text('Ajustes de IA'),
                ),
              ),
              PopupMenuItem(
                value: 'credits',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.info_outline),
                  title: Text('Créditos'),
                ),
              ),
            ],
          ),
          PopupMenuButton<int>(
            tooltip: 'Cambiar perfil',
            initialValue: _selected,
            onSelected: _selectProfile,
            itemBuilder: (context) => [
              ..._profiles.asMap().entries.map(
                (entry) => PopupMenuItem<int>(
                  value: entry.key,
                  child: Row(
                    children: [
                      const Icon(Icons.person_outline, size: 20),
                      const SizedBox(width: 10),
                      Text(entry.value.name),
                      if (entry.key == _selected) ...[
                        const Spacer(),
                        const Icon(Icons.check, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<int>(
                value: 99999,
                child: Text('+ Añadir perfil'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CircleAvatar(
                radius: 17,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  _profile.name.isEmpty ? '?' : _profile.name[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              // Deslizar a los lados cambia entre Hoy, Rutinas y Progreso.
              child: PageView(
                controller: _pages,
                onPageChanged: (index) {
                  if (!_animatingToTab) setState(() => _tab = index);
                },
                children: [_today(), _routinePage(), _progressPage()],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: _goToTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Hoy',
          ),
          NavigationDestination(
            icon: Icon(Icons.view_list_outlined),
            selectedIcon: Icon(Icons.view_list),
            label: 'Rutinas',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progreso',
          ),
        ],
      ),
    );
  }

  Widget _today() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
    children: [
      Text(
        'Hola, ${_profile.name}',
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.7,
        ),
      ),
      const SizedBox(height: 4),
      Text(_dateLabel(), style: TextStyle(color: Colors.grey.shade700)),
      const SizedBox(height: 20),
      _heroCard(),
      const SizedBox(height: 22),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _multiDay ? 'Hoy toca: ${_currentDay.name}' : 'Tu entrenamiento',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
            ),
          ),
          Text(
            '${_sessionSets.length}/${_exercises.length}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      if (_multiDay) ...[
        const SizedBox(height: 8),
        _daySelector(lockedWhileLogging: true),
      ],
      const SizedBox(height: 12),
      if (_exercises.isEmpty)
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Este día no tiene ejercicios'),
            subtitle: const Text(
              'Añádelos en Rutinas → Personaliza tu rutina.',
            ),
            onTap: () => _goToTab(1),
          ),
        ),
      ..._exercises.asMap().entries.map(
        (entry) => _exerciseTile(entry.key, entry.value),
      ),
      Card(
        margin: const EdgeInsets.only(bottom: 9),
        child: ListTile(
          leading: const Icon(Icons.edit_note),
          title: Text(
            _sessionNote.isEmpty ? 'Añadir nota (opcional)' : 'Nota',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: _sessionNote.isEmpty
              ? null
              : Text(
                  _sessionNote,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
          onTap: _editSessionNote,
        ),
      ),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: _sessionSets.isEmpty ? null : _finishWorkout,
        icon: const Icon(Icons.check_circle_outline),
        label: const Text('Guardar entrenamiento'),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
      ),
      const SizedBox(height: 8),
      Center(
        child: Text(
          'Añade las series que completes y guarda la sesión',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ),
    ],
  );

  /// Chips para elegir el día de la rutina. En Hoy se bloquea mientras hay
  /// series apuntadas, para no mezclar ejercicios de días distintos.
  Widget _daySelector({bool lockedWhileLogging = false}) {
    final locked = lockedWhileLogging && _sessionSets.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (var i = 0; i < _profile.days.length; i++)
              ChoiceChip(
                label: Text(_dayTitle(i)),
                selected: i == _day.clamp(0, _profile.days.length - 1),
                onSelected: locked ? null : (_) => setState(() => _day = i),
              ),
          ],
        ),
        if (locked)
          Text(
            'Guarda o borra las series de hoy para cambiar de día.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
      ],
    );
  }

  Widget _heroCard() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      gradient: const LinearGradient(
        colors: [Color(0xFF14594E), Color(0xFF247D69)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Tu objetivo de hoy',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Icon(
              Icons.auto_awesome,
              color: Colors.white.withValues(alpha: .9),
              size: 20,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Muévete a tu ritmo.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Una rutina sencilla para ganar constancia y aprender la técnica.',
          style: TextStyle(color: Colors.white70, height: 1.35),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _heroMetric(Icons.timer_outlined, '35 min'),
            const SizedBox(width: 18),
            _heroMetric(
              Icons.fitness_center,
              '${_exercises.length} ejercicios',
            ),
          ],
        ),
      ],
    ),
  );

  Widget _heroMetric(IconData icon, String label) => Row(
    children: [
      Icon(icon, size: 17, color: Colors.white70),
      const SizedBox(width: 6),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _exerciseTile(int index, Exercise exercise) {
    final sets = _sessionSets[index] ?? const <WorkoutSet>[];
    return Card(
      margin: const EdgeInsets.only(bottom: 9),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: sets.isNotEmpty
                ? const Color(0xFFE0F1EA)
                : const Color(0xFFF0F2EE),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            exercise.icon,
            color: sets.isNotEmpty
                ? const Color(0xFF156B5B)
                : const Color(0xFF59635D),
          ),
        ),
        title: Text(
          exercise.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            decoration: sets.isNotEmpty ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          sets.isEmpty
              ? exercise.detail
              : isCardioExercise(exercise.name)
              ? formatSets(sets)
              : '${sets.length} series · ${formatSets(sets)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Cómo se hace',
              onPressed: () => showExerciseGuide(context, exercise.name),
              icon: const Icon(Icons.info_outline),
            ),
            IconButton.filledTonal(
              tooltip: isCardioExercise(exercise.name)
                  ? 'Registrar'
                  : 'Añadir serie',
              onPressed: () => _logSet(index),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        onTap: () => _logSet(index),
      ),
    );
  }

  /// Lista de días con sus ejercicios, para las tarjetas de rutina.
  Widget _daysSummary(List<(String, List<Exercise>)> days) {
    if (days.every((day) => day.$2.isEmpty)) {
      return const Text(
        'Sin ejercicios. Añade alguno abajo o elige una rutina.',
        style: TextStyle(fontSize: 12),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (days.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${days.length} días que se alternan',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        for (final (name, exercises) in days)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text.rich(
              TextSpan(
                children: [
                  if (days.length > 1)
                    TextSpan(
                      text: '$name: ',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  TextSpan(
                    text: exercises
                        .map((exercise) => exercise.name)
                        .join(' · '),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
      ],
    );
  }

  Widget _currentRoutineCard() {
    final isTemplate = routineOptions.any(
      (option) => option.name == _profile.routineName,
    );
    return Card(
      color: const Color(0xFFE0F1EA),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF156B5B)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu rutina actual',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      Text(
                        _profile.routineName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _daysSummary([
              for (final day in _profile.days) (day.name, day.exercises),
            ]),
            if (!isTemplate)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Si eliges otra rutina, esta se sustituye.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _goToTab(0),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Empezar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routinePage() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Text(
        'Tu plan',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      const SizedBox(height: 6),
      Text(
        'Objetivo: ${_profile.goal}',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        onPressed: _chooseGoal,
        icon: const Icon(Icons.flag_outlined),
        label: const Text('Cambiar objetivo'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(46)),
      ),
      const SizedBox(height: 22),
      _currentRoutineCard(),
      const SizedBox(height: 18),
      const Text(
        'Elige una rutina',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
      ),
      const SizedBox(height: 4),
      Text(
        'Puedes cambiarla cuando quieras.',
        style: TextStyle(color: Colors.grey.shade700),
      ),
      const SizedBox(height: 12),
      ..._optionsForGoal().map((option) {
        final selected = option.name == _profile.routineName;
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      selected ? Icons.check_circle : Icons.fitness_center,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        option.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (selected) const Chip(label: Text('Actual')),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  option.summary,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 8),
                _daysSummary([
                  for (final day in option.days) (day.name, day.exercises),
                ]),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: selected
                      ? OutlinedButton.icon(
                          onPressed: () => _goToTab(0),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Empezar'),
                        )
                      : FilledButton.tonal(
                          onPressed: () => _selectRoutine(option),
                          child: const Text('Elegir esta rutina'),
                        ),
                ),
              ],
            ),
          ),
        );
      }),
      Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 6,
          ),
          leading: const Icon(Icons.auto_awesome),
          title: const Text(
            'Pedir propuestas a la IA',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Rutinas adaptadas a tu objetivo, nivel y material. '
            'Tú eliges si aplicas alguna.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openRoutineAi,
        ),
      ),
      const SizedBox(height: 18),
      const Text(
        'Personaliza tu rutina',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
      ),
      const SizedBox(height: 8),
      _daySelector(),
      Wrap(
        children: [
          TextButton.icon(
            onPressed: _addDay,
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('Añadir día'),
          ),
          if (_multiDay)
            TextButton.icon(
              onPressed: _renameDay,
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Renombrar'),
            ),
          if (_multiDay)
            TextButton.icon(
              onPressed: _removeDay,
              icon: const Icon(Icons.delete_outline),
              label: const Text('Quitar día'),
            ),
        ],
      ),
      const SizedBox(height: 4),
      FilledButton.tonalIcon(
        onPressed: _openCatalog,
        icon: const Icon(Icons.library_add_outlined),
        label: Text(
          _multiDay
              ? 'Añadir ejercicios del catálogo a ${_currentDay.name}'
              : 'Añadir ejercicios del catálogo',
          overflow: TextOverflow.ellipsis,
        ),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
      ),
      const SizedBox(height: 10),
      // Arrastrar desde el asa (≡) para cambiar el orden.
      ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        itemCount: _exercises.length,
        onReorder: (from, to) => _moveExercise(from, to > from ? to - 1 : to),
        itemBuilder: (context, index) {
          final exercise = _exercises[index];
          final last = index == _exercises.length - 1;
          return Card(
            key: ObjectKey(exercise),
            margin: const EdgeInsets.only(bottom: 7),
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 4, right: 4),
              leading: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReorderableDragStartListener(
                    index: index,
                    child: const Padding(
                      padding: EdgeInsets.all(8),
                      child: Tooltip(
                        message: 'Arrastra para cambiar el orden',
                        child: Icon(Icons.drag_indicator),
                      ),
                    ),
                  ),
                  Icon(
                    exercise.icon,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              title: Text(
                exercise.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(exercise.detail),
              onTap: () => showExerciseGuide(context, exercise.name),
              trailing: PopupMenuButton<String>(
                onSelected: (action) => switch (action) {
                  'guide' => showExerciseGuide(context, exercise.name),
                  'up' => _moveExercise(index, index - 1),
                  'down' => _moveExercise(index, index + 1),
                  'edit' => _editExercise(index),
                  _ => _removeExercise(index),
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'guide',
                    child: Text('Cómo se hace'),
                  ),
                  if (index > 0)
                    const PopupMenuItem(value: 'up', child: Text('Subir')),
                  if (!last)
                    const PopupMenuItem(value: 'down', child: Text('Bajar')),
                  const PopupMenuItem(value: 'edit', child: Text('Editar')),
                  const PopupMenuItem(value: 'remove', child: Text('Quitar')),
                ],
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 14),
      Card(
        child: ListTile(
          leading: const Icon(Icons.lightbulb_outline),
          title: const Text(
            'Consejo para empezar',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text(
            'Elige un peso cómodo y termina cada serie con algunas repeticiones todavía posibles. Si tienes dudas de técnica, pide ayuda al personal del gimnasio.',
          ),
        ),
      ),
    ],
  );

  static const _recentLimit = 5;

  Widget _progressPage() {
    final last = _profile.lastWorkout;
    final exerciseProgress = buildExerciseProgress(_profile.history);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Tu progreso',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Un paso cada vez, ${_profile.name}.',
          style: TextStyle(color: Colors.grey.shade700),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _statCard(
                'Sesiones',
                '${_profile.workouts}',
                Icons.calendar_month_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                'Última sesión',
                last == null ? '—' : '${last.day}/${last.month}',
                Icons.trending_up,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Actividad reciente',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                ),
                const SizedBox(height: 16),
                if (_profile.history.isEmpty && _profile.workouts == 0)
                  const Text(
                    'Cuando termines tu primera sesión, aparecerá aquí.',
                  )
                else if (_profile.history.isEmpty)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(child: Icon(Icons.check)),
                    title: const Text(
                      'Sesiones anteriores',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'El detalle estará disponible en las próximas sesiones.',
                    ),
                  )
                else ...[
                  ..._profile.history
                      .take(_recentLimit)
                      .map((record) => WorkoutRecordTile(record: record)),
                  if (_profile.history.length > _recentLimit)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HistoryScreen(history: _profile.history),
                          ),
                        ),
                        icon: const Icon(Icons.history),
                        label: Text(
                          'Ver todo el historial (${_profile.history.length})',
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
        if (exerciseProgress.isNotEmpty) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Por ejercicio',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Toca un ejercicio para ver su evolución.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 8),
                  ...exerciseProgress.map(
                    (progress) => ExerciseProgressTile(progress: progress),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text(
              'Seguimiento con IA',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'Pide a la IA rutinas nuevas que tengan en cuenta tu historial. Tú decides qué cambios aplicar.',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _openRoutineAi,
          ),
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    ),
  );

  String _dateLabel() {
    const days = [
      'lunes',
      'martes',
      'miércoles',
      'jueves',
      'viernes',
      'sábado',
      'domingo',
    ];
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1][0].toUpperCase()}${days[now.weekday - 1].substring(1)}, ${now.day} de ${months[now.month - 1]}';
  }
}
