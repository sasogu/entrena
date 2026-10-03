import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  });
  final String name;
  final String summary;
  final List<Exercise> exercises;
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
];

const goalOptions = [
  'Empezar a entrenar',
  'Ganar fuerza',
  'Aumentar masa muscular',
  'Mejorar resistencia',
  'Perder grasa',
  'Moverme y sentirme mejor',
];

class WorkoutSet {
  const WorkoutSet({required this.reps, required this.weight});
  final int reps;
  final double weight;

  Map<String, dynamic> toJson() => {'reps': reps, 'weight': weight};

  factory WorkoutSet.fromJson(Map<String, dynamic> json) => WorkoutSet(
    reps: (json['reps'] as num?)?.toInt() ?? 0,
    weight: (json['weight'] as num?)?.toDouble() ?? 0,
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
  final Map<int, List<WorkoutSet>> _sessionSets = {};
  String _sessionNote = '';
  bool _loaded = false;

  Profile get _profile => _profiles[_selected];

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
      _sessionSets.clear();
      _sessionNote = '';
    });
    await _save();
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
                  decoration: const InputDecoration(labelText: 'Objetivo'),
                  items: [
                    ...goalOptions.map(
                      (goal) =>
                          DropdownMenuItem(value: goal, child: Text(goal)),
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
      _profile.exercises = List.of(option.exercises);
      _sessionSets.clear();
    });
    await _save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${option.name} añadida a tu rutina')),
      );
    }
  }

  List<RoutineOption> _optionsForGoal() {
    final prescription = switch (_profile.goal) {
      'Ganar fuerza' => '3 series · 6–8 repeticiones',
      'Aumentar masa muscular' => '3 series · 8–12 repeticiones',
      'Mejorar resistencia' => '2–3 series · 12–15 repeticiones',
      _ => '2–3 series · 8–12 repeticiones',
    };
    return routineOptions
        .map(
          (option) => RoutineOption(
            name: option.name,
            summary: '${option.summary} · ${_profile.goal.toLowerCase()}',
            exercises: option.exercises
                .map(
                  (exercise) => Exercise(
                    exercise.name,
                    exercise.name == 'Plancha' || exercise.name == 'Dead bug'
                        ? exercise.detail
                        : prescription,
                    exercise.iconIndex,
                  ),
                )
                .toList(),
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
          exercises: _sessionSets.entries
              .where((entry) => entry.value.isNotEmpty)
              .map(
                (entry) => LoggedExercise(
                  name: _profile.exercises[entry.key].name,
                  sets: List.of(entry.value),
                ),
              )
              .toList(),
          note: _sessionNote,
        ),
      );
      _sessionSets.clear();
      _sessionNote = '';
      _tab = 2;
    });
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
    final exercise = _profile.exercises[index];
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

  Future<void> _editExercise([int? index]) async {
    final existing = index == null ? null : _profile.exercises[index];
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
                Exercise(name, detail, existing?.iconIndex ?? 0),
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
        _profile.exercises.add(result);
      } else {
        _profile.exercises[index] = result;
      }
      _profile.routineName = 'Mi rutina personalizada';
      _sessionSets.clear();
    });
    await _save();
  }

  Future<void> _removeExercise(int index) async {
    final exercise = _profile.exercises[index];
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
      _profile.exercises.removeAt(index);
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
          : SafeArea(child: _content()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (index) => setState(() => _tab = index),
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

  Widget _content() => switch (_tab) {
    0 => _today(),
    1 => _routinePage(),
    _ => _progressPage(),
  };

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
          const Text(
            'Entrenamiento A',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
          ),
          Text(
            '${_sessionSets.length}/${_profile.exercises.length}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      ..._profile.exercises.asMap().entries.map(
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
              '${_profile.exercises.length} ejercicios',
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
              : '${sets.length} series · ${sets.map((set) => '${set.reps}×${set.weight} kg').join(', ')}',
        ),
        trailing: IconButton.filledTonal(
          tooltip: 'Añadir serie',
          onPressed: () => _logSet(index),
          icon: const Icon(Icons.add),
        ),
        onTap: () => _logSet(index),
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
                Text(
                  option.exercises.map((exercise) => exercise.name).join(' · '),
                  style: const TextStyle(fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: selected
                      ? OutlinedButton.icon(
                          onPressed: () => setState(() => _tab = 0),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_outlined),
                  SizedBox(width: 8),
                  Text(
                    'Más adelante, con IA',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Estas son opciones de ejemplo. La IA podrá proponer alternativas adaptadas a tu objetivo cuando conectemos el servicio.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Personaliza tu rutina',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          TextButton.icon(
            onPressed: () => _editExercise(),
            icon: const Icon(Icons.add),
            label: const Text('Añadir'),
          ),
        ],
      ),
      ..._profile.exercises.asMap().entries.map(
        (entry) => Card(
          margin: const EdgeInsets.only(bottom: 7),
          child: ListTile(
            leading: Icon(
              entry.value.icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              entry.value.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(entry.value.detail),
            trailing: PopupMenuButton<String>(
              onSelected: (action) => action == 'edit'
                  ? _editExercise(entry.key)
                  : _removeExercise(entry.key),
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Editar')),
                PopupMenuItem(value: 'remove', child: Text('Quitar')),
              ],
            ),
          ),
        ),
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

  Widget _progressPage() {
    final last = _profile.lastWorkout;
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
                else
                  ..._profile.history
                      .take(8)
                      .map(
                        (record) => ExpansionTile(
                          tilePadding: EdgeInsets.zero,
                          leading: const CircleAvatar(child: Icon(Icons.check)),
                          title: Text(
                            record.routineName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(_formatDate(record.date)),
                          children: [
                            if (record.note.isNotEmpty)
                              ListTile(
                                dense: true,
                                leading: const Icon(Icons.edit_note),
                                title: Text(record.note),
                              ),
                            ...record.exercises.map(
                              (exercise) => ListTile(
                                dense: true,
                                title: Text(exercise.name),
                                subtitle: Text(
                                  exercise.sets
                                      .map(
                                        (set) =>
                                            '${set.reps} rep · ${set.weight} kg',
                                      )
                                      .join('  /  '),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: ListTile(
            leading: const Icon(Icons.auto_awesome),
            title: const Text(
              'Seguimiento con IA',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: const Text(
              'El siguiente paso será conectar un asistente para revisar tus entrenamientos y sugerir ajustes. Tú decides qué cambios aplicar.',
            ),
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

  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';
}
