# RediseÃ±o visual sobre 1.1.5+7 (2026-10-28)

- Tema claro y oscuro: `lib/ui/sapo_theme.dart` define `SapoPalette` (ThemeExtension) y `sapoTheme(Brightness)`. Las pantallas leen `context.sapo` en lugar de colores fijos. El ajuste `settings['theme']` (system/light/dark) se elige en Ajustes o con el botÃ³n del inicio, y se guarda.
- Logo vivo (`lib/ui/sapo_logo.dart`): tres sapos dibujados en canvas (brindis con tarro, shot con guiÃ±o, cÃ³ctel con sorbete) que se alternan cada 4,8 s. El sapo flota, mece la bebida, parpadea y le suben burbujas; al tocarlo pasa al siguiente. En el inicio mide hasta 184 px.
- TÃ­tulo S.A.P.O. y encabezados en Lilita One (`assets/fonts`, licencia OFL incluida).
- Tarjeta: entra volteÃ¡ndose (420 ms, easeOutBack). Ficha: cada paso es un salto con aplastamiento al aterrizar (`TokenHop`), y el destino fijo de `AnimatedPositioned` la deja centrada dentro de la casilla. Turno: entra deslizÃ¡ndose. Victoria: confeti de una sola pasada (`board/confetti.dart`), trofeo con rebote y Â«<ganador> reparte 3 tragos a quien quiera.Â».
- Propuesta visual en el lienzo de Claude Design: https://claude.ai/artifact/LBfeV3Fbr9EJPrLFuuyUFq
- QA: analyze limpio, 105/105 pruebas, matriz 372/372, Samsung 12/12, APK debug instalado y abierto. Detalle en TEST_REPORT.md.

# Estado vigente 1.1.4+6 â identidad editorial adulta

SAPO es exclusivamente +18. Tranqui tambiÃ©n es para adultos; la intensidad aumenta la incomodidad y explicitud. Se eliminÃ³ HOT como categorÃ­a y se migraron sus preguntas a Verdad o Shot y sus retos a Reto. Se reescribieron las preguntas rutinarias, las consignas de Bebe cotidianas y los retos infantiles seÃ±alados. El catÃ¡logo mantiene 385 tarjetas: 180 Verdad o Shot, 60 Bebe, 110 Retos, 10 Minijuegos y 25 Eventos. La fuente editorial es `mobile/tool/catalog_editorial.json`; se valida/genera a `mobile/assets/catalog.json` y se exporta para lectura a `CATALOGO_REVISION.md`.

El contenido explÃ­cito se ubica en Verdad o Shot, intensidad 3. Los niveles 1 y 2 conservan contenido de adultos con coqueteo, besos, atracciÃ³n, relaciones y situaciones Ã­ntimas. La intensidad filtra el catÃ¡logo; no hay categorÃ­a sexual independiente. El primer ingreso confirma mayorÃ­a de edad y muestra consentimiento para retos con terceros; negarse a participar en esos retos no se penaliza.

VerificaciÃ³n de esta revisiÃ³n: `flutter analyze` limpio; `flutter test --concurrency=1` aprobÃ³ 101 pruebas; matriz UI auditada 372/372 en 31 mÃ¡scaras de categorÃ­as, cuatro tamaÃ±os y tres intensidades; integraciÃ³n Samsung 1/1 con 12/12 configuraciones. APK debug 1.1.4+6 compilado, instalado y abierto en `R5GYC4WPCYX`; la pantalla de aceptaciÃ³n +18 y luego la pantalla de inicio se inspeccionaron mediante captura del dispositivo. CATALOGO_REVISION.md exportado para revisiÃ³n.

## Historial 1.1.3+5 â tablero y comodines

TamaÃ±os admitidos: 30, 50, 75 y 100 posiciones visibles en total. El Ã­ndice 0 es INICIO y se rotula como casilla 1; el Ã­ndice N-1 es META y se rotula como casilla N. Los jugadores comienzan en 0. Render, motor, victoria y numeraciÃ³n ahora comparten esa convenciÃ³n.

Los eventos de avance/retroceso calculan un resultado aleatorio 1-6 al extraer la tarjeta; tÃ­tulo, tirada y destino quedan guardados en la tarjeta pendiente. El modal muestra la cantidad y las posiciones anteriores/nuevas; al aplicarlo anima cada paso, guarda el avance y registra causa/resultado. El movimiento se limita al inicio/meta y no activa efectos encadenados.

VerificaciÃ³n de esta revisiÃ³n: flutter analyze limpio; flutter test --concurrency=1 pasÃ³ con 103 pruebas; matriz UI 756/756 aprobada y auditada; integraciÃ³n Samsung 1/1 aprobada con 12 configuraciones distribuidas entre 30/50/75/100. APK 1.1.3+5 instalado y abierto en R5GYC4WPCYX. Detalle en TEST_REPORT.md.
# S.A.P.O. â progreso

## CorrecciÃ³n vigente 1.1.5+7 â meta exacta y minijuegos

El tablero usa `N` casillas jugables numeradas del 1 al N, ademÃ¡s de marcadores fÃ­sicos separados de Inicio (Ã­ndice 0) y Meta (Ã­ndice N+1). Todos comienzan en Inicio. La victoria ocurre al terminar una tirada exactamente en Meta; si sobran pasos, la ficha llega a Meta y rebota hacia atrÃ¡s. Por ejemplo, desde la casilla 50, un 2 termina de nuevo en 50; un 3 termina en 49.

Los eventos de avance/retroceso son individuales, eligen 1â6 una sola vez, guardan ruta y resultado, animan la ficha y muestran una nueva tarjeta en el destino si no hubo victoria. Esa tarjeta no activa un segundo movimiento automÃ¡tico. Carta alta y 21 usan cartas visuales locales; 21 acumula valores elegidos de 1 a 13, penaliza al superar 21 y permite elegir a quiÃ©n toma al llegar exactamente. Reemplazar el conteo de 7 PUM y OraciÃ³n oculta su secuencia hasta que se acusa. Al finalizar una dinÃ¡mica, se cierra y avanza el turno.

QA de la correcciÃ³n: `flutter analyze` sin incidencias; suite completa de 102 pruebas aprobada, matriz UI 372/372; integraciÃ³n Samsung 12/12; APK 1.1.5+7 recompilado, instalado y abierto tras el ajuste final de OraciÃ³n. Incluye 14 pruebas focales de minijuegos. Ver resultados y hash en `TEST_REPORT.md`.

Actualizado: 28/10/2026. **Sistema Aleatorio de Preguntas Ofensivas**. Lema: **Â«El juego donde nadie sale limpioÂ»**.

AplicaciÃ³n Flutter offline en `mobile/`. El proyecto Android nativo original de la raÃ­z se conserva. No se integraron servicios externos ni Supabase.

**RevisiÃ³n anterior 1.1.1**: cubo 3D de seis caras, giro de 2 s, pausa de resultado de 750 ms, pasos de 360 ms, paleta propia, INICIO fÃ­sico y selector unificado. Sus pruebas y APK se conservan como historial; la revisiÃ³n anterior fue 1.1.3+5.

## Implementado

- Inicio, nueva partida, guardado automÃ¡tico y continuaciÃ³n mediante Riverpod + Drift/SQLite.
- ConfiguraciÃ³n Jugadores â Partida â RevisiÃ³n, borrador al volver, errores claros y acciones fijas que respetan teclado y navegaciÃ³n Android.
- De 2 a 12 jugadores: alta sucesiva con +/Listo/Agregar otro, fichas, nombres editables, eliminaciÃ³n y reordenamiento.
- Tableros reproducibles de 30/50/75/100 casillas jugables numeradas 1..N, mÃ¡s marcadores fÃ­sicos aparte para INICIO y META. La llegada a Meta exige nÃºmero exacto con rebote al excederse.
- CatÃ¡logo adulto reescrito: 180 preguntas, 60 consignas Bebe, 110 retos, 10 minijuegos y 25 eventos; no existe HOT como categorÃ­a.
- AceptaciÃ³n +18 al primer ingreso; los retos con terceros exigen aceptaciÃ³n y su negativa no se penaliza.
- Espiral continua ampliable; marcadores INICIO/META separados de las casillas numeradas; fichas con pasos de 360 ms, dado cÃºbico 3D y tarjetas superpuestas.
- Dado de 1â6. Ganar exige acabar exactamente en Meta; un sobretiro rebota. Los comodines individuales muestran, guardan y animan el resultado; la casilla de destino muestra una tarjeta sin encadenar automÃ¡ticamente otro movimiento.
- Verdad o Shot, Bebe, Reto, Minijuego y Evento. Tomar es la penalizaciÃ³n narrativa; sin puntos, monedas ni selector alternativo.
- Diez minijuegos y retos Carta alta, Todito y Par o impar, con estados persistidos y reglas bÃ¡sicas documentadas.
- Veinticinco eventos con efectos reales: movimiento, intercambio, pÃ©rdida/extra de turno, escudo y reglas temporales.
- JSON local con 385 contenidos, validaciÃ³n de IDs, conceptos, categorÃ­as, intensidades y duplicados normalizados; export editorial para revisiÃ³n.
- AntirrepeticiÃ³n por ID/concepto dentro de la partida y preferencia por nuevos entre partidas. Agotamiento sin reciclaje en la partida ni subida de intensidad.
- Ajustes persistentes de sonido, vibraciÃ³n y animaciones; estadÃ­sticas, historial con confirmaciÃ³n para reiniciarlo y CRUD de contenidos personalizados.
- Identidad propia S.A.P.O., petrÃ³leo/verde Ã¡cido y acentos por categorÃ­a, con icono Android vectorial de rana. La referencia orienta el recorrido, no los colores. `AGENTS.md` resume reglas, estructura y continuidad.

## VerificaciÃ³n 1.1.3+5 (histÃ³rica)

- `flutter analyze`: sin incidencias despuÃ©s de los Ãºltimos ajustes.
- Suite general actual: 103 pruebas aprobadas en la revisiÃ³n 1.1.3+5.
- Matriz del motor: 9.072 partidas y 1.008 configuraciones de intensidad, aprobadas en la suite vigente.
- Matriz UI actual: 756 combinaciones aprobadas y auditadas (63 mÃ¡scaras Ã 4 tamaÃ±os Ã 3 intensidades), CSV y resumen en mobile/build/.
- InspecciÃ³n fÃ­sica de Samsung de 1.1.1 conservada como evidencia histÃ³rica; la integraciÃ³n de 1.1.3+5 verificÃ³ los cuatro tamaÃ±os.
- IntegraciÃ³n Samsung 1.1.3+5 aprobada: 12 configuraciones distribuidas entre 30/50/75/100, navegaciÃ³n, reanudaciÃ³n, ajustes y personalizados.
- APK normal 1.1.3+5 compilado, instalado y abierto; hash, tamaÃ±o y comandos en TEST_REPORT.md.
- InspecciÃ³n manual de 1.1.1 conservada como evidencia histÃ³rica; la validaciÃ³n vigente del dispositivo estÃ¡ en la integraciÃ³n 1.1.3+5.
- Comandos, fallos, correcciones y evidencias detallados en `TEST_REPORT.md`; no confundir resultados histÃ³ricos con la revisiÃ³n actual.

## LÃ­mites y continuidad

Una partida continuable por dispositivo. Equivalencia semÃ¡ntica por grupos editoriales y ayuda lÃ©xica para personalizados, sin modelo semÃ¡ntico remoto. Variantes bÃ¡sicas de minijuegos y mejoras futuras en `PENDIENTES.md`. PublicaciÃ³n, firma release, Supabase y servicios externos quedan fuera del MVP autorizado.
Ajuste identidad en inicio 2026-10-29: sustituido significado literal por botón ¿Qué significa? y aviso lúdico sobre el chisme peruano.
Verificacion en Samsung 2026-10-29: cambio instalado; boton y aviso inspeccionados en pantalla. APK debug actualizado en mobile/build/app/outputs/flutter-apk/app-debug.apk.
Minijuegos 2026-10-29: Oracion resuelta muestra el resultado y solo Aceptar y cerrar el juego; acepta para consumir la tarjeta y pasar turno. Ajustes incluye galeria Probar minijuegos con diez dinamicas aisladas de partidas guardadas. Pruebas del modulo 16/16, analyze limpio, APK instalado; Samsung queda en galeria para feedback.
Minijuegos revision 2026-10-29: Yo Nunca Nunca tiene titulo directo; Limon deja elegir a quien pasar; Pato/Cultura no muestran guias; Reemplazo valida conteo, palabra y secuencia; Oracion valida la frase completa y finaliza con aceptar/cerrar; Presidente/Palabra prohibida duran 1-5 turnos; 21 mantiene total oculto y rota carta; Carta alta voltea carta. Galeria incluye retos individuales. 17/17 pruebas minigame y 19/19 game; Samsung actualizado y en la galeria.
Correccion final Limón: inicia con el jugador activo como numero 1; el selector permite escoger al siguiente, que pasa a ser el turno actual. Prueba 17/17 repetida y aprobada. APK recompilado/reinstalado: 185280842 bytes; Samsung queda en la galeria.
## QA UX minijuegos 2026-10-29
Limón, Pato, Cultura, Reemplazo y Oración actualizados; panel con 13 modos y retos. Analyze limpio; suite sin exhaustive-ui 107/107; minijuegos 17/17; Samsung 12/12. APK debug instalada y abierta. La matriz completa se detuvo en 31/372; ver TEST_REPORT.md.
## Correccion final de Limon y Pato (2026-10-29)
Limon asigna numeros estaticos desde quien activa: 1 al inicio y el resto por orden circular. La llamada selecciona un nombre en un toque, sin mostrar el numero del destino. El Pato explica la regla acumulativa y deja solo el ejemplo inicial. flutter analyze limpio; minigame_test 17/17; APK debug reconstruida, instalada y abierta en el Samsung.

## Preparacion del repositorio (2026-10-30)
Se agrupo la documentacion tecnica en .agents/; el README principal para GitHub permanece en la raiz, se agrego un indice y se actualizo el exportador del catalogo. Se creo .gitignore para caches, compilaciones, ajustes locales, IDE y claves de firma. Git inicializado en main, sin remoto ni commit.
