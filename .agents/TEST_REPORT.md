# RediseÃ±o visual sobre 1.1.5+7 (2026-10-28) â resultados reales

Cambios: tema claro y oscuro con selector Sistema/Claro/Oscuro, logo vivo con tres sapos que se alternan, tÃ­tulo en Lilita One, tarjeta que entra volteÃ¡ndose, ficha que salta y aterriza centrada en cada casilla, cambio de turno deslizante y victoria con confeti y el mensaje Â«<ganador> reparte 3 tragos a quien quiera.Â». VersiÃ³n sin cambios en `pubspec.yaml`.

- `flutter analyze`: **No issues found**, cÃ³digo 0.
- `flutter test --concurrency=1`: **105 pruebas aprobadas**, cÃ³digo 0, incluida la matriz UI **372/372**. Nuevas: `test/theme_test.dart` (3: paletas, alternar y persistir el tema desde el inicio, el logo pasa por los tres sapos al tocarlo) y una aserciÃ³n del mensaje de los 3 tragos en la prueba de victoria.
- Primera ejecuciÃ³n: 100/101 sin la matriz. FallÃ³ `config_test` en 360Ã640 porque el encabezado Â«Â¿QuiÃ©nes se atreven?Â» a 28 px pasaba a tres lÃ­neas y sacaba el campo de nombre del Ã¡rea construida. Se dejÃ³ en 26 px y la prueba pasÃ³, sin modificar las pruebas.
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **1/1 aprobada**, 12/12 configuraciones.
- Las animaciones en bucle del logo se desactivan con los bindings de prueba (unitarias e integraciÃ³n), con Â«AnimacionesÂ» apagado o con reducciÃ³n de movimiento del sistema. Por eso las pruebas automÃ¡ticas no ejercitan ese bucle. SÃ­ se vio en el telÃ©fono: una captura mostrÃ³ el logo (variante cÃ³ctel) en tema oscuro con el aviso +18.
- `flutter build apk --debug`: **aprobado**. `mobile/build/app/outputs/flutter-apk/app-debug.apk`, **185.270.677 bytes**, SHA-256 `A005B617AC18C080010D0FDDBFB0A0378298448D14020BDBDFA61E6F8C23C3E4`. Instalado con `adb install -r` (Success) y abierto en R5GYC4WPCYX.

# RevisiÃ³n vigente 1.1.4+6 â resultados reales

- `flutter pub get`: aprobado; dependencias resueltas.
- `flutter analyze`: **No issues found**, cÃ³digo 0.
- `flutter test --concurrency=1`: **101 pruebas aprobadas**, cÃ³digo 0, incluida la matriz UI exhaustiva.
- `dart run tool/catalog.dart`: aprobado; validÃ³ y generÃ³ el JSON runtime, con 180/60/110/10/25 tarjetas en categorÃ­as 1â5.
- `dart run tool/audit_matrix.dart`: **372/372** configuraciones Ãºnicas y correctas; 31 mÃ¡scaras de categorÃ­a Ã 4 tamaÃ±os Ã 3 intensidades. CSV y resumen en `mobile/build/qa_ui_matrix_v114.csv` y `qa_ui_matrix_v114_summary.json`.
- CatÃ¡logo editorial: **385** entradas: 180 Verdad o Shot, 60 Bebe, 110 Reto, 10 Minijuego y 25 Evento. IDs, conceptos, textos normalizados, categorÃ­as e intensidades Ãºnicos/vÃ¡lidos; cero tarjetas de categorÃ­a 7. `tool/catalog.dart` genera el JSON runtime desde `tool/catalog_editorial.json`; `CATALOGO_REVISION.md` es la exportaciÃ³n legible.
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **1/1 aprobada**, 12/12 configuraciones sobre Samsung SM A176B (Android 16), incluye configuraciÃ³n de partida, ciclo de juego, reanudaciÃ³n, ajustes y persistencia de personalizados. Tiempo total de la Ãºltima ejecuciÃ³n: ~3 min 45 s, incluida la compilaciÃ³n e instalaciÃ³n del runner.
- Una ejecuciÃ³n intermedia fallÃ³ porque el test suponÃ­a que el diÃ¡logo +18 siempre se mostrarÃ­a. En el dispositivo ya se habÃ­a persistido esa confirmaciÃ³n. Se corrigiÃ³ para aceptar estado confirmado o primera entrada; la Ãºltima ejecuciÃ³n completa pasÃ³.
- `flutter build apk --debug`: **aprobado**, cÃ³digo 0. APK normal, entrypoint `lib/main.dart`: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, versiÃ³n 1.1.4+6, **180.346.700 bytes**, SHA-256 `236D83C3EF596071BE9B9E35274274CE91988561C3FFBE5951BCF729AE62CDA4`.
- `adb -s R5GYC4WPCYX install -r ...app-debug.apk`: **Success**. La actividad `com.sapo.sapo/.MainActivity` quedÃ³ en primer plano. Se inspeccionaron capturas de la confirmaciÃ³n +18 y de la pantalla inicial.

## RevisiÃ³n 1.1.3+5 (histÃ³rica)

- flutter analyze: No issues found, cÃ³digo 0.
- flutter test --concurrency=1: 103 pruebas aprobadas, cÃ³digo 0. Incluye 9.072 combinaciones del motor, lÃ­mites/victoria, persistencia, y 30/50/75/100 casillas. La prueba visual inspecciona N nodos de casilla: Inicio=1, Meta=N y cada casilla intermedia numerada.
- UI exhaustiva: 756 combinaciones aprobadas; auditor dart run tool/audit_matrix.dart confirma 756 Ãºnicas, 63 mÃ¡scaras, 4 tamaÃ±os y 3 niveles.
- Eventos: pruebas de carta con nombre, cantidad aleatoria persistida, posiciones anterior/nueva, lÃ­mites, ausencia de reroll al reconstruir/restaurar, animaciÃ³n del controlador e historial SQLite. Los efectos al aterrizar en otras casillas no se encadenan.
- Interfaz de tarjetas: retirada la acciÃ³n Omitir; las preguntas conservan responder/tomar, los retos cumplir/tomar y cada otra categorÃ­a su acciÃ³n principal.
- RegresiÃ³n final del tablero despuÃ©s del ajuste de legibilidad: flutter test --concurrency=1 test/spiral_board_test.dart, 41 aprobadas, cÃ³digo 0.
- RegresiÃ³n final de minijuegos tras retirar omitir de las instrucciones: flutter test --concurrency=1 test/minigame_test.dart, 13 aprobadas, cÃ³digo 0.
- flutter test integration_test/app_test.dart -d R5GYC4WPCYX: 1/1 aprobada. Samsung SM-A176B; 12 configuraciones verificadas, incluidos tableros de 30, 50, 75 y 100.
- flutter build apk --debug: aprobado, cÃ³digo 0. APK normal: mobile/build/app/outputs/flutter-apk/app-debug.apk, versiÃ³n 1.1.3+5, 180.346.295 bytes, SHA-256 BF626A37AB06FB4CFCAB49E1D5ACAE4C9EB96C056408C54D803A3590581D2072.
- InstalaciÃ³n adb en R5GYC4WPCYX: Success. Apertura com.sapo.sapo/.MainActivity confirmada como ventana enfocada.

Durante la primera corrida de la prueba visual se usÃ³ un finder de semÃ¡ntica de widget que Flutter Test no exponÃ­a para CustomPainter. Se corrigiÃ³ la verificaciÃ³n para inspeccionar los nodos semÃ¡nticos generados por el pintor y contar exactamente N; la suite completa posterior pasÃ³. No se eliminÃ³ ninguna prueba.
# S.A.P.O. â informe de pruebas

## RevisiÃ³n 1.1.5+7 â tablero, victoria exacta y minijuegos

- `flutter pub get`: completado; dependencias resueltas, incluido `playing_cards`.
- `flutter analyze`: **No issues found**, cÃ³digo 0.
- `flutter test --concurrency=1`: **102 pruebas aprobadas**, cÃ³digo 0. Incluye motor (100 partidas simuladas), 372/372 combinaciones de UI, tablero de 30/50/75/100, movimiento, persistencia y minijuegos.
- `flutter test --no-pub test/minigame_test.dart`: **14/14 aprobadas** en una ejecuciÃ³n focal. Incluye cierre y avance de turno, cartas, 21 exacto, Replace y OraciÃ³n.
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **1/1 aprobada**, 12/12 configuraciones en Samsung SM A176B / Android 16. Verifica guardar/reanudar, navegaciÃ³n, ediciÃ³n y que las acciones del turno respeten los efectos de evento. La primera ejecuciÃ³n encontrÃ³ una expectativa fija incorrecta de siguiente jugador ante eventos de turno extra/salto; se ajustÃ³ la prueba a las reglas reales y la segunda ejecuciÃ³n pasÃ³ completa.
- Tablero: exactamente N casillas de juego numeradas 1..N, ademÃ¡s de marcadores Inicio y Meta; posiciones iniciales en Inicio. Pruebas verifican 30/50/75/100 y los pasos desde casilla 50: tirada 2 termina en 50 tras pasar por Meta; tirada 3 termina en 49. Solo ganar al terminar exactamente en Meta.
- Comodines: el resultado 1â6 y su ruta se guardan una vez. La tarjeta muestra movimiento y posiciones, la ficha anima cada paso, SQLite guarda posiciÃ³n e historial; si no gana, aparece la tarjeta de destino sin encadenar automÃ¡ticamente otro movimiento. Una prueba UI corrigiÃ³ el formateo de destino para no usar el Ã­ndice de casilla como Ã­ndice de jugador.
- APK debug final (incluye la revisiÃ³n de acusaciÃ³n de OraciÃ³n): `flutter build apk --debug` aprobado; `mobile/build/app/outputs/flutter-apk/app-debug.apk`, versiÃ³n 1.1.5+7, **185.234.660 bytes**, SHA-256 `D7C3336BEF2EAAC071887D62FE7391086DEFE915550C48C1160A0D3199FD7B0D`.
- `adb -s R5GYC4WPCYX install -r ...app-debug.apk`: **Success**. `monkey -p com.sapo.sapo 1` abriÃ³ la app y `dumpsys activity` confirmÃ³ `com.sapo.sapo/.MainActivity` como actividad en primer plano.

La suite final de 102 pruebas se ejecutÃ³ despuÃ©s de pasar analyze y terminÃ³ en 3:23. TambiÃ©n se repitiÃ³ la prueba focal de minijuegos, 14/14. DespuÃ©s se volviÃ³ a compilar e instalar el APK final; `dumpsys activity` confirmÃ³ `com.sapo.sapo/.MainActivity` en primer plano.

## RevisiÃ³n anterior 1.1.1 (histÃ³rica)

Solicitada despuÃ©s del cierre 1.1.0: sustituir plano giratorio por sÃ³lido de seis caras, alargar giro/lectura/caminata, retirar paleta morada pastel, integrar INICIO fÃ­sico y unificar perfil e intensidad. Cubo por cuaterniones, proyecciÃ³n en perspectiva, descarte de caras ocultas, orden por profundidad y puntos sobre cada plano. Giro 2.000 ms, asentamiento 450 ms, pausa total de resultado 750 ms antes de mover; pasos de 360 ms con transiciÃ³n de 280 ms. Sin animaciones se omiten esperas. La selecciÃ³n Tranqui/Picante/Sin vergÃ¼enza deriva tambiÃ©n la distribuciÃ³n y conserva lectura de partidas antiguas con perfiles independientes.

Primera regresiÃ³n del cubo: seis resultados con tres caras conectadas aprobados; una prueba de tiempos terminÃ³ antes de completar la caminata porque `pumpAndSettle` puede salir en la pausa entre saltos. Se conserva la aserciÃ³n temporal y se espera ademÃ¡s el fin real de `c.working` antes de comprobar posiciÃ³n final; mismo ajuste para integraciÃ³n y matriz. No se registra esa ejecuciÃ³n como exitosa.

La nueva UI tiene **567 combinaciones** (63 mÃ¡scaras Ã 3 tamaÃ±os Ã 3 intensidades unificadas), en lugar de 2.268 selecciones independientes. La matriz se adapta a las opciones realmente ofrecidas y verifica tambiÃ©n la distribuciÃ³n derivada; la matriz antigua del motor se mantiene para guardados compatibles. Evidencia nueva: `qa_ui_matrix_v111.csv` y auditor sin `--shards`. Los resultados histÃ³ricos de 1.1.0 siguientes quedan separados de este cierre.

- `flutter test --concurrency=1 --exclude-tags=exhaustive-ui`: **93 aprobadas**, cÃ³digo 0 (56 s). Incluye seis orientaciones finales del cubo, tres caras conectadas por aristas, opuestas sumando siete, puntos por cara, tiempos de giro/lectura/paso, bloqueo de doble toque, INICIOâ1 adyacentes, tamaÃ±os y accesibilidad.
- `flutter analyze`: **No issues found**, cÃ³digo 0 (11,7 s).
- `flutter test test/ui_matrix_test.dart --concurrency=1`: **aprobado**, 567 configuraciones completas (3:08), cÃ³digo 0.
- `dart run tool/audit_matrix.dart`: **aprobado**, 567 filas Ãºnicas `cube3d-start-cell`, 189 por intensidad/tamaÃ±o/distribuciÃ³n derivada y 9 por mÃ¡scara. Resumen en `build/qa_ui_matrix_v111_summary.json`.
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **aprobado**, cÃ³digo 0. Doce configuraciones, sin selector de perfil independiente, con distribuciÃ³n derivada, cubo y cara final, omisiÃ³n, reanudaciÃ³n y ajustes/personalizados. EjecuciÃ³n 3:49, Gradle 56,7 s e instalaciÃ³n 33,0 s.

InspecciÃ³n fÃ­sica del APK normal 1.1.1+3: instalaciÃ³n `Success`, versiÃ³n comprobada por dumpsys; nueva partida Ana/Luis, Picante/50/todas, INICIO fÃ­sico con ambas fichas y tres planos visibles del cubo. Lanzamiento manual 2, captura en la casilla 1 durante el avance y captura final en 2/Evento. Se omite la tarjeta y queda Luis activo. Evidencias `sapo_v111_board.png`, `sapo_v111_dice_spin.png` (el nombre es histÃ³rico del intento: muestra la caminata con el cubo ya asentado), `sapo_v111_result.png`. La inspecciÃ³n detectÃ³ un mensaje incorrecto Â«Toca para lanzarÂ» durante la caminata: se cambia Ãºnicamente a Â«Resultado: NÂ» mientras hay trabajo. `flutter test test/spiral_board_test.dart --plain-name 'Dado espera'` volviÃ³ a pasar con una aserciÃ³n de ese texto. La integraciÃ³n y matriz anteriores certifican el flujo; este Ãºltimo ajuste textual se certifica con esa regresiÃ³n y anÃ¡lisis, sin atribuirle otra ejecuciÃ³n de 12 casos fÃ­sicos.

AnÃ¡lisis posterior al ajuste textual: **sin incidencias**, cÃ³digo 0 (11,4 s). APK normal final: `flutter build apk --debug`, **cÃ³digo 0**, Gradle 29,5 s. Ruta `mobile/build/app/outputs/flutter-apk/app-debug.apk`, versiÃ³n **1.1.1+3**, **180.327.160 bytes**. SHA-256 **CF649117ED78B2C951E338B59D3730E9272C7EADE8C7495CD910F44C6C9C7C55**. La compilaciÃ³n normal previa a ese texto tambiÃ©n fue exitosa (64,6 s), seguida de instalaciÃ³n y revisiÃ³n visual; su hash queda sustituido por este entregable final.

ADB final `install -r`: **Success**, cÃ³digo 0. Actividad normal abierta. Continuar partida desde el APK final recuperÃ³ **Ana en 2, Luis en INICIO, turno de Luis**, mismo tablero y sin tarjeta pendiente despuÃ©s de omitir el Evento. Evidencia actual `sapo_v111_resumed.xml/png`. La app queda en ese tablero lista para lanzar. Primer dump durante arranque devolviÃ³ raÃ­z nula y se repitiÃ³ una vez lista la UI; no se interpreta ese dump inicial como aprobaciÃ³n ni como fallo de persistencia. No hubo limpieza de datos, cambios de permisos ni modificaciones externas al proyecto/SDK y ADB autorizados.

## HistÃ³rico â MVP y revisiÃ³n visual 1.1.0

28/10/2026. APK normal **1.1.0+2**, paquete `com.sapo.sapo`, instalado y abierto en Samsung `R5GYC4WPCYX` (Android 16). Identidad exacta S.A.P.O. / Sistema Aleatorio de Preguntas Ofensivas / Â«El juego donde nadie sale limpioÂ».

| VerificaciÃ³n | Resultado ejecutado |
| --- | --- |
| `flutter pub get` | CÃ³digo 0 |
| `flutter analyze` final | Sin incidencias, cÃ³digo 0 |
| `flutter test --concurrency=1 --exclude-tags=exhaustive-ui` | 84 aprobadas |
| Dos nuevos casos de victoria, ejecutados por nombre | 2 aprobados; 320Ã568/640Ã360, texto 160 % |
| `flutter test test/ui_matrix_test.dart --dart-define=QA_SHARD=N`, N=0..3, secuencial | Los cuatro procesos aprobados; 2.268 configuraciones UI completas |
| `dart run tool/audit_matrix.dart --shards` | 2.268 configuraciones Ãºnicas, reparto exacto, `renderer=spiral` |
| Motor y frecuencia HOT, dentro de suite general | 6.804 partidas y 756 bases de intensidad aprobadas |
| `flutter test integration_test/app_test.dart -d R5GYC4WPCYX` | Aprobado, 12 configuraciones y ajustes/personalizados, 3:19 de ejecuciÃ³n |
| `flutter build apk --debug` final, entrada normal | CÃ³digo 0, Gradle 52,3 s |
| ADB `install -r`, apertura y versiÃ³n instalada | `Success`, actividad abierta, 1.1.0/code 2/target 36 |
| Persistencia manual APK normal | Contenido creado desde UI, proceso detenido, app reabierta y fila recuperada en Ajustes |

La suite general suma **86 pruebas distintas aprobadas en dos ejecuciones**, mÃ¡s una prueba matricial ejecutada en cuatro particiones. No se afirma que la ejecuciÃ³n Ãºnica sin particionar terminara: su interrupciÃ³n por memoria se conserva abajo. La matriz exhaustiva cubre selecciones de configuraciÃ³n y sus recorridos definidos; la integraciÃ³n fÃ­sica cubre 12 casos representativos, no 2.268 en el dispositivo.

APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, **180.268.760 bytes**.
SHA-256: `D36AC4EB7ADC389A566A6F056A7B341FBDEF008EFBAF64B897DB0D9D73CF1C21`.

Evidencias actuales: `mobile/build/qa_ui_matrix.csv`, `qa_ui_matrix_summary.json`, cuatro CSV por perfil, `sapo_home_final.png`, `sapo_spiral_board.png`, `sapo_roster_two.png` y `sapo_persisted.xml/png`. Las capturas de tablero/lista corresponden al APK visual preliminar; el cambio posterior fue contraste del + y acciÃ³n semÃ¡ntica del dado, verificados por las pruebas y el APK final. La captura final de Inicio y la evidencia de persistencia sÃ­ corresponden al APK normal final.

La comprobaciÃ³n manual del APK normal se hizo con contenido creado en ese mismo APK, ya que tras la instalaciÃ³n el almacenamiento se observÃ³ vacÃ­o. Se verificÃ³ la fila antes y despuÃ©s de `am force-stop`/apertura, sin borrar datos ni cambiar permisos. Se retirÃ³ Ãºnicamente la pregunta QA creada para esa comprobaciÃ³n. Se deja la aplicaciÃ³n en Inicio. Los primeros dumps de UI durante arranque devolvieron raÃ­z nula; se repitieron tras estar lista la UI, sin registrarlos como comprobaciÃ³n exitosa.

## Registro de ejecuciÃ³n y correcciones

## RevisiÃ³n visual posterior a las referencias

Durante esta revisiÃ³n se repitieron anÃ¡lisis y matriz completa con `renderer=spiral`. El resultado final vigente figura arriba; los pÃ¡rrafos siguientes conservan intentos y correcciones.

La primera ejecuciÃ³n completa visual se interrumpiÃ³ de forma controlada tras **1.827 casos UI registrados sin fallos**, por presiÃ³n de memoria del equipo de 8 GB (aproximadamente 120 MB fÃ­sicos libres). No se registra como suite aprobada. Se aÃ±ade particiÃ³n `QA_SHARD=0..3`: cada proceso repite las mismas 567 combinaciones de un perfil, con las mismas aserciones de widgets, SQLite y navegaciÃ³n. No se reduce la cobertura. El auditor `dart run tool/audit_matrix.dart --shards` exige los cuatro CSV, 2.268 IDs consecutivos, configuraciones Ãºnicas y reparto exacto antes de generar el CSV conjunto.

Primera repeticiÃ³n con `--exclude-tags=exhaustive-ui`: **83 aprobadas y 1 fallida**. La nueva aserciÃ³n accesible del dado comprobÃ³ la acciÃ³n `tap`, pero la verificaciÃ³n final detectÃ³ un `SemanticsHandle` activo: `addTearDown` se ejecutaba despuÃ©s de la verificaciÃ³n del binding. Se cambia por `try/finally` con liberaciÃ³n antes de retornar; se conserva la prueba de acciÃ³n, figura, giro y resultado, y se repite la suite.

RepeticiÃ³n tras corregir la liberaciÃ³n: `flutter test --concurrency=1 --exclude-tags=exhaustive-ui`, **84 aprobadas**, cÃ³digo 0 (~52 s). Se aÃ±aden dos escenarios de regreso desde victoria con texto al 160 %. Intento de ejecutarlos en paralelo con la matriz: bloqueado antes de cargar tests porque el hook de SQLite intentÃ³ sustituir `build/native_assets/windows/sqlite3.dll` todavÃ­a en uso. No se cambia ningÃºn permiso ni se elimina el archivo: se ejecutarÃ¡n secuencialmente tras terminar la matriz.

Matriz visual particionada final: **los cuatro procesos terminaron con cÃ³digo 0**, 567 casos cada uno (3:15/3:05/3:10/3:02 de ejecuciÃ³n). `dart run tool/audit_matrix.dart --shards`: **aprobado**, 2.268 filas Ãºnicas `ok,spiral`, 567 por perfil, 756 por tamaÃ±o, 756 por intensidad y 36 por cada una de las 63 mÃ¡scaras de categorÃ­as. CSV conjunto y resumen JSON regenerados. Los dos escenarios aÃ±adidos de victoria tuvieron inicialmente un error de compilaciÃ³n del fixture por intentar asignar `winner`; se elimina esa asignaciÃ³n porque el motor deriva la victoria de las posiciones, sin modificar el motor ni las aserciones.

- `flutter test test/spiral_board_test.dart --plain-name 'Victoria:'`: **2 aprobadas**, retorno al inicio en 320Ã568 y 640Ã360 con texto al 160 %. Total de pruebas generales distintas aprobadas: **86**, mÃ¡s la matriz UI parametrizada de 2.268 casos.
- `flutter analyze` despuÃ©s de las pruebas adicionales: **No issues found**, cÃ³digo 0 (11,6 s).
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX` sobre el diseÃ±o en espiral: **aprobado en Samsung**, cÃ³digo 0, 12 configuraciones y ajustes/personalizados (~3:19 de ejecuciÃ³n; Gradle 57,5 s e instalaciÃ³n 30,9 s). Se verifica explÃ­citamente `SpiralBoardView`, `VisualDice` y cara dibujada igual al resultado del motor. No se confunde con las 2.268 configuraciones de widgets.
- `flutter pub get` final: aprobado, cÃ³digo 0. Las versiones bloqueadas se mantienen; los avisos de nuevas versiones no son errores de resoluciÃ³n.

InspecciÃ³n manual ejecutada en Samsung sobre APK normal 1.1.0+2: inicio con identidad exacta, alta de Ana y Luis mediante +, teclado y pie de navegaciÃ³n, configuraciÃ³n Picante/Equilibrado/50, revisiÃ³n, creaciÃ³n, tablero completo, lanzamiento 4 y tarjeta Bebe de la casilla 4. Capturas reales en `mobile/build/sapo_brand_home.png`, `sapo_roster_manual.png`, `sapo_roster_two.png`, `sapo_spiral_board.png` y `sapo_dice_spin.png`. Esta Ãºltima muestra la tarjeta ya abierta, no prueba por sÃ­ sola el giro. El giro/detenciÃ³n se verifica mediante la transformaciÃ³n y cara dibujada en widgets. La inspecciÃ³n detectÃ³ poco contraste del + y ausencia de acciÃ³n accesible en la etiqueta del dado; ambos se corrigen en fuente y se validan antes del APK final.

Se sustituye la tabla por una proyecciÃ³n en espiral, sin cambiar el vector del motor ni sus posiciones. El dado se dibuja con puntos, giro 3D y resultado final. Se aÃ±aden identidad confirmada, estilo morado/pastel, tarjetas superpuestas, fichas y controles de alta mÃ¡s claros. La nueva matriz CSV incorpora `renderer=spiral` para distinguirla de la matriz anterior; debe volver a ejecutarse antes del cierre.

RegresiÃ³n parcial inicial ejecutada: **42 pruebas aprobadas**, incluidos recorridos adyacentes de 30/50/75, 18 combinaciones de viewport/texto con doce fichas, giro/detenciÃ³n del dado, tarjeta larga, configuraciÃ³n, navegaciÃ³n y HOT. Se corrigiÃ³ la transformaciÃ³n residual del dado detenido. Los pendientes de esa fase (matriz completa, integraciÃ³n fÃ­sica, inspecciÃ³n y APK normal) se resolvieron en el cierre vigente de arriba.

## RevisiÃ³n actual: reporte del usuario sobre configuraciÃ³n y HOT

Se reabre QA. La cobertura anterior comprobaba un camino de creaciÃ³n y no justificaba afirmar que toda la navegaciÃ³n UX estaba validada. Se aÃ±ade HOT independiente y se sustituye el formulario largo por pasos con controles de avance fijos. La intensidad debe cambiar tanto el contenido como la frecuencia HOT. Las nuevas pruebas y resultados se registrarÃ¡n al final; los resultados histÃ³ricos siguientes corresponden al APK anterior.

La nueva cobertura incluye los 63 subconjuntos no vacÃ­os de seis categorÃ­as Ã 3 tamaÃ±os Ã 4 perfiles Ã 3 intensidades = 2.268 configuraciones. Se estÃ¡n recorriendo tambiÃ©n desde la interfaz con toques, revisiÃ³n, creaciÃ³n, persistencia y regreso al inicio. La evidencia de cada caso aprobado se acumula en `mobile/build/qa_ui_matrix.csv`; no se confunde esta UI simulada con ejecuciÃ³n en el Samsung.

### Resultados parciales de la revisiÃ³n HOT

- CatÃ¡logo regenerado y auditado: 385 contenidos, incluidos 30 preguntas y 30 retos HOT. Tipos y tres niveles vÃ¡lidos.
- Matriz del motor: **6.804 partidas aprobadas** (2.268 configuraciones con 2, 6 y 12 jugadores).
- Propiedad de intensidad: **756 configuraciones base aprobadas**; HOT nunca disminuye al subir intensidad, no aparece desactivada y tiene al menos una casilla cuando estÃ¡ activada.
- Los escenarios de configuraciÃ³n en 360Ã640 y 384Ã832 con texto ampliado, retrocesos, borrador, nombres duplicados y ediciÃ³n pasaron.
- Se detectÃ³ y corrigiÃ³ un fallo real de teclado: `bottomNavigationBar` no se elevaba sobre el IME. Se aÃ±adiÃ³ compensaciÃ³n explÃ­cita de `viewInsets.bottom`; el caso con teclado de 300 px pasÃ³ despuÃ©s.
- Se corrigieron selectores de prueba que asumÃ­an una lista no virtualizada y el tooltip de retroceso predeterminado. Se mantiene la comprobaciÃ³n de orden real y se usa el retroceso Android (`handlePopRoute`).
- AnÃ¡lisis estÃ¡tico posterior: **No issues found**.
- `flutter test --concurrency=1`: **48 pruebas aprobadas** en ~21 min 10 s, incluida la matriz UI completa de **2.268 configuraciones**.
- `dart run tool/audit_matrix.dart`: **aprobado**. CSV con 2.268 filas Ãºnicas y aprobadas; 567 por perfil, 756 por tamaÃ±o, 756 por intensidad y 36 por cada uno de los 63 conjuntos de categorÃ­as. Resumen en `mobile/build/qa_ui_matrix_summary.json`.
- Las pruebas adicionales encontraron un desbordamiento real de 0,941 px en una casilla con texto al 160 %. Se ajustan las columnas del tablero Ãºnicamente para texto ampliado (5 normales, 3 ampliadas, 2 muy ampliadas). Se mantiene el error como prueba de regresiÃ³n y se vuelve a ejecutar.
- `flutter test test/navigation_edges_test.dart test/hot_ui_test.dart test/config_test.dart --concurrency=1`: **18 aprobadas** despuÃ©s de corregir el desbordamiento. Incluye 11 casos adicionales nuevos y repeticiÃ³n de los 7 de configuraciÃ³n: **59 pruebas locales distintas aprobadas** entre ambas ejecuciones.
- Casos adicionales: texto al 160 %, rotaciÃ³n a 640Ã360, 12 jugadores/rechazo del 13, cancelaciÃ³n conservando la partida anterior, doble toque en Comenzar y las seis resoluciones de pregunta/reto HOT (completar, tomar u omitir).
- La matriz de 2.268 UI corresponde al tamaÃ±o de texto normal. El ajuste posterior de columnas afecta Ãºnicamente a texto ampliado; se repitieron las regresiones de configuraciÃ³n y HOT, incluida accesibilidad, sin volver a ejecutar innecesariamente los 2.268 casos de texto normal.
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **aprobado en Samsung**, cÃ³digo 0, 12 configuraciones verificadas dentro del test (~3 min 35 s de ejecuciÃ³n, mÃ¡s compilaciÃ³n e instalaciÃ³n).
- Recorrido fÃ­sico: alta de tres nombres, ediciÃ³n de nombre/icono, reordenamiento y eliminaciÃ³n, errores por jugadores/categorÃ­as, 12 perfiles-intensidades con tamaÃ±os 30/50/75 y seis mÃ¡scaras de categorÃ­as, revisiÃ³n/retroceso, creaciÃ³n, lectura SQLite, dado, tarjeta, omisiÃ³n, reanudaciÃ³n y ajustes. TambiÃ©n se creÃ³ y recuperÃ³ un reto HOT personalizado desde el dispositivo.
- La Ãºltima mejora de redacciÃ³n cambia el campo a Primer/Siguiente jugador y el botÃ³n a Agregar/Agregar otro jugador. Se ejecutan regresiones de configuraciÃ³n y navegaciÃ³n tras esa mejora; el APK normal final se compila a continuaciÃ³n.

## Estado del entregable anterior

Ãltimo cÃ³digo verificado: anÃ¡lisis sin incidencias, 37 pruebas locales aprobadas y prueba de integraciÃ³n aprobada en Samsung despuÃ©s de corregir el Ã¡rea segura inferior. APK normal definitivo compilado con cÃ³digo 0, instalado con `Success` y actividad abierta por ADB. Las secciones siguientes conservan el registro cronolÃ³gico de intentos y correcciones; sus pendientes intermedios estÃ¡n resueltos por este cierre.

Fecha: 28/10/2026. Directorio de comandos Flutter: `D:\Plataformas\SAPO\mobile`.

## Evidencia inicial

- `flutter --version`: Flutter 3.47.6, Dart 3.13.5.
- ADB absoluto: `C:\Users\LUIS\AppData\Local\Android\Sdk\platform-tools\adb.exe`.
- `adb devices`: `R5GYC4WPCYX device`, conectado y autorizado.
- `flutter create --platforms=android --org com.sapo --project-name sapo mobile`: creaciÃ³n de proyecto.
- Dependencias aÃ±adidas: flutter_riverpod, drift, sqlite3_flutter_libs, path_provider, path e integration_test.
- Intento de generador Python: fallÃ³ porque Python no estÃ¡ disponible; sustituido por generador Dart local.
- `dart run tool/catalog.dart`: ejecutado correctamente. Cantidades reales 150/60/80/10/25 (Verdad/Bebe/Reto/Minijuego/Evento).
- `dart format lib test integration_test tool`: ejecutado, 11 archivos formateados.
- Primeros anÃ¡lisis: detectaron referencias al proyecto de ejemplo y errores de sintaxis. Corregidos; repeticiÃ³n en curso.

## Verificaciones automatizadas creadas

- Cantidades JSON, IDs y textos Ãºnicos, categorÃ­as/intensidades/estado/temÃ¡tica vÃ¡lidos.
- Registro y orden circular, distribuciÃ³n exacta, reproducibilidad, tamaÃ±os y filtros.
- Dado, lÃ­mites, bloqueo de acciones duplicadas, meta y victoria.
- SelecciÃ³n por intensidad, ID y concepto compartido entre categorÃ­as, agotamiento y recuperaciÃ³n.
- Efectos de los 25 eventos, escudos, pÃ©rdida de turno, lanzamiento extra, reglas y 7 PUM.
- SerializaciÃ³n, SQLite, historial y reapertura de contenidos personalizados/ajustes.
- Widgets: registro, reordenamiento, ediciÃ³n, eliminaciÃ³n y creaciÃ³n de partida.
- IntegraciÃ³n Samsung: crear, lanzar, omitir y continuar partida.

## Ejecuciones en curso

`flutter analyze`, `flutter test`, `flutter build apk --debug`.

Los resultados finales se aÃ±adirÃ¡n al finalizar. No se afirma aprobaciÃ³n de pruebas aÃºn.

## Resultados intermedios ejecutados

- `flutter analyze`: **aprobado, No issues found** tras corregir diez observaciones de estilo con `dart fix --apply`.
- `flutter test`: **18 pruebas aprobadas** (auditorÃ­a, motor, SQLite y flujo de jugadores).
- `flutter test test/minigame_test.dart`: **13 pruebas aprobadas**, una por cada minijuego o reto especial, con interacciÃ³n y verificaciÃ³n del estado guardado.
- `flutter test test/settings_test.dart --timeout 60s`: **2 pruebas aprobadas**. CreaciÃ³n real desde UI, cierre/reapertura de SQLite y controlador, ediciÃ³n y eliminaciÃ³n; ajuste persistente; confirmaciÃ³n del borrado de historial.
- Prueba inicial de widgets: fallÃ³ por `pumpAndSettle` durante carga de assets; corregida inicializaciÃ³n en contexto de IO real. Segundo intento detectÃ³ varios Scrollable; se hizo explÃ­cito el scroll exterior. Prueba repetida aprobada.
- Una ejecuciÃ³n combinada de settings/motor se interrumpiÃ³ al investigar IO real dentro del reloj simulado de widgets; la prueba de settings se corrigiÃ³ usando `runAsync` para abrir/cerrar archivos y pasÃ³. No cuenta como ejecuciÃ³n aprobada de la suite completa.
- CompilaciÃ³n inicial: preparaciÃ³n de Gradle 9.3.1 y dependencias Android; advertencia de versiones XML del SDK. El equipo llegÃ³ a ~25 MB libres de 8 GB. Se limitÃ³ Gradle localmente a 2 GB y dos workers; no se modificaron ajustes globales.

La suite completa debe repetirse tras los Ãºltimos cambios. AÃºn no se acredita ejecuciÃ³n de integraciÃ³n ni APK final.

## VerificaciÃ³n completa local y primer APK

- `flutter pub get`: **aprobado**. Se mantienen las versiones resueltas en pubspec.lock; se informan actualizaciones mayores disponibles, sin errores de resoluciÃ³n.
- `flutter test --concurrency=1`: **37 aprobadas, 0 fallidas**, duraciÃ³n de ejecuciÃ³n de pruebas ~21 s tras carga del runner.
- Desglose: 2 catÃ¡logo, 3 configuraciÃ³n/responsividad/concurrencia, 16 motor/persistencia (incluida simulaciÃ³n de 100 partidas completas), 13 minijuegos/retos especiales, 2 ajustes/personalizados y 1 flujo de jugadores.
- ValidaciÃ³n de pantalla estrecha: 360 px, doce fichas en la misma casilla, sin excepciÃ³n de layout.
- AnÃ¡lisis posterior detectÃ³ tres observaciones de llaves en cÃ³digo nuevo, corregidas; pendiente repetir el anÃ¡lisis final.
- Primer build completo: `flutter build apk --debug --verbose` con log en `mobile/build/android_build.log`; log `BUILD SUCCESSFUL in 2m`, 146 tareas, salida Flutter `Built ... app-debug.apk`, cÃ³digo interno 0. La redirecciÃ³n de PowerShell devolviÃ³ 1 pese al Ã©xito registrado; se verificÃ³ el artefacto y su instalaciÃ³n, y se repetirÃ¡ el comando normal al finalizar.
- APK verificado: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 162.993.111 bytes en esa primera compilaciÃ³n.
- `adb -s R5GYC4WPCYX install -r ...app-debug.apk`: **Success**.
- `adb ... shell am start -n com.sapo.sapo/.MainActivity`: **actividad iniciada**.
- Captura real extraÃ­da e inspeccionada: `mobile/build/sapo_home.png`, pantalla de inicio SAPO correcta, caracteres espaÃ±oles e icono visibles.
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **en ejecuciÃ³n**.

## CorrecciÃ³n y prueba en Samsung

Primera ejecuciÃ³n de integraciÃ³n: **fallida**. El toque sobre Â«Omitir y continuarÂ» estaba fuera del viewport (`Offset(192, 980)` para pantalla lÃ³gica de 384Ã832), por lo que no cambiaba el turno. Se movieron tarjeta y acciones antes del tablero para reducir el desplazamiento necesario. La prueba espera la acciÃ³n habilitada, asegura su visibilidad y trata los toques fallidos como error; no se suprimiÃ³ la verificaciÃ³n.

- `flutter analyze` tras la correcciÃ³n: **No issues found**.
- `flutter test --concurrency=1` tras la correcciÃ³n: **37 aprobadas, 0 fallidas**, ~16 s de ejecuciÃ³n de pruebas.
- Segunda ejecuciÃ³n exacta de `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **1 aprobada, 0 fallidas**, ~17 s de ejecuciÃ³n en Samsung, ademÃ¡s del tiempo de compilaciÃ³n/instalaciÃ³n. CÃ³digo de salida 0.
- Flujo real probado: nueva partida con dos jugadores, lanzamiento, tarjeta, omisiÃ³n, salida a inicio y continuaciÃ³n con el turno de Luis QA.
- El generador se dejÃ³ exclusivamente en Dart/JSON. Se eliminÃ³ el archivo Python provisional. RegeneraciÃ³n ejecutada con las mismas cantidades; SHA-256 del JSON idÃ©ntico antes/despuÃ©s: `982EAC6C9E3B8ACADAE8B2B11D3838CB536DFC28563A64AB548D9789FB87F0B2`.

En curso: build normal final y verificaciÃ³n del guardado tras detener y abrir el proceso Android.

La revisiÃ³n manual del APK normal detectÃ³ que el Ã¡rea de navegaciÃ³n de tres botones de Samsung podÃ­a cubrir parcialmente el Ãºltimo botÃ³n del formulario. Se aÃ±adiÃ³ protecciÃ³n de Ã¡rea segura inferior a toda la navegaciÃ³n de la app. Se repiten las verificaciones despuÃ©s de esta correcciÃ³n.

UIAutomator devolviÃ³ `null root node` al intentar extraer el Ã¡rbol; esa vÃ­a no se contÃ³ como prueba aprobada. Se usa captura real y entradas ADB dirigidas a la aplicaciÃ³n para la comprobaciÃ³n manual.

## Ãltima validaciÃ³n tras Ã¡rea segura inferior

- `flutter analyze`: **No issues found**, cÃ³digo 0.
- `flutter test --concurrency=1`: **37 aprobadas**, cÃ³digo 0 (~22 s de ejecuciÃ³n de pruebas).
- `flutter test integration_test/app_test.dart -d R5GYC4WPCYX`: **1 aprobada**, cÃ³digo 0 (~12 s de ejecuciÃ³n en Samsung, 45,4 s de compilaciÃ³n y 33,9 s de instalaciÃ³n).
- ComprobaciÃ³n manual de persistencia en APK normal: se registraron Ana y Luis con iconos diferentes, se iniciÃ³ una partida, se ejecutÃ³ `adb shell am force-stop com.sapo.sapo` y se volviÃ³ a abrir la actividad. ApareciÃ³ Â«Continuar partidaÂ»; al abrirla se conservaron ambos jugadores, sus iconos, el turno de Ana y las posiciones iniciales. Capturas: `mobile/build/sapo_after_restart.png` y `mobile/build/sapo_board.png`.
- La comprobaciÃ³n de persistencia manual corresponde al mismo motor SQLite, antes de la correcciÃ³n exclusiva del Ã¡rea segura. La integraciÃ³n Android y la suite local se ejecutaron otra vez despuÃ©s de esa correcciÃ³n y pasaron.

El APK normal se regenera despuÃ©s de la Ãºltima ejecuciÃ³n de integraciÃ³n para no entregar el entrypoint de pruebas.

## Artefacto definitivo

- `flutter build apk --debug`: **aprobado**, cÃ³digo 0, ~49,9 s.
- APK normal, entrypoint `lib/main.dart`: `D:\Plataformas\SAPO\mobile\build\app\outputs\flutter-apk\app-debug.apk`.
- TamaÃ±o: **183.584.387 bytes**.
- SHA-256: `6605D040E7C064DAE4F255A6252C5F58E5885962BB8E44D7A2D13B07FBC6948C`.
- InstalaciÃ³n final: `adb -s R5GYC4WPCYX install -r ...app-debug.apk` â **Success**, cÃ³digo 0.
- Apertura final: `adb ... shell am start -n com.sapo.sapo/.MainActivity` â **Starting: Intent**, cÃ³digo 0.
- Pantalla inicial del APK definitivo inspeccionada despuÃ©s del arranque: `mobile/build/sapo_final.png`. La app queda abierta en el Samsung.
Ajuste de identidad en inicio 2026-10-29: reemplazada expansion literal por boton ¿Que significa? y aviso sobre el chisme peruano; prueba branding actualizada. No se ejecutaron pruebas ni analisis.
Verificacion final 2026-10-29: flutter analyze limpio; flutter test test/branding_test.dart aprobado (3/3 tamanos/orientaciones); flutter build apk --debug aprobado (185270458 bytes, SHA-256 66B00095090D832E9B11B6C7229CF08AF2DCA212785446B102E5228900EC7F45); adb install -r Success en R5GYC4WPCYX y arranque confirmado. Se toco el boton en el Samsung y se verifico visualmente el aviso; captura en mobile/build/sapo_verification.png.
Minijuegos 2026-10-29: flutter test --concurrency=1 test/minigame_test.dart aprobado 16/16. Un primer intento fallo por finder ambiguo en el dialogo Oracion; se corrigio a texto exacto y la ejecucion final paso. flutter analyze: No issues found. flutter build apk --debug aprobado: 185275361 bytes; SHA-256 404D80EA809FBF5DE99F93E71E8DF056D6D41E199EA4A9008A0F15135429E7FB. adb install -r Success en R5GYC4WPCYX; app abierta en Ajustes > Probar minijuegos y pantalla revisada: mobile/build/sapo_minigame_review.png.
Revision minijuegos 2026-10-29: flutter analyze limpio. flutter test --concurrency=1 test/minigame_test.dart: 17/17 aprobado; incluye galeria, retos, validacion de Oracion/Reemplazo y las dinamicas. Primer intento fallo porque el reto estaba al final de una lista perezosa; se hizo scroll antes del tap y paso. flutter test --concurrency=1 test/game_test.dart: 19/19 aprobado, incluye exclusion de minijuegos del historial SQLite. flutter build apk --debug aprobado, 185282048 bytes, SHA-256 3DCDB445EFF274B9E69FA0C87D7DA0FD4EF4A2735CF54C6ED3B3FC9685051B53. adb install -r Success; Samsung R5GYC4WPCYX abierto en Probar minijuegos. Captura: mobile/build/sapo_minigame_review.png.
Correccion final de Limón 2026-10-29: inicia por el jugador activo y el selector decide quien recibe el turno. flutter test --concurrency=1 test/minigame_test.dart: 17/17 aprobado; flutter analyze: No issues found. APK final recompilado e instalado con adb Success en R5GYC4WPCYX; 185280842 bytes; SHA-256 2F3AE0B986F14D32B0DB67720E3D8BF1E232D464A1CAC8EB4642D1B6C29B7539. App en Ajustes > Probar minijuegos; captura mobile/build/sapo_minigame_review.png.

### QA UX minijuegos 2026-10-29: analyzer limpio; pruebas minijuego 17/17; suite estándar sin exhaustive-ui 107/107; Samsung 12/12; APK debug instalada/abierta. Matriz completa se detuvo en 31/372 sin progreso >90s y no se declara aprobada. SHA256 APK AB90E0C5125452E90CF836F797054A216215D6C17BDBA854BDB5DB8645A65F76.
### Correccion de numeros fijos para Limon y guia del Pato (2026-10-29)
Flutter analyze: sin problemas; flutter test --concurrency=1 test/minigame_test.dart: 17/17 aprobadas, incluyendo inicio de Limon desde el indice 2 y retorno al numero fijo de otra persona.
flutter build apk --debug: aprobado; instalacion ADB y lanzamiento en R5GYC4WPCYX completados. APK 185288312 bytes. SHA-256 D3190552A5139D1812D8E221630E24F98C8DC643080472946E66F05E31CCF97A.

## Preparacion para GitHub (2026-10-30)
- git init --initial-branch=main: completado; no se configuro remoto ni se creo commit.
- git check-ignore -v confirmo que local.properties, .gradle, .dart_tool, mobile/build (incluido el APK), app/.cxx y .idea quedan ignorados.
- node tool/export_catalog.mjs desde mobile/: completado; exporta a .agents/CATALOGO_REVISION.md.
- No se ejecutaron pruebas Flutter ni compilacion: este cambio prepara la estructura Git.
