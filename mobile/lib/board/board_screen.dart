import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controller.dart';
import '../game.dart';
import '../minigame.dart';
import '../ui/sapo_widgets.dart';
import 'board_view.dart';
import 'confetti.dart';
import 'dice.dart';

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});
  @override
  ConsumerState<BoardScreen> createState() => _BoardState();
}

class _BoardState extends ConsumerState<BoardScreen> {
  bool busy = false, rolling = false;
  Future<void> run(Future<void> Function() task, {bool roll = false}) async {
    if (busy) return;
    setState(() {
      busy = true;
      rolling = roll;
    });
    try {
      await task();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo guardar. Intenta de nuevo.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          busy = false;
          rolling = false;
        });
      }
    }
  }

  String position(Game g, int i) => g.positions[i] == 0
      ? 'Inicio'
      : g.positions[i] == g.goalPosition
      ? 'Meta'
      : 'Casilla ${g.positions[i]}';
  String positionLabel(Game g, int position) => position == 0
      ? 'Inicio'
      : position == g.goalPosition
      ? 'Meta'
      : 'Casilla $position';
  Widget players(Game g) => SizedBox(
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: g.names.length,
      separatorBuilder: (_, i) => const SizedBox(width: 7),
      itemBuilder: (context, i) => Chip(
        backgroundColor: i == g.turn
            ? context.sapo.chipActive
            : context.sapo.surface,
        side: BorderSide(
          color: i == g.turn ? context.sapo.chipActiveLine : context.sapo.line,
        ),
        avatar: Text(g.icons[i]),
        label: Text(
          '${i + 1}. ${g.names[i]} · ${position(g, i)}${g.shields[i] ? ' 🛡' : ''}${g.skips[i] > 0 ? ' ⏸' : ''}',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
  Widget turn(AppController c, Game g) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: ClipRect(
      child: AnimatedSwitcher(
        duration: Duration(
          milliseconds: c.settings['animation'] == true ? 320 : 0,
        ),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.centerLeft,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Row(
          key: ValueKey(g.turn),
          children: [
            Text(g.icons[g.turn], style: const TextStyle(fontSize: 27)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Turno de ${g.names[g.turn]}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: titleFont, fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    ),
  );
  Widget rules(Game g) => g.rules.isEmpty
      ? const SizedBox.shrink()
      : SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final rule in g.rules)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Chip(
                    avatar: const Icon(Icons.rule, size: 16),
                    label: Text(
                      '${rule['text']} · ${rule['remaining']} turnos',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
        );
  Widget dice(AppController c, Game g, {bool compact = false}) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      VisualDice(
        value: g.die,
        rolling: rolling,
        animate: c.settings['animation'] == true,
        size: compact ? 66 : 86,
        onRoll: busy || g.pending != null || g.winner != null
            ? null
            : () => run(() async {
                if (c.settings['animation'] == true) {
                  await Future<void>.delayed(diceRollDuration);
                }
                if (!mounted) return;
                await c.roll(
                  onResult: c.settings['animation'] == true
                      ? (_) async {
                          if (mounted) setState(() => rolling = false);
                          await Future<void>.delayed(diceResultPause);
                        }
                      : null,
                );
              }, roll: true),
      ),
      Text(
        rolling
            ? '¡Que decida la suerte!'
            : busy
            ? 'Resultado: ${g.die}'
            : g.pending != null
            ? 'Resuelve la tarjeta'
            : g.die == 0
            ? 'Toca el dado para lanzar'
            : 'Último dado: ${g.die} · Toca para lanzar',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: context.sapo.muted),
      ),
    ],
  );
  Widget legend(Game g) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 10,
    runSpacing: 3,
    children: [
      for (final cat in playableCategories.where(g.enabled.contains))
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: context.sapo.category(cat),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              {1: 'Verdad', 2: 'Bebe', 3: 'Reto', 4: 'Mini', 5: 'Evento'}[cat]!,
              style: TextStyle(fontSize: 10, color: context.sapo.muted),
            ),
          ],
        ),
    ],
  );
  void inspect(Game g, int index) {
    final names = [
      for (var i = 0; i < g.names.length; i++)
        if (g.positions[i] == index) g.names[i],
    ];
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 2),
        content: Text(
          '${index == 0
              ? 'Marcador de inicio'
              : index == g.goalPosition
              ? 'Marcador de meta'
              : 'Casilla $index · ${categories[g.board[index]]}'}${names.isEmpty ? '' : ' — ${names.join(', ')}'}',
        ),
      ),
    );
  }

  Widget card(AppController c, Game g) {
    final palette = context.sapo,
        p = g.pending!,
        cat = p['category'] as int,
        accent = palette.category(cat);
    final isQuestion = cat == 1, animate = c.settings['animation'] == true;
    return Stack(
      children: [
        Positioned.fill(
          child: ModalBarrier(color: palette.scrim, dismissible: false),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              // La tarjeta entra volteándose desde el canto con un rebote suave.
              child: TweenAnimationBuilder<double>(
                key: ValueKey('${g.turn}:${p['id'] ?? p['text']}'),
                tween: Tween(begin: animate ? 0 : 1, end: 1),
                duration: Duration(milliseconds: animate ? 420 : 0),
                curve: Curves.easeOutBack,
                builder: (context, t, child) => Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, .0012)
                    ..rotateY((1 - t) * pi / 2)
                    ..scaleByDouble(.7 + .3 * t, .7 + .3 * t, 1, 1),
                  child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.lerp(accent, palette.card, .88)!,
                        palette.card,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: accent, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow,
                        offset: const Offset(0, 12),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    primary: false,
                    padding: const EdgeInsets.all(21),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          categories[cat].toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: titleFont,
                            fontSize: 32,
                            letterSpacing: .5,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(color: accent),
                        const SizedBox(height: 8),
                        Text(
                          p['text'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            color: palette.text,
                          ),
                        ),
                        if (cat == 5 && p['movementFrom'] != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            '${positionLabel(g, p['movementFrom'] as int)} → ${positionLabel(g, p['movementTo'] as int)}',
                            key: const Key('movementResult'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.accentText,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                        if (cat == 2)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              'Cada persona decide si participa.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: palette.muted),
                            ),
                          ),
                        const SizedBox(height: 16),
                        if (p['kind'] != null)
                          action(
                            'Abrir dinámica',
                            busy
                                ? null
                                : () async {
                                    await showDialog<void>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => MiniGameScreen(
                                        kind: p['kind'],
                                        embedded: true,
                                      ),
                                    );
                                    if (mounted) setState(() {});
                                  },
                          ),
                        action(
                          cat == 5
                              ? 'Aplicar evento'
                              : isQuestion
                              ? 'Respondí'
                              : cat == 3 || cat == 7
                              ? 'Reto cumplido'
                              : 'Finalizar dinámica',
                          busy
                              ? null
                              : () => run(() => c.finish(applyEvent: cat == 5)),
                        ),
                        if (cat == 1 || cat == 3 || cat == 7)
                          action(
                            'Tomar y continuar',
                            busy ? null : () => run(() => c.finish()),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget victory(AppController c, Game g) {
    final palette = context.sapo,
        animate = c.settings['animation'] == true,
        winner = g.names[g.winner!];
    return Stack(
      children: [
        Positioned.fill(
          child: ModalBarrier(color: palette.scrim, dismissible: false),
        ),
        if (animate)
          Positioned.fill(
            child: IgnorePointer(child: Confetti(colors: palette.categories)),
          ),
        Center(
          child: Card(
            color: palette.card,
            margin: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              primary: false,
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: animate ? 0 : 1, end: 1),
                    duration: Duration(milliseconds: animate ? 700 : 0),
                    curve: Curves.elasticOut,
                    builder: (context, t, child) => Transform.rotate(
                      angle: (1 - t) * -.35,
                      child: Transform.scale(scale: t, child: child),
                    ),
                    child: const Text('🏆', style: TextStyle(fontSize: 72)),
                  ),
                  Text(
                    '¡Ganó $winner!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: titleFont,
                      fontSize: 34,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    key: const Key('winnerReward'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: lime.withValues(alpha: .18),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: palette.chipActiveLine),
                    ),
                    child: Text(
                      '$winner reparte 3 tragos a quien quiera.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: palette.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tomar sigue siendo voluntario.',
                    style: TextStyle(fontSize: 12, color: palette.muted),
                  ),
                  const SizedBox(height: 18),
                  action(
                    'Volver al inicio',
                    () => Navigator.of(context).popUntil((r) => r.isFirst),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appProvider);
    final c = ref.read(appProvider.notifier), g = c.game!;
    return Scaffold(
      appBar: AppBar(
        title: const Text(brandName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${g.size} casillas',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: PartyBackdrop(
        child: LayoutBuilder(
          builder: (context, box) {
            final wide = box.maxWidth > box.maxHeight * 1.25;
            final board = SpiralBoardView(
              game: g,
              animate: c.settings['animation'] == true,
              onInspect: (index) => inspect(g, index),
            );
            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
                  child: wide
                      ? Row(
                          children: [
                            Expanded(child: board),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 210,
                              child: SingleChildScrollView(
                                primary: false,
                                child: Column(
                                  children: [
                                    turn(c, g),
                                    players(g),
                                    rules(g),
                                    dice(c, g, compact: true),
                                    const SizedBox(height: 6),
                                    legend(g),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            turn(c, g),
                            players(g),
                            rules(g),
                            Expanded(child: board),
                            legend(g),
                            const SizedBox(height: 4),
                            dice(c, g),
                          ],
                        ),
                ),
                if (g.pending != null && g.winner == null)
                  Positioned.fill(child: card(c, g)),
                if (g.winner != null) Positioned.fill(child: victory(c, g)),
              ],
            );
          },
        ),
      ),
    );
  }
}
