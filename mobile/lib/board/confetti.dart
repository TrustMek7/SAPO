import 'dart:math';

import 'package:flutter/material.dart';

/// Lluvia de confeti de una sola pasada para la victoria. Usa los colores de
/// categoría del tema y termina sola, sin bucles.
class Confetti extends StatefulWidget {
  const Confetti({
    super.key,
    required this.colors,
    this.count = 70,
    this.duration = const Duration(milliseconds: 3200),
  });
  final List<Color> colors;
  final int count;
  final Duration duration;
  @override
  State<Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<Confetti>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();
  late final pieces = List.generate(widget.count, (i) {
    final r = Random(i * 7919);
    return _Piece(
      x: r.nextDouble(),
      delay: r.nextDouble() * .35,
      speed: .75 + r.nextDouble() * .5,
      drift: (r.nextDouble() - .5) * .25,
      spin: (r.nextDouble() - .5) * 18,
      size: 6 + r.nextDouble() * 6,
      color: widget.colors[1 + i % (widget.colors.length - 1)],
    );
  });

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: controller,
    builder: (context, _) => CustomPaint(
      size: Size.infinite,
      painter: _ConfettiPainter(pieces, controller.value),
    ),
  );
}

class _Piece {
  const _Piece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.spin,
    required this.size,
    required this.color,
  });
  final double x, delay, speed, drift, spin, size;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.pieces, this.t);
  final List<_Piece> pieces;
  final double t;
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in pieces) {
      final local = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (local == 0 || local == 1) continue;
      final fall = Curves.easeIn.transform(local) * p.speed;
      final position = Offset(
        (p.x + p.drift * local + sin(local * 9 + p.x * 6) * .02) * size.width,
        -20 + fall * (size.height + 40),
      );
      final opacity = local > .8 ? (1 - local) / .2 : 1.0;
      canvas
        ..save()
        ..translate(position.dx, position.dy)
        ..rotate(p.spin * local)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size,
              // Simula el giro en 3D estrechando el papel.
              height: p.size * 1.5 * cos(local * p.spin).abs().clamp(.25, 1),
            ),
            const Radius.circular(2),
          ),
          Paint()..color = p.color.withValues(alpha: opacity),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}
