import 'dart:io';

import 'package:entrena/credits_screen.dart';
import 'package:entrena/exercise_guide.dart';
import 'package:entrena/exercise_videos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cada vídeo corresponde a una ficha y su fichero existe', () {
    final credits = File('assets/videos/CREDITS.md').readAsStringSync();
    for (final entry in exerciseVideos.entries) {
      expect(
        exerciseGuides.any((guide) => guide.name == entry.key),
        isTrue,
        reason: entry.key,
      );
      final video = entry.value;
      expect(File(video.asset).existsSync(), isTrue, reason: video.asset);
      expect(video.author, isNotEmpty, reason: entry.key);
      expect(video.licenseUrl, startsWith('https://'), reason: entry.key);
      expect(
        credits,
        contains(video.asset.split('/').last),
        reason: 'falta en CREDITS.md: ${video.asset}',
      );
    }
  });

  test('no hay vídeos en la carpeta sin créditos', () {
    final assets = exerciseVideos.values.map((video) => video.asset).toSet();
    final files = Directory('assets/videos')
        .listSync()
        .whereType<File>()
        .map((file) => file.path)
        .where((path) => path.endsWith('.mp4'));
    for (final path in files) {
      expect(assets, contains(path), reason: path);
    }
  });

  testWidgets('la pantalla de créditos lista todos los vídeos', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreditsScreen()));
    expect(find.text(exerciseVideos.keys.first), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Licencias del software'), 300);
    expect(find.text('Licencias del software'), findsOneWidget);
  });
}
