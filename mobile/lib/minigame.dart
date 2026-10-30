import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:playing_cards/playing_cards.dart';

import 'controller.dart';
import 'game.dart';
import 'ui/sapo_widgets.dart' show action;

String _answerKey(String value) {
  var key = value.toLowerCase().trim();
  const replacements = {
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'â': 'a',
    'é': 'e',
    'è': 'e',
    'ë': 'e',
    'ê': 'e',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'î': 'i',
    'ó': 'o',
    'ò': 'o',
    'ö': 'o',
    'ô': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'û': 'u',
    'ñ': 'n',
  };
  for (final entry in replacements.entries) {
    key = key.replaceAll(entry.key, entry.value);
  }
  return key.replaceAll(RegExp(r'[^a-z0-9]+'), '');
}

bool _sameAnswer(String first, String second) {
  final a = _answerKey(first), b = _answerKey(second);
  if (a == b) return true;
  if (a.length < 5 || b.length < 5 || (a.length - b.length).abs() > 1) {
    return false;
  }
  var i = 0, j = 0, edits = 0;
  while (i < a.length && j < b.length) {
    if (a[i] == b[j]) {
      i++;
      j++;
    } else {
      if (++edits > 1) return false;
      if (a.length > b.length) {
        i++;
      } else if (b.length > a.length) {
        j++;
      } else {
        i++;
        j++;
      }
    }
  }
  if (i < a.length || j < b.length) edits++;
  return edits <= 1;
}

class MiniGameScreen extends ConsumerStatefulWidget {
  const MiniGameScreen({
    super.key,
    required this.kind,
    this.preview = false,
    this.embedded = false,
  });
  final String kind;
  final bool preview;
  final bool embedded;
  @override
  ConsumerState<MiniGameScreen> createState() => _MiniState();
}

class _MiniState extends ConsumerState<MiniGameScreen> {
  final input = TextEditingController();
  Timer? timer;
  bool saving = false;
  late final Game _game;
  late Map<String, dynamic> m;
  Game get game => _game;
  @override
  void initState() {
    super.initState();
    _game = widget.preview
        ? Game(['Ana', 'Luis', 'Sol'], 50)
        : ref.read(appProvider.notifier).game!;
    if (widget.preview) {
      _game.pending = {
        'id': 'preview',
        'text': 'Vista de prueba',
        'category': 4,
        'kind': widget.kind,
      };
    }
    final p = game.pending!;
    m = Map<String, dynamic>.from(
      p['mini'] ??
          {
            'step': 1,
            'round': 1,
            'phase': 1,
            'player': game.turn,
            'answers': <String>[],
            'sentence': '',
            'result': '',
            'rival': nextPlayer(game.turn, game.names.length),
            'card': Random().nextInt(13) + 1,
            'suit': Random().nextInt(4),
            'total': 0,
            'selectedCard': 1,
            'count': 1,
            'replacementNumber': 2,
            'replacementWord': '',
            'revealed': false,
            'ruleDuration': Random().nextInt(5) + 1,
            'target': widget.kind == 'lemon'
                ? nextPlayer(
                    nextPlayer(game.turn, game.names.length),
                    game.names.length,
                  )
                : nextPlayer(game.turn, game.names.length),
            'culture': [
              'Marcas de autos',
              'Ciudades del Perú',
              'Películas animadas',
              'Instrumentos musicales',
              'Comidas que se comen con la mano',
              'Profesiones',
              'Animales que nadan',
              'Países de América',
            ][Random().nextInt(8)],
          },
    );
    if (widget.kind == 'lemon') {
      m['target'] = nextPlayer(m['player'] as int, game.names.length);
      m.putIfAbsent('lemonStart', () => m['player'] as int);
    }
    m.putIfAbsent('count', () => 1);
    m.putIfAbsent('replacementNumber', () => 2);
    m.putIfAbsent('replacementWord', () => '');
    m.putIfAbsent('revealed', () => false);
    m.putIfAbsent('ruleDuration', () => Random().nextInt(5) + 1);
    p['mini'] = m;
    timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && widget.kind == 'bomb') setState(() {});
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    input.dispose();
    super.dispose();
  }

  Future<void> change(VoidCallback update) async {
    if (saving) return;
    setState(() {
      saving = true;
      update();
    });
    try {
      game.pending!['mini'] = m;
      if (!widget.preview) await ref.read(appProvider.notifier).save();
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> registerCultureAnswer() async {
    final word = input.text.trim();
    if (word.isEmpty) return;
    final answers = List<String>.from(m['answers'] as List);
    final repeated = answers.cast<String?>().firstWhere(
      (answer) => answer != null && _sameAnswer(answer, word),
      orElse: () => null,
    );
    await change(() {
      if (repeated != null) {
        m['result'] = 'Fallaste. «$repeated» ya se había dicho. Toma.';
        m['failedAnswer'] = word;
      } else {
        answers.add(word);
        m['answers'] = answers;
        input.clear();
        next();
      }
    });
    if (repeated != null && mounted) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Fallaste'),
          content: Text('«$repeated» ya se había dicho. Toma.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    }
  }

  void next() {
    m['step']++;
    m['player'] = nextPlayer(m['player'], game.names.length);
  }

  String get person => game.names[m['player']];
  int get lemonNumber {
    final start = m['lemonStart'] as int;
    final active = m['player'] as int;
    return (active - start + game.names.length) % game.names.length + 1;
  }

  void fail() => change(() => m['result'] = 'Fallaste. Toma.');

  Widget failButton({String key = 'failButton'}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: FilledButton(
      key: Key(key),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Theme.of(context).colorScheme.onError,
      ),
      onPressed: saving ? null : fail,
      child: const Text('Fallé'),
    ),
  );

  Future<void> finishMiniGame() async {
    if (!widget.preview) await ref.read(appProvider.notifier).finish();
    if (mounted) Navigator.of(context).pop();
  }

  CardValue cardValue(int value) => switch (value) {
    1 => CardValue.ace,
    2 => CardValue.two,
    3 => CardValue.three,
    4 => CardValue.four,
    5 => CardValue.five,
    6 => CardValue.six,
    7 => CardValue.seven,
    8 => CardValue.eight,
    9 => CardValue.nine,
    10 => CardValue.ten,
    11 => CardValue.jack,
    12 => CardValue.queen,
    _ => CardValue.king,
  };

  Suit cardSuit(int suit) =>
      [Suit.clubs, Suit.diamonds, Suit.hearts, Suit.spades][suit % 4];

  Widget playingCard(int value, int suit, {bool faceDown = false}) => SizedBox(
    width: 90,
    height: 125,
    child: PlayingCardView(
      card: PlayingCard(cardSuit(suit), cardValue(value)),
      showBack: faceDown,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final k = widget.kind, n = m['step'] as int;
    final remaining = m['deadline'] == null
        ? null
        : ((m['deadline'] as int) - DateTime.now().millisecondsSinceEpoch);
    final over = remaining != null && remaining <= 0;
    final sentenceResolved = k == 'sentence' && m['sentenceResolved'] == true;
    final resolved = (m['result'] as String).isNotEmpty;
    final screen = Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !resolved && !widget.embedded,
        title: Text(switch (k) {
          'never' => 'Yo nunca nunca…',
          'lemon' => 'Un limón, medio limón',
          'duck' => 'El pato',
          'culture' => 'Cultura chupística',
          'replace' => 'Cuenta con reemplazo',
          'sentence' => 'Oración',
          'bomb' => 'La bomba',
          'president' => 'Presidente',
          'forbidden' => 'Palabra prohibida',
          '21' => '21',
          'cards' => 'Carta alta',
          'todito' => 'Todito',
          'parity' => 'Par o impar',
          _ => 'Minijuego',
        }),
      ),
      body: resolved
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          m['result'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    action(
                      sentenceResolved
                          ? 'Aceptar y cerrar el juego'
                          : 'Finalizar dinámica',
                      saving ? null : finishMiniGame,
                      key: const Key('finishMiniGame'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                if (widget.preview)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Modo de prueba: explora esta dinamica sin afectar una partida.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Text(
                  person,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (k == 'never') ...[
                  const Text(
                    'Di una frase que empiece con "Yo nunca nunca...". Quienes si lo hayan hecho pueden tomar. No tienes que contar detalles.',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
                if (k == 'lemon') ...[
                  Text(
                    'Tu número fijo: $lemonNumber',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$lemonNumber limón, medio limón, ___ limón.',
                    style: const TextStyle(fontSize: 30),
                  ),
                  const Text(
                    'Cada persona conserva su número. El 1 es quien inicia; '
                    'los siguientes reciben números en el orden circular de inscripción. '
                    'Di tu número, «medio limón» y llama a alguien por su número. '
                    'Quien recibe continúa con el suyo y elige a otra persona. '
                    'Solo puedes llamar a alguien distinto de ti.',
                  ),
                  const Text(
                    'Ejemplo: si A inicia en un círculo A–E, A=1, B=2, C=3, '
                    'D=4 y E=5. A puede llamar a E; E continúa con el 5 y llama a otro.',
                  ),
                  const Text('¿A quién llamas?'),
                  for (var i = 0; i < game.names.length; i++)
                    if (i != m['player'])
                      action(
                        game.names[i],
                        saving
                            ? null
                            : () => change(() {
                                m['player'] = i;
                                m['step'] = (m['step'] as int) + 1;
                              }),
                      ),
                  failButton(),
                ],
                if (k == 'duck') ...[
                  Text(
                    'Ronda $n',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'El pato es una secuencia acumulativa por turnos. Empiezan '
                    'con un pato y, en cada ronda, se suma otro. Acompañen cada '
                    'pato con un «pum» y un «chutín», manteniendo el orden. '
                    'El grupo verifica de memoria; si alguien se equivoca, pulsa Fallé. '
                    'Si completa su ronda, pasa el celular.',
                  ),
                  const Text(
                    'Ejemplo de la primera ronda: «1 pato, pum, chutín, cayó al agua». '
                    'En la segunda se repite el patrón con dos patos, dos pum y dos chutines.',
                  ),
                  action('Pasar', saving ? null : () => change(next)),
                  failButton(),
                ],
                if (k == 'culture') ...[
                  Text(
                    'Categoria: ${m['culture']}',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const Text(
                    'Di un elemento válido de la categoría, sin repetir.',
                  ),
                  TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      labelText: 'Tu respuesta',
                    ),
                  ),
                  action(
                    'Registrar y pasar',
                    saving ? null : registerCultureAnswer,
                  ),
                ],
                if (k == 'replace') ...[
                  Text(
                    m['round'] == 1
                        ? 'Ronda inicial. Di el numero ${m['count']}.'
                        : m['round'] == 2
                        ? 'Define una palabra para reemplazar un numero.'
                        : 'Ronda con regla: reemplaza ${m['replacementNumber']} por ${m['replacementWord']}.',
                    style: const TextStyle(fontSize: 22),
                  ),
                  if (m['round'] == 1)
                    TextField(
                      controller: input,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Numero que dijiste',
                      ),
                    ),
                  if (m['round'] == 2) ...[
                    DropdownButton<int>(
                      value: m['replacementNumber'] as int,
                      isExpanded: true,
                      items: [
                        for (var value = 1; value <= 10; value++)
                          DropdownMenuItem(
                            value: value,
                            child: Text(value.toString()),
                          ),
                      ],
                      onChanged: saving
                          ? null
                          : (value) => change(() {
                              if (value != null) m['replacementNumber'] = value;
                            }),
                    ),
                    TextField(
                      controller: input,
                      decoration: const InputDecoration(
                        labelText: 'Palabra de reemplazo',
                      ),
                    ),
                  ],
                  if (m['round'] == 3)
                    TextField(
                      controller: input,
                      decoration: const InputDecoration(
                        labelText: 'Escribe la secuencia completa',
                      ),
                    ),
                  if (m['result'] == '')
                    action(
                      m['round'] == 1
                          ? 'Validar y pasar'
                          : m['round'] == 2
                          ? 'Guardar regla'
                          : 'Validar y pasar',
                      saving
                          ? null
                          : () => change(() {
                              final round = m['round'] as int;
                              if (round == 1) {
                                if (input.text.trim() !=
                                    (m['count'] as int).toString()) {
                                  m['result'] = 'Fallaste el conteo. Toma.';
                                } else if (m['count'] == 10) {
                                  m['round'] = 2;
                                  m['player'] = 0;
                                  input.clear();
                                } else {
                                  m['count'] = (m['count'] as int) + 1;
                                  input.clear();
                                  next();
                                }
                              } else if (round == 2) {
                                final word = input.text.trim();
                                if (word.isNotEmpty &&
                                    !word.contains(RegExp(r'\s'))) {
                                  m['replacementWord'] = word;
                                  m['round'] = 3;
                                  m['player'] = 0;
                                  input.clear();
                                }
                              } else {
                                final number = m['replacementNumber'] as int;
                                final word = _answerKey(
                                  m['replacementWord'] as String,
                                );
                                final expected = List.generate(
                                  10,
                                  (index) => index + 1 == number
                                      ? word
                                      : (index + 1).toString(),
                                );
                                final response = input.text
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .map(_answerKey)
                                    .toList();
                                if (response.length != expected.length ||
                                    List.generate(
                                      expected.length,
                                      (i) => response[i] == expected[i],
                                    ).any((same) => !same)) {
                                  m['result'] =
                                      'Fallaste. La cuenta correcta era: '
                                      '${expected.join(' ')}. Toma.';
                                } else {
                                  input.clear();
                                  next();
                                }
                              }
                            }),
                    ),
                ],
                if (k == 'sentence') ...[
                  Text(
                    'Agrega una palabra a la oración acumulada y escribe '
                    'la secuencia completa de memoria.',
                    style: const TextStyle(fontSize: 22),
                  ),
                  const Text(
                    'La frase no se muestra. Se valida lo que escribas.',
                  ),
                  TextField(
                    controller: input,
                    decoration: const InputDecoration(
                      labelText: 'Oracion completa',
                    ),
                  ),
                  action(
                    'Verificar y pasar',
                    saving || m['sentenceResolved'] == true
                        ? null
                        : () => change(() {
                            final previous = (m['sentence'] as String)
                                .trim()
                                .toLowerCase()
                                .replaceAll(RegExp(r'\s+'), ' ');
                            final response = input.text
                                .trim()
                                .toLowerCase()
                                .replaceAll(RegExp(r'\s+'), ' ');
                            final oldWords = previous.isEmpty
                                ? <String>[]
                                : previous.split(' ');
                            final newWords = response.split(' ');
                            final valid =
                                newWords.length == oldWords.length + 1 &&
                                newWords.take(oldWords.length).join(' ') ==
                                    previous;
                            if (valid) {
                              m['sentence'] = response;
                              input.clear();
                              next();
                            } else {
                              m['sentenceResolved'] = true;
                              m['result'] =
                                  'Fallaste. La oración correcta era: '
                                  '«$previous». Toma.';
                            }
                          }),
                  ),
                  if (m['sentenceResolved'] != true)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: FilledButton(
                        key: const Key('sentenceFailButton'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor: Theme.of(context)
                              .colorScheme
                              .onError,
                        ),
                        onPressed: saving
                            ? null
                            : () => change(() {
                                m['sentenceResolved'] = true;
                                final correct = (m['sentence'] as String)
                                    .trim();
                                m['result'] = correct.isEmpty
                                    ? 'Fallaste. Toma.'
                                    : 'Fallaste. La oración correcta era: '
                                          '«$correct». Toma.';
                              }),
                        child: const Text('Fallé'),
                      ),
                    ),
                ],
                if (k == 'bomb') ...[
                  const Text(
                    'Pasa el celular y pulsa «Recibido» al entregarlo. Cuando explota, quien lo tenga pierde; la penalización es tomar. Temporizador aleatorio de 20 a 45 segundos.',
                  ),
                  Text(
                    over
                        ? '💥 ¡BOOM!'
                        : m['deadline'] == null
                        ? '💣 Lista'
                        : '💣 TIC… TAC…',
                    style: const TextStyle(fontSize: 44),
                  ),
                  if (m['deadline'] == null)
                    action(
                      'Activar bomba',
                      saving
                          ? null
                          : () => change(
                              () => m['deadline'] =
                                  DateTime.now().millisecondsSinceEpoch +
                                  (20 + Random().nextInt(26)) * 1000,
                            ),
                    ),
                  if (m['deadline'] != null && !over)
                    action(
                      'Recibido: siguiente jugador',
                      saving ? null : () => change(next),
                    ),
                  if (over)
                    Text(
                      '$person debe tomar.',
                      style: const TextStyle(fontSize: 26),
                    ),
                ],
                if (k == 'president' || k == 'forbidden') ...[
                  Text(
                    k == 'president'
                        ? 'Crea una regla para ${m['ruleDuration']} turnos. Si alguien la incumple, toma.'
                        : 'Elige una palabra prohibida durante ${m['ruleDuration']} turnos. Si alguien la dice, toma.',
                    style: const TextStyle(fontSize: 22),
                  ),
                  TextField(
                    controller: input,
                    decoration: InputDecoration(
                      labelText: k == 'president'
                          ? 'Tu regla'
                          : 'Palabra prohibida',
                    ),
                  ),
                  action(
                    'Activar regla',
                    saving || m['ruleAdded'] == true
                        ? null
                        : () => change(() {
                            final value = input.text.trim();
                            if (value.isEmpty) return;
                            game.addRule(
                              k == 'president' ? value : 'No decir $value',
                              m['ruleDuration'] as int,
                            );
                            m['ruleAdded'] = true;
                            m['result'] = 'Regla activa. Vuelve al tablero.';
                          }),
                  ),
                ],
                if (k == '21') ...[
                  Text(
                    'Voltea una carta y mírala sin mostrarla.',
                    style: const TextStyle(fontSize: 22),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) => Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(
                          (1 - animation.value) * pi / 2,
                        ),
                        child: child,
                      ),
                      child: child,
                    ),
                    child: KeyedSubtree(
                      key: ValueKey<bool>(m['revealed'] == true),
                      child: Center(
                        child: playingCard(
                          m['card'] as int,
                          m['suit'] as int,
                          faceDown: m['revealed'] != true,
                        ),
                      ),
                    ),
                  ),
                  if (m['result'] == '' &&
                      m['phase'] != 2 &&
                      m['revealed'] != true)
                    action(
                      'Voltear carta',
                      saving
                          ? null
                          : () => change(() {
                              final card = Random().nextInt(13) + 1;
                              m['card'] = card;
                              m['suit'] = Random().nextInt(4);
                              m['total'] = (m['total'] as int) + card;
                              m['revealed'] = true;
                              if ((m['total'] as int) > 21) {
                                m['result'] = '$person paso de 21 y toma.';
                              } else if (m['total'] == 21) {
                                m['phase'] = 2;
                              }
                            }),
                    ),
                  if (m['revealed'] == true &&
                      m['phase'] != 2 &&
                      m['result'] == '')
                    action(
                      'Ocultar y pasar el celular',
                      saving
                          ? null
                          : () => change(() {
                              m['revealed'] = false;
                              m['player'] = nextPlayer(
                                m['player'] as int,
                                game.names.length,
                              );
                            }),
                    ),
                  if (m['phase'] == 2 && m['result'] == '') ...[
                    const Text('Llegaste a 21 exacto. Elige quien toma.'),
                    DropdownButton<int>(
                      value: m['target'] as int,
                      isExpanded: true,
                      items: [
                        for (var i = 0; i < game.names.length; i++)
                          DropdownMenuItem(
                            value: i,
                            child: Text(game.names[i]),
                          ),
                      ],
                      onChanged: saving
                          ? null
                          : (value) => change(() {
                              if (value != null) m['target'] = value;
                            }),
                    ),
                    action(
                      'Confirmar',
                      saving
                          ? null
                          : () => change(
                              () => m['result'] =
                                  '21 exacto: ${game.names[m['target'] as int]} toma.',
                            ),
                    ),
                  ],
                  if (m['result'] != '')
                    Text(m['result'], style: const TextStyle(fontSize: 24)),
                ],
                if (k == 'cards') ...[
                  Text(
                    'Voltea tu carta, memorizala y predice si la siguiente sera mayor o menor.',
                    style: const TextStyle(fontSize: 22),
                  ),
                  Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) => AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) => Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(
                            (1 - animation.value) * pi / 2,
                          ),
                          child: child,
                        ),
                        child: child,
                      ),
                      child: KeyedSubtree(
                        key: ValueKey<bool>(m['revealed'] == true),
                        child: playingCard(
                          m['card'] as int,
                          m['suit'] as int,
                          faceDown: m['revealed'] != true,
                        ),
                      ),
                    ),
                  ),
                  if (m['revealed'] != true && m['result'] == '')
                    action(
                      'Voltear carta',
                      saving ? null : () => change(() => m['revealed'] = true),
                    ),
                  if (m['revealed'] == true && m['result'] == '')
                    for (final higher in [true, false])
                      action(
                        higher
                            ? 'La siguiente sera mayor'
                            : 'La siguiente sera menor',
                        saving
                            ? null
                            : () => change(() {
                                final next = Random().nextInt(13) + 1;
                                final current = m['card'] as int;
                                final correct = higher
                                    ? next > current
                                    : next < current;
                                m['drawnCard'] = next;
                                m['drawnSuit'] = Random().nextInt(4);
                                m['result'] = correct
                                    ? 'Acertaste.'
                                    : 'No acertaste: toma.';
                              }),
                      ),
                  if (m['drawnCard'] != null)
                    Center(
                      child: playingCard(
                        m['drawnCard'] as int,
                        m['drawnSuit'] as int,
                      ),
                    ),
                  if (m['result'] != '')
                    Text(m['result'], style: const TextStyle(fontSize: 24)),
                ],
                if (k == 'todito') ...[
                  const Text(
                    'Cuatro resultados equiprobables. Tú: toma el jugador activo. Obliga: elige a alguien, que toma. Derecha e Izquierda: vecino según orden circular.',
                  ),
                  action(
                    'Sortear',
                    saving || m['result'] != ''
                        ? null
                        : () => change(() {
                            final result = Random().nextInt(4);
                            final index = result == 2
                                ? nextPlayer(game.turn, game.names.length)
                                : (game.turn - 1 + game.names.length) %
                                      game.names.length;
                            m['result'] = [
                              'Tú: toma ${game.names[game.turn]}.',
                              'Obliga: elige a alguien, que toma.',
                              'Derecha: ${game.names[index]} toma.',
                              'Izquierda: ${game.names[index]} toma.',
                            ][result];
                          }),
                  ),
                ],
                if (k == 'parity') ...[
                  const Text(
                    'El activo apuesta PAR; el rival, IMPAR. Ambos eligen de 0 a 5 dedos en secreto, pasan el celular y revelan la suma. Quien pierda recibe la penalización de tomar.',
                  ),
                  DropdownButton<int>(
                    value: m['rival'],
                    items: [
                      for (var i = 0; i < game.names.length; i++)
                        if (i != game.turn)
                          DropdownMenuItem(
                            value: i,
                            child: Text(game.names[i]),
                          ),
                    ],
                    onChanged: m['first'] != null
                        ? null
                        : (v) => change(() => m['rival'] = v),
                  ),
                  Text(
                    m['first'] == null
                        ? 'Elige ${game.names[game.turn]}'
                        : 'Elige ${game.names[m['rival']]} (sin mirar la elección anterior)',
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var fingers = 0; fingers <= 5; fingers++)
                        action(
                          '$fingers',
                          saving || m['result'] != ''
                              ? null
                              : () => change(() {
                                  if (m['first'] == null) {
                                    m['first'] = fingers;
                                  } else {
                                    final total = (m['first'] as int) + fingers;
                                    final loser = total.isEven
                                        ? game.names[m['rival']]
                                        : game.names[game.turn];
                                    m['result'] =
                                        'Suma: $total. Pierde $loser; la penalización es tomar.';
                                  }
                                }),
                        ),
                    ],
                  ),
                ],
                if (m['result'] != '')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        m['result'],
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (k == 'replace' && m['result'] == '') failButton(),
                action(
                  'Finalizar dinámica',
                  saving ? null : finishMiniGame,
                  key: const Key('finishMiniGame'),
                ),
              ],
            ),
    );
    if (!widget.embedded) return screen;
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SizedBox(
        width: 520,
        height: MediaQuery.sizeOf(context).height * .86,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: screen,
        ),
      ),
    );
  }
}

class MiniGameReviewScreen extends StatelessWidget {
  const MiniGameReviewScreen({super.key, this.challenges = const []});
  final List<Map<String, dynamic>> challenges;

  static const games = <(String, String, String)>[
    ('never', 'Yo Nunca Nunca', 'Ronda libre de confesiones.'),
    (
      'lemon',
      'Un lim\u00F3n, medio lim\u00F3n',
      'Números fijos desde quien inicia; llama a otra persona.',
    ),
    ('duck', 'El pato', 'Secuencia acumulativa que crece en cada ronda.'),
    (
      'culture',
      'Cultura chup\u00EDstica',
      'Categor\u00EDa y respuestas sin repetir.',
    ),
    (
      'replace',
      'Cuenta con reemplazo',
      'Cuenta del 1 al 10 con una palabra acordada.',
    ),
    ('sentence', 'Oraci\u00F3n', 'Construyan y recuerden una oraci\u00F3n.'),
    ('bomb', 'La bomba', 'Pasa el celular antes de que termine el tiempo.'),
    ('president', 'Presidente', 'Propongan una regla temporal para el grupo.'),
    (
      'forbidden',
      'Palabra prohibida',
      'Elijan una palabra que nadie debe decir.',
    ),
    ('21', '21', 'Suma cartas elegidas hasta acercarse a 21.'),
    (
      'cards',
      'Carta alta',
      'Adivina si la siguiente carta será mayor o menor.',
    ),
    (
      'todito',
      'Todito',
      'Reto individual de azar: Tú, Obliga, Derecha o Izquierda.',
    ),
    ('parity', 'Par o impar', 'Duelo rápido con un rival.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Probar minijuegos')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Abre cada din\u00E1mica, pru\u00E9bala y vuelve aqu\u00ED para dar feedback. '
            'Este modo no guarda cambios en tus partidas.',
          ),
        ),
        for (final entry in games)
          Card(
            child: ListTile(
              title: Text(entry.$2),
              subtitle: Text(entry.$3),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MiniGameScreen(kind: entry.$1, preview: true),
                ),
              ),
            ),
          ),
        if (challenges.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 24, 8, 8),
            child: Text(
              'Retos del catálogo (incluye retos individuales)',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          for (final challenge in challenges)
            Card(
              child: ListTile(
                title: Text(challenge['text'] as String),
                subtitle: Text('Intensidad ${challenge['intensity']}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ChallengeReviewScreen(challenge: challenge),
                  ),
                ),
              ),
            ),
        ],
      ],
    ),
  );
}

class ChallengeReviewScreen extends StatelessWidget {
  const ChallengeReviewScreen({super.key, required this.challenge});
  final Map<String, dynamic> challenge;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reto para revisar')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'INTENSIDAD ${challenge['intensity']}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                challenge['text'] as String,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Tema: ${challenge['theme']}', textAlign: TextAlign.center),
          const SizedBox(height: 20),
          action('Volver a los retos', () => Navigator.pop(context)),
        ],
      ),
    ),
  );
}
