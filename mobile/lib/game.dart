import 'dart:convert';
import 'dart:math';

const categories = [
  'Inicio',
  'Verdad o Shot',
  'Bebe',
  'Reto',
  'Minijuego',
  'Evento',
  'Meta',
];
const playableCategories = [1, 2, 3, 4, 5];
const movementWildcardMin = 1;
const movementWildcardMax = 6;

class Game {
  Game(
    List<String> names,
    this.seed, {
    this.intensity = 1,
    this.size = 50,
    this.profile = 'Equilibrado',
    List<int>? enabled,
    List<String>? icons,
  }) : names = List.of(names),
       positions = List.filled(names.length, 0),
       enabled = List<int>.of(enabled ?? playableCategories)..sort(),
       icons = icons == null
           ? List.generate(
               names.length,
               (i) => ['🐸', '🦊', '🐼', '🐯', '🦁', '🐙', '🦄', '🐝'][i % 8],
             )
           : List<String>.of(icons),
       skips = List.filled(names.length, 0),
       shields = List.filled(names.length, false) {
    if (names.length < 2 ||
        names.length > 12 ||
        names.any((n) => n.trim().isEmpty) ||
        names.map((n) => n.trim().toLowerCase()).toSet().length !=
            names.length) {
      throw ArgumentError('Usa entre 2 y 12 nombres diferentes');
    }
    if (this.enabled.isEmpty ||
        this.enabled.any((c) => !playableCategories.contains(c)) ||
        this.enabled.toSet().length != this.enabled.length ||
        ![1, 2, 3].contains(intensity) ||
        ![
          'Equilibrado',
          'Puro caos',
          'Sin vergüenza',
          'Tranqui',
        ].contains(profile) ||
        this.icons.length != names.length ||
        ![30, 50, 75, 100].contains(size)) {
      throw ArgumentError('Configuración inválida');
    }
    final weights = profile == 'Puro caos'
        ? [0, 6, 6, 10, 10, 8, 0]
        : profile == 'Sin vergüenza'
        ? [0, 14, 5, 9, 5, 2, 0]
        : profile == 'Tranqui'
        ? [0, 12, 8, 6, 18, 2, 0]
        : [0, 12, 10, 10, 12, 4, 0];
    final cells = <int>[];
    // La intensidad filtra el catálogo adulto; el perfil distribuye categorías.
    final total = this.enabled.fold<int>(0, (n, c) => n + weights[c]);
    final remaining = size - this.enabled.length;
    final counts = <int, int>{};
    for (final c in this.enabled) {
      counts[c] = 1 + (remaining * weights[c] / total).floor();
    }
    final order = List<int>.of(this.enabled)
      ..sort((a, b) {
        final difference = ((remaining * weights[b]) % total).compareTo(
          (remaining * weights[a]) % total,
        );
        return difference == 0 ? a.compareTo(b) : difference;
      });
    final missing = size - counts.values.fold<int>(0, (a, b) => a + b);
    for (var i = 0; i < missing; i++) {
      counts[order[i]] = counts[order[i]]! + 1;
    }
    for (final c in this.enabled) {
      cells.addAll(List.filled(counts[c]!, c));
    }
    cells.shuffle(Random(seed));
    // Inicio y meta son marcadores de recorrido, además de las N casillas jugables.
    board = [0, ...cells, 6];
  }
  final int size;
  final String profile;
  final List<int> enabled;
  final List<String> icons;
  final List<String> names;
  final int seed;
  final int intensity;
  late List<int> board;
  List<int> positions, skips;
  List<bool> shields;
  int turn = 0, round = 0, die = 0, rolls = 0;
  List<int> lastRollPath = [];
  bool extra = false;
  Map<String, dynamic>? pending;
  List<String> used = [], concepts = [], recentGames = [];
  List<String> historyExcluded = [];
  List<Map<String, dynamic>> rules = [];
  List<Map<String, dynamic>> movementHistory = [];
  int? get winner {
    final i = positions.indexOf(size + 1);
    return i < 0 ? null : i;
  }

  int roll() {
    if (pending != null || winner != null) return die;
    die = Random(seed + rolls++ * 7919).nextInt(6) + 1;
    lastRollPath = move(turn, die);
    return die;
  }

  int get goalPosition => size + 1;

  List<int> move(int player, int delta) {
    if (delta < 0 && shields[player]) {
      shields[player] = false;
      return [];
    }
    final path = <int>[];
    var position = positions[player];
    if (delta < 0) {
      for (var step = 0; step < delta.abs() && position > 0; step++) {
        position--;
        path.add(position);
      }
    } else {
      var direction = 1;
      for (var step = 0; step < delta; step++) {
        if (position == goalPosition && direction > 0) direction = -1;
        position += direction;
        path.add(position);
      }
    }
    positions[player] = position;
    return path;
  }

  Map<String, dynamic> draw(
    List<Map<String, dynamic>> catalog,
    List<String> history, {
    bool resolveMovement = true,
  }) {
    final cat = board[positions[turn]];
    var pool = catalog
        .where(
          (e) =>
              e['category'] == cat &&
              (e['intensity'] as int) <= intensity &&
              e['status'] == 'active',
        )
        .toList();
    if (pool.isEmpty) {
      pending = {
        'id': 'rest',
        'text': 'Descanso. Continúa el siguiente jugador.',
        'category': cat,
      };
      return pending!;
    }
    var eligible = pool
        .where(
          (e) =>
              !used.contains(e['id']) &&
              !concepts.contains(e['concept']) &&
              !recentGames.contains(e['id']),
        )
        .toList();
    if (eligible.isEmpty) {
      eligible = pool
          .where(
            (e) => !used.contains(e['id']) && !concepts.contains(e['concept']),
          )
          .toList();
    }
    if (eligible.isEmpty) {
      pending = {
        'id': 'rest',
        'text': 'Categoría agotada: descanso sin repetir contenido.',
        'category': cat,
      };
      return pending!;
    }
    eligible.sort(
      (a, b) => (history.contains(a['id']) ? 1 : 0).compareTo(
        history.contains(b['id']) ? 1 : 0,
      ),
    );
    final fresh = eligible.where((e) => !history.contains(e['id'])).toList();
    pool = fresh.isEmpty ? eligible : fresh;
    final item = Map<String, dynamic>.from(
      pool[Random(seed + rolls * 31).nextInt(pool.length)],
    );
    used.add(item['id']);
    concepts.add(item['concept']);
    if (cat == 4) {
      if (!historyExcluded.contains(item['id'])) {
        historyExcluded.add(item['id']);
      }
      recentGames.add(item['id']);
      if (recentGames.length > 3) recentGames.removeAt(0);
    }
    if (cat == 5 &&
        (item['effect'] == 'advance' || item['effect'] == 'back') &&
        resolveMovement) {
      final idSeed = (item['id'] as String).codeUnits.fold<int>(
        0,
        (sum, unit) => sum * 31 + unit,
      );
      final amount =
          Random(seed + rolls * 31 + idSeed)
              .nextInt(movementWildcardMax - movementWildcardMin + 1) +
          movementWildcardMin;
      final backwards = item['effect'] == 'back';
      final from = positions[turn];
      final shielded = backwards && shields[turn];
      final path = shielded
          ? <int>[]
          : _previewPath(from, backwards ? -amount : amount);
      final to = path.isEmpty ? from : path.last;
      final title = (item['text'] as String)
          .split(':')
          .first
          .replaceAll('.', '');
      item['movementTitle'] = title;
      item['movementFrom'] = from;
      item['movementTo'] = to;
      item['movementSteps'] = (to - from).abs();
      item['movementPath'] = path;
      item['movementShielded'] = shielded;
      item['amount'] = amount;
      final capped = (to - from).abs() < amount;
      item['text'] = shielded
          ? '$title: tu escudo bloquea el retroceso de $amount casillas.'
          : backwards
          ? '$title: retrocedes $amount casillas${capped ? ' (hasta el inicio)' : ''}.'
          : '$title: avanzas $amount casillas${capped ? ' (hasta la meta)' : ''}.';
      item['movementApplied'] = false;
    } else if (cat == 5 &&
        (item['effect'] == 'advance' || item['effect'] == 'back')) {
      item['movementApplied'] = true;
      item['text'] = '${item['text']} Aquí termina la cadena de movimiento.';
    }
    pending = item;
    return item;
  }

  List<int> _previewPath(int from, int delta) {
    final original = positions[turn];
    positions[turn] = from;
    final path = move(turn, delta);
    positions[turn] = original;
    return path;
  }

  void event(String effect, {int target = 0, int amount = 3, String? text}) {
    switch (effect) {
      case 'advance':
        move(turn, amount);
      case 'back':
        move(turn, -amount.abs());
      case 'swap':
        if (shields[turn] && positions[target] < positions[turn]) {
          shields[turn] = false;
          break;
        }
        if (shields[target] && positions[turn] < positions[target]) {
          shields[target] = false;
          break;
        }
        final p = positions[turn];
        positions[turn] = positions[target];
        positions[target] = p;
      case 'skip':
        if (shields[turn]) {
          shields[turn] = false;
        } else {
          skips[turn]++;
        }
      case 'extra':
        extra = true;
      case 'shield':
        shields[turn] = true;
      case 'rule':
        addRule(text ?? 'Hablar en plural', names.length * amount + 1);
      case 'swapPrevious':
        event('swap', target: (turn - 1 + names.length) % names.length);
      case 'swapLeader':
        final others = List.generate(names.length, (i) => i)..remove(turn);
        others.sort((a, b) => positions[b].compareTo(positions[a]));
        event('swap', target: others.first);
      case 'swapLast':
        final others = List.generate(names.length, (i) => i)..remove(turn);
        others.sort((a, b) => positions[a].compareTo(positions[b]));
        event('swap', target: others.first);
      case 'giftShield':
        shields[target] = true;
      case 'clearSkip':
        skips = List.filled(names.length, 0);
      case 'clearRules':
        rules.clear();
    }
  }

  void addRule(String text, int duration) =>
      rules.add({'text': text, 'remaining': duration});
  void logMovement(Map<String, dynamic> event) {
    movementHistory.add(Map<String, dynamic>.from(event));
    if (movementHistory.length > 100) movementHistory.removeAt(0);
  }

  void finish() {
    pending = null;
    for (final rule in rules) {
      rule['remaining'] = (rule['remaining'] as int) - 1;
    }
    rules.removeWhere((r) => r['remaining'] <= 0);
    if (winner != null) return;
    if (extra) {
      extra = false;
      return;
    }
    do {
      turn = (turn + 1) % names.length;
      round++;
      if (skips[turn] == 0) break;
      skips[turn]--;
    } while (true);
  }

  Map<String, dynamic> toMap() => {
    'size': size,
    'profile': profile,
    'enabled': enabled,
    'icons': icons,
    'names': names,
    'seed': seed,
    'intensity': intensity,
    'board': board,
    'positions': positions,
    'skips': skips,
    'shields': shields,
    'turn': turn,
    'round': round,
    'die': die,
    'rolls': rolls,
    'lastRollPath': lastRollPath,
    'extra': extra,
    'pending': pending,
    'used': used,
    'concepts': concepts,
    'recentGames': recentGames,
    'historyExcluded': historyExcluded,
    'rules': rules,
    'movementHistory': movementHistory,
  };
  String encode() => jsonEncode(toMap());
  factory Game.decode(String value) {
    final m = jsonDecode(value) as Map<String, dynamic>;
    final oldEnabled = List<int>.from(m['enabled']);
    final migratedEnabled = <int>{
      for (final category in oldEnabled)
        if (category == 7) ...[1, 3] else category,
    }.toList()..sort();
    if (migratedEnabled.isEmpty) migratedEnabled.addAll(playableCategories);
    final g = Game(
      List<String>.from(m['names']),
      m['seed'],
      intensity: m['intensity'],
      size: m['size'],
      profile: m['profile'],
      enabled: migratedEnabled,
      icons: List<String>.from(m['icons']),
    );
    final savedBoard = List<int>.from(m['board']);
    final oldSize = savedBoard.length == g.size;
    final mappedBoard = savedBoard.asMap().entries.map((entry) {
      if (entry.value != 7) return entry.value;
      return Random(g.seed + entry.key).nextBool() ? 1 : 3;
    }).toList();
    if (oldSize) {
      final rng = Random(g.seed + 0x51A0);
      final additions = [
        for (var i = 0; i < 2; i++)
          migratedEnabled[rng.nextInt(migratedEnabled.length)],
      ];
      g.board = [0, ...mappedBoard.sublist(1, g.size - 1), ...additions, 6];
    } else {
      g.board = mappedBoard;
    }
    g.positions = List<int>.from(m['positions']).map((position) {
      return oldSize && position == g.size - 1 ? g.goalPosition : position;
    }).toList();
    g.skips = List<int>.from(m['skips']);
    g.shields = List<bool>.from(m['shields']);
    g.turn = m['turn'];
    g.round = m['round'];
    g.die = m['die'];
    g.rolls = m['rolls'];
    g.lastRollPath = List<int>.from(m['lastRollPath'] ?? const []);
    g.extra = m['extra'];
    final oldPending = m['pending'];
    g.pending = oldPending == null
        ? null
        : Map<String, dynamic>.from(oldPending as Map);
    if (g.pending?['category'] == 7) {
      final wasChallenge = g.pending?['type'] == 'challenge';
      g.pending!['category'] = wasChallenge ? 3 : 1;
      g.pending!.remove('type');
    }
    if (g.pending != null && oldSize) {
      for (final key in ['movementFrom', 'movementTo']) {
        if (g.pending![key] == g.size - 1) {
          g.pending![key] = g.goalPosition;
        }
      }
      if (g.pending!['movementPath'] is List) {
        g.pending!['movementPath'] = List<int>.from(g.pending!['movementPath'])
            .map(
              (position) => position == g.size - 1 ? g.goalPosition : position,
            )
            .toList();
      }
    }
    g.used = List<String>.from(m['used']);
    g.concepts = List<String>.from(m['concepts']);
    g.recentGames = List<String>.from(m['recentGames']);
    g.historyExcluded = List<String>.from(m['historyExcluded'] ?? const []);
    g.rules = List<Map<String, dynamic>>.from(m['rules']);
    g.movementHistory = List<Map<String, dynamic>>.from(
      m['movementHistory'] ?? const [],
    );
    return g;
  }
}

int nextPlayer(int player, int count) => (player + 1) % count;
