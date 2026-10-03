import 'package:entrena/ai/routine_ai.dart';
import 'package:entrena/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('elegir una propuesta de IA la muestra como rutina actual', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const EntrenaApp());
    await tester.pumpAndSettle();

    final state = tester.state(find.byType(HomeScreen)) as dynamic;
    final proposal = parseProposals(
      '''
{"propuestas":[{"nombre":"Fuerza con máquinas","resumen":"Guiada","por_que":"",
"ejercicios":[{"nombre":"Prensa de piernas","series":3,"repeticiones":"8-10"},
{"nombre":"Jalón al pecho","series":3,"repeticiones":"8-10"},
{"nombre":"Remo sentado en polea","series":3,"repeticiones":"8-10"}]}]}''',
    ).single;
    await state.applyProposalForTest(proposal);
    await tester.pumpAndSettle();

    // Hoy muestra los ejercicios nuevos.
    expect(find.text('Prensa de piernas'), findsOneWidget);
    expect(find.text('Sentadilla goblet'), findsNothing);

    // Rutinas muestra la rutina elegida como actual.
    await tester.tap(find.text('Rutinas'));
    await tester.pumpAndSettle();
    expect(find.text('Fuerza con máquinas'), findsWidgets);
    expect(find.text('Tu rutina actual'), findsOneWidget);
    expect(find.text('Actual'), findsNothing);
  });
}
