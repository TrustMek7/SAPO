import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';

import 'config_test.dart' as harness;

void main() {
  for (final landscape in [false, true]) {
    testWidgets(
      landscape
          ? 'Rotar durante configuración conserva opciones y botón de inicio'
          : 'Aumentar texto durante configuración conserva controles accesibles',
      (tester) async {
        final (db, container) = await harness.setup(tester);
        await harness.players(tester);
        if (landscape) {
          tester.view.physicalSize = const Size(640, 360);
        } else {
          tester.platformDispatcher.textScaleFactorTestValue = 1.6;
        }
        await tester.pumpAndSettle();
        await harness.key(tester, 'setupNext');
        await harness.key(tester, 'size30');
        await harness.key(tester, 'intensity2');
        await harness.tap(tester, find.text('Ninguna'));
        await harness.key(tester, 'category1');
        await harness.key(tester, 'setupNext');
        expect(
          find.byKey(const Key('startGame')).hitTestable(),
          findsOneWidget,
        );
        await harness.key(tester, 'startGame');
        expect(container.read(appProvider.notifier).game!.enabled, [1]);
        expect(tester.takeException(), isNull);
        await harness.close(tester, db, container);
      },
    );
  }
  testWidgets(
    'Límite de 12 jugadores: rechazar el 13 no bloquea una partida válida',
    (tester) async {
      final (db, container) = await harness.setup(
        tester,
        size: const Size(360, 640),
      );
      for (var i = 1; i <= 12; i++) {
        await tester.enterText(
          find.byKey(const Key('playerName')),
          'Persona $i',
        );
        await harness.key(tester, 'addPlayerInline');
      }
      await tester.enterText(find.byKey(const Key('playerName')), 'Persona 13');
      await harness.key(tester, 'addPlayerInline');
      expect(find.text('El máximo es 12 jugadores.'), findsOneWidget);
      expect(
        (container.read(appProvider.notifier).setupDraft['names'] as List)
            .length,
        12,
      );
      await tester.enterText(find.byKey(const Key('playerName')), '');
      await harness.key(tester, 'setupNext');
      await harness.key(tester, 'setupNext');
      await harness.key(tester, 'startGame');
      expect(container.read(appProvider.notifier).game!.names.length, 12);
      expect(tester.takeException(), isNull);
      await harness.close(tester, db, container);
    },
  );
  testWidgets(
    'Cancelar la configuración conserva la partida anterior y el borrador nuevo',
    (tester) async {
      final (db, container) = await harness.setup(tester);
      final c = container.read(appProvider.notifier);
      final old = Game(['Anterior A', 'Anterior B'], 99);
      c.game = old;
      await c.save();
      await harness.players(tester);
      await harness.key(tester, 'setupNext');
      await harness.key(tester, 'size75');
      await harness.key(tester, 'intensity3');
      await harness.tap(tester, find.text('Ninguna'));
      await harness.key(tester, 'category1');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect((await db.load())!.toMap(), old.toMap());
      await harness.tap(tester, find.text('Continuar partida'));
      expect(find.textContaining('Turno de Anterior A'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await harness.key(tester, 'newGame');
      expect(find.text('1. Ana'), findsOneWidget);
      await harness.key(tester, 'setupNext');
      expect(
        tester.widget<ChoiceChip>(find.byKey(const Key('size75'))).selected,
        true,
      );
      await harness.key(tester, 'setupNext');
      await harness.key(tester, 'startGame');
      expect(c.game!.names, ['Ana', 'Luis']);
      expect(c.game!.enabled, [1]);
      expect(c.game!.size, 75);
      await harness.close(tester, db, container);
    },
  );
  testWidgets('Doble toque en Comenzar crea y guarda una sola partida', (
    tester,
  ) async {
    final (db, container) = await harness.setup(tester);
    await harness.players(tester);
    await harness.key(tester, 'setupNext');
    await harness.key(tester, 'setupNext');
    final start = find.byKey(const Key('startGame'));
    expect(start.hitTestable(), findsOneWidget);
    await tester.tap(start);
    await tester.tap(start);
    await tester.pumpAndSettle();
    final c = container.read(appProvider.notifier);
    expect(c.played, 1);
    expect((await db.load())!.names, ['Ana', 'Luis']);
    expect(find.textContaining('Turno de Ana'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await harness.close(tester, db, container);
  });
}
