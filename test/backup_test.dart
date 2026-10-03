import 'dart:convert';

import 'package:entrena/backup.dart';
import 'package:entrena/models.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _profile(String name, {int sessions = 1}) {
  final profile = Profile(name, workouts: sessions)
    ..goal = 'Ganar fuerza'
    ..routineName = 'Cuerpo completo B';
  profile.history = List.generate(
    sessions,
    (i) => WorkoutRecord(
      date: DateTime(2026, 10, 1 + i),
      routineName: 'Cuerpo completo B',
      exercises: const [
        LoggedExercise(
          name: 'Sentadilla',
          sets: [WorkoutSet(reps: 8, weight: 62.5)],
        ),
      ],
      note: 'Sesión $i',
    ),
  );
  return profile;
}

void main() {
  test('exportar e importar conserva perfiles, rutinas e historial', () {
    final original = [_profile('Samuel', sessions: 2), _profile('Ana')];
    final restored = decodeBackup(encodeBackup(original));

    expect(restored.map((p) => p.name), ['Samuel', 'Ana']);
    expect(restored.first.goal, 'Ganar fuerza');
    expect(restored.first.routineName, 'Cuerpo completo B');
    expect(restored.first.history, hasLength(2));
    expect(restored.first.history.last.note, 'Sesión 1');
    expect(
      restored.first.history.first.exercises.single.sets.single.weight,
      62.5,
    );
    expect(restored.first.exercises.length, original.first.exercises.length);
    expect(
      jsonEncode(restored.map((p) => p.toJson()).toList()),
      jsonEncode(original.map((p) => p.toJson()).toList()),
    );
  });

  test('el fichero lleva la marca de la app y la versión del formato', () {
    final data =
        jsonDecode(encodeBackup([_profile('Samuel')])) as Map<String, dynamic>;
    expect(data['app'], 'entrena');
    expect(data['format'], backupFormat);
  });

  test('rechaza ficheros que no son copias de Entrena', () {
    for (final text in ['hola', '[]', '{"app": "otra"}', '{}']) {
      expect(
        () => decodeBackup(text),
        throwsA(
          isA<BackupException>().having(
            (e) => e.message,
            'message',
            'El fichero no es una copia de Entrena.',
          ),
        ),
        reason: text,
      );
    }
  });

  test('rechaza copias de una versión más nueva o dañadas', () {
    expect(
      () => decodeBackup('{"app":"entrena","format":99,"profiles":[]}'),
      throwsA(isA<BackupException>()),
    );
    expect(
      () => decodeBackup('{"app":"entrena","format":1,"profiles":[{"x":1}]}'),
      throwsA(isA<BackupException>()),
    );
    expect(
      () => decodeBackup('{"app":"entrena","format":1,"profiles":[]}'),
      throwsA(isA<BackupException>()),
    );
  });

  test('añadir renombra los perfiles con nombre repetido', () {
    final merged = mergeProfiles(
      [_profile('Samuel'), _profile('Samuel (2)')],
      [_profile('Samuel', sessions: 3), _profile('Ana')],
    );

    expect(merged.map((p) => p.name), [
      'Samuel',
      'Samuel (2)',
      'Samuel (3)',
      'Ana',
    ]);
    expect(merged[2].history, hasLength(3));
    expect(sessionCount(merged), 1 + 1 + 3 + 1);
  });

  test('el nombre del fichero lleva la fecha', () {
    expect(backupFileName(DateTime(2026, 10, 3)), 'entrena-2026-10-03.json');
  });
}
