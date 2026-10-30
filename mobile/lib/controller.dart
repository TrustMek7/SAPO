import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'game.dart';
import 'catalog.dart';
import 'storage.dart';

final repositoryProvider = Provider<LocalRepository>(
  (ref) => throw UnimplementedError(),
);
final appProvider = NotifierProvider<AppController, int>(AppController.new);

class AppController extends Notifier<int> {
  late LocalRepository repository;
  Game? game;
  List<Map<String, dynamic>> catalog = [], custom = [];
  List<String> history = [];
  Map<String, dynamic> settings = {
    'sound': true,
    'vibration': true,
    'animation': true,
    'adultConfirmed': false,
    'theme': 'system',
  };
  int played = 0, victories = 0;
  bool initialized = false;
  bool working = false;
  Map<String, dynamic> setupDraft = {};
  @override
  int build() {
    repository = ref.read(repositoryProvider);
    return 0;
  }

  Future<void> initialize() async {
    if (initialized) return;
    catalog = decodeCatalog(await rootBundle.loadString('assets/catalog.json'));
    custom = List<Map<String, dynamic>>.from(
      jsonDecode(await repository.readValue('custom') ?? '[]'),
    );
    var migratedCustom = false;
    for (final item in custom) {
      if (item['category'] == 7) {
        item['category'] = item.remove('type') == 'challenge' ? 3 : 1;
        item['concept'] = 'migrado_${item['concept']}';
        migratedCustom = true;
      }
    }
    if (migratedCustom) await saveCustom();
    settings.addAll(
      Map<String, dynamic>.from(
        jsonDecode(await repository.readValue('settings') ?? '{}'),
      ),
    );
    played = int.parse(await repository.readValue('played') ?? '0');
    victories = int.parse(await repository.readValue('victories') ?? '0');
    history = await repository.history();
    game = await repository.load();
    initialized = true;
    state++;
  }

  Future<void> start(Game value) async {
    game = value;
    played++;
    await repository.writeValue('played', '$played');
    await save();
  }

  Future<void> save() async {
    if (game != null) await repository.save(game!);
    state++;
  }

  Future<void> roll({Future<void> Function(int result)? onResult}) async {
    final g = game!;
    if (working || g.pending != null || g.winner != null) return;
    working = true;
    try {
      final from = g.positions[g.turn];
      g.roll();
      final to = g.positions[g.turn];
      final path = List<int>.of(g.lastRollPath);
      // Reveal and settle the die before any token moves. The controller lock
      // also protects this pause from a second launch.
      g.positions[g.turn] = from;
      if (onResult != null) await onResult(g.die);
      if (settings['animation'] == true) {
        for (final position in path) {
          g.positions[g.turn] = position;
          state++;
          await Future<void>.delayed(const Duration(milliseconds: 360));
        }
      } else {
        g.positions[g.turn] = to;
      }
      if (g.winner == null) {
        g.draw([...catalog, ...custom], history);
      } else {
        victories++;
        await repository.writeValue('victories', '$victories');
      }
      if (settings['vibration'] == true) HapticFeedback.mediumImpact();
      if (settings['sound'] == true) SystemSound.play(SystemSoundType.click);
      await save();
    } finally {
      working = false;
    }
  }

  Future<void> finish({bool applyEvent = false}) async {
    final g = game!;
    if (working || g.pending == null || g.winner != null) return;
    working = true;
    try {
      if (applyEvent && g.pending?['effect'] != null) {
        final event = g.pending!;
        if ((event['effect'] == 'advance' || event['effect'] == 'back') &&
            event['movementApplied'] != true) {
          final from = event['movementFrom'] as int;
          final to = event['movementTo'] as int;
          final path = List<int>.from(event['movementPath'] ?? const []);
          if (event['movementShielded'] == true) g.shields[g.turn] = false;
          if (settings['animation'] == true && path.isNotEmpty) {
            for (final position in path) {
              g.positions[g.turn] = position;
              state++;
              await save();
              await Future<void>.delayed(const Duration(milliseconds: 360));
            }
          } else {
            g.positions[g.turn] = to;
          }
          event['movementApplied'] = true;
          g.logMovement({
            'player': g.names[g.turn],
            'cause': event['movementTitle'] ?? event['text'],
            'from': from,
            'to': to,
            'steps': path.length,
            'effect': event['effect'],
            'amount': event['amount'],
            'result': event['text'],
          });
          if (to != from && g.winner == null) {
            g.pending = null;
            g.draw([...catalog, ...custom], history, resolveMovement: false);
            await save();
            return;
          }
        } else if (event['movementApplied'] != true) {
          g.event(
            event['effect'],
            target: nextPlayer(g.turn, g.names.length),
            amount: event['amount'] ?? 3,
            text: event['text'],
          );
          event['movementApplied'] = true;
        }
      }
      if (g.winner != null) {
        victories++;
        await repository.writeValue('victories', '$victories');
      }
      g.finish();
      history = await repository.history();
      await save();
    } finally {
      working = false;
    }
  }

  Future<void> setting(String key, Object value) async {
    settings[key] = value;
    await repository.writeValue('settings', jsonEncode(settings));
    state++;
  }

  Future<void> clearHistory() async {
    await repository.clearHistory();
    history = [];
    state++;
  }

  Future<void> saveCustom() async {
    await repository.writeValue('custom', jsonEncode(custom));
    state++;
  }
}
