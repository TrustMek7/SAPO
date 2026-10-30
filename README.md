# S.A.P.O.

**Sistema Aleatorio de Preguntas Ofensivas**  
*El juego donde nadie sale limpio.*

Juego de tablero local para fiestas de adultos (+18). De 2 a 12 personas comparten un teléfono y avanzan por un recorrido con preguntas, retos, minijuegos y eventos. Funciona sin conexión; el catálogo se incluye como JSON en la aplicación. Tomar es voluntario y los retos con otra persona requieren su aceptación.

## Ejecutar y compilar

La aplicación Flutter está en [`mobile/`](mobile/). Con Flutter instalado, desde esa carpeta:

```powershell
flutter pub get
flutter run
```

Para revisar y compilar una versión Android debug:

```powershell
flutter analyze
flutter test --concurrency=1
flutter build apk --debug
```

El APK queda en `mobile/build/app/outputs/flutter-apk/app-debug.apk`.

## Catálogo

El juego carga el banco offline desde `mobile/assets/catalog.json`. La fuente editorial está en `mobile/tool/catalog_editorial.json`; para regenerar el catálogo, ejecuta desde `mobile/`:

```powershell
dart run tool/catalog.dart
node tool/export_catalog.mjs
```

La exportación para revisión editorial queda en `.agents/CATALOGO_REVISION.md`.

## Estructura

- `mobile/`: aplicación Flutter, pruebas, integración y herramientas del catálogo.
- `app/` y archivos Gradle de la raíz: proyecto Android nativo existente, conservado junto con la aplicación Flutter.
- `.agents/`: arquitectura, continuidad, progreso, pendientes, reporte QA y documentación extendida.

El repositorio está preparado localmente en la rama `main`. Aún no tiene remoto ni commits.
