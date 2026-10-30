import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/catalog.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';
import 'package:sapo/screens.dart';
import 'package:sapo/storage.dart';

void main() {
  final catalog = decodeCatalog(File('assets/catalog.json').readAsStringSync());
  for (final category in [1, 3]) {
    testWidgets(
      'Contenido adulto migrado categoría $category funciona en partida',
      (tester) async {
        tester.view.physicalSize = const Size(384, 832);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final db = LocalRepository(NativeDatabase.memory());
        await db.prepare();
        final container = ProviderContainer(
          overrides: [repositoryProvider.overrideWithValue(db)],
        );
        addTearDown(() async {
          container.dispose();
          await db.close();
        });
        final c = container.read(appProvider.notifier);
        final g = Game(['Ana', 'Luis'], 7, enabled: [category], intensity: 3);
        final card = Map<String, dynamic>.from(
          catalog.firstWhere(
            (item) => item['category'] == category && item['intensity'] == 3,
          ),
        );
        g.pending = card;
        g.used = [card['id']];
        g.concepts = [card['concept']];
        c.game = g;
        await c.save();
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const BoardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          find.text(category == 1 ? 'VERDAD O SHOT' : 'RETO'),
          findsOneWidget,
        );
        expect(find.text('HOT +18'), findsNothing);
        expect(find.text('PREGUNTA HOT'), findsNothing);
        expect(find.text('RETO HOT'), findsNothing);
        final completedLabel = category == 1 ? 'Respondí' : 'Reto cumplido';
        expect(
          find.widgetWithText(FilledButton, completedLabel),
          findsOneWidget,
        );
        expect(find.text('Tomar y continuar'), findsOneWidget);
        final target = find.widgetWithText(FilledButton, completedLabel);
        await tester.ensureVisible(target);
        await tester.pumpAndSettle();
        await tester.tap(target.hitTestable());
        await tester.pumpAndSettle();
        expect(g.turn, 1);
        expect(g.pending, isNull);
        expect((await db.load())!.turn, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
