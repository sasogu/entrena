import 'package:flutter/material.dart';

import 'models.dart';
import 'progress.dart';

String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

String formatSet(WorkoutSet set) {
  if (set.isCardio) {
    return set.distanceKm > 0
        ? '${formatMinutes(set.minutes)} · ${formatDistance(set.distanceKm)}'
        : formatMinutes(set.minutes);
  }
  return set.weight > 0
      ? '${set.reps} × ${formatKg(set.weight)}'
      : '${set.reps} rep';
}

String formatSets(List<WorkoutSet> sets) => sets.map(formatSet).join('  /  ');

/// Una sesión del historial, desplegable para ver la nota y las series.
class WorkoutRecordTile extends StatelessWidget {
  const WorkoutRecordTile({super.key, required this.record});
  final WorkoutRecord record;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    leading: const CircleAvatar(child: Icon(Icons.check)),
    title: Text(
      record.routineName,
      style: const TextStyle(fontWeight: FontWeight.w700),
    ),
    subtitle: Text(formatDate(record.date)),
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
          subtitle: Text(formatSets(exercise.sets)),
        ),
      ),
    ],
  );
}

/// Fila de la lista «Por ejercicio» en la pestaña Progreso.
class ExerciseProgressTile extends StatelessWidget {
  const ExerciseProgressTile({super.key, required this.progress});
  final ExerciseProgress progress;

  @override
  Widget build(BuildContext context) {
    final sessions = progress.entries.length;
    final latest = progress.formatMetric(progress.metric(progress.latest));
    final change = sessions > 1 ? ' · ${formatChange(progress)}' : '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Icon(
          progress.isCardio
              ? Icons.directions_run
              : progress.usesWeight
              ? Icons.fitness_center
              : Icons.repeat,
          size: 20,
        ),
      ),
      title: Text(
        progress.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '$sessions ${sessions == 1 ? 'sesión' : 'sesiones'} · última: $latest$change',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExerciseProgressScreen(progress: progress),
        ),
      ),
    );
  }
}

class ExerciseProgressScreen extends StatelessWidget {
  const ExerciseProgressScreen({super.key, required this.progress});
  final ExerciseProgress progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final entries = progress.entries.reversed.toList();
    return Scaffold(
      appBar: AppBar(title: Text(progress.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: _summary(
                  'Última',
                  progress.formatMetric(progress.metric(progress.latest)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summary('Récord', progress.formatMetric(progress.best)),
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
                  Text(
                    progress.metricLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress.entries.length > 1
                        ? formatChange(progress)
                        : 'Registra otra sesión para ver la evolución.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                  if (progress.entries.length > 1) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 160,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: ProgressChartPainter(
                          values: progress.entries
                              .map(progress.metric)
                              .toList(),
                          color: colors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sesiones',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  ...entries.map(
                    (entry) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        formatDate(entry.date),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(formatSets(entry.sets)),
                      trailing: Text(
                        progress.isCardio
                            ? entry.totalDistance > 0
                                  ? 'Distancia\n${formatDistance(entry.totalDistance)}'
                                  : 'Total\n${formatMinutes(entry.totalMinutes)}'
                            : progress.usesWeight
                            ? 'Volumen\n${formatKg(entry.volume)}'
                            : 'Total\n${entry.totalReps} rep',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summary(String label, String value) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    ),
  );
}

/// Gráfica de línea sencilla, sin dependencias externas.
class ProgressChartPainter extends CustomPainter {
  ProgressChartPainter({required this.values, required this.color});
  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue == 0 ? 1.0 : maxValue - minValue;
    const padding = 8.0;
    final height = size.height - padding * 2;
    final step = (size.width - padding * 2) / (values.length - 1);

    Offset point(int index) => Offset(
      padding + step * index,
      padding + height - (values[index] - minValue) / range * height,
    );

    final grid = Paint()
      ..color = const Color(0xFFE7EAE5)
      ..strokeWidth = 1;
    for (final y in [padding, padding + height / 2, padding + height]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final path = Path()..moveTo(point(0).dx, point(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(point(i).dx, point(i).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    final dot = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), 4, dot);
    }
  }

  @override
  bool shouldRepaint(ProgressChartPainter oldDelegate) =>
      oldDelegate.values != values || oldDelegate.color != color;
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.history});
  final List<WorkoutRecord> history;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Historial')),
    body: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: history
          .map((record) => WorkoutRecordTile(record: record))
          .toList(),
    ),
  );
}
