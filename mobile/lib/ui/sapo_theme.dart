import 'package:flutter/material.dart';

const lime = Color(0xFFC4F447);
const ink = Color(0xFF10262C);
const titleFont = 'LilitaOne';

/// Colores propios de S.A.P.O. que Material no cubre. Las pantallas los leen
/// con `context.sapo` para que claro y oscuro compartan el mismo código.
@immutable
class SapoPalette extends ThemeExtension<SapoPalette> {
  const SapoPalette({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.line,
    required this.text,
    required this.muted,
    required this.accentText,
    required this.motto,
    required this.bubble,
    required this.titleShadow,
    required this.logoRing,
    required this.chipActive,
    required this.chipActiveLine,
    required this.scrim,
    required this.card,
    required this.boardFill,
    required this.boardLine,
    required this.markerFill,
    required this.markerLine,
    required this.markerText,
    required this.shadow,
    required this.categories,
  });
  final Color bg, surface, surface2, line, text, muted, accentText, motto;
  final Color bubble, titleShadow, logoRing, chipActive, chipActiveLine;
  final Color scrim, card, boardFill, boardLine, markerFill, markerLine;
  final Color markerText, shadow;

  /// Índices 1–5 = Verdad o Shot, Bebe, Reto, Minijuego, Evento.
  final List<Color> categories;
  Color category(int cat) =>
      categories[cat >= 0 && cat < categories.length ? cat : 0];

  static const dark = SapoPalette(
    bg: Color(0xFF0B1921),
    surface: Color(0xFF152B34),
    surface2: Color(0xFF1C3640),
    line: Color(0xFF2D4A52),
    text: Color(0xFFEEF5F2),
    muted: Color(0xFFA9C2C0),
    accentText: lime,
    motto: Color(0xFFFFDE87),
    bubble: Color(0x1465D6B2),
    titleShadow: Color(0xFF248B79),
    logoRing: Color(0xFFDAFF7A),
    chipActive: Color(0xFF275449),
    chipActiveLine: lime,
    scrim: Color(0xBB050C10),
    card: Color(0xFF10242D),
    boardFill: Color(0xFF142D36),
    boardLine: Color(0xFF3C6467),
    markerFill: Color(0xFF1E4040),
    markerLine: lime,
    markerText: lime,
    shadow: Color(0x99000000),
    categories: [
      Colors.grey,
      Color(0xFF34D399),
      Color(0xFFFBBF24),
      Color(0xFFF472B6),
      Color(0xFF38BDF8),
      Color(0xFFA78BFA),
      lime,
      Color(0xFFFB6B4B),
    ],
  );

  static const light = SapoPalette(
    bg: Color(0xFFF3F6F0),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE8EFEA),
    line: Color(0xFFCBD8D2),
    text: Color(0xFF0E2229),
    muted: Color(0xFF4B6468),
    accentText: Color(0xFF3D6B00),
    motto: Color(0xFF8A5A00),
    bubble: Color(0x0F0F4C52),
    titleShadow: lime,
    logoRing: Color(0xFFFFFFFF),
    chipActive: Color(0xFFE4F7B5),
    chipActiveLine: Color(0xFF6E9A12),
    scrim: Color(0x6B0E2229),
    card: Color(0xFFFFFFFF),
    boardFill: Color(0xFFFFFFFF),
    boardLine: Color(0xFFCBD8D2),
    markerFill: lime,
    markerLine: Color(0xFF6E9A12),
    markerText: ink,
    shadow: Color(0x330E2229),
    categories: [
      Color(0xFF6B7F83),
      Color(0xFF0E8F63),
      Color(0xFFA86A00),
      Color(0xFFC93A78),
      Color(0xFF0277B8),
      Color(0xFF6E4FD8),
      Color(0xFF3D6B00),
      Color(0xFFC2410C),
    ],
  );

  @override
  SapoPalette copyWith() => this;
  @override
  SapoPalette lerp(covariant SapoPalette? other, double t) =>
      other == null || t < .5 ? this : other;
}

extension SapoContext on BuildContext {
  SapoPalette get sapo =>
      Theme.of(this).extension<SapoPalette>() ?? SapoPalette.dark;
}

ThemeMode themeModeFrom(Object? value) => switch (value) {
  'light' => ThemeMode.light,
  'dark' => ThemeMode.dark,
  _ => ThemeMode.system,
};

ThemeData sapoTheme([Brightness brightness = Brightness.dark]) {
  final dark = brightness == Brightness.dark;
  final p = dark ? SapoPalette.dark : SapoPalette.light;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: lime,
      brightness: brightness,
      primary: dark ? lime : const Color(0xFF3D6B00),
      onPrimary: dark ? ink : Colors.white,
      surface: p.surface,
      onSurface: p.text,
    ),
    extensions: [p],
    scaffoldBackgroundColor: p.bg,
    appBarTheme: AppBarTheme(
      backgroundColor: dark ? const Color(0xFF10272F) : p.surface,
      foregroundColor: p.text,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        fontFamily: titleFont,
        fontSize: 24,
        color: p.text,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.surface,
      elevation: dark ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: dark ? BorderSide.none : BorderSide(color: p.line),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: p.surface,
      side: BorderSide(color: p.line),
      labelStyle: TextStyle(color: p.text),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: lime,
        foregroundColor: ink,
        disabledBackgroundColor: p.surface2,
        disabledForegroundColor: p.muted,
        minimumSize: const Size(0, 50),
        elevation: dark ? 5 : 2,
        shadowColor: dark ? Colors.black87 : const Color(0x553D6B00),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: dark ? const Color(0xFFDAFF7A) : const Color(0xFF9CCB1F),
            width: 1.5,
          ),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF10242D) : p.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: dark ? const Color(0xFF44656A) : p.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(
          color: dark ? lime : const Color(0xFF6E9A12),
          width: 2,
        ),
      ),
    ),
  );
}
