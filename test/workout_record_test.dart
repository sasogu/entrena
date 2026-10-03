import 'package:entrena/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la nota de la sesión se guarda y se recupera', () {
    final record = WorkoutRecord(
      date: DateTime(2026, 10, 3),
      routineName: 'Cuerpo completo A',
      exercises: const [],
      note: 'Molestia leve en el hombro',
    );

    final restored = WorkoutRecord.fromJson(record.toJson());

    expect(restored.note, 'Molestia leve en el hombro');
  });

  test('las sesiones guardadas sin nota siguen cargando', () {
    final restored = WorkoutRecord.fromJson({
      'date': '2026-09-25T10:00:00.000',
      'routineName': 'Cuerpo completo A',
      'exercises': [],
    });

    expect(restored.note, isEmpty);
  });
}
