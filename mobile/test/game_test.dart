import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:sapo/game.dart';
import 'package:sapo/storage.dart';

void main() {
  final catalog = List<Map<String, dynamic>>.from(
    jsonDecode(File('assets/catalog.json').readAsStringSync()),
  );
  test(
    '100 partidas completas llegan a victoria sin bucles ni repetir contenido',
    () {
      for (var seed = 0; seed < 100; seed++) {
        final g = Game(
          ['Ana', 'Luis', 'Sol'],
          seed,
          intensity: 3,
          size: [30, 50, 75, 100][seed % 3],
        );
        var turns = 0;
        while (g.winner == null && turns++ < 2000) {
          g.roll();
          if (g.winner != null) break;
          final item = g.draw(catalog, []);
          if (item['effect'] != null) {
            g.event(
              item['effect'],
              target: nextPlayer(g.turn, g.names.length),
              amount: item['amount'],
              text: item['text'],
            );
          }
          g.finish();
          expect(g.positions.every((p) => p >= 0 && p <= g.goalPosition), true);
        }
        expect(g.winner, isNotNull, reason: 'Semilla $seed');
        expect(g.used.toSet().length, g.used.length);
        expect(g.concepts.toSet().length, g.concepts.length);
      }
    },
  );
  test('Catálogo real: cantidades, IDs, textos y metadatos válidos', () {
    final counts = {1: 180, 2: 60, 3: 110, 4: 10, 5: 25};
    for (final e in counts.entries) {
      expect(catalog.where((c) => c['category'] == e.key).length, e.value);
    }
    expect(catalog.map((e) => e['id']).toSet().length, catalog.length);
    expect(
      catalog
          .map((e) => e['text'].toString().trim().toLowerCase())
          .toSet()
          .length,
      catalog.length,
    );
    for (final e in catalog) {
      expect(playableCategories, contains(e['category']));
      expect([1, 2, 3], contains(e['intensity']));
      expect(e['theme'], isNotEmpty);
      expect(e['concept'], isNotEmpty);
      expect(e['status'], 'active');
    }
  });
  test('Registro, orden circular y validación', () {
    expect(() => Game(['Ana'], 1), throwsArgumentError);
    expect(() => Game(['Ana', 'Ana'], 1), throwsArgumentError);
    expect(() => Game(['Ana', 'Luis'], 1, enabled: []), throwsArgumentError);
    final g = Game(['Ana', 'Luis', 'Sol'], 1);
    g.finish();
    expect(g.turn, 1);
    g.finish();
    expect(g.turn, 2);
    g.finish();
    expect(g.turn, 0);
    expect(nextPlayer(2, 3), 0);
  });
  test('Tablero equilibrado exacto y reproducible', () {
    final a = Game(['A', 'B'], 42, enabled: [1, 2, 3, 4, 5]),
        b = Game(['A', 'B'], 42, enabled: [1, 2, 3, 4, 5]);
    expect(a.board, b.board);
    for (final e in {0: 1, 6: 1}.entries) {
      expect(a.board.where((c) => c == e.key).length, e.value);
    }
    expect(a.board.sublist(1, 51).length, 50);
    expect(a.board.sublist(1, 51).every(playableCategories.contains), isTrue);
  });
  test('Tamaños, perfiles y categorías se aplican', () {
    for (final size in [30, 50, 75, 100]) {
      for (final profile in [
        'Equilibrado',
        'Puro caos',
        'Tranqui',
        'Sin vergüenza',
      ]) {
        final g = Game(
          ['A', 'B'],
          3,
          size: size,
          profile: profile,
          enabled: [1, 4],
        );
        expect(g.board.length, size + 2);
        expect(
          g.board.sublist(1, size + 1).every((c) => [1, 4].contains(c)),
          true,
        );
      }
    }
    final a = Game(['A', 'B'], 1, intensity: 2),
        b = Game(['A', 'B'], 1, profile: 'Puro caos', intensity: 2);
    expect(a.board.where((c) => c == 5).length, 5);
    expect(b.board.where((c) => c == 5).length, 10);
  });
  test('Dado, límites, bloqueo de doble lanzamiento y victoria', () {
    final g = Game(['A', 'B'], 9);
    final results = <int>{};
    for (var i = 0; i < 100; i++) {
      g.positions[g.turn] = 0;
      results.add(g.roll());
    }
    expect(results, {1, 2, 3, 4, 5, 6});
    g.move(0, -100);
    expect(g.positions[0], 0);
    g.pending = {'id': 'x'};
    final rolls = g.rolls;
    g.roll();
    expect(g.rolls, rolls);
    g.pending = null;
    g.positions[0] = g.size;
    expect(g.move(0, 2), [g.goalPosition, g.size]);
    expect(g.winner, isNull);
    g.positions[0] = g.size;
    expect(g.move(0, 3), [g.goalPosition, g.size, g.size - 1]);
    expect(g.winner, isNull);
    g.positions[0] = g.size;
    g.move(0, 1);
    expect(g.winner, 0);
  });
  test('Selección respeta intensidad y nunca repite IDs ni conceptos', () {
    final g = Game(['A', 'B'], 2, intensity: 1, enabled: [1]);
    g.positions[0] = 1;
    final ids = <String>{}, concepts = <String>{};
    for (var i = 0; i < 200; i++) {
      final c = g.draw(catalog, []);
      if (c['id'] == 'rest') continue;
      expect(c['category'], 1);
      expect(c['intensity'], 1);
      expect(ids.add(c['id']), true);
      expect(concepts.add(c['concept']), true);
    }
    expect(g.pending!['id'], 'rest');
  });
  test('Historial entre partidas prioriza contenido nuevo', () {
    final g = Game(['A', 'B'], 2, enabled: [1], intensity: 3);
    g.positions[0] = 1;
    final one = g.draw(catalog, []);
    final other = Game(['A', 'B'], 2, enabled: [1], intensity: 3)
      ..positions[0] = 1;
    expect(other.draw(catalog, [one['id']])['id'], isNot(one['id']));
  });
  test('Conceptos equivalentes bloqueados entre categorías', () {
    final g = Game(['A', 'B'], 1);
    final sample = [
      {
        'id': 'a',
        'category': 1,
        'intensity': 1,
        'status': 'active',
        'concept': 'shared',
        'text': 'a',
      },
      {
        'id': 'b',
        'category': 3,
        'intensity': 1,
        'status': 'active',
        'concept': 'shared',
        'text': 'b',
      },
    ];
    g.board[1] = 1;
    g.positions[0] = 1;
    g.draw(sample, []);
    g.board[1] = 3;
    expect(g.draw(sample, [])['id'], 'rest');
  });
  test('Diez minijuegos distintos antes de recuperación controlada', () {
    final g = Game(['A', 'B'], 1);
    g.positions[0] = 1;
    g.board[1] = 4;
    final ids = <String>{};
    for (var i = 0; i < 10; i++) {
      expect(ids.add(g.draw(catalog, [])['id']), true);
    }
    expect(g.draw(catalog, [])['id'], 'rest');
  });
  test('Eventos: movimientos, intercambio, escudo, pérdida y turno extra', () {
    final g = Game(['A', 'B', 'C'], 1);
    g.positions = [10, 20, 30];
    g.event('advance', amount: 5);
    expect(g.positions[0], 15);
    g.event('back', amount: -3);
    expect(g.positions[0], 12);
    g.event('swap', target: 1);
    expect(g.positions, [20, 12, 30]);
    g.event('shield');
    g.event('back');
    expect(g.positions[0], 20);
    expect(g.shields[0], false);
    g.event('skip');
    g.finish();
    g.finish();
    g.finish();
    expect(g.turn, 1);
    expect(g.skips[0], 0);
    g.event('extra');
    final t = g.turn;
    g.finish();
    expect(g.turn, t);
    g.finish();
    expect(g.turn, isNot(t));
  });
  test('Los 25 eventos tienen efectos y no encadenan casillas', () {
    for (final e in catalog.where((c) => c['category'] == 5)) {
      final g = Game(['A', 'B', 'C'], 1);
      g.positions = [10, 20, 30];
      g.skips = [1, 1, 0];
      g.addRule('anterior', 10);
      final before = g.encode();
      g.event(
        e['effect'],
        amount: (e['amount'] as int) == 0 ? 1 : e['amount'],
        text: e['text'],
        target: 1,
      );
      expect(g.encode(), isNot(before), reason: e['text']);
      expect(g.pending, isNull);
    }
  });
  test('Reglas temporales expiran al completar turnos', () {
    final g = Game(['A', 'B'], 1);
    g.addRule('x', 2);
    g.finish();
    expect(g.rules.single['remaining'], 1);
    g.finish();
    expect(g.rules, isEmpty);
  });
  test('Serialización conserva tablero, configuración, tarjeta y dinámica', () {
    final g = Game(
      ['A', 'B'],
      3,
      size: 75,
      enabled: [3, 4],
      profile: 'Tranqui',
      intensity: 2,
    );
    g.pending = {
      'id': 'x',
      'mini': {'step': 4, 'deadline': 9999},
    };
    g.addRule('no', 6);
    g.rolls = 7;
    expect(Game.decode(g.encode()).toMap(), g.toMap());
  });
  test('Tamaños admitidos comparten inicio, meta y posiciones iniciales', () {
    for (final size in [30, 50, 75, 100]) {
      final game = Game(['A', 'B', 'C'], 2026, size: size);
      expect(game.board, hasLength(size + 2));
      expect(game.board.first, 0);
      expect(game.board.last, 6);
      expect(game.positions, [0, 0, 0]);
      game.positions[0] = size;
      game.move(0, 1);
      expect(game.positions[0], size + 1);
      expect(game.winner, 0);
    }
  });
  test('Comodín calcula una vez y recorta movimiento a los extremos', () {
    final game = Game(['A', 'B'], 2026, size: 30, enabled: [5]);
    game.board[1] = 5;
    game.positions[0] = 1;
    final card = game.draw([
      {
        'id': 'advance-test',
        'category': 5,
        'intensity': 1,
        'status': 'active',
        'concept': 'advance-test',
        'text': 'Atajo secreto: avanza.',
        'effect': 'advance',
      },
    ], []);
    expect(card['movementFrom'], 1);
    expect(card['movementTo'], inInclusiveRange(2, 7));
    expect(card['text'], contains('avanzas ${card['amount']} casillas'));
    final restored = Game.decode(game.encode());
    expect(restored.pending, card);
    expect(restored.pending!['movementTo'], card['movementTo']);

    final backward = Game(['A', 'B'], 2026, size: 30, enabled: [5]);
    backward.board[1] = 5;
    backward.positions[0] = 1;
    final backCard = backward.draw([
      {
        'id': 'back-test',
        'category': 5,
        'intensity': 1,
        'status': 'active',
        'concept': 'back-test',
        'text': 'Vuelve por donde viniste.',
        'effect': 'back',
      },
    ], []);
    expect(backCard['movementTo'], 0);
    expect(backCard['text'], contains('retrocedes'));
  });
  test('SQLite: guardado transaccional e historial', () async {
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final g = Game(['A', 'B'], 4);
    g.used = ['a', 'b'];
    g.historyExcluded = ['b'];
    await db.save(g);
    expect((await db.load())!.toMap(), g.toMap());
    expect(await db.history(), ['a']);
    await db.clearHistory();
    expect(await db.history(), isEmpty);
    expect((await db.load())!.used, ['a', 'b']);
    await db.close();
  });
  test('Minijuego no se registra en historial global al terminar', () async {
    final db = LocalRepository(NativeDatabase.memory());
    await db.prepare();
    final game = Game(['Ana', 'Luis'], 18)
      ..board[1] = 4
      ..positions[0] = 1;
    final item = {
      'id': 'mini-one',
      'category': 4,
      'intensity': 1,
      'status': 'active',
      'concept': 'mini-one',
      'text': 'Yo nunca nunca',
    };
    game.draw([item], []);
    expect(game.used, ['mini-one']);
    expect(game.historyExcluded, ['mini-one']);
    await db.save(game);
    expect(await db.history(), isEmpty);
    expect((await db.load())!.historyExcluded, ['mini-one']);
    await db.close();
  });
  test('Personalizados y ajustes persisten tras cerrar conexión', () async {
    final directory = Directory('build/test_storage')
      ..createSync(recursive: true);
    final file = File(
      '${directory.path}/persist_${DateTime.now().microsecondsSinceEpoch}.sqlite',
    );
    var db = LocalRepository(NativeDatabase(file));
    await db.prepare();
    await db.writeValue(
      'custom',
      jsonEncode([
        {
          'id': 'custom',
          'text': 'Reto propio',
          'category': 3,
          'concept': 'custom',
          'intensity': 1,
          'status': 'active',
          'theme': 'personalizado',
        },
      ]),
    );
    await db.writeValue('settings', '{"sound":false}');
    await db.close();
    db = LocalRepository(NativeDatabase(file));
    await db.prepare();
    expect(
      jsonDecode((await db.readValue('custom'))!).first['text'],
      'Reto propio',
    );
    expect(jsonDecode((await db.readValue('settings'))!)['sound'], false);
    await db.close();
    await file.delete();
  });
}
