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
    await state.applyProposalForTest(proposal, 'Ganar fuerza');
    await tester.pumpAndSettle();

    // Tras elegirla, se abre Rutinas con la rutina nueva como actual.
    NavigationBar bar() => tester.widget(find.byType(NavigationBar));
    expect(bar().selectedIndex, 1);
    expect(find.text('Tu rutina actual'), findsOneWidget);
    expect(find.text('Fuerza con máquinas'), findsOneWidget);
    // El objetivo usado para pedir la propuesta pasa al perfil.
    expect(find.text('Objetivo: Ganar fuerza'), findsWidgets);

    // Hoy muestra los ejercicios nuevos.
    await tester.tap(find.text('Hoy').last);
    await tester.pumpAndSettle();
    expect(find.text('Prensa de piernas').hitTestable(), findsOneWidget);
    expect(find.text('Sentadilla goblet').hitTestable(), findsNothing);
  });
}
