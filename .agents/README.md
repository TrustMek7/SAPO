# Documentación del proyecto S.A.P.O.

Esta carpeta reúne la documentación técnica y de continuidad del repositorio. El README principal y la guía rápida para GitHub están en `../README.md`. El proyecto Flutter está en `../mobile/`; el proyecto Android nativo existente se conserva en la raíz (`../app/`).

## Documentos

- `AGENTS.md`: identidad, reglas vigentes y guía de continuidad.
- `ARCHITECTURE.md`: módulos y decisiones técnicas.
- `PROGRESO.md`: funcionalidades y cambios implementados.
- `TEST_REPORT.md`: comandos y resultados de QA comprobados.
- `PENDIENTES.md`: límites y trabajo pendiente.
- `CATALOGO_REVISION.md`: exportación legible del catálogo editorial.
- `MOBILE_README.md`: instrucciones detalladas para compilar y jugar.

Desde `mobile/`, comandos habituales: `flutter pub get`, `flutter analyze`, `flutter test --concurrency=1` y `flutter build apk --debug`. El exportador del catálogo escribe la revisión en esta carpeta.

El repositorio local está preparado para revisión. No se configuró remoto, no se hizo commit ni se publicó nada.
