import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sapo/main.dart' as app;
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';
import 'package:sapo/screens.dart';
import 'package:sapo/board/board_view.dart';
import 'package:sapo/board/dice.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetController.hitTestWarningShouldBeFatal = true;
  testWidgets(
    'Samsung: 12 configuraciones, edición, retrocesos, intensidades y reanudación',
    (tester) async {
      await app.main();
      await tester.pumpAndSettle();
      final c = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)),
        listen: false,
      ).read(appProvider.notifier);
      Future<void> touch(Finder finder) async {
        if (finder.evaluate().isNotEmpty) {
          await tester.ensureVisible(finder);
          await tester.pumpAndSettle();
        }
        if (finder.hitTestable().evaluate().isEmpty) {
          final list =
              find.byKey(const Key('setupScroll')).evaluate().isNotEmpty
              ? find.byKey(const Key('setupScroll'))
              : find.byType(ListView).first;
          await tester.scrollUntilVisible(
            finder,
            220,
            scrollable: find
                .descendant(of: list, matching: find.byType(Scrollable))
                .first,
            maxScrolls: 40,
          );
          await tester.pumpAndSettle();
        }
        expect(finder.hitTestable(), findsOneWidget);
        for (var i = 0; i < 100; i++) {
          final widget = tester.widget(finder);
          if (widget is! ButtonStyleButton || widget.onPressed != null) break;
          await tester.pump(const Duration(milliseconds: 50));
        }
        final widget = tester.widget(finder);
        if (widget is ButtonStyleButton) expect(widget.onPressed, isNotNull);
        await tester.tap(finder.hitTestable());
        await tester.pumpAndSettle();
      }

      Future<void> key(String value) => touch(find.byKey(Key(value)));
      Future<void> button(String label) =>
          touch(find.widgetWithText(TextButton, label));
      if (find.byKey(const Key('confirmAdult')).evaluate().isNotEmpty) {
        await touch(find.byKey(const Key('confirmAdult')));
      }
      await key('newGame');
      await key('setupNext');
      expect(
        find.text('Agrega al menos 2 jugadores para continuar.'),
        findsOneWidget,
      );
      for (final name in ['Ana QA', 'Luis QA', 'Temporal QA']) {
        await tester.enterText(find.byKey(const Key('playerName')), name);
        await key('addPlayerInline');
      }
      await touch(find.text('2. Luis QA'));
      await tester.enterText(
        find.byKey(const Key('editPlayerName')),
        'Luis QA editado',
      );
      await touch(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('🦁'),
        ),
      );
      await touch(find.widgetWithText(FilledButton, 'Guardar'));
      await touch(
        find.descendant(
          of: find.byKey(const Key('player2')),
          matching: find.byTooltip('Subir'),
        ),
      );
      await touch(
        find.descendant(
          of: find.byKey(const Key('player1')),
          matching: find.byTooltip('Eliminar'),
        ),
      );
      expect(c.setupDraft['names'], ['Ana QA', 'Luis QA editado']);
      await key('setupNext');
      const profiles = ['Tranqui', 'Equilibrado', 'Sin vergüenza'];
      const masks = [31, 16, 15, 17, 1, 3, 31, 16, 15, 17, 1, 3];
      for (var index = 0; index < 12; index++) {
        final intensity = index % 3 + 1,
            size = [30, 50, 75, 100][index % 4],
            profile = profiles[index % 3],
            mask = masks[index];
        final enabled = [
          for (var bit = 0; bit < 5; bit++)
            if (mask & (1 << bit) != 0) playableCategories[bit],
        ];
        await key('intensity$intensity');
        await key('size$size');
        expect(find.byKey(const Key('profile')), findsNothing);
        await button('Ninguna');
        await key('setupNext');
        expect(
          find.text('Activa al menos una categoría para continuar.'),
          findsOneWidget,
        );
        if (mask == 31) {
          await button('Todas');
        } else {
          for (final cat in enabled) {
            await key('category$cat');
          }
        }
        await key('setupNext');
        await key('setupStep1');
        expect(
          tester
              .widget<ChoiceChip>(find.byKey(Key('intensity$intensity')))
              .selected,
          true,
        );
        expect(
          tester.widget<ChoiceChip>(find.byKey(Key('size$size'))).selected,
          true,
        );
        await key('setupNext');
        await key('startGame');
        for (
          var wait = 0;
          wait < 200 && find.byKey(const Key('roll')).evaluate().isEmpty;
          wait++
        ) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        expect(
          find.byKey(const Key('roll')),
          findsOneWidget,
          reason: 'La creación debe terminar y abrir el tablero.',
        );
        final g = c.game!;
        expect(find.byType(SpiralBoardView), findsOneWidget);
        expect(find.byType(VisualDice), findsOneWidget);
        expect(g.names, ['Ana QA', 'Luis QA editado']);
        expect(g.icons[1], '🦁');
        expect(g.size, size);
        expect(g.intensity, intensity);
        expect(g.profile, profile);
        expect(g.enabled, enabled);
        expect(g.board.length, size + 2);
        expect(g.board.sublist(1, size + 1).toSet(), enabled.toSet());
        expect((await c.repository.load())!.toMap(), g.toMap());
        await key('roll');
        for (var wait = 0; wait < 300 && c.working; wait++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();
        final face = find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is DicePainter,
        );
        expect(
          (tester.widget<CustomPaint>(face).painter! as DicePainter).value,
          g.die,
        );
        expect(g.pending, isNotNull);
        expect(enabled, contains(g.pending!['category']));
        expect(g.pending!['intensity'], lessThanOrEqualTo(intensity));
        final hadMiniGame = g.pending!['kind'] != null;
        if (hadMiniGame) {
          await touch(find.widgetWithText(FilledButton, 'Abrir dinámica'));
          expect(find.byKey(const Key('finishMiniGame')), findsOneWidget);
          await touch(find.byKey(const Key('finishMiniGame')));
          expect(g.pending, isNull);
        }
        if (!hadMiniGame) {
          final card = g.pending!;
          final cardAction = switch (card['category']) {
            1 => 'Respondí',
            2 || 4 => 'Finalizar dinámica',
            3 => 'Reto cumplido',
            5 => 'Aplicar evento',
            _ => fail('Categoría inesperada: ${card['category']}'),
          };
          await touch(find.widgetWithText(FilledButton, cardAction));
        }
        expect(g.turn, inInclusiveRange(0, g.names.length - 1));
        if (hadMiniGame) expect(g.turn, 1);
        final activePlayerAfterTurn = g.names[g.turn];
        await tester.pageBack();
        await tester.pumpAndSettle();
        await touch(find.widgetWithText(FilledButton, 'Continuar partida'));
        expect(
          find.textContaining('Turno de $activePlayerAfterTurn'),
          findsOneWidget,
        );
        await tester.pageBack();
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        debugPrint('Samsung QA: configuración ${index + 1}/12 verificada.');
        if (index < 11) {
          await key('newGame');
          expect(find.text('1. Ana QA'), findsOneWidget);
          await key('setupNext');
        }
      }
      await touch(find.widgetWithText(FilledButton, 'Ajustes y contenido'));
      final oldSound = c.settings['sound'];
      await touch(find.byType(SwitchListTile).first);
      expect(c.settings['sound'], !oldSound);
      await touch(find.text('Reiniciar historial'));
      expect(find.text('¿Borrar el historial entre partidas?'), findsOneWidget);
      await button('Cancelar');
      await touch(find.byType(DropdownButton<int>).first);
      await touch(find.text('Reto').last);
      final customText =
          'Reto QA ${DateTime.now().microsecondsSinceEpoch}: inventa un título coqueto para una cita.';
      final previousCustom = c.custom.length;
      await tester.enterText(find.byType(TextField), customText);
      await touch(find.widgetWithText(FilledButton, 'Guardar contenido'));
      expect(c.custom.last['category'], 3);
      expect(c.custom.length, previousCustom + 1);
      expect(c.custom.last.containsKey('type'), isFalse);
      final stored =
          jsonDecode((await c.repository.readValue('custom'))!) as List;
      expect(stored.last['text'], c.custom.last['text']);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await touch(find.widgetWithText(FilledButton, 'Ajustes y contenido'));
      await touch(find.text(customText));
      expect(find.text('Guardar cambios'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    timeout: const Timeout(Duration(minutes: 20)),
  );
}
