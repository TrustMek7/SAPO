import 'dart:convert';

String normalizeContent(String text) {
  var value = text.toLowerCase();
  const accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u', 'ü': 'u'};
  for (final entry in accents.entries) {
    value = value.replaceAll(entry.key, entry.value);
  }
  return value
      .replaceAll(RegExp(r'[^a-z0-9ñ\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class CatalogAudit {
  CatalogAudit(this.errors, this.similarityGroups);
  final List<String> errors;
  final Map<String, List<String>> similarityGroups;
  bool get valid => errors.isEmpty;
}

CatalogAudit auditCatalog(List<Map<String, dynamic>> items) {
  final errors = <String>[], ids = <String>{}, texts = <String>{};
  final groups = <String, List<String>>{};
  for (final item in items) {
    final id = item['id'];
    if (id is! String || id.isEmpty || !ids.add(id)) {
      errors.add('ID inválido o duplicado: $id');
    }
    final text = item['text'];
    if (text is! String ||
        text.trim().isEmpty ||
        !texts.add(normalizeContent(text))) {
      errors.add('Texto vacío o duplicado: $id');
    }
    if (![1, 2, 3, 4, 5].contains(item['category'])) {
      errors.add('Categoría inválida: $id');
    }
    if (![1, 2, 3].contains(item['intensity'])) {
      errors.add('Intensidad inválida: $id');
    }
    if (!['active', 'inactive'].contains(item['status'])) {
      errors.add('Estado inválido: $id');
    }
    for (final field in ['theme', 'concept']) {
      if (item[field] is! String || (item[field] as String).trim().isEmpty) {
        errors.add('$field inválido: $id');
      }
    }
    final concept = item['concept'];
    if (concept is String && id is String) {
      groups.putIfAbsent(concept, () => []).add(id);
    }
  }
  groups.removeWhere((key, value) => value.length < 2);
  return CatalogAudit(errors, groups);
}

List<Map<String, dynamic>> decodeCatalog(String json) {
  final items = List<Map<String, dynamic>>.from(
    jsonDecode(json.replaceFirst('\uFEFF', '')),
  );
  final audit = auditCatalog(items);
  if (!audit.valid) {
    throw FormatException(audit.errors.join('\n'));
  }
  return items;
}

/// Coincidencia léxica conservadora para contenido introducido en el dispositivo.
/// Los conceptos editoriales siguen siendo la fuente de equivalencias semánticas.
String conceptForCustom(
  String text,
  List<Map<String, dynamic>> catalog,
  String fallback,
) {
  final words = normalizeContent(text)
      .split(' ')
      .where((w) => w.length > 3)
      .toSet();
  for (final item in catalog) {
    if (normalizeContent(item['text']) == normalizeContent(text)) {
      return item['concept'];
    }
    final other = normalizeContent(item['text'])
        .split(' ')
        .where((w) => w.length > 3)
        .toSet();
    final union = words.union(other).length;
    if (union > 0 && words.intersection(other).length / union >= 0.75) {
      return item['concept'];
    }
  }
  return fallback;
}
