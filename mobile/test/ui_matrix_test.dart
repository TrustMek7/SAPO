import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';
import 'package:sapo/board/board_view.dart';

import 'config_test.dart' as harness;
import 'config_matrix_test.dart' as matrix;

void main() {
  const expected = 372;
  const output = 'build/qa_ui_matrix_v114.csv';
  testWidgets(
    'UI exhaustiva: las 372 combinaciones de la configuración unificada',
    (tester) async {
      WidgetController.hitTestWarningShouldBeFatal = true;
      final (db, container) = await harness.setup(tester);
      await harness.players(tester);
      await harness.key(tester, 'setupNext');
      final csv = StringBuffer(
        'case,mask,size,profile,intensity,enabled,result,renderer\n',
      );
      var completed = 0, currentMask = 31;
      Future<void> touch(Finder finder) async {
        if (finder.evaluate().isNotEmpty &&
            finder.hitTestable().evaluate().isEmpty) {
          await tester.ensureVisible(finder);
          await tester.pumpAndSettle();
        }
        if (finder.hitTestable().evaluate().isEmpty) {
          await tester.scrollUntilVisible(
            finder,
            250,
            scrollable: find
                .descendant(
                  of: find.byType(ListView).first,
                  matching: find.byType(Scrollable),
                )
                .first,
            maxScrolls: 40,
          );
          await tester.pumpAndSettle();
        }
        expect(finder.hitTestable(), findsOneWidget);
        await tester.tap(finder.hitTestable());
        await tester.pumpAndSettle();
      }

      Future<void> select(String key) async {
        final finder = find.byKey(Key(key));
        if (finder.evaluate().isNotEmpty &&
            tester.widget<ChoiceChip>(finder).selected) {
          return;
        }
        await harness.key(tester, key);
      }

      for (var intensity = 1; intensity <= 3; intensity++) {
        final profile = [
          'Tranqui',
          'Equilibrado',
          'Sin vergüenza',
        ][intensity - 1];
        for (final size in [30, 50, 75, 100]) {
          for (var gray = 1; gray < 32; gray++) {
            final mask = gray ^ (gray >> 1),
                enabled = matrix.maskCategories(mask);
            final reason =
                'UI #${completed + 1}: mask=$mask $size $profile intensidad=$intensity';
            await select('intensity$intensity');
            await select('size$size');
            expect(find.byKey(const Key('profile')), findsNothing);
            final changed = currentMask ^ mask;
            for (var bit = 0; bit < 5; bit++) {
              if (changed & (1 << bit) != 0) {
                await harness.key(tester, 'category${playableCategories[bit]}');
              }
            }
            currentMask = mask;
            await harness.key(tester, 'setupNext');
            expect(
              find.byKey(const Key('startGame')).hitTestable(),
              findsOneWidget,
              reason: reason,
            );
            expect(
              tester.getBottomRight(find.byKey(const Key('startGame'))).dy,
              lessThanOrEqualTo(784),
              reason: reason,
            );
            await harness.key(tester, 'startGame');
            final g = container.read(appProvider.notifier).game!;
            expect(
              find.byType(SpiralBoardView),
              findsOneWidget,
              reason: reason,
            );
            expect(g.names, ['Ana', 'Luis'], reason: reason);
            expect(g.size, size, reason: reason);
            expect(g.intensity, intensity, reason: reason);
            expect(g.profile, profile, reason: reason);
            expect(g.enabled, enabled, reason: reason);
            expect(g.board.length, size + 2, reason: reason);
            expect(
              g.board.sublist(1, size + 1).toSet(),
              enabled.toSet(),
              reason: reason,
            );
            expect((await db.load())!.toMap(), g.toMap(), reason: reason);
            if (mask == 1 || mask == 4) {
              await touch(find.byKey(const Key('roll')));
              for (
                var wait = 0;
                wait < 300 && container.read(appProvider.notifier).working;
                wait++
              ) {
                await tester.pump(const Duration(milliseconds: 50));
              }
              await tester.pumpAndSettle();
              final card = g.pending!;
              expect(card['category'], mask == 4 ? 3 : 1, reason: reason);
              expect(
                card['intensity'],
                lessThanOrEqualTo(intensity),
                reason: reason,
              );
              final action = card['category'] == 3
                  ? 'Reto cumplido'
                  : 'Respondí';
              await touch(find.widgetWithText(FilledButton, action));
              expect(g.turn, 1, reason: reason);
            }
            expect(tester.takeException(), isNull, reason: reason);
            completed++;
            csv.writeln(
              '$completed,$mask,$size,$profile,$intensity,${enabled.join('|')},ok,cube3d-start-cell',
            );
            await tester.pageBack();
            await tester.pumpAndSettle();
            if (gray == 31) {
              File(output).writeAsStringSync(csv.toString());
              debugPrint(
                'QA UI: $completed / $expected configuraciones unificadas comprobadas.',
              );
            }
            if (completed < expected) {
              await harness.key(tester, 'newGame');
              await harness.key(tester, 'setupNext');
            }
          }
        }
      }
      expect(completed, expected);
      expect(container.read(appProvider.notifier).played, expected);
      File(output).writeAsStringSync(csv.toString());
      await harness.close(tester, db, container);
    },
    timeout: const Timeout(Duration(minutes: 45)),
    tags: ['exhaustive-ui'],
  );
}
