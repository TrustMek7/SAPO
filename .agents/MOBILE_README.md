# S.A.P.O.

**Sistema Aleatorio de Preguntas Ofensivas** · **«El juego donde nadie sale limpio»**.

Juego local de tablero para fiestas de adultos (+18), en español. Un único teléfono se pasa entre participantes. No requiere cuenta ni conexión durante la partida.

## Jugar

1. Abre Nueva partida. En Jugadores registra de dos a doce adultos con el botón +, la tecla Listo o Agregar otro. El campo cambia de Primer jugador a Siguiente jugador. Toca la ficha junto al campo para elegirla o una tarjeta para editar un jugador; usa la flecha para cambiar el orden y la papelera para eliminar.
2. Al entrar confirma que todas las personas tienen 18 años o más. Los retos con otra persona requieren su aceptación y una negativa no se penaliza. Pulsa Elegir partida. Selecciona Tranqui, Picante o Sin vergüenza; la intensidad filtra el contenido de las cinco categorías y el perfil ajusta solo su distribución. Elige longitud y categorías. Debe quedar alguna categoría activa.
3. Pulsa Revisar partida. Puedes volver para corregir opciones; Comenzar partida queda fijo abajo, separado de la navegación del teléfono y del teclado.
4. Todos parten de INICIO (índice 0, casilla visible 1); el tablero tiene 30, 50, 75 o 100 casillas totales, incluida META (casilla N). Toca el cubo 3D: gira dos segundos, se asienta y deja leer el resultado antes de caminar 360 ms por casilla. Amplía la espiral con dos dedos. La tarjeta aparece superpuesta. En Verdad o Shot eliges responder o tomar; los retos y minijuegos indican quién pierde. Tomar nunca es obligatorio.
5. La primera ficha que llegue a la meta gana; un lanzamiento que la supere se detiene allí.
6. El progreso se guarda automáticamente. Usa Continuar partida después de cerrar y abrir la aplicación.

En Ajustes puedes cambiar sonido, vibración y animaciones, consultar estadísticas e historial y crear, editar o eliminar preguntas y retos propios. Reiniciar historial requiere confirmación y no modifica la protección contra repeticiones de la partida actual.

## Desarrollo

Desde ../mobile/, usando Flutter 3.47.6:

```powershell
flutter pub get
flutter analyze
flutter test
flutter test integration_test/app_test.dart -d R5GYC4WPCYX
flutter build apk --debug
```

APK estándar: `build/app/outputs/flutter-apk/app-debug.apk`.

El catálogo de ejecución es `assets/catalog.json`; las cantidades mínimas y metadatos se validan automáticamente. `dart run tool/catalog.dart` regenera el banco inicial desde sus fuentes locales. No se necesita Python para compilar ni jugar.

La documentación del repositorio está en ../.agents/: `ARCHITECTURE.md`, `PROGRESO.md`, `TEST_REPORT.md` y `PENDIENTES.md`. Incluye variantes básicas de reglas, recuperación por agotamiento y límites del MVP.

Con poca memoria, ejecuta primero `flutter test --concurrency=1 --exclude-tags=exhaustive-ui`, después `flutter test test/ui_matrix_test.dart --concurrency=1` y finalmente `dart run tool/audit_matrix.dart`. El auditor comprueba las 372 configuraciones únicas de UI (31 máscaras × cuatro tamaños × tres intensidades) y genera CSV y resumen en `build/`. La matriz antigua de cuatro perfiles independientes se conserva solo como evidencia histórica de 1.1.0.

`../.agents/AGENTS.md` resume identidad, alcance, arquitectura, restricciones y comandos para continuar el desarrollo.
