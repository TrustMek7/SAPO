import 'package:drift/native.dart';
import 'package:flutter/material.dart';

import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/app.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';
import 'package:sapo/screens.dart';
import 'package:sapo/storage.dart';

Future<(LocalRepository, ProviderContainer)> setup(
  WidgetTester tester, {
  Size size = const Size(384, 832),
  double scale = 1,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
  tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
  tester.platformDispatcher.textScaleFactorTestValue = scale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  final db = LocalRepository(NativeDatabase.memory());
  await db.prepare();
  final container = ProviderContainer(
    overrides: [repositoryProvider.overrideWithValue(db)],
  );
  addTearDown(() async {
    container.dispose();
    await db.close();
  });
  await tester.runAsync(
    () => container.read(appProvider.notifier).initialize(),
  );
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const SapoApp()),
  );
  await tester.pumpAndSettle();
  await tap(tester, find.byKey(const Key('confirmAdult')));
  await tap(tester, find.byKey(const Key('newGame')));
  return (db, container);
}

Future<void> visible(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty && finder.hitTestable().evaluate().isEmpty) {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }
  if (finder.hitTestable().evaluate().isEmpty) {
    final scrollable = find.byType(Scrollable).first;
    await tester.fling(scrollable, const Offset(0, 2000), 8000);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      finder,
      220,
      scrollable: scrollable,
      maxScrolls: 40,
    );
    await tester.pumpAndSettle();
  }
  expect(
    finder.hitTestable(),
    findsOneWidget,
    reason: 'El control debe poder tocarse, sin alterar su estado por código.',
  );
}

Future<void> tap(WidgetTester tester, Finder finder) async {
  await visible(tester, finder);
  await tester.tap(finder.hitTestable());
  await tester.pumpAndSettle();
}

Future<void> key(WidgetTester tester, String value) =>
    tap(tester, find.byKey(Key(value)));
Future<void> players(WidgetTester tester) async {
  for (final name in ['Ana', 'Luis']) {
    await tester.enterText(find.byKey(const Key('playerName')), name);
    await key(tester, 'addPlayerInline');
  }
  expect(find.text('Siguiente jugador'), findsOneWidget);
  await visible(tester, find.byKey(const Key('addPlayer')));
  expect(find.text('Agregar otro'), findsOneWidget);
  await visible(tester, find.byKey(const Key('playerName')));
}

Future<void> close(
  WidgetTester tester,
  LocalRepository db,
  ProviderContainer container,
) async {
  await tester.pumpWidget(const SizedBox());
}

void main() {
  WidgetController.hitTestWarningShouldBeFatal = true;
  for (final screen in [
    (const Size(360, 640), 1.0),
    (const Size(384, 832), 1.3),
  ]) {
    testWidgets(
      'Configuración completa y errores en ${screen.$1} escala ${screen.$2}',
      (tester) async {
        final (db, container) = await setup(
          tester,
          size: screen.$1,
          scale: screen.$2,
        );
        await key(tester, 'setupNext');
        expect(
          find.text('Agrega al menos 2 jugadores para continuar.'),
          findsOneWidget,
        );
        await players(tester);
        await key(tester, 'setupNext');
        await key(tester, 'intensity3');
        await key(tester, 'size30');
        expect(find.byKey(const Key('profile')), findsNothing);
        await tap(tester, find.text('Ninguna'));
        await key(tester, 'setupNext');
        expect(
          find.text('Activa al menos una categoría para continuar.'),
          findsOneWidget,
        );
        expect(container.read(appProvider.notifier).game, isNull);
        await key(tester, 'category1');
        await key(tester, 'setupNext');
        expect(
          find.byKey(const Key('startGame')).hitTestable(),
          findsOneWidget,
        );
        expect(
          tester.getBottomRight(find.byKey(const Key('startGame'))).dy,
          lessThanOrEqualTo(screen.$1.height - 48),
        );
        await key(tester, 'startGame');
        final g = container.read(appProvider.notifier).game!;
        expect(g.size, 30);
        expect(g.intensity, 3);
        expect(g.profile, 'Sin vergüenza');
        expect(g.enabled, [1]);
        expect(g.board.sublist(1, 31).toSet(), {1});
        expect((await db.load())!.toMap(), g.toMap());
        expect(tester.takeException(), isNull);
        await close(tester, db, container);
      },
    );
  }
  testWidgets('Volver entre pasos y salir conserva jugadores y opciones', (
    tester,
  ) async {
    final (db, container) = await setup(tester);
    await players(tester);
    await key(tester, 'setupNext');
    await key(tester, 'intensity2');
    await key(tester, 'size75');
    expect(find.byKey(const Key('profile')), findsNothing);
    await key(tester, 'setupNext');
    await key(tester, 'setupStep1');
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('intensity2'))).selected,
      true,
    );
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('size75'))).selected,
      true,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('1. Ana'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('newGame')), findsOneWidget);
    await key(tester, 'newGame');
    await visible(tester, find.byKey(const Key('player1')));
    expect(find.text('2. Luis'), findsOneWidget);
    await key(tester, 'setupNext');
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('size75'))).selected,
      true,
    );
    await key(tester, 'setupNext');
    await key(tester, 'startGame');
    expect(container.read(appProvider.notifier).game!.profile, 'Equilibrado');
    await close(tester, db, container);
  });
  testWidgets(
    'Teclado abierto permite agregar nombres y acceder al botón fijo',
    (tester) async {
      final (db, container) = await setup(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      tester.view.padding = const FakeViewPadding(top: 24);
      await tester.pumpAndSettle();
      await players(tester);
      expect(find.byKey(const Key('setupNext')).hitTestable(), findsOneWidget);
      expect(
        tester.getBottomRight(find.byKey(const Key('setupNext'))).dy,
        lessThanOrEqualTo(532),
      );
      await key(tester, 'setupNext');
      expect(find.byKey(const Key('intensity')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await close(tester, db, container);
    },
  );
  testWidgets('Nombres duplicados y edición inválida no cambian el orden', (
    tester,
  ) async {
    final (db, container) = await setup(tester);
    await players(tester);
    await tester.enterText(find.byKey(const Key('playerName')), ' ana ');
    await key(tester, 'addPlayerInline');
    expect(find.text('Ese nombre ya está en la lista.'), findsOneWidget);
    await tester.enterText(find.byKey(const Key('playerName')), '');
    await tap(tester, find.text('2. Luis'));
    await tester.enterText(find.byKey(const Key('editPlayerName')), 'Ana');
    await tap(tester, find.text('Guardar'));
    expect(find.text('Usa un nombre diferente y no vacío.'), findsOneWidget);
    await tap(tester, find.text('Cancelar'));
    expect(find.text('2. Luis'), findsOneWidget);
    await close(tester, db, container);
  });
  testWidgets('Tablero legible a 360 px con doce fichas en una casilla', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(db)],
    );
    container.read(appProvider.notifier).game = Game(
      List.generate(12, (i) => 'Participante ${i + 1}'),
      42,
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: ThemeData.dark(), home: const BoardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await close(tester, db, container);
  });
  test(
    'Controlador serializa doble toque y cuenta una sola victoria',
    () async {
      final db = LocalRepository(NativeDatabase.memory());
      await db.prepare();
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(db)],
      );
      final c = container.read(appProvider.notifier);
      c.settings = {'sound': false, 'vibration': false, 'animation': false};
      var seed = 0;
      while (Random(seed).nextInt(6) + 1 != 1) {
        seed++;
      }
      c.game = Game(['Ana', 'Luis'], seed)..positions[0] = 50;
      await Future.wait([c.roll(), c.roll()]);
      expect(c.game!.rolls, 1);
      expect(c.game!.winner, 0);
      expect(c.victories, 1);
      await c.roll();
      await c.finish();
      expect(c.victories, 1);
      container.dispose();
      await db.close();
    },
  );
}
