import 'package:entrena/ai/ai_client.dart';
import 'package:entrena/ai/ai_screens.dart';
import 'package:entrena/ai/ai_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Evita el almacén cifrado de Android, que no existe en los tests.
class _FakeStore extends AiSettingsStore {
  @override
  Future<AiSettings> load() => loadFor(AiProvider.claude);

  @override
  Future<AiSettings> loadFor(AiProvider provider) async => AiSettings(
    provider: provider,
    model: provider.defaultModel,
    apiKey: null,
    consented: false,
  );
}

Future<void> _pump(WidgetTester tester, String goal) async {
  SharedPreferences.setMockInitialValues({});
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.5;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      home: RoutineAiScreen(
        goal: goal,
        historySummary: 'Sin sesiones registradas.',
        onApply: (_, _) async {},
        store: _FakeStore(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('se puede cambiar el objetivo en la pantalla de la IA', (
    tester,
  ) async {
    await _pump(tester, 'Ganar fuerza');
    expect(find.text('Ganar fuerza'), findsOneWidget);

    await tester.tap(find.text('Ganar fuerza'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Perder grasa').last);
    await tester.pumpAndSettle();
    expect(find.text('Perder grasa'), findsOneWidget);
    expect(find.text('Ganar fuerza'), findsNothing);
  });

  testWidgets('un objetivo propio aparece como «Escribir otro objetivo»', (
    tester,
  ) async {
    await _pump(tester, 'Preparar una ruta de montaña');
    expect(find.text('Escribir otro objetivo'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Preparar una ruta de montaña'),
      findsOneWidget,
    );
  });
}
