# Continuidad de trabajo — revisión 1.1.4+6

## Rediseño visual sobre 1.1.5+7 (2026-10-28)

- Tema claro y oscuro: colores en `mobile/lib/ui/sapo_theme.dart` (`SapoPalette`, `context.sapo`). No usar colores fijos nuevos en pantallas. El ajuste `theme` admite system, light o dark.
- Logo vivo de tres sapos en `ui/sapo_logo.dart`. Títulos en Lilita One (`assets/fonts`). Tarjeta que se voltea, ficha con salto (`TokenHop`, aterriza centrada en la casilla) y victoria con confeti y «<ganador> reparte 3 tragos a quien quiera.».
- Los bucles decorativos pasan por `ambientMotion`, que los apaga bajo bindings de prueba. Las animaciones finitas respetan el ajuste «Animaciones».
- Verificado: analyze limpio, 105 pruebas, matriz 372/372, Samsung 12/12, APK debug instalado y abierto.

## Actualización 1.1.5+7

Este bloque define las reglas actuales y prevalece sobre las notas de revisiones anteriores que siguen debajo.

- Tamaño N significa N casillas jugables numeradas 1..N, más marcadores Inicio índice 0 y Meta índice N+1. Tablero visible = N+2 ubicaciones, pero N casillas de juego. Todos parten en 0.
- Ganar exige llegar exactamente a Meta. El movimiento positivo rebota al excederse; desde casilla N, un 2 termina en N y un 3 en N-1. Negativos no cruzan Inicio.
- Avance/retroceso de comodín es individual, aleatorio 1–6 resuelto y serializado una vez. Se registra y anima; tras moverse aparece una tarjeta de destino sin disparar otro movimiento en cadena.
- Minijuego finalizado consume la tarjeta y pasa turno al volver al tablero. Oración no revela su texto hasta la acusación. 21 acumula cartas elegidas 1–13; valores >21 penalizan al actual, exacto deja elegir a quien toma. Carta alta y 21 usan `playing_cards` con caja de tamaño fijo.
- 7 PUM se reemplazó por cuenta 1..10 con reemplazo verbal elegido por el grupo; no se registra ni muestra esa palabra.
- Verificación final 1.1.5+7 completada: analyze limpio; flutter test --concurrency=1 102/102; integración Samsung 12/12; APK debug instalado y abierto. Mantener el reporte y hash en TEST_REPORT.md.

SAPO significa Sistema Aleatorio de Preguntas Ofensivas; lema: El juego donde nadie sale limpio. Proyecto Flutter existente: mobile/. Esta sesión corrigió el recorrido y los comodines; no crear otro proyecto.

Regla vigente: N representa N casillas jugables 1..N, con Inicio en índice 0 y Meta en índice N+1. El recorrido visual y serializado contiene esos dos marcadores además de las N casillas. Todos empiezan en 0. Se gana al terminar exactamente en Meta; si sobran pasos, se rebota hacia atrás. Los eventos de movimiento afectan solo al activo, se sortean 1..6 una sola vez, se persisten/anima y muestran una tarjeta en el destino sin activar automáticamente otro movimiento.

Identidad editorial vigente: SAPO es exclusivamente +18. Tranqui también es adulto; la intensidad gradúa incomodidad y explicitud. Solo existen cinco categorías activables: Verdad o Shot (1), Bebe (2), Reto (3), Minijuego (4), Evento (5). HOT ya no es categoría: sus preguntas y retos se migraron a 1 y 3. Catálogo autoritativo: `mobile/tool/catalog_editorial.json`; generador: `mobile/tool/catalog.dart`; export de revisión: `CATALOGO_REVISION.md`. El primer ingreso confirma +18; retos con terceros requieren aceptación y una negativa no se penaliza. Tomar es voluntario.

Desde mobile/: flutter analyze, flutter test --concurrency=1, flutter test integration_test/app_test.dart -d R5GYC4WPCYX, flutter build apk --debug. Revisión 1.1.4+6 verificada: analyze limpio, 101 pruebas, matriz UI 372/372, integración Samsung 12/12, APK debug instalado y abierto. Ver PROGRESO.md y TEST_REPORT.md.
# S.A.P.O. — guía para continuar el proyecto

## Identidad y objetivo

- Nombre visible: **S.A.P.O.** (con puntos).
- Significado: **Sistema Aleatorio de Preguntas Ofensivas**.
- Lema exacto: **«El juego donde nadie sale limpio»**.
- Juego de fiesta para adultos (+18), multijugador local, un teléfono compartido, totalmente offline.
- La aplicación Flutter está en `mobile/`. El proyecto Android nativo de la raíz se conserva: no sustituirlo ni limpiarlo.

## Límites de trabajo

- Trabajar solo en `D:\Plataformas\SAPO`. Se permiten accesos necesarios a Flutter, Android SDK, Gradle y herramientas de compilación.
- No modificar otros proyectos, archivos personales, credenciales, permisos, variables globales ni configuración de Windows.
- No hacer push, despliegues, publicaciones, Docker ni integrar Supabase.
- ADB autorizado únicamente para el Samsung `R5GYC4WPCYX`.
- No limpiar caches globales ni detener procesos ajenos al trabajo.
- Mantener `PROGRESO.md`, `TEST_REPORT.md`, `ARCHITECTURE.md` y `PENDIENTES.md` actualizados. No afirmar que una prueba pasó sin ejecutarla.

## Reglas vigentes

- De **2 a 12 jugadores**, con iconos, edición, eliminación y orden circular.
- Un dado de **1 a 6** por turno. Conservar el avance animado casilla a casilla.
- Tableros de 30/50/75/100 posiciones totales, inicio visible/numerado 1, meta visible/numerada N e índice de jugadores inicial 0.
- Cinco categorías: Verdad o Shot (1), Bebe (2), Reto (3), Minijuego (4), Evento (5). Inicio=0 y Meta=6 son tipos de casilla.
- Las tres intensidades son +18. La intensidad filtra contenido; el perfil interno solo distribuye categorías.
- Tomar es la penalización narrativa. No usar puntos/monedas ni selector de penalizaciones alternativas. Las tarjetas no ofrecen una acción para omitir. La app no registra ni vigila consumo.
- Eventos con efecto real; el destino de un evento no dispara otra tarjeta.
- Antirrepetición por ID y concepto entre categorías; preferir no vistos entre partidas. Agotamiento: descanso controlado, sin reciclar contenido en la partida ni subir intensidad.

## UX y dirección visual aceptada

- Configuración en Jugadores → Partida → Revisión, con acciones fijas visibles y protección del teclado/área de navegación.
- Alta sucesiva evidente: campo Primer/Siguiente jugador, + para agregar, lista visible, iconos y contador.
- La referencia del usuario orienta el formato del recorrido, no su identidad visual. Dirección vigente: azul petróleo, verde ácido y acentos por categoría; retirar el morado pastel dominante.
- El tablero debe representar un **recorrido continuo en espiral**, no una tabla que salta de fila. Debe caber en pantalla y permitir ampliación.
- Dado como cubo de seis caras proyectadas, con puntos, iluminación, profundidad y giro de 2 s. Asienta en 450 ms y deja 750 ms de lectura total antes del avance; cada paso dura 360 ms (transición 280 ms). Sin animaciones no se aplican esperas.
- Inicio y Meta son las posiciones físicas 0 y N-1 del recorrido. Se ven como casillas 1 y N y todos comienzan en la primera; no existe posición invisible.
- Un solo selector de intensidad: Tranqui/Picante/Sin vergüenza ajusta contenido y distribución. No mostrar selector independiente de perfil. Se conservan los perfiles internos para leer guardados antiguos.
- Usar identidad propia S.A.P.O.; no incorporar marca, logos o textos del juego de referencia.
- Priorizar UI nativa Flutter, gráficos vectoriales/canvas y funcionamiento offline.

## Estructura

- `mobile/lib/game.dart`: motor, configuración, distribución reproducible, turnos, eventos, antirrepetición y serialización.
- `mobile/lib/controller.dart`: coordinación Riverpod y guardado.
- `mobile/lib/storage.dart`: Drift/SQLite, snapshots, historial, ajustes y personalizados.
- `mobile/lib/catalog.dart`: auditoría/normalización y conceptos de similitud.
- `mobile/lib/setup_screen.dart`: configuración y borrador de navegación.
- `mobile/lib/screens.dart`: inicio/ajustes y exportaciones de pantallas.
- `mobile/lib/minigame.dart`: diez minijuegos y tres retos especiales.
- `mobile/assets/catalog.json`: banco offline; 180 Verdad o Shot, 60 Bebe, 110 retos, 25 eventos y 10 minijuegos (385 total).
- `mobile/tool/catalog_editorial.json`: fuente editorial; `mobile/tool/catalog.dart` valida y exporta el catálogo de runtime.
- Módulos visuales nuevos bajo `mobile/lib/board/` y `mobile/lib/ui/`: continuar la separación entre presentación y motor.

## QA y compilación

Desde `mobile/`:

```powershell
flutter pub get
flutter analyze
flutter test --concurrency=1
flutter test integration_test/app_test.dart -d R5GYC4WPCYX
flutter build apk --debug
```

- APK estándar: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- ADB absoluto si falta PATH: `C:\Users\LUIS\AppData\Local\Android\Sdk\platform-tools\adb.exe`.
- Equipo de 8 GB: mantener Gradle limitado localmente a 2 GB/dos workers; evitar compilaciones pesadas simultáneas.
- `config_matrix_test.dart`: 4.464 partidas (31 máscaras × 4 tamaños × 4 perfiles × 3 intensidades × 3 grupos de jugadores).
- `ui_matrix_test.dart`: 372 configuraciones de UI (31 máscaras × 4 tamaños × 3 intensidades), creación, SQLite y regreso al inicio.
- En equipos de 8 GB ejecutar primero `flutter test --concurrency=1 --exclude-tags=exhaustive-ui`. No lanzar dos procesos Flutter test simultáneos: el hook nativo de SQLite usa el mismo archivo.
- Evidencias vigentes: `build/qa_ui_matrix_v114.csv`, auditables con `dart run tool/audit_matrix.dart`, y resumen v114. Los CSV de selecciones independientes corresponden a 1.1.0 y son históricos; auditor `--shards` solo para esos archivos.
- Integración física ampliada: 12 configuraciones representativas, edición/orden, intensidad, categorías, reanudación, ajustes y personalizados.
- Consultar el estado actual de `TEST_REPORT.md`: un resultado de un APK anterior no certifica cambios posteriores. No eliminar pruebas para lograr verde.

## Estado al redactar esta guía

Revisión vigente 1.1.4+6: SAPO adulto en las tres intensidades; cinco categorías; catálogo 385 entradas (180/60/110/10/25) en fuente editorial JSON; confirmación +18 y consentimiento para retos; snapshots HOT antiguos migrados; tamaños 30/50/75/100; comodines aleatorios 1-6 persistidos y animados. Suite 101 pruebas, matriz 372/372, integración Samsung 12/12, APK debug compilado/instalado/abierto. Revisar PROGRESO.md y TEST_REPORT.md.
