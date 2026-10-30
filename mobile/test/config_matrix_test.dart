import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/catalog.dart';
import 'package:sapo/game.dart';

const profiles = ['Equilibrado', 'Sin vergüenza', 'Puro caos', 'Tranqui'];
List<int> maskCategories(int mask) => [
  for (var i = 0; i < playableCategories.length; i++)
    if (mask & (1 << i) != 0) playableCategories[i],
];
void main() {
  final catalog = decodeCatalog(File('assets/catalog.json').readAsStringSync());
  test('Matriz completa: 1.488 configuraciones × 3 cantidades de jugadores = 4.464 partidas', () {
    var combinations = 0;
    for (final players in [2, 6, 12]) {
      for (var mask = 1; mask < 32; mask++) {
        final enabled = maskCategories(mask);
        for (final size in [30, 50, 75, 100]) {
          for (final profile in profiles) {
            for (var intensity = 1; intensity <= 3; intensity++) {
              final names = List.generate(players, (i) => 'Jugador ${i + 1}');
              final g = Game(
                names,
                mask * 37 + size,
                size: size,
                profile: profile,
                intensity: intensity,
                enabled: enabled,
              );
              final reason =
                  'mask=$mask size=$size profile=$profile intensity=$intensity players=$players';
              expect(g.board.length, size + 2, reason: reason);
              expect(g.board.first, 0);
              expect(g.board.last, 6);
              expect(
                g.board.sublist(1, size + 1).toSet(),
                enabled.toSet(),
                reason: reason,
              );
              expect(
                Game.decode(g.encode()).toMap(),
                g.toMap(),
                reason: reason,
              );
              final twin = Game(
                names,
                mask * 37 + size,
                size: size,
                profile: profile,
                intensity: intensity,
                enabled: enabled.reversed.toList(),
              );
              expect(twin.board, g.board, reason: reason);
              for (final cat in enabled) {
                g.positions[g.turn] = g.board.indexOf(cat);
                final card = g.draw(catalog, []);
                expect(card['id'], isNot('rest'), reason: reason);
                expect(card['category'], cat, reason: reason);
                expect(
                  card['intensity'],
                  lessThanOrEqualTo(intensity),
                  reason: reason,
                );
                g.finish();
              }
              combinations++;
            }
          }
        }
      }
    }
    expect(combinations, 4464);
  });
  test('Los perfiles mantienen una distribución válida sin categoría especial por intensidad', () {
    var count = 0;
    for (var mask = 1; mask < 32; mask++) {
      final enabled = maskCategories(mask);
      for (final size in [30, 50, 75, 100]) {
        for (final profile in profiles) {
          final g = Game(
            ['Ana', 'Luis'],
            1,
            size: size,
            profile: profile,
            intensity: 2,
            enabled: enabled,
          );
          expect(g.board.sublist(1, size + 1).toSet(), enabled.toSet());
          expect(g.board.where((cell) => cell == 7), isEmpty);
          count++;
        }
      }
    }
    expect(count, 496);
  });
}
