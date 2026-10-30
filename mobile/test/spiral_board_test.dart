import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/board/spiral_layout.dart';
import 'package:sapo/board/board_view.dart';
import 'package:sapo/board/board_screen.dart';
import 'package:sapo/board/dice.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';
import 'package:sapo/storage.dart';
import 'package:sapo/ui/sapo_widgets.dart';

void main() {
  for (var result = 1; result <= 6; result++) {
    test('Cubo 3D: resultado $result dominante y tres caras conectadas', () {
      final faces = DicePainter(result).projectedFaces(const Size.square(100));
      expect(faces.length, 3);
      expect(faces.last.value, result);
      expect(faces.map((f) => f.value).toSet().length, 3);
      for (final face in faces) {
        expect(DicePainter.patterns[face.value]!.length, face.value);
        expect(face.corners.length, 4);
        expect(faces.any((other) => other.value == 7 - face.value), false);
        for (final p in face.corners) {
          expect(p.dx, inInclusiveRange(0, 100));
          expect(p.dy, inInclusiveRange(0, 100));
        }
      }
      // Three adjacent planes share edges; a flat square cannot pass this.
      expect(faces.expand((f) => f.corners).toSet().length, 7);
    });
  }
  testWidgets('Dado espera, muestra resultado y luego camina sin doble toque', (
    tester,
  ) async {
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final c = container.read(appProvider.notifier),
        g = Game(['Ana', 'Luis'], 5, enabled: [1]);
    c.game = g;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(theme: sapoTheme(), home: const BoardScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('roll')));
    await tester.pump(const Duration(milliseconds: 1900));
    expect(g.rolls, 0);
    expect(g.positions[0], 0);
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('roll'))).onPressed,
      isNull,
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(g.rolls, 1);
    expect(g.positions[0], 0);
    expect(tester.widget<VisualDice>(find.byType(VisualDice)).rolling, false);
    expect(find.text('Resultado: ${g.die}'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
    expect(g.positions[0], 0);
    await tester.pump(const Duration(milliseconds: 60));
    expect(g.positions[0], 1);
    await tester.pump(const Duration(milliseconds: 250));
    expect(g.positions[0], 1);
    await tester.pumpAndSettle();
    for (var wait = 0; wait < 300 && c.working; wait++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();
    expect(g.positions[0], g.die);
    expect(g.rolls, 1);
    expect(g.pending, isNotNull);
    expect((await db.load())!.positions[0], g.die);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final viewport in [const Size(320, 568), const Size(640, 360)]) {
    testWidgets(
      'Victoria: regresar al inicio en $viewport con texto ampliado',
      (tester) async {
        tester.view.physicalSize = viewport;
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
        final g = Game(['Ana', 'Luis'], 1);
        g.positions[0] = g.goalPosition;
        container.read(appProvider.notifier).game = g;
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              theme: sapoTheme(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: const TextScaler.linear(1.6)),
                child: child!,
              ),
              home: Builder(
                builder: (context) => Scaffold(
                  body: FilledButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const BoardScreen(),
                      ),
                    ),
                    child: const Text('Inicio QA'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Inicio QA'));
        await tester.pumpAndSettle();
        expect(find.text('¡Ganó Ana!'), findsOneWidget);
        expect(
          find.text('Ana reparte 3 tragos a quien quiera.'),
          findsOneWidget,
        );
        final back = find.widgetWithText(FilledButton, 'Volver al inicio');
        await tester.ensureVisible(back);
        await tester.pumpAndSettle();
        expect(back.hitTestable(), findsOneWidget);
        await tester.tap(back);
        await tester.pumpAndSettle();
        expect(find.byType(BoardScreen), findsNothing);
        expect(find.text('Inicio QA'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  for (final size in [30, 50, 75, 100]) {
    test(
      'Espiral $size: todas las casillas únicas, adyacentes, inicio y meta conectados',
      () {
        final layout = SpiralLayout.forSize(size);
        expect(layout.path.length, size + 2);
        expect(layout.path.toSet().length, size + 2);
        expect(layout.path.first, BoardPoint(0, layout.rows - 1));
        expect(layout.path[1], BoardPoint(1, layout.rows - 1));
        expect(layout.goalCells, contains(layout.path.last));
        final regular = layout.path.sublist(1, size + 1).toSet();
        expect(regular.intersection(layout.goalCells.toSet()), isEmpty);
        var turns = 0;
        for (var i = 1; i < layout.path.length; i++) {
          expect(
            layout.path[i - 1].distanceTo(layout.path[i]),
            1,
            reason: 'No puede saltar de una fila a otra en el paso $i.',
          );
          if (i >= 2) {
            final a = layout.path[i - 2],
                b = layout.path[i - 1],
                c = layout.path[i];
            if (b.column - a.column != c.column - b.column ||
                b.row - a.row != c.row - b.row) {
              turns++;
            }
          }
        }
        expect(turns, greaterThanOrEqualTo(4));
      },
    );
    for (final viewport in [
      (const Size(384, 832), 1.0),
      (const Size(360, 640), 1.3),
      (const Size(640, 360), 1.0),
      (const Size(384, 832), 1.6),
      (const Size(320, 568), 1.0),
      (const Size(640, 360), 1.6),
    ]) {
      testWidgets(
        'Tablero completo $size, ${viewport.$1}, texto ${viewport.$2}, doce fichas',
        (tester) async {
          tester.view.physicalSize = viewport.$1;
          tester.view.devicePixelRatio = 1;
          tester.view.padding = const FakeViewPadding(top: 24, bottom: 48);
          tester.view.viewPadding = const FakeViewPadding(top: 24, bottom: 48);
          tester.platformDispatcher.textScaleFactorTestValue = viewport.$2;
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
          final c = container.read(appProvider.notifier),
              g = Game(
                List.generate(12, (i) => 'Persona ${i + 1}'),
                18,
                size: size,
              );
          if (viewport.$2 > 1) g.addRule('Regla temporal activa', 5);
          c.game = g;
          c.settings['animation'] = false;
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                theme: sapoTheme(),
                builder: (_, child) => SafeArea(top: false, child: child!),
                home: const BoardScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.byType(SpiralBoardView), findsOneWidget);
          expect(find.byKey(const Key('pawn11')), findsOneWidget);
          final boardSize = tester.getSize(find.byType(SpiralBoardView));
          expect(boardSize.width, greaterThan(0));
          expect(boardSize.height, greaterThan(0));
          await tester.ensureVisible(find.byKey(const Key('roll')));
          await tester.pumpAndSettle();
          expect(find.byKey(const Key('roll')).hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
  testWidgets(
    'Dado: figura con seis puntos, giro real y detención al terminar',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final spinning = ValueNotifier(false);
        addTearDown(spinning.dispose);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: spinning,
                  builder: (_, rolling, child) => VisualDice(
                    value: 6,
                    rolling: rolling,
                    animate: true,
                    onRoll: () => spinning.value = true,
                  ),
                ),
              ),
            ),
          ),
        );
        Finder face() => find.byWidgetPredicate(
          (w) => w is CustomPaint && w.painter is DicePainter,
        );
        final diceSemantics = find.byWidgetPredicate(
          (w) =>
              w is Semantics &&
              (w.properties.label ?? '').startsWith('Dado de seis caras.'),
        );
        expect(
          tester
              .getSemantics(diceSemantics)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          true,
        );
        expect(
          (tester.widget<CustomPaint>(face()).painter! as DicePainter).value,
          6,
        );
        await tester.tap(find.byKey(const Key('roll')));
        await tester.pump(const Duration(milliseconds: 170));
        final during =
            (tester.widget<CustomPaint>(face()).painter! as DicePainter)
                .rotation;
        expect(
          during.rotate(const DicePoint(1, 0, 0)).x,
          isNot(
            closeTo(
              DiceRotation.forValue(6).rotate(const DicePoint(1, 0, 0)).x,
              .001,
            ),
          ),
        );
        expect(
          (tester.widget<CustomPaint>(face()).painter! as DicePainter).value,
          inInclusiveRange(1, 6),
        );
        spinning.value = false;
        await tester.pumpAndSettle();
        final settled =
            tester.widget<CustomPaint>(face()).painter! as DicePainter;
        expect(settled.projectedFaces(const Size.square(90)).last.value, 6);
        expect(
          (tester.widget<CustomPaint>(face()).painter! as DicePainter).value,
          6,
        );
        await tester.pumpWidget(const SizedBox());
      } finally {
        semantics.dispose();
      }
    },
  );
  testWidgets(
    'Reto adulto largo mantiene acción disponible en pantalla pequeña',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
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
      final c = container.read(appProvider.notifier),
          g = Game(['Ana', 'Luis'], 1, enabled: [3]);
      g.pending = {
        'id': 'long',
        'category': 3,
        'text': List.filled(20, 'Un reto personalizado largo.').join(' '),
      };
      c.game = g;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: sapoTheme(), home: const BoardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      final complete = find.widgetWithText(FilledButton, 'Reto cumplido');
      await tester.ensureVisible(complete);
      await tester.pumpAndSettle();
      expect(complete.hitTestable(), findsOneWidget);
      await tester.tap(complete);
      await tester.pumpAndSettle();
      expect(g.turn, 1);
      expect(g.pending, isNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('Las N casillas se exponen numeradas, con inicio 1 y meta N', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      for (final size in [30, 50, 75, 100]) {
        final game = Game(['Ana', 'Luis'], 40, size: size);
        expect(game.positions, [0, 0]);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 380,
                height: 720,
                child: SpiralBoardView(game: game, animate: false),
              ),
            ),
          ),
        );
        final paint = tester.widget<CustomPaint>(
          find.byWidgetPredicate(
            (widget) => widget is CustomPaint && widget.painter != null,
          ),
        );
        final semanticsNodes = paint.painter!.semanticsBuilder!(
          const Size(380, 720),
        );
        final labels = semanticsNodes
            .map((node) => node.properties.label!)
            .toList();
        expect(labels, hasLength(size + 2));
        expect(labels.first, 'Casilla 1, ${categories[game.board[1]]}');
        expect(
          labels[size - 1],
          'Casilla $size, ${categories[game.board[size]]}',
        );
        expect(labels[size], 'Marcador de inicio');
        expect(labels[size + 1], 'Marcador de meta');
        for (var number = 1; number <= size; number++) {
          expect(labels[number - 1], startsWith('Casilla $number,'));
        }
        expect(game.board, hasLength(size + 2));
        expect(tester.takeException(), isNull);
      }
    } finally {
      semantics.dispose();
    }
  });
  testWidgets(
    'Comodín muestra resultado y persiste el movimiento una sola vez',
    (tester) async {
      final db = LocalRepository(NativeDatabase.memory());
      await db.prepare();
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(db)],
      );
      addTearDown(() async {
        container.dispose();
        await db.close();
      });
      final controller = container.read(appProvider.notifier);
      final game = Game(['Ana', 'Luis'], 19, size: 30);
      game.positions[0] = 4;
      game.board[4] = 5;
      game.draw([
        {
          'id': 'wildcard',
          'category': 5,
          'intensity': 1,
          'status': 'active',
          'concept': 'wildcard',
          'effect': 'advance',
          'text': 'Tremenda suerte: avanza.',
        },
      ], []);
      final result = Map<String, dynamic>.from(game.pending!);
      controller.game = game;
      controller.settings['animation'] = false;
      await controller.save();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(theme: sapoTheme(), home: const BoardScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(result['text']), findsOneWidget);
      await controller.save();
      await tester.pumpAndSettle();
      expect(game.pending, result);
      expect(game.pending!['amount'], inInclusiveRange(1, 6));
      expect(
        game.pending!['text'],
        contains('avanzas ${result['amount']} casillas'),
      );
      final button = find.widgetWithText(FilledButton, 'Aplicar evento');
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(game.positions[0], result['movementTo']);
      expect(game.movementHistory, hasLength(1));
      expect(game.movementHistory.single['from'], 4);
      expect(game.movementHistory.single['to'], result['movementTo']);
      expect(game.movementHistory.single['cause'], 'Tremenda suerte');
      expect((await db.load())!.positions[0], result['movementTo']);
      expect(game.winner, isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
