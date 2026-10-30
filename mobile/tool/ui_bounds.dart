import 'dart:convert';
import 'dart:io';

/// Lee solo nodos de S.A.P.O.; ayuda a tocar controles del Samsung sin adivinar.
void main(List<String> args) {
  if (args.length != 2) {
    throw ArgumentError('ui_bounds.dart archivo.xml etiqueta');
  }
  final source = File(args[0]).readAsStringSync();
  for (final node in RegExp(r'<node\b[^>]*>').allMatches(source)) {
    final attrs = {
      for (final match in RegExp(r'([\w-]+)="([^"]*)"').allMatches(node[0]!))
        match[1]!: match[2]!,
    };
    if (attrs['package'] != 'com.sapo.sapo' || attrs['clickable'] != 'true') {
      continue;
    }
    String decode(String value) => value
        .replaceAll('&#10;', '\n')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"');
    if (![
      'content-desc',
      'text',
      'hint',
    ].any((key) => decode(attrs[key] ?? '').split('\n').contains(args[1]))) {
      continue;
    }
    final values = RegExp(r'\d+')
        .allMatches(attrs['bounds'] ?? '')
        .map((m) => int.parse(m[0]!))
        .toList();
    if (values.length != 4) continue;
    stdout.writeln(
      jsonEncode({
        'label': args[1],
        'x': (values[0] + values[2]) ~/ 2,
        'y': (values[1] + values[3]) ~/ 2,
        'bounds': attrs['bounds'],
      }),
    );
    return;
  }
  stderr.writeln('Control no visible en S.A.P.O.: ${args[1]}');
  exitCode = 1;
}
