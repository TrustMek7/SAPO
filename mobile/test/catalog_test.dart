import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sapo/catalog.dart';

void main() {
  test('Auditoría detecta errores y grupos de similitud repetidos', () {
    final catalog = decodeCatalog(
      File('assets/catalog.json').readAsStringSync(),
    );
    final audit = auditCatalog(catalog);
    expect(audit.errors, isEmpty);
    expect(audit.similarityGroups, isEmpty);
    final bad = [
      ...catalog,
      Map<String, dynamic>.from(catalog.first)
        ..['category'] = 8
        ..['intensity'] = 0,
    ];
    final errors = auditCatalog(bad).errors;
    expect(errors.any((e) => e.contains('ID')), true);
    expect(errors.any((e) => e.contains('Texto')), true);
    expect(errors.any((e) => e.contains('Categoría')), true);
    expect(errors.any((e) => e.contains('Intensidad')), true);
  });
  test('Personalizados: normalización y agrupación de variantes cercanas', () {
    final catalog = [
      {
        'text': '¿Qué mensaje te arrepentiste de enviar de madrugada?',
        'concept': 'mensaje',
      },
    ];
    expect(
      conceptForCustom(
        'Que mensaje te arrepentiste de enviar de madrugada',
        catalog,
        'new',
      ),
      'mensaje',
    );
    expect(conceptForCustom('Baila una salsa sentado', catalog, 'new'), 'new');
    expect(normalizeContent('¡Éxito!  HOY.'), 'exito hoy');
  });
}
