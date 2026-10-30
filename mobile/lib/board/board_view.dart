import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../game.dart';
import '../ui/sapo_widgets.dart';
import 'spiral_layout.dart';

class SpiralBoardView extends StatelessWidget {
  const SpiralBoardView({
    super.key,
    required this.game,
    required this.animate,
    this.onInspect,
  });
  final Game game;
  final bool animate;
  final ValueChanged<int>? onInspect;
  @override
  Widget build(BuildContext context) {
    final palette = context.sapo;
    final layout = SpiralLayout.forSize(game.size);
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth, height = constraints.maxHeight;
        if (width < 24 || height < 24) return const SizedBox.shrink();
        final unit = min(
          (width - 16) / layout.columns,
          (height - 16) / (layout.rows * 1.12),
        ).clamp(1.0, 100.0);
        final cell = Size(unit, unit * 1.12),
            content = Size(
              layout.columns * cell.width,
              layout.rows * cell.height,
            );
        Rect tile(BoardPoint p) => Rect.fromLTWH(
          p.column * cell.width,
          p.row * cell.height,
          cell.width,
          cell.height,
        );
        Offset pawn(int player) {
          final position = game.positions[player],
              base = tile(layout.path[position]).center;
          final occupants = [
            for (var i = 0; i < game.names.length; i++)
              if (game.positions[i] == position) i,
          ];
          final order = occupants.indexOf(player);
          if (occupants.length == 1) return base;
          final angle = 2 * pi * order / occupants.length;
          return base +
              Offset(
                cos(angle) * cell.width * .22,
                sin(angle) * cell.height * .22,
              );
        }

        return Center(
          child: InteractiveViewer(
            clipBehavior: Clip.none,
            minScale: 1,
            maxScale: 3,
            boundaryMargin: const EdgeInsets.all(24),
            child: SizedBox(
              width: content.width,
              height: content.height,
              child: GestureDetector(
                onTapUp: onInspect == null
                    ? null
                    : (details) {
                        final point = details.localPosition;
                        for (var i = 0; i < layout.path.length; i++) {
                          if (tile(layout.path[i]).contains(point)) {
                            onInspect!(i);
                            return;
                          }
                        }
                      },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _BoardPainter(game, layout, cell, palette),
                      ),
                    ),
                    for (var i = 0; i < game.names.length; i++)
                      Builder(
                        builder: (context) {
                          final occupants = game.positions
                              .where((p) => p == game.positions[i])
                              .length;
                          final tokenSize =
                                  (game.positions[i] == 0 ||
                                              game.positions[i] ==
                                                  game.goalPosition
                                          ? cell.width *
                                                (occupants > 3 ? .24 : .40)
                                          : occupants > 3
                                          ? cell.width * .40
                                          : cell.width * .73)
                                      .clamp(8.0, 29.0),
                              point = pawn(i);
                          return AnimatedPositioned(
                            key: Key('pawn$i'),
                            duration: Duration(milliseconds: animate ? 280 : 0),
                            curve: Curves.easeInOutCubic,
                            left: point.dx - tokenSize / 2,
                            top: point.dy - tokenSize / 2,
                            child: TokenHop(
                              position: game.positions[i],
                              animate: animate,
                              height: cell.height * .5,
                              child: Semantics(
                                label:
                                    '${game.names[i]}, ${game.positions[i] == 0
                                        ? 'Inicio'
                                        : game.positions[i] == game.goalPosition
                                        ? 'Meta'
                                        : 'casilla ${game.positions[i]}'}',
                                child: Container(
                                  width: tokenSize,
                                  height: tokenSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: HSVColor.fromAHSV(
                                      1,
                                      (i * 137.5) % 360,
                                      .55,
                                      .95,
                                    ).toColor(),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 1.5,
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black38,
                                        offset: Offset(0, 2),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Center(
                                        child: FittedBox(
                                          child: Text(
                                            game.icons[i],
                                            style: TextStyle(
                                              fontSize: tokenSize * .72,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        right: -3,
                                        bottom: -3,
                                        child: Container(
                                          padding: const EdgeInsets.all(1.5),
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF102D34),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              fontSize: max(6, tokenSize * .30),
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BoardPainter extends CustomPainter {
  _BoardPainter(this.game, this.layout, this.cell, this.palette);
  final Game game;
  final SpiralLayout layout;
  final Size cell;
  final SapoPalette palette;
  bool get dark => identical(palette, SapoPalette.dark);
  Rect tile(BoardPoint p) => Rect.fromLTWH(
    p.column * cell.width,
    p.row * cell.height,
    cell.width,
    cell.height,
  );
  void text(
    Canvas canvas,
    String value,
    Offset center,
    double size,
    Color color, {
    double? maxWidth,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxWidth ?? cell.width * .92);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
    painter.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final board = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        0,
        0,
        cell.width * layout.columns,
        cell.height * layout.rows,
      ),
      Radius.circular(cell.width * .32),
    );
    canvas.drawShadow(Path()..addRRect(board), palette.shadow, 7, true);
    canvas.drawRRect(board, Paint()..color = palette.boardFill);
    canvas.drawRRect(
      board,
      Paint()
        ..color = palette.boardLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.save();
    canvas.clipRRect(board);
    for (var i = 1; i <= game.size; i++) {
      final cat = game.board[i], rect = tile(layout.path[i]).deflate(.8);
      final accent = palette.category(cat),
          color = Color.lerp(accent, palette.boardFill, dark ? .78 : .84)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell.width * .05)),
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color.lerp(color, accent, .10)!, color],
          ).createShader(rect),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(cell.width * .05)),
        Paint()
          ..color = accent.withValues(alpha: .75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = .8,
      );
      if (game.positions[game.turn] == i) {
        canvas.drawRect(
          rect.deflate(1),
          Paint()
            ..color = palette.chipActiveLine
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      text(
        canvas,
        '$i',
        Offset(rect.right - cell.width * .27, rect.bottom - cell.height * .22),
        max(7, cell.width * .29),
        palette.text,
      );
      text(
        canvas,
        {1: 'V', 2: 'B', 3: 'R', 4: 'M', 5: 'E'}[cat]!,
        Offset(rect.left + cell.width * .30, rect.top + cell.height * .29),
        max(6, cell.width * .23),
        accent,
      );
    }
    for (final isStart in [true, false]) {
      final index = isStart ? 0 : game.goalPosition;
      final rect = tile(layout.path[index]).deflate(cell.width * .08);
      final shape = Path()..addOval(rect);
      canvas.drawShadow(shape, palette.shadow, 4, true);
      canvas.drawOval(rect, Paint()..color = palette.markerFill);
      canvas.drawOval(
        rect,
        Paint()
          ..color = palette.markerLine
          ..style = PaintingStyle.stroke
          ..strokeWidth = max(1.5, cell.width * .06),
      );
      if (game.positions[game.turn] == index) {
        canvas.drawOval(
          rect.deflate(2),
          Paint()
            ..color = dark ? Colors.white : ink
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      text(
        canvas,
        isStart ? 'INICIO' : 'META',
        rect.center,
        max(7, cell.width * .17),
        palette.markerText,
      );
    }
    canvas.restore();
    // Flechas de giro: indican que el recorrido sigue alrededor de los bordes.
    final arrowPaint = Paint()
      ..color = palette.chipActiveLine.withValues(alpha: .6);
    for (var i = 0; i < layout.path.length - 1; i++) {
      final from = layout.path[i], to = layout.path[i + 1];
      if (i > 1) {
        final previous = layout.path[i - 1];
        if (from.column - previous.column == to.column - from.column &&
            from.row - previous.row == to.row - from.row) {
          continue;
        }
      }
      final a = tile(from).center,
          b = tile(to).center,
          mid = Offset.lerp(a, b, .49)!,
          delta = (b - a) / ((b - a).distance),
          side = Offset(-delta.dy, delta.dx),
          r = cell.width * .08;
      canvas.drawPath(
        Path()
          ..moveTo((mid + delta * r).dx, (mid + delta * r).dy)
          ..lineTo(
            (mid - delta * r + side * r).dx,
            (mid - delta * r + side * r).dy,
          )
          ..lineTo(
            (mid - delta * r - side * r).dx,
            (mid - delta * r - side * r).dy,
          )
          ..close(),
        arrowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) => true;
  @override
  SemanticsBuilderCallback get semanticsBuilder =>
      (size) => [
        for (var i = 1; i <= game.size; i++)
          CustomPainterSemantics(
            rect: tile(layout.path[i]),
            properties: SemanticsProperties(
              label: 'Casilla $i, ${categories[game.board[i]]}',
              textDirection: TextDirection.ltr,
            ),
          ),
        CustomPainterSemantics(
          rect: tile(layout.path.first),
          properties: const SemanticsProperties(
            label: 'Marcador de inicio',
            textDirection: TextDirection.ltr,
          ),
        ),
        CustomPainterSemantics(
          rect: tile(layout.path.last),
          properties: const SemanticsProperties(
            label: 'Marcador de meta',
            textDirection: TextDirection.ltr,
          ),
        ),
      ];
  @override
  bool shouldRebuildSemantics(covariant _BoardPainter oldDelegate) => true;
}

/// Salto de la ficha: cada cambio de casilla dibuja un arco y un leve
/// aplastamiento al aterrizar. El destino lo fija `AnimatedPositioned`, así
/// que la ficha siempre termina centrada dentro de la casilla.
class TokenHop extends StatefulWidget {
  const TokenHop({
    super.key,
    required this.position,
    required this.animate,
    required this.height,
    required this.child,
  });
  final int position;
  final bool animate;
  final double height;
  final Widget child;
  @override
  State<TokenHop> createState() => _TokenHopState();
}

class _TokenHopState extends State<TokenHop>
    with SingleTickerProviderStateMixin {
  late final hop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  );
  @override
  void didUpdateWidget(covariant TokenHop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && oldWidget.position != widget.position) {
      hop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    hop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: hop,
    child: widget.child,
    builder: (context, child) {
      final t = hop.value,
          lift = hop.isAnimating ? sin(pi * min(t / .85, 1)) : 0.0,
          squash = t > .85 && hop.isAnimating ? sin(pi * (t - .85) / .15) : 0.0;
      return Transform.translate(
        offset: Offset(0, -lift * widget.height),
        child: Transform(
          alignment: Alignment.bottomCenter,
          transform: Matrix4.diagonal3Values(
            1 + .18 * squash,
            1 - .2 * squash,
            1,
          ),
          child: child,
        ),
      );
    },
  );
}
