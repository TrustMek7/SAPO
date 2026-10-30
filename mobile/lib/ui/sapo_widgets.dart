import 'package:flutter/material.dart';

import 'sapo_theme.dart';

export 'sapo_theme.dart';

const brandName = 'S.A.P.O.';
const brandMotto = 'El juego donde nadie sale limpio';

/// Colores de categoría del tema oscuro. En pantalla usar
/// `context.sapo.category(cat)`, que cambia con el tema.
const colors = [
  Colors.grey,
  Color(0xFF34D399),
  Color(0xFFFBBF24),
  Color(0xFFF472B6),
  Color(0xFF38BDF8),
  Color(0xFFA78BFA),
  Color(0xFFC4F447),
  Color(0xFFFB6B4B),
];
const avatars = [
  '🐸',
  '🪩',
  '👑',
  '🍕',
  '💎',
  '👽',
  '🍻',
  '⚽',
  '🦊',
  '🐼',
  '🐯',
  '🦁',
  '🐙',
  '🦄',
  '🐝',
  '🚀',
];

Widget action(String text, VoidCallback? pressed, {Key? key}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: FilledButton(key: key, onPressed: pressed, child: Text(text)),
);
void open(BuildContext context, Widget screen) =>
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));

/// Las animaciones decorativas en bucle (logo vivo) se apagan cuando el
/// usuario desactiva animaciones, cuando el sistema pide reducir movimiento y
/// bajo los bindings de prueba, donde un bucle infinito impide `pumpAndSettle`.
bool ambientMotion(BuildContext context, {required bool enabled}) =>
    enabled &&
    !MediaQuery.disableAnimationsOf(context) &&
    !WidgetsBinding.instance.runtimeType.toString().contains('TestWidgets');

class PartyBackdrop extends StatelessWidget {
  const PartyBackdrop({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.sapo.bg,
    child: CustomPaint(painter: _Bubbles(context.sapo.bubble), child: child),
  );
}

class _Bubbles extends CustomPainter {
  _Bubbles(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (final point in [
      Offset(-.05, .15),
      Offset(.95, .34),
      Offset(.12, .97),
      Offset(.88, .94),
      Offset(.76, .02),
    ]) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        size.shortestSide * .18,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _Bubbles oldDelegate) =>
      oldDelegate.color != color;
}
