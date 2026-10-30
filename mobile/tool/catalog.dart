import 'dart:convert';
import 'dart:io';

void main() {
  final source = File('tool/catalog_editorial.json');
  final items = jsonDecode(source.readAsStringSync()) as List<dynamic>;
  final ids = <String>{};
  final texts = <String>{};
  final counts = <int, int>{};
  for (final raw in items) {
    final item = raw as Map<String, dynamic>;
    final id = item['id'];
    final category = item['category'];
    final intensity = item['intensity'];
    final text = item['text'];
    if (id is! String || id.isEmpty || !ids.add(id)) {
      throw StateError('ID vacío o duplicado: $id');
    }
    if (![1, 2, 3, 4, 5].contains(category)) {
      throw StateError('Categoría fuera del catálogo: $id / $category');
    }
    if (![1, 2, 3].contains(intensity)) {
      throw StateError('Intensidad inválida: $id');
    }
    if (!['active', 'inactive'].contains(item['status']) ||
        (item['theme'] as String? ?? '').isEmpty ||
        (item['concept'] as String? ?? '').isEmpty ||
        (text as String? ?? '').trim().isEmpty) {
      throw StateError('Metadatos incompletos: $id');
    }
    final normalized = (text as String)
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9ñ]+'), ' ')
        .trim();
    if (!texts.add(normalized)) throw StateError('Texto duplicado: $id');
    counts[category as int] = (counts[category] ?? 0) + 1;
  }
  File('assets/catalog.json').writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(items)}\n',
  );
  for (final category in [1, 2, 3, 4, 5]) {
    stdout.writeln('$category: ${counts[category] ?? 0}');
  }
}
