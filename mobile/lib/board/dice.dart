import 'dart:math';

import 'package:flutter/material.dart';

const diceRollDuration = Duration(milliseconds: 2000);
const diceSettleDuration = Duration(milliseconds: 450);
const diceResultPause = Duration(milliseconds: 750);

/// Unit quaternion: one orientation for the entire solid, never separate faces.
class DiceRotation {
  const DiceRotation(this.x, this.y, this.z, this.w);
  final double x, y, z, w;
  factory DiceRotation.axis(double x, double y, double z, double angle) {
    final s = sin(angle / 2);
    return DiceRotation(x * s, y * s, z * s, cos(angle / 2));
  }
  DiceRotation operator *(DiceRotation b) => DiceRotation(
    w * b.x + x * b.w + y * b.z - z * b.y,
    w * b.y - x * b.z + y * b.w + z * b.x,
    w * b.z + x * b.y - y * b.x + z * b.w,
    w * b.w - x * b.x - y * b.y - z * b.z,
  );
  DicePoint rotate(DicePoint p) {
    final tx = 2 * (y * p.z - z * p.y),
        ty = 2 * (z * p.x - x * p.z),
        tz = 2 * (x * p.y - y * p.x);
    return DicePoint(
      p.x + w * tx + y * tz - z * ty,
      p.y + w * ty + z * tx - x * tz,
      p.z + w * tz + x * ty - y * tx,
    );
  }

  static DiceRotation forValue(int value) {
    final base = switch (value) {
      2 => DiceRotation.axis(0, 1, 0, -pi / 2),
      3 => DiceRotation.axis(1, 0, 0, -pi / 2),
      4 => DiceRotation.axis(1, 0, 0, pi / 2),
      5 => DiceRotation.axis(0, 1, 0, pi / 2),
      6 => DiceRotation.axis(0, 1, 0, pi),
      _ => const DiceRotation(0, 0, 0, 1),
    };
    return DiceRotation.axis(1, 0, 0, -.36) *
        DiceRotation.axis(0, 1, 0, -.48) *
        base;
  }

  static DiceRotation tumble(double t) =>
      DiceRotation.axis(0, 0, 1, sin(t * 2 * pi) * .35) *
      DiceRotation.axis(1, 0, 0, -.36 + t * 4 * pi) *
      DiceRotation.axis(0, 1, 0, -.48 + t * 6 * pi);

  DiceRotation towards(DiceRotation b, double t) {
    var dot = x * b.x + y * b.y + z * b.z + w * b.w;
    final sign = dot < 0 ? -1.0 : 1.0;
    dot = dot.abs().clamp(0.0, 1.0);
    final angle = acos(dot);
    final aWeight = angle < .001 ? 1 - t : sin((1 - t) * angle) / sin(angle);
    final bWeight = (angle < .001 ? t : sin(t * angle) / sin(angle)) * sign;
    final q = DiceRotation(
      x * aWeight + b.x * bWeight,
      y * aWeight + b.y * bWeight,
      z * aWeight + b.z * bWeight,
      w * aWeight + b.w * bWeight,
    );
    final length = sqrt(q.x * q.x + q.y * q.y + q.z * q.z + q.w * q.w);
    return DiceRotation(q.x / length, q.y / length, q.z / length, q.w / length);
  }
}

class DicePoint {
  const DicePoint(this.x, this.y, this.z);
  final double x, y, z;
  DicePoint operator +(DicePoint b) => DicePoint(x + b.x, y + b.y, z + b.z);
  DicePoint operator *(double s) => DicePoint(x * s, y * s, z * s);
}

class VisualDice extends StatefulWidget {
  const VisualDice({
    super.key,
    required this.value,
    required this.rolling,
    required this.animate,
    required this.onRoll,
    this.size = 90,
  });
  final int value;
  final bool rolling, animate;
  final VoidCallback? onRoll;
  final double size;
  @override
  State<VisualDice> createState() => _VisualDiceState();
}

class _VisualDiceState extends State<VisualDice>
    with SingleTickerProviderStateMixin {
  late final animation = AnimationController(
    vsync: this,
    duration: diceRollDuration,
  );
  late DiceRotation from = DiceRotation.forValue(widget.value), to = from;
  DiceRotation get rotation => widget.rolling && widget.animate
      ? DiceRotation.tumble(animation.value)
      : from.towards(to, Curves.easeOutCubic.transform(animation.value));
  @override
  void initState() {
    super.initState();
    if (widget.rolling && widget.animate) animation.repeat();
  }

  @override
  void didUpdateWidget(covariant VisualDice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rolling && widget.animate) {
      if (!oldWidget.rolling || !oldWidget.animate) {
        animation.duration = diceRollDuration;
        animation.value = 0;
        animation.repeat();
      }
    } else if (oldWidget.rolling ||
        oldWidget.value != widget.value ||
        oldWidget.animate != widget.animate) {
      // Capture the previous orientation before changing the controller.
      from = oldWidget.rolling && oldWidget.animate
          ? DiceRotation.tumble(animation.value)
          : from.towards(to, Curves.easeOutCubic.transform(animation.value));
      to = DiceRotation.forValue(widget.value);
      animation.stop();
      if (widget.animate) {
        animation.duration = diceSettleDuration;
        animation.forward(from: 0);
      } else {
        from = to;
        animation.value = 1;
      }
    }
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    label:
        'Dado de seis caras. ${widget.rolling
            ? 'Girando'
            : widget.value > 0
            ? 'Último resultado ${widget.value}'
            : 'Listo para lanzar'}',
    button: true,
    onTap: widget.onRoll,
    excludeSemantics: true,
    child: FilledButton(
      key: const Key('roll'),
      onPressed: widget.onRoll,
      style: FilledButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(widget.size + 18, widget.size + 18),
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, child) => CustomPaint(
          size: Size.square(widget.size),
          painter: DicePainter(widget.value.clamp(1, 6), rotation: rotation),
        ),
      ),
    ),
  );
}

class _CubeFace {
  const _CubeFace(this.value, this.normal, this.u, this.v);
  final int value;
  final DicePoint normal, u, v;
  DicePoint point(double x, double y) => normal + u * x + v * y;
}

class ProjectedDiceFace {
  ProjectedDiceFace(this.value, this.corners, this.depth, this.normalZ);
  final int value;
  final List<Offset> corners;
  final double depth, normalZ;
}

class DicePainter extends CustomPainter {
  DicePainter(this.value, {DiceRotation? rotation})
    : rotation = rotation ?? DiceRotation.forValue(value);
  final int value;
  final DiceRotation rotation;
  static const _faces = [
    _CubeFace(1, DicePoint(0, 0, 1), DicePoint(1, 0, 0), DicePoint(0, 1, 0)),
    _CubeFace(6, DicePoint(0, 0, -1), DicePoint(-1, 0, 0), DicePoint(0, 1, 0)),
    _CubeFace(2, DicePoint(1, 0, 0), DicePoint(0, 0, -1), DicePoint(0, 1, 0)),
    _CubeFace(5, DicePoint(-1, 0, 0), DicePoint(0, 0, 1), DicePoint(0, 1, 0)),
    _CubeFace(3, DicePoint(0, -1, 0), DicePoint(1, 0, 0), DicePoint(0, 0, 1)),
    _CubeFace(4, DicePoint(0, 1, 0), DicePoint(1, 0, 0), DicePoint(0, 0, -1)),
  ];
  static const patterns = <int, List<(int, int)>>{
    1: [(1, 1)],
    2: [(0, 0), (2, 2)],
    3: [(0, 0), (1, 1), (2, 2)],
    4: [(0, 0), (2, 0), (0, 2), (2, 2)],
    5: [(0, 0), (2, 0), (1, 1), (0, 2), (2, 2)],
    6: [(0, 0), (2, 0), (0, 1), (2, 1), (0, 2), (2, 2)],
  };
  Offset _project(DicePoint p, Size size) {
    final scale = size.width * .265 * 6 / (6 - p.z);
    return Offset(
      size.width / 2 + p.x * scale,
      size.height * .45 + p.y * scale,
    );
  }

  List<ProjectedDiceFace> projectedFaces(Size size) {
    final result = <ProjectedDiceFace>[];
    for (final face in _faces) {
      final n = rotation.rotate(face.normal);
      // Perspective culling: camera at (0,0,6), not at infinity.
      if (n.z * 6 <= 1) continue;
      result.add(
        ProjectedDiceFace(
          face.value,
          [
            for (final p in [
              (-1.0, -1.0),
              (1.0, -1.0),
              (1.0, 1.0),
              (-1.0, 1.0),
            ])
              _project(rotation.rotate(face.point(p.$1, p.$2)), size),
          ],
          n.z,
          n.z,
        ),
      );
    }
    result.sort((a, b) => a.depth.compareTo(b.depth));
    return result;
  }

  Path _polygon(List<Offset> points) => Path()..addPolygon(points, true);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * .5, size.height * .88),
        width: size.width * .67,
        height: size.height * .11,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: .48)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    for (final projected in projectedFaces(size)) {
      final face = _faces.firstWhere((f) => f.value == projected.value);
      final normal = rotation.rotate(face.normal);
      final light = ((normal.z - normal.y * .45 - normal.x * .35) / 1.15).clamp(
        0.0,
        1.0,
      );
      final color = Color.lerp(
        const Color(0xFF628B8B),
        const Color(0xFFFFFBFF),
        light,
      )!;
      final path = _polygon(projected.corners);
      canvas.drawPath(path, Paint()..color = color);
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF194648)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.3
          ..strokeJoin = StrokeJoin.round,
      );
      canvas.save();
      canvas.clipPath(path);
      for (final (x, y) in patterns[face.value]!) {
        final cx = (x - 1) * .49, cy = (y - 1) * .49;
        final points = [
          for (var i = 0; i < 24; i++)
            _project(
              rotation.rotate(
                face.point(
                  cx + .145 * cos(i * pi / 12),
                  cy + .145 * sin(i * pi / 12),
                ),
              ),
              size,
            ),
        ];
        canvas.drawPath(
          _polygon(points),
          Paint()..color = const Color(0xFF10262C),
        );
        canvas.drawPath(
          _polygon(points),
          Paint()
            ..color = Colors.white.withValues(alpha: .32)
            ..style = PaintingStyle.stroke
            ..strokeWidth = .65,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant DicePainter oldDelegate) =>
      oldDelegate.rotation != rotation || oldDelegate.value != value;
}
