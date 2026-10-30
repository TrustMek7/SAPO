import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'sapo_theme.dart';

const _green = Color(0xFF7FD95D);
const _belly = Color(0xFFA8EB7E);
const _pink = Color(0xFFF472B6);
const _amber = Color(0xFFFBBF24);
const _foamLine = Color(0xFFFFDE87);

/// Sapo de la marca. Con [animate] flota, mece la bebida, parpadea y alterna
/// cada [cycle] entre brindis, shot con guiño y cóctel con sorbete. Tocarlo
/// pasa al siguiente sapo.
class SapoLogo extends StatefulWidget {
  const SapoLogo({
    super.key,
    this.size = 184,
    this.animate = true,
    this.cycle = const Duration(milliseconds: 4800),
  });
  final double size;
  final bool animate;
  final Duration cycle;
  static const labels = [
    'sapo brindando con un tarro de cerveza',
    'sapo guiñando el ojo con un shot',
    'sapo tomando un cóctel con sorbete',
  ];
  @override
  State<SapoLogo> createState() => _SapoLogoState();
}

class _SapoLogoState extends State<SapoLogo>
    with SingleTickerProviderStateMixin {
  late final motion = AnimationController(vsync: this, duration: widget.cycle);
  Timer? swap;
  int variant = 0;

  @override
  void initState() {
    super.initState();
    sync();
  }

  @override
  void didUpdateWidget(covariant SapoLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) sync();
  }

  void sync() {
    swap?.cancel();
    if (widget.animate) {
      motion.repeat();
      swap = Timer.periodic(widget.cycle, (_) => next());
    } else {
      motion
        ..stop()
        ..value = 0;
    }
  }

  void next() {
    if (mounted) setState(() => variant = (variant + 1) % 3);
  }

  @override
  void dispose() {
    swap?.cancel();
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.sapo, inner = widget.size * .89;
    return Semantics(
      label: 'Logo de S.A.P.O.: ${SapoLogo.labels[variant]}',
      button: true,
      child: GestureDetector(
        onTap: next,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: lime,
            border: Border.all(color: p.logoRing, width: widget.size / 46),
            boxShadow: [
              BoxShadow(
                color: p.shadow,
                offset: Offset(0, widget.size * .05),
                blurRadius: widget.size * .12,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: widget.animate ? 450 : 0),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: AnimatedBuilder(
              key: ValueKey(variant),
              animation: motion,
              builder: (context, _) => CustomPaint(
                size: Size.square(inner),
                painter: FrogPainter(variant, motion.value),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Dibuja el sapo en un lienzo de 200×200 unidades. [t] es la fase 0..1 del
/// ciclo: dos balanceos, un parpadeo y burbujas que suben.
class FrogPainter extends CustomPainter {
  FrogPainter(this.variant, this.t);
  final int variant;
  final double t;

  Paint fill(Color c) => Paint()..color = c;
  Paint stroke([double w = 5, Color c = ink]) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  void both(Canvas canvas, Path path, Color color, [double w = 5]) => canvas
    ..drawPath(path, fill(color))
    ..drawPath(path, stroke(w));

  @override
  void paint(Canvas canvas, Size size) {
    final wave = sin(2 * pi * t * 2),
        sway = -(1 - cos(2 * pi * t * 2)) / 2 * 14 * pi / 180,
        blink = t > .9 && t < .96
            ? .12 + .88 * (cos((t - .9) / .06 * 2 * pi) + 1) / 2
            : 1.0;
    canvas
      ..save()
      ..scale(size.width / 200)
      ..translate(0, -wave * 6);
    final shift = variant == 2 ? -4.0 : 0.0, lx = 60 + shift, rx = 124 + shift;
    for (final x in [lx, rx]) {
      both(canvas, Path()..addOval(_circle(x, 64, 24)), _green);
    }
    both(
      canvas,
      Path()..addOval(
        Rect.fromCenter(
          center: Offset(92 + shift, 116),
          width: 144,
          height: 112,
        ),
      ),
      _green,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(92 + shift, 137), width: 88, height: 46),
      fill(_belly),
    );
    switch (variant) {
      case 0:
        eye(canvas, lx, 5, blink);
        eye(canvas, rx, 5, blink);
        cheek(canvas, 46);
        canvas.drawPath(
          Path()
            ..moveTo(58, 120)
            ..quadraticBezierTo(88, 148, 118, 122),
          stroke(),
        );
        mug(canvas, sway);
      case 1:
        canvas.drawPath(
          Path()
            ..moveTo(47, 62)
            ..quadraticBezierTo(60, 52, 73, 62),
          stroke(),
        );
        eye(canvas, rx, 3, blink);
        final mouth = Path()
          ..moveTo(60, 114)
          ..quadraticBezierTo(90, 152, 120, 114)
          ..close();
        both(canvas, mouth, ink);
        canvas
          ..save()
          ..clipPath(mouth)
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(92, 132),
              width: 28,
              height: 14,
            ),
            fill(_pink),
          )
          ..restore();
        cheek(canvas, 44);
        shot(canvas, sway);
      default:
        eye(canvas, lx, 2, blink, pupil: 6, dy: 4);
        eye(canvas, rx, 2, blink, pupil: 6, dy: 4);
        for (final x in [lx, rx]) {
          both(
            canvas,
            Path()
              ..moveTo(x - 14, 60)
              ..arcToPoint(
                Offset(x + 14, 60),
                radius: const Radius.circular(14),
              )
              ..close(),
            _green,
            4,
          );
        }
        cheek(canvas, 42);
        canvas.drawPath(
          Path()
            ..moveTo(62, 122)
            ..quadraticBezierTo(84, 138, 104, 124),
          stroke(),
        );
        cocktail(canvas);
    }
    canvas.restore();
  }

  Rect _circle(double x, double y, double r) =>
      Rect.fromCircle(center: Offset(x, y), radius: r);

  void eye(
    Canvas canvas,
    double x,
    double look,
    double blink, {
    double pupil = 7,
    double dy = 1,
  }) {
    canvas
      ..save()
      ..translate(x, 60)
      ..scale(1, blink)
      ..translate(-x, -60);
    both(canvas, Path()..addOval(_circle(x, 60, 14)), Colors.white, 4);
    canvas
      ..drawCircle(Offset(x + look, 60 + dy), pupil, fill(ink))
      ..restore();
  }

  void cheek(Canvas canvas, double x) => canvas.drawOval(
    Rect.fromCenter(center: Offset(x, 117), width: 18, height: 12),
    fill(_pink.withValues(alpha: .7)),
  );

  void pivot(Canvas canvas, Offset at, double angle) => canvas
    ..translate(at.dx, at.dy)
    ..rotate(angle)
    ..translate(-at.dx, -at.dy);

  void mug(Canvas canvas, double sway) {
    canvas.save();
    pivot(canvas, const Offset(134, 142), sway);
    pivot(canvas, const Offset(150, 130), -12 * pi / 180);
    canvas.drawPath(
      Path()
        ..moveTo(170, 114)
        ..lineTo(178, 114)
        ..arcToPoint(const Offset(188, 124), radius: const Radius.circular(10))
        ..lineTo(188, 138)
        ..arcToPoint(const Offset(178, 148), radius: const Radius.circular(10))
        ..lineTo(170, 148),
      stroke(),
    );
    both(
      canvas,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(132, 102, 40, 58),
          const Radius.circular(7),
        ),
      ),
      _amber,
    );
    canvas.drawPath(
      Path()
        ..moveTo(144, 118)
        ..lineTo(144, 148)
        ..moveTo(158, 118)
        ..lineTo(158, 148),
      stroke(4, _foamLine),
    );
    both(
      canvas,
      Path()
        ..moveTo(128, 106)
        ..relativeArcToPoint(
          const Offset(12, -12),
          radius: const Radius.circular(9),
        )
        ..relativeArcToPoint(
          const Offset(18, -2),
          radius: const Radius.circular(10),
        )
        ..relativeArcToPoint(
          const Offset(16, 6),
          radius: const Radius.circular(9),
        )
        ..relativeArcToPoint(
          const Offset(-2, 12),
          radius: const Radius.circular(7),
        )
        ..lineTo(132, 110)
        ..relativeArcToPoint(
          const Offset(-4, -4),
          radius: const Radius.circular(7),
        )
        ..close(),
      Colors.white,
    );
    bubbles(canvas, const [Offset(146, 88), Offset(160, 84), Offset(152, 90)]);
    both(
      canvas,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(134, 142), width: 22, height: 18),
      ),
      _green,
    );
    canvas.restore();
  }

  void shot(Canvas canvas, double sway) {
    canvas.save();
    pivot(canvas, const Offset(142, 140), sway * .7);
    pivot(canvas, const Offset(158, 128), 14 * pi / 180);
    canvas
      ..drawPath(
        Path()
          ..moveTo(143, 116)
          ..lineTo(173, 116)
          ..lineTo(169, 152)
          ..lineTo(147, 152)
          ..close(),
        fill(_amber),
      )
      ..drawPath(
        Path()
          ..moveTo(138, 100)
          ..lineTo(178, 100)
          ..lineTo(170, 154)
          ..lineTo(146, 154)
          ..close(),
        stroke(),
      );
    bubbles(canvas, const [
      Offset(152, 112),
      Offset(164, 110),
      Offset(158, 114),
    ]);
    both(
      canvas,
      Path()..addOval(
        Rect.fromCenter(center: const Offset(142, 140), width: 22, height: 18),
      ),
      _green,
    );
    canvas.restore();
  }

  void cocktail(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(162, 128)
        ..lineTo(162, 160)
        ..moveTo(146, 162)
        ..lineTo(178, 162),
      stroke(),
    );
    both(
      canvas,
      Path()
        ..moveTo(134, 96)
        ..lineTo(190, 96)
        ..lineTo(162, 128)
        ..close(),
      _pink,
    );
    const mouth = Offset(108, 124), glass = Offset(160, 86);
    canvas
      ..drawLine(mouth, glass, stroke(11))
      ..drawLine(mouth, glass, stroke(5, lime));
    // Sorbo: una gota sube por el sorbete hacia la boca.
    final sip = (t * 2) % 1;
    canvas
      ..drawCircle(Offset.lerp(glass, mouth, sip)!, 3.2, fill(_pink))
      ..drawCircle(const Offset(184, 94), 10, fill(lime))
      ..drawCircle(const Offset(184, 94), 10, stroke(4))
      ..drawCircle(mouth, 5, fill(ink));
  }

  void bubbles(Canvas canvas, List<Offset> starts) {
    for (var i = 0; i < starts.length; i++) {
      final phase = (t * 2 + i * .33) % 1;
      if (phase < .05) continue;
      final opacity = phase < .2 ? phase / .2 : 1 - (phase - .2) / .8;
      canvas.drawCircle(
        starts[i] - Offset(0, phase * 30),
        4 - i * .6,
        fill(Colors.white.withValues(alpha: opacity.clamp(0, 1))),
      );
    }
  }

  @override
  bool shouldRepaint(covariant FrogPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.variant != variant;
}
