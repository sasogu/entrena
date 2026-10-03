import 'package:entrena/exercise_guide.dart';
import 'package:entrena/exercise_guide_sheet.dart';
import 'package:entrena/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('todos los ejercicios de las rutinas tienen explicación', () {
    for (final option in routineOptions) {
      for (final exercise in option.exercises) {
        expect(
          findExerciseGuide(exercise.name),
          isNotNull,
          reason: exercise.name,
        );
      }
    }
  });

  test('cada explicación está completa', () {
    for (final guide in exerciseGuides) {
      expect(guide.muscles, isNotEmpty, reason: guide.name);
      expect(guide.steps.length, greaterThanOrEqualTo(3), reason: guide.name);
      expect(guide.mistakes, isNotEmpty, reason: guide.name);
      expect(guide.videoQuery, isNotEmpty, reason: guide.name);
    }
  });

  test('ningún nombre o alias apunta a dos ejercicios distintos', () {
    final seen = <String, String>{};
    for (final guide in exerciseGuides) {
      for (final name in [guide.name, ...guide.aliases]) {
        final key = normalizeExerciseName(name);
        expect(seen[key], isNull, reason: '$name (${guide.name})');
        seen[key] = guide.name;
      }
    }
  });

  test('busca sin tener en cuenta mayúsculas, tildes ni espacios', () {
    expect(findExerciseGuide('  JALON al   pecho ')?.name, 'Jalón al pecho');
    expect(findExerciseGuide('press banca')?.name, 'Press de banca');
    expect(findExerciseGuide('Ejercicio inventado'), isNull);
  });

  test('el enlace de vídeo es una búsqueda de YouTube', () {
    final known = exerciseVideoUri('Plancha');
    expect(known.host, 'www.youtube.com');
    expect(
      known.queryParameters['search_query'],
      'plancha abdominal técnica correcta',
    );

    final custom = exerciseVideoUri('Remo con kettlebell');
    expect(
      custom.queryParameters['search_query'],
      'Remo con kettlebell técnica correcta',
    );
  });

  testWidgets('la ficha muestra pasos, errores y el botón de vídeo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExerciseGuideView(name: 'Dead bug')),
      ),
    );
    expect(find.text('Cómo se hace'), findsOneWidget);
    expect(find.text('Errores habituales'), findsOneWidget);
    expect(find.text('Ver vídeos en YouTube'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('un ejercicio sin ficha ofrece igualmente el vídeo', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ExerciseGuideView(name: 'Remo con kettlebell')),
      ),
    );
    expect(find.textContaining('Todavía no hay explicación'), findsOneWidget);
    expect(find.text('Ver vídeos en YouTube'), findsOneWidget);
  });
}
