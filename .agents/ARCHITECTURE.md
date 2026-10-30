# Addendum visual (2026-10-28) â temas y animaciÃ³n

- `ui/sapo_theme.dart`: `SapoPalette` con tokens (fondo, superficies, texto, acentos, marcadores del tablero y `categories[0..7]`), en variantes `light` y `dark`. `sapoTheme([Brightness])` las adjunta como extensiÃ³n; `context.sapo` vuelve a la oscura si no hay extensiÃ³n. `themeModeFrom(settings['theme'])` alimenta `MaterialApp.themeMode`. `SapoApp` observa `appProvider`. La lista global `colors` se conserva por compatibilidad (paleta oscura); en pantalla usar `context.sapo.category`.
- `_BoardPainter` recibe la paleta. Las casillas mezclan el color de categorÃ­a con el fondo del tablero (.78 oscuro / .84 claro).
- `ambientMotion(context, enabled:)` decide si corren los bucles decorativos: requiere el ajuste Â«AnimacionesÂ», que el sistema no pida reducir movimiento y que el binding no sea de prueba (un bucle infinito impedirÃ­a `pumpAndSettle`). Las animaciones finitas (tarjeta, salto, turno, confeti) usan duraciÃ³n 0 con Â«AnimacionesÂ» apagado.
- `AppController.setting` acepta `Object` para guardar cadenas (tema) ademÃ¡s de booleanos.

# Addendum 1.1.4+6 â clasificaciÃ³n adulta y catÃ¡logo editorial

La versiÃ³n vigente del catÃ¡logo usa exclusivamente categorÃ­as 1..5: Verdad o Shot, Bebe, Reto, Minijuego y Evento. Inicio=0 y Meta=6 son casillas de borde. El identificador 7 solo se reconoce en la migraciÃ³n de snapshots antiguos: las casillas antiguas se asignan de forma determinista a Verdad o Shot o Reto, y el pending antiguo se migra segÃºn su antiguo tipo. El editor local y el catÃ¡logo no ofrecen HOT como categorÃ­a.

SAPO es +18 en toda intensidad. Tranqui contiene coqueteo, besos, atracciÃ³n y confesiones adultas; Picante introduce intimidad y temas mÃ¡s personales; Sin vergÃ¼enza incluye preguntas sexuales directas. `Game.draw` conserva el filtro `intensity <= game.intensity`; no hay peso ni casilla especial para HOT. El perfil interno solo aplica los pesos de distribuciÃ³n de categorÃ­as. La semilla conserva el tablero.

`tool/catalog_editorial.json` es la fuente autoritativa offline. `tool/catalog.dart` valida ID, categorÃ­a, intensidad, estado, temÃ¡tica, concepto y texto Ãºnico; exporta `assets/catalog.json`. `tool/export_catalog.mjs` genera `../.agents/CATALOGO_REVISION.md`, organizado por categorÃ­a e intensidad. Los conceptos son grupos editoriales de antirrepeticiÃ³n; no se reutiliza el mismo concepto en entradas distintas. Preguntas sexuales explÃ­citas se clasifican en Verdad o Shot, intensidad 3. El primer ingreso guarda aceptaciÃ³n +18 en ajustes locales. Los retos con terceros necesitan aceptaciÃ³n; declinar no aplica la penalizaciÃ³n del reto.

`catalog_editorial.json` contiene 385 entradas: 180 Verdad o Shot, 60 Bebe, 110 Reto, 10 minijuegos y 25 eventos. Las preguntas/retos HOT histÃ³ricos mantienen IDs para trazabilidad y se cargan en sus categorÃ­as de destino, con conceptos migrados. Los snapshots antiguos se recuperan mediante `Game.decode`; los personalizados cat. 7 se convierten durante `AppController.initialize` y se persisten.

## Addendum 1.1.3+5 â posiciones y movimiento de evento (histÃ³rico)

El tamaÃ±o del recorrido es el total de posiciones, extremos incluidos: Ã­ndice 0 = INICIO/casilla visible 1, Ã­ndices 1..N-2 jugables/casillas visibles 2..N-1, Ã­ndice N-1 = META/casilla visible N. Game.board, Game.positions, SpiralLayout.path, la semÃ¡ntica del lienzo, el lÃ­mite de movimiento y Game.winner deben conservar longitud N. Los layouts admitidos son 30 (6x5), 50 (8x7), 75 (9x9) y 100 (10x10); las celdas de relleno quedan fuera de path y no reciben nÃºmero.

Game.draw calcula una sola vez el resultado de eventos advance/back y lo guarda dentro de pending: tÃ­tulo, cantidad 1-6, origen, destino clamped, pasos efectivos y marca de aplicaciÃ³n. El snapshot serializa pending, asÃ­ que reconstruir o reanudar la tarjeta no consume nueva aleatoriedad. AppController.finish recorre el destino en pasos de una casilla, guarda cada paso y aÃ±ade movimiento al historial; la celda alcanzada no genera otra tarjeta. Un movimiento hasta N-1 registra victoria mediante la condiciÃ³n compartida de Game.winner.
# S.A.P.O. â arquitectura

Identidad: **Sistema Aleatorio de Preguntas Ofensivas**. Lema: **Â«El juego donde nadie sale limpioÂ»**.

## RevisiÃ³n anterior 1.1.1 (histÃ³rica)

La interfaz expone Ãºnicamente intensidad (Tranqui, Picante, Sin vergÃ¼enza), tamaÃ±o y categorÃ­as. Intensidad deriva internamente distribuciÃ³n Tranqui/Equilibrado/Sin vergÃ¼enza, respectivamente; perfiles independientes siguen siendo legibles en snapshots anteriores. El valor predeterminado nuevo es Picante. La revisiÃ³n muestra el nivel una sola vez.

`dice.dart` proyecta un sÃ³lido de seis planos con cuaterniones, perspectiva de cÃ¡mara, descarte de planos ocultos, orden por profundidad, iluminaciÃ³n y puntos proyectados en cada cara. Caras opuestas suman siete. La orientaciÃ³n final coloca el resultado real en la cara dominante y deja tres caras visibles. La transiciÃ³n usa interpolaciÃ³n esfÃ©rica; no es un cuadrado transformado.

`BoardScreen` espera 2 s de giro y llama `AppController.roll(onResult:)`. El controlador calcula una sola tirada bajo bloqueo, mantiene la posiciÃ³n de origen durante la presentaciÃ³n del resultado y despuÃ©s avanza. El callback asienta el cubo en 450 ms y deja 750 ms totales antes del primer paso. Cada paso espera 360 ms y la ficha interpola 280 ms. Sin animaciones se omiten esas esperas. Las pruebas esperan el estado real de trabajo ademÃ¡s de `pumpAndSettle`, que puede terminar durante una pausa sin frames.

INICIO es la primera celda fÃ­sica de la espiral (posiciÃ³n 0, categorÃ­a 0), con el nÃºmero 1 a la derecha. No hay panel de salida externo. El nÃºmero total de posiciones y los snapshots conservan la misma interpretaciÃ³n del motor. Paleta petrÃ³leo/verde Ã¡cido con celdas oscuras y acentos legibles por categorÃ­a, independiente de la estÃ©tica de las referencias.

La matriz UI vigente 1.1.4+6 cubre 372 combinaciones (31 mÃ¡scaras Ã 4 tamaÃ±os Ã 3 intensidades) y genera el archivo v114. La matriz histÃ³rica de 756 y 2.268 selecciones corresponde a versiones anteriores.

La aplicaciÃ³n Flutter estÃ¡ en `mobile/`. El proyecto Android original en la raÃ­z se conserva sin modificaciones.

## MÃ³dulos

- `lib/game.dart`: motor Dart independiente de la interfaz. ConfiguraciÃ³n, tablero reproducible, turnos, movimiento, contenido, reglas y efectos.
- `lib/storage.dart`: contrato GameRepository e implementaciÃ³n Drift con SQLite. Snapshot JSON transaccional e historial global de IDs; metadatos para ajustes, estadÃ­sticas y contenidos personalizados.
- `lib/controller.dart`: Notifier Riverpod; coordina motor, catÃ¡logo, efectos del dispositivo y persistencia. El proveedor de repositorio se inyecta y permite pruebas con SQLite en memoria.
- `lib/app.dart` y `main.dart`: arranque y tema oscuro.
- `lib/screens.dart`: inicio, ajustes y exportaciones de pantallas.
- `lib/setup_screen.dart`: configuraciÃ³n por pasos, revisiÃ³n, borrador en memoria, ediciÃ³n de jugadores y controles fijos que respetan el teclado.
- `lib/ui/sapo_widgets.dart`: identidad, paleta, tema, fondos y botones compartidos; sin fuentes ni recursos remotos.
- `lib/ui/home_content.dart`: bienvenida con marca y lema; acciones de inicio siempre visibles.
- `lib/board/spiral_layout.dart`: coordenadas de espiral para 30/50/75/100; cada par consecutivo es ortogonalmente adyacente y path tiene N posiciones visibles.
- `lib/board/board_view.dart`: tablero en canvas, ampliable, cada nodo de path tiene una casilla/nÃºmero y semÃ¡ntica, Inicio 1 y Meta N.
- `lib/board/dice.dart`: dado vectorial con puntos, giro 3D y detenciÃ³n en el resultado real del motor.
- `lib/board/board_screen.dart`: composiciÃ³n vertical/horizontal, turnos, reglas, dado, tarjetas superpuestas y victoria.
- `lib/minigame.dart`: dinÃ¡micas con estado persistido dentro de la tarjeta pendiente.
- `assets/catalog.json`: fuente offline editable con ID, categorÃ­a, intensidad, temÃ¡tica, concepto y estado.
- `tool/catalog.dart`: generador reproducible del banco inicial con fuente base en `tool/catalog_base.json`; no requiere Python.
- `test/` e `integration_test/`: pruebas de motor, persistencia, widgets y dispositivo.

## Reglas del motor â descripciÃ³n de 1.1.3+5 (histÃ³rica; reemplazada por el addendum vigente)

Posiciones internas desde cero. Inicio y meta ocupan casillas. Alcanzar o superar la Ãºltima casilla gana; no hay rebote. HOT se aÃ±ade con ID 7 y Meta conserva ID 6, por lo que los snapshots anteriores mantienen su recorrido al cargarse.

Hay seis categorÃ­as activables. Cada categorÃ­a habilitada recibe al menos una casilla; las restantes se asignan por pesos del perfil usando mayores restos, con desempate por ID. La intensidad multiplica el peso HOT por 0,25/1/2 (mÃ­nimo peso 1) y limita el contenido a nivel 1/2/3. Con Equilibrado, 50 casillas y todas las categorÃ­as activas, HOT ocupa 3/8/13 casillas en Tranqui/Picante/Sin vergÃ¼enza. Si se desactiva no recibe casillas; si se deja solo HOT, todas las casillas jugables son HOT y la intensidad cambia sus tarjetas. La semilla y el tablero completo se guardan. La configuraciÃ³n antigua equilibrada sin HOT conserva 12/10/10/12/4.

Los eventos mueven o alteran estado, pero su casilla de destino no activa una segunda tarjeta: no hay cadenas ni bucles de eventos. Los intercambios usan el vecino, lÃ­der o Ãºltimo segÃºn la tarjeta. Empates de posiciÃ³n se resuelven por orden de inscripciÃ³n. Un escudo es de un uso y no se acumula.

La penalizaciÃ³n narrativa es tomar; las tarjetas no exponen una acciÃ³n para omitir. No se registra cuÃ¡nto consume una persona, ni se usan puntos o monedas.

## AntirrepeticiÃ³n

Se bloquean ID y concepto usados en la partida, incluso entre categorÃ­as. Primero se prefieren IDs no vistos en el historial global. Si no quedan nuevos entre partidas, se usan los elegibles de esa partida. Si se agota la categorÃ­a en la partida actual, se da descanso sin reciclar preguntas ni elevar intensidad. Minijuegos tambiÃ©n se agotan antes de repetirse. Los conceptos se curan en el catÃ¡logo; no hay un modelo semÃ¡ntico ni acceso a internet.

`lib/catalog.dart` valida IDs, textos normalizados y metadatos, informa grupos de similitud repetidos y agrupa contenido personalizado con coincidencia lÃ©xica conservadora. Esta ayuda no sustituye la revisiÃ³n editorial de equivalencias. Las pruebas incluyen conceptos compartidos entre categorÃ­as distintas.

## Persistencia y evoluciÃ³n

Se guarda tras cada acciÃ³n relevante; al reanudar se mantiene la tarjeta pendiente. La bomba conserva un instante de vencimiento, por lo que salir de pantalla no reinicia su tiempo. La ediciÃ³n del catÃ¡logo personalizado no modifica tarjetas ya extraÃ­das. El MVP mantiene una partida continuable, estadÃ­sticas agregadas e historial entre partidas.

El repositorio separa datos y UI para una futura fuente remota. No hay integraciÃ³n de Supabase ni servicios externos.

El controlador serializa las acciones para impedir doble lanzamiento incluso al salir y volver a la pantalla. La animaciÃ³n avanza la ficha casilla a casilla; las preferencias pueden desactivarla. Los sonidos usan SystemSound y la vibraciÃ³n HapticFeedback, sin archivos de audio remotos.

La espiral representa las N posiciones del motor: Inicio Ã­ndice 0/casilla visible 1, Meta Ã­ndice N-1/casilla visible N. El centro queda fuera del path y no oculta ni cuenta como Meta. Los tests comprueban los N nodos semÃ¡nticos, continuidad Manhattan=1, unicidad y cuatro tamaÃ±os.

El dado usa `AnimationController`, cuaterniones y `CustomPainter` para proyectar los seis planos; los puntos reflejan el dado guardado al detenerse. Las fichas esperan 360 ms por paso del controlador e interpolan durante 280 ms con `AnimatedPositioned`. No se generan recursos raster ni se copian marcas del juego de referencia. El icono Android es un vector original de rana sobre petrÃ³leo.

## ConfiguraciÃ³n y QA combinatoria

La matriz UI actual tiene 372 combinaciones en un proceso. exhaustive-ui permite separarla de la suite general para liberar memoria entre fases. Los CSV de perfiles independientes de 1.1.0 siguen siendo histÃ³ricos.

La configuraciÃ³n tiene Jugadores â Partida â RevisiÃ³n. El borrador vive en el controlador y se conserva al navegar atrÃ¡s o salir de la pantalla; no es una segunda partida guardada. Crear la partida ocurre Ãºnicamente en Comenzar partida. El panel inferior se separa explÃ­citamente de `viewInsets.bottom` para no quedar detrÃ¡s del IME.

`config_matrix_test.dart` comprueba 31 conjuntos Ã 4 tamaÃ±os Ã 4 perfiles internos Ã 3 intensidades Ã 2/6/12 jugadores (4.464 partidas). `ui_matrix_test.dart` recorre 372 configuraciones de UI (31 mÃ¡scaras Ã 4 tamaÃ±os Ã 3 intensidades), revisa, crea, comprueba distribuciÃ³n y SQLite y vuelve al inicio. La integraciÃ³n fÃ­sica cubre 12 casos representativos.

Para el equipo de 8 GB se limita Gradle a 2 GB y dos workers en `mobile/android/gradle.properties`; Kotlin compila dentro del proceso. No se modifica la configuraciÃ³n global.
# Addendum 1.1.5+7

La propiedad `Game.size` representa exclusivamente el total de casillas jugables. El `board` serializado contiene `size + 2` elementos: marcador Inicio 0, Ã­ndices jugables 1..size y marcador Meta `size + 1`. `positions` usa esos mismos Ã­ndices; los mapas antiguos de `size` elementos se migran al cargar.

`Game.move` devuelve y aplica la ruta paso a paso. El avance rebota desde Meta si sobran pasos; el retroceso termina en Inicio. La victoria solo se obtiene al quedar exactamente en Meta. `Game.draw` calcula una vez la ruta aleatoria del comodÃ­n y la conserva en la tarjeta pendiente; el controlador la anima, registra y persiste. Al aterrizar tras comodÃ­n, obtiene una sola tarjeta de destino con resoluciÃ³n de movimiento desactivada.

Las dinÃ¡micas Carta alta y 21 renderizan naipes del paquete `playing_cards`, con tamaÃ±o fijo para respetar el aspecto en listas desplazables. El estado de 21 persiste la suma, jugador, carta elegida y objetivo. Al cerrar una pantalla de minijuego, el controlador consume la tarjeta y pasa el turno antes de volver al tablero.
Minijuegos en 1.1.5+7: `MiniGameReviewScreen` abre diez minijuegos en una instancia temporal de `Game` (preview), sin persistir cambios. El panel tambien muestra las tarjetas de Reto del catalogo y abre una vista aislada para revision. La suma de 21 y la palabra/oracion son estado local de la tarjeta pendiente; el total de 21 no se renderiza. `Game.historyExcluded` conserva IDs de categoria 4 necesarios para evitar repeticiones en la partida, pero `LocalRepository.save` los excluye del historial global SQLite. Al finalizar, `Game.finish` limpia `pending`, incluida la dinamica.
## Tarjeta modal de minijuegos (2026-10-29)
board_screen abre MiniGameScreen en showDialog; al terminar, el estado resuelto muestra solo resultado y cierre. El cotejo de respuestas elimina diacríticos/signos y Cultura tolera una edición adyacente. La galería prueba los diez minijuegos y tres retos interactivos de azar/duelo.
Limon usa lemonStart serializado: el iniciador se fija en 1 y cada indice siguiente del orden circular conserva su numero durante la dinamica. Los botones de nombre entregan el turno sin paso intermedio.
