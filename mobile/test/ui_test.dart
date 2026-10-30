import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:sapo/app.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/storage.dart';

void main() {
  testWidgets('Inicio, registro, edición, borrado, reordenamiento y partida', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(384, 832);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(db)],
    );
    await tester.runAsync(
      () => container.read(appProvider.notifier).initialize(),
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const SapoApp()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('confirmAdult')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('newGame')));
    await tester.pumpAndSettle();
    for (final name in ['Ana', 'Luis', 'Sol']) {
      await tester.enterText(find.byKey(const Key('playerName')), name);
      await tester.tap(find.byKey(const Key('addPlayer')));
      await tester.pumpAndSettle();
    }
    await tester.scrollUntilVisible(
      find.byKey(const Key('player0')),
      160,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('setupScroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    expect(find.text('1. Ana'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('player2')),
      180,
      scrollable: find
          .descendant(
            of: find.byKey(const Key('setupScroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('player2')),
        matching: find.byTooltip('Subir'),
      ),
    );
    await tester.pumpAndSettle();
    expect(container.read(appProvider.notifier).setupDraft['names'], [
      'Ana',
      'Sol',
      'Luis',
    ]);
    await tester.ensureVisible(find.byKey(const Key('player1')));
    await tester.pumpAndSettle();
    expect(find.text('2. Sol'), findsOneWidget);
    await tester.ensureVisible(find.text('2. Sol'));
    await tester.tap(find.text('2. Sol'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('editPlayerName')), 'Luna');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();
    expect(find.text('2. Luna'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('Eliminar').last);
    await tester.tap(find.byTooltip('Eliminar').last);
    await tester.pumpAndSettle();
    expect(find.text('3. Luis'), findsNothing);
    await tester.tap(find.byKey(const Key('setupNext')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('setupNext')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('startGame')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Turno de Ana'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await db.close();
  });
}
