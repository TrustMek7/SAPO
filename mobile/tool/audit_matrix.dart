import 'dart:convert';
import 'dart:io';

void main(List<String> args) {
  final paths = args.contains('--shards')
      ? [for (var i = 0; i < 4; i++) 'build/qa_ui_matrix_$i.csv']
      : ['build/qa_ui_matrix_v114.csv'];
  final legacy = args.contains('--shards');
  final expected = legacy ? 2268 : 372;
  final renderer = legacy ? 'spiral' : 'cube3d-start-cell';
  final rows = paths
      .expand((path) => File(path).readAsLinesSync().skip(1))
      .where((s) => s.isNotEmpty)
      .map((s) => s.split(','))
      .toList();
  rows.sort((a, b) => int.parse(a[0]).compareTo(int.parse(b[0])));
  final unique = <String>{},
      profiles = <String, int>{},
      sizes = <String, int>{},
      levels = <String, int>{},
      masks = <String, int>{};
  for (var i = 0; i < rows.length; i++) {
    final r = rows[i];
    if (r.length != 8 ||
        r[0] != '${i + 1}' ||
        r[6] != 'ok' ||
        r[7] != renderer) {
      throw StateError('Resultado inválido en fila ${i + 1}');
    }
    if (!unique.add(r.sublist(1, 5).join('/'))) {
      throw StateError('Configuración duplicada en fila ${i + 1}');
    }
    if (!legacy &&
        r[3] !=
            ['Tranqui', 'Equilibrado', 'Sin vergüenza'][int.parse(r[4]) - 1]) {
      throw StateError('Intensidad y distribución no coinciden');
    }
    for (final pair in [
      (profiles, r[3]),
      (sizes, r[2]),
      (levels, r[4]),
      (masks, r[1]),
    ]) {
      pair.$1.update(pair.$2, (n) => n + 1, ifAbsent: () => 1);
    }
  }
  if (rows.length != expected ||
      profiles.length != (legacy ? 4 : 3) ||
      profiles.values.any((n) => n != (legacy ? 567 : 124)) ||
      sizes.length != (legacy ? 3 : 4) ||
      sizes.values.any((n) => n != (legacy ? 756 : 93)) ||
      levels.length != 3 ||
      levels.values.any((n) => n != (legacy ? 756 : 124)) ||
      masks.length != (legacy ? 63 : 31) ||
      masks.values.any((n) => n != (legacy ? 36 : 12))) {
    throw StateError('Cobertura incompleta');
  }
  final summary = {
    'cases': rows.length,
    'renderer': renderer,
    'unique': unique.length,
    'passed': rows.length,
    'profiles': profiles,
    'sizes': sizes,
    'intensities': levels,
    'categoryMasks': masks.length,
    'casesPerMask': legacy ? 36 : 12,
    'sources': paths,
  };
  if (args.contains('--shards')) {
    File('build/qa_ui_matrix.csv').writeAsStringSync(
      'case,mask,size,profile,intensity,enabled,result,renderer\n'
      '${rows.map((row) => row.join(',')).join('\n')}\n',
    );
  }
  File(
    legacy
        ? 'build/qa_ui_matrix_summary.json'
        : 'build/qa_ui_matrix_v114_summary.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(summary));
  stdout.writeln(jsonEncode(summary));
}
