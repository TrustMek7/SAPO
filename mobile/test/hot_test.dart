import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/catalog.dart';
import 'package:sapo/game.dart';

void main() {
  final catalog = decodeCatalog(File('assets/catalog.json').readAsStringSync());
  test(
    'El catálogo adulto usa cinco categorías y clasifica contenido sexual',
    () {
      expect(catalog.length, 385);
      expect(catalog.any((item) => item['category'] == 7), isFalse);
      expect(playableCategories, [1, 2, 3, 4, 5]);
      expect(catalog.map((item) => item['id']).toSet().length, catalog.length);
      expect(
        catalog.map((item) => item['concept']).toSet().length,
        catalog.length,
      );
      final explicit = catalog.where(
        (item) =>
            (item['text'] as String).toLowerCase().contains('masturb') ||
            (item['text'] as String).toLowerCase().contains('sexo anal') ||
            (item['text'] as String).toLowerCase().contains(
              'fingiste un orgasmo',
            ),
      );
      expect(explicit, isNotEmpty);
      expect(
        explicit.every(
          (item) => item['category'] == 1 && item['intensity'] == 3,
        ),
        true,
      );
      expect(
        catalog
            .where((item) => item['category'] == 1 && item['intensity'] == 1)
            .any((item) => (item['text'] as String).contains('atrae')),
        true,
      );
      expect(catalog.where((item) => item['category'] == 3).length, 110);
    },
  );

  test('Tablero equilibrado suma 50 incluyendo inicio y meta', () {
    final g = Game(['Ana', 'Luis'], 42, intensity: 2);
    expect(g.enabled, [1, 2, 3, 4, 5]);
    expect(g.board.length, 52);
    expect(g.board.first, 0);
    expect(g.board.last, 6);
    expect(g.board.sublist(1, 51).toSet(), {1, 2, 3, 4, 5});
  });

  test(
    'Las tarjetas migradas a Verdad o Shot y Reto se filtran por intensidad',
    () {
      for (final category in [1, 3]) {
        for (var level = 1; level <= 3; level++) {
          final g = Game(
            ['Ana', 'Luis'],
            42,
            enabled: [category],
            intensity: level,
          );
          expect(g.board.sublist(1, 51).toSet(), {category});
          g.positions[0] = 1;
          final card = g.draw(catalog, []);
          expect(card['category'], category);
          expect(card['intensity'], lessThanOrEqualTo(level));
          expect(card['id'], isNot('rest'));
        }
      }
    },
  );

  test(
    'Partidas antiguas migran HOT a Verdad o Shot / Reto al recuperarse',
    () {
      final old = Game(['Ana', 'Luis'], 42).toMap()
        ..['enabled'] = [1, 7]
        ..['board'] = List<int>.filled(50, 7)
        ..['pending'] = {'id': 'c7_old', 'category': 7, 'type': 'challenge'};
      old['board'][0] = 0;
      old['board'][49] = 6;
      final restored = Game.decode(jsonEncode(old));
      expect(restored.enabled, [1, 3]);
      expect(restored.board.length, 52);
      expect(restored.board, isNot(contains(7)));
      expect(restored.pending!['category'], 3);
      expect(restored.pending!.containsKey('type'), isFalse);
    },
  );
}
