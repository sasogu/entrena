import 'package:flutter/material.dart';

import 'exercise_guide.dart';
import 'exercise_guide_sheet.dart';
import 'exercise_videos.dart';
import 'models.dart';

/// Zonas del catálogo, en el orden en que se muestran. El índice coincide con
/// el icono del ejercicio (ver exerciseIconIndex y exerciseIcons).
const catalogGroups = [
  'Pierna',
  'Empuje: pecho, hombro y tríceps',
  'Tirón: espalda y bíceps',
  'Cadera y parte trasera',
  'Tronco',
  'Cardio',
];

/// Series y repeticiones con las que se añade un ejercicio del catálogo. Se
/// pueden cambiar después con «Editar».
String defaultDetailFor(ExerciseGuide guide) {
  if (guide.cardio) return '10–15 minutos a ritmo moderado';
  final name = normalizeExerciseName(guide.name);
  if (name.startsWith('plancha')) return '3 series · 20–30 segundos';
  if (guide.name == 'Dead bug') return '3 series · 8 por lado';
  return '3 series · 8–12 repeticiones';
}

/// Catálogo completo para añadir ejercicios al día que se está editando.
/// Se pueden añadir varios seguidos; [onAdd] se llama con cada uno.
class ExerciseCatalogScreen extends StatefulWidget {
  const ExerciseCatalogScreen({
    super.key,
    required this.dayName,
    required this.alreadyAdded,
    required this.onAdd,
    required this.onCustom,
  });
  final String dayName;
  final Set<String> alreadyAdded;
  final Future<void> Function(Exercise exercise) onAdd;

  /// Para escribir a mano un ejercicio que no está en el catálogo.
  final VoidCallback onCustom;

  @override
  State<ExerciseCatalogScreen> createState() => _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends State<ExerciseCatalogScreen> {
  late final Set<String> _added = {...widget.alreadyAdded};
  String _query = '';

  bool _matches(ExerciseGuide guide) {
    final query = normalizeExerciseName(_query);
    if (query.isEmpty) return true;
    return [
      guide.name,
      ...guide.aliases,
      guide.muscles,
    ].any((text) => normalizeExerciseName(text).contains(query));
  }

  Future<void> _add(ExerciseGuide guide) async {
    final exercise = Exercise(
      guide.name,
      defaultDetailFor(guide),
      exerciseIconIndex(guide.name),
    );
    await widget.onAdd(exercise);
    if (!mounted) return;
    setState(() => _added.add(guide.name));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('${guide.name} añadido a ${widget.dayName}'),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final grey = TextStyle(color: Colors.grey.shade700);
    final visible = exerciseGuides.where(_matches).toList();
    return Scaffold(
      appBar: AppBar(title: Text('Añadir a ${widget.dayName}')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar por nombre o músculo',
            ),
            onChanged: (value) => setState(() => _query = value),
          ),
          const SizedBox(height: 8),
          Text(
            '${exerciseGuides.length} ejercicios. Toca ＋ para añadir o el '
            'nombre para ver cómo se hace. Las series se cambian después.',
            style: grey.copyWith(fontSize: 12),
          ),
          for (var group = 0; group < catalogGroups.length; group++)
            ..._groupSection(
              group,
              visible.where((g) => exerciseIconIndex(g.name) == group),
            ),
          if (visible.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No hay ningún ejercicio con «$_query».',
                style: grey,
                textAlign: TextAlign.center,
              ),
            ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Escribir un ejercicio que no está'),
            subtitle: const Text('Sin ficha ni vídeo; con búsqueda en YouTube'),
            onTap: () {
              Navigator.pop(context);
              widget.onCustom();
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _groupSection(int group, Iterable<ExerciseGuide> guides) {
    if (guides.isEmpty) return const [];
    return [
      Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 4),
        child: Row(
          children: [
            Icon(exerciseIcons[group], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                catalogGroups[group],
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
      for (final guide in guides) _tile(guide),
    ];
  }

  Widget _tile(ExerciseGuide guide) {
    final added = _added.contains(guide.name);
    final hasVideo = exerciseVideos.containsKey(guide.name);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16, right: 8),
        title: Text(
          guide.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${hasVideo ? '▶ Con vídeo · ' : ''}${guide.muscles}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // Tocar la fila abre la ficha con la técnica (y el vídeo si lo hay).
        onTap: () => showExerciseGuide(context, guide.name),
        trailing: added
            ? const IconButton(
                tooltip: 'Ya está en este día',
                onPressed: null,
                icon: Icon(Icons.check_circle),
              )
            : IconButton.filledTonal(
                tooltip: 'Añadir ${guide.name}',
                icon: const Icon(Icons.add),
                onPressed: () => _add(guide),
              ),
      ),
    );
  }
}
