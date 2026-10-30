import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:playing_cards/playing_cards.dart';
import 'package:sapo/controller.dart';
import 'package:sapo/game.dart';
import 'package:sapo/minigame.dart';
import 'package:sapo/storage.dart';

void main() {
  testWidgets('Finalizar minijuego cierra la tarjeta y pasa el turno', (
    tester,
  ) async {
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(db)],
    );
    final game = Game(['Ana', 'Luis'], 13)
      ..pending = {'id': 'mini-finish', 'text': 'Yo nunca', 'category': 4};
    container.read(appProvider.notifier).game = game;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (_) =>
                      const MiniGameScreen(kind: 'never', embedded: true),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    await tester.tap(find.text('Finalizar dinámica'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir'), findsOneWidget);
    expect(game.pending, isNull);
    expect(game.turn, 1);
    expect(tester.takeException(), isNull);
    container.dispose();
    await db.close();
  });

  testWidgets('Oracion resuelta solo permite aceptar y cerrar el juego', (
    tester,
  ) async {
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final container = ProviderContainer(
      overrides: [repositoryProvider.overrideWithValue(db)],
    );
    final game = Game(['Ana', 'Luis', 'Sol'], 1)
      ..pending = {
        'id': 'sentence-resolved',
        'text': 'Oracion',
        'category': 4,
        'kind': 'sentence',
        'mini': {
          'step': 1,
          'round': 1,
          'phase': 1,
          'player': 1,
          'answers': <String>[],
          'sentence': 'hola',
          'result': '',
          'rival': 1,
          'card': 1,
          'suit': 0,
          'total': 0,
          'selectedCard': 1,
          'target': 1,
          'culture': 'Marcas de autos',
        },
      };
    container.read(appProvider.notifier).game = game;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MiniGameScreen(kind: 'sentence'),
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'otra');
    await tester.tap(find.text('Verificar y pasar'));
    await tester.pumpAndSettle();
    expect(find.text('Aceptar y cerrar el juego'), findsOneWidget);
    expect(find.textContaining('Acusar a'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('Finalizar'), findsNothing);
    await tester.tap(find.text('Aceptar y cerrar el juego'));
    await tester.pumpAndSettle();
    expect(find.text('Abrir'), findsOneWidget);
    expect(game.pending, isNull);
    expect(game.turn, 1);
    expect(tester.takeException(), isNull);
    container.dispose();
    await db.close();
  });

  testWidgets('Galería permite abrir y cerrar las trece pruebas sin guardar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MiniGameReviewScreen())),
    );
    for (final entry in MiniGameReviewScreen.games) {
      await tester.ensureVisible(find.text(entry.$2));
      await tester.tap(find.text(entry.$2));
      await tester.pumpAndSettle();
      expect(find.textContaining('Modo de prueba'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('Probar minijuegos'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('La galeria permite revisar retos sin registrar resultados', (
    tester,
  ) async {
    const challenge = {
      'id': 'review_challenge',
      'category': 3,
      'intensity': 2,
      'theme': 'coqueteo',
      'text': 'Improvisa un brindis coqueto.',
    };
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: MiniGameReviewScreen(challenges: [challenge])),
      ),
    );
    await tester.drag(find.byType(ListView), const Offset(0, -5000));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Improvisa un brindis coqueto.'));
    await tester.tap(find.text('Improvisa un brindis coqueto.'));
    await tester.pumpAndSettle();
    expect(find.text('INTENSIDAD 2'), findsOneWidget);
    expect(find.text('Tema: coqueteo'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(
      find.text('Retos del catálogo (incluye retos individuales)'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final kind in [
    'never',
    'lemon',
    'duck',
    'culture',
    'replace',
    'sentence',
    'bomb',
    'president',
    'forbidden',
    '21',
    'cards',
    'todito',
    'parity',
  ]) {
    testWidgets('Dinámica jugable y guardada: $kind', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = LocalRepository(NativeDatabase.memory());
      await db.prepare();
      final container = ProviderContainer(
        overrides: [repositoryProvider.overrideWithValue(db)],
      );
      final c = container.read(appProvider.notifier);
      final testGame = Game(['Ana', 'Luis', 'Sol'], 1);
      if (kind == 'lemon') testGame.turn = 2;
      c.game = testGame;
      c.game!.pending = {
        'id': 'test_$kind',
        'text': kind,
        'kind': kind,
        'category': 4,
      };
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData.dark(),
            home: MiniGameScreen(kind: kind),
          ),
        ),
      );
      await tester.pump();
      Future<void> tap(String text) async {
        await tester.ensureVisible(find.text(text));
        await tester.tap(find.text(text));
        await tester.pumpAndSettle();
      }

      Future<void> enter(String text) async {
        await tester.enterText(find.byType(TextField), text);
      }

      Map<String, dynamic> getMini() => c.game!.pending!['mini'];
      switch (kind) {
        case 'never':
          expect(find.textContaining('Di una frase'), findsOneWidget);
          await c.save();
        case 'lemon':
          expect(find.text('Sol'), findsOneWidget);
          expect(find.byType(DropdownButton<int>), findsNothing);
          expect(find.text('Pasar a Luis'), findsNothing);
          expect(find.text('Tu número fijo: 1'), findsOneWidget);
          expect(
            find.textContaining('Cada persona conserva su número'),
            findsOneWidget,
          );
          await tap('Luis');
          expect(getMini()['player'], 1);
          expect(getMini()['step'], 2);
          expect(find.text('Tu número fijo: 3'), findsOneWidget);
          await tap('Ana');
          expect(getMini()['step'], 3);
          expect(find.text('Tu número fijo: 2'), findsOneWidget);
          expect(find.text('2 limón, medio limón, ___ limón.'), findsOneWidget);
        case 'duck':
          expect(find.text('Ronda 1'), findsOneWidget);
          expect(
            find.textContaining('El pato es una secuencia acumulativa'),
            findsOneWidget,
          );
          expect(
            find.textContaining('Ejemplo de la primera ronda'),
            findsOneWidget,
          );
          await tap('Pasar');
          await tap('Fallé');
          expect(getMini()['result'], 'Fallaste. Toma.');
        case 'culture':
          await enter('Abogado');
          await tap('Registrar y pasar');
          expect(getMini()['answers'], ['Abogado']);
          expect(find.textContaining('Ya dichos'), findsNothing);
          await enter('ABOGAD');
          await tap('Registrar y pasar');
          expect(find.byType(AlertDialog), findsOneWidget);
          await tester.tap(find.text('Aceptar'));
          await tester.pumpAndSettle();
          expect(getMini()['result'], contains('Fallaste'));
        case 'replace':
          for (var count = 1; count <= 10; count++) {
            await enter(count.toString());
            await tap('Validar y pasar');
          }
          expect(getMini()['round'], 2);
          await enter('papá');
          await tap('Guardar regla');
          expect(getMini()['replacementNumber'], 2);
          expect(getMini()['replacementWord'], 'papá');
          await enter('1 papa 3 4 5 6 7 8 9 10');
          await tap('Validar y pasar');
          expect(getMini()['player'], 1);
          await enter('1 papa 3 4 5 6 7 8 9');
          await tap('Validar y pasar');
          expect(getMini()['result'], contains('Fallaste'));
        case 'sentence':
          await enter('hola');
          await tap('Verificar y pasar');
          expect(getMini()['sentence'], 'hola');
          expect(getMini()['player'], 1);
          expect(find.text('hola'), findsNothing);
          await enter('hola mi');
          await tap('Verificar y pasar');
          expect(getMini()['sentence'], 'hola mi');
          expect(getMini()['player'], 2);
          await enter('hola alguien');
          await tap('Verificar y pasar');
          expect(getMini()['sentenceResolved'], true);
          expect(getMini()['result'], contains('Fallaste'));
          expect(getMini()['result'], contains('hola'));
          expect(find.text('Aceptar y cerrar el juego'), findsOneWidget);
        case 'bomb':
          final before = DateTime.now().millisecondsSinceEpoch;
          await tap('Activar bomba');
          final deadline = getMini()['deadline'] as int;
          expect(deadline, greaterThanOrEqualTo(before + 20000));
          expect(
            deadline,
            lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch + 45000),
          );
          await tap('Recibido: siguiente jugador');
          expect(getMini()['player'], 1);
        case 'president':
          await enter('Hablar con rima');
          await tap('Activar regla');
          expect(c.game!.rules.single['text'], 'Hablar con rima');
          expect(c.game!.rules.single['remaining'], inInclusiveRange(1, 5));
          expect(getMini()['result'], 'Regla activa. Vuelve al tablero.');
          expect(c.game!.rules.length, 1);
        case 'forbidden':
          await enter('sapo');
          await tap('Activar regla');
          expect(c.game!.rules.single['text'], contains('sapo'));
        case '21':
          expect(find.textContaining('Total:'), findsNothing);
          expect(find.byType(DropdownButton<int>), findsNothing);
          await tap('Voltear carta');
          expect(getMini()['total'], greaterThan(0));
          expect(getMini()['revealed'], true);
          expect(find.textContaining('Total:'), findsNothing);
          await tap('Ocultar y pasar el celular');
          expect(getMini()['player'], 1);
          expect(getMini()['revealed'], false);
          expect(find.textContaining('Total:'), findsNothing);
        case 'cards':
          expect(find.byType(PlayingCardView), findsWidgets);
          await tap('Voltear carta');
          expect(getMini()['revealed'], true);
          await tap('La siguiente sera mayor');
          expect(getMini()['result'], isNotEmpty);
          expect(find.textContaining('Total:'), findsNothing);
        case 'todito':
          await tap('Sortear');
          expect(getMini()['result'], isNotEmpty);
        case 'parity':
          await tap('2');
          expect(getMini()['first'], 2);
          await tap('3');
          expect(getMini()['result'], contains('Suma: 5. Pierde Ana'));
      }
      final saved = await db.load();
      expect(saved, isNotNull);
      expect(saved!.pending!['mini'], getMini());
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
      await db.close();
    });
  }
}
