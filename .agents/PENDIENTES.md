# RediseÃ±o visual (2026-10-28)

Implementado y verificado (ver TEST_REPORT.md). Pendiente opcional, no hecho:
- El brindis del logo al tocar Â«Nueva partidaÂ» se propuso en el diseÃ±o pero no estÃ¡ implementado, para no retrasar la navegaciÃ³n.
- Halo en la casilla destino al aterrizar: el tablero solo conserva el resaltado de la casilla del turno.
- DiÃ¡logo +18 y pantallas de minijuegos: usan los componentes Material del tema, sin un diseÃ±o especÃ­fico.

# Estado vigente 1.1.4+6

La correcciÃ³n editorial, las pruebas, la integraciÃ³n en Samsung y el APK debug estÃ¡n terminados. No hay bloqueos para este alcance. Resultados verificables en TEST_REPORT.md.
# S.A.P.O. â decisiones y pendientes

Estado vigente: revisiÃ³n editorial 1.1.4+6 implementada y verificada.

## RevisiÃ³n editorial +18

HOT no es categorÃ­a vigente. Sus preguntas se clasificaron en Verdad o Shot y sus retos en Reto. Se mantienen los identificadores histÃ³ricos para soporte de partidas y conceptos; los snapshots cat. 7 se migran determinÃ­sticamente al cargar. El catÃ¡logo revisado se exporta a `CATALOGO_REVISION.md`. La matriz, las pruebas unitarias/widget, la integraciÃ³n fÃ­sica y el APK estÃ¡n aprobados.

Tranqui es contenido adulto de intensidad ligera; Picante aumenta la intimidad; Sin vergÃ¼enza incluye preguntas sexuales directas en Verdad o Shot y retos sensuales sin contacto impuesto. El juego confirma +18 al primer ingreso. Los retos con otra persona requieren aceptaciÃ³n y negarse no recibe penalizaciÃ³n. El catÃ¡logo conserva la cantidad, pero cada tarjeta relevante se reescribiÃ³ para el tono de fiesta.

La configuraciÃ³n utiliza Jugadores â Partida â RevisiÃ³n, con acciones fijas y protecciÃ³n del teclado. El alta usa campo Primer/Siguiente jugador, +, icono y lista visible. La nueva presentaciÃ³n mantiene las reglas del motor y proyecta el recorrido en espiral, con dado grÃ¡fico y tarjetas superpuestas. Consultar el resultado vigente de QA y APK en `TEST_REPORT.md`.

## Versiones bÃ¡sicas documentadas

- Un limÃ³n: comienza el siguiente jugador; cada participante dice su nÃºmero de limones segÃºn el orden de inscripciÃ³n y Â«medio limÃ³nÂ», pasando en orden circular. Sin saltos a jugadores arbitrarios.
- El pato: secuencia acumulativa, validaciÃ³n del grupo y registro manual del fallo.
- Cultura: categorÃ­a local, respuestas registradas, bloqueo de repeticiÃ³n exacta; validez semÃ¡ntica decidida por el grupo.
- OraciÃ³n: una palabra por turno; no se muestra la secuencia salvo que se acuse. Si la acusaciÃ³n es correcta, toma la persona acusada; si no, quien acusa.
- 21: cada jugador elige una carta de valor 1..13 y se suma. Al pasar 21, toma quien excediÃ³; con 21 exacto, el jugador elige quiÃ©n toma.
- Par o impar: activo par, rival impar; ambos eligen 0â5 dedos por turnos privados en el celular. Cero es par.
- Carta alta: valores A=1 a K=13, extracciÃ³n independiente con reemplazo; empate cuenta como acierto.
- Todito: cuatro resultados equiprobables; vecinos definidos por orden de inscripciÃ³n.
- Reglas temporales: duraciÃ³n medida en turnos resueltos, no en tiempo real.

## LÃ­mites explÃ­citos

- Los conceptos equivalentes se etiquetan editorialmente; no se garantiza detectar automÃ¡ticamente todas las parÃ¡frasis de texto personalizado.
- Una partida continuable por dispositivo. Crear otra sustituye el snapshot actual y conserva el historial global.
- DiseÃ±o funcional propio inspirado en la direcciÃ³n festiva de las referencias; puede refinarse posteriormente sin sustituir la espiral ni el movimiento casilla a casilla.
- No publicaciÃ³n, push, servicios externos ni Supabase.

## PrÃ³ximas mejoras fuera del cierre del MVP

- Refinamiento visual por la etapa de diseÃ±o posterior.
- CatÃ¡logo ampliable y revisiÃ³n editorial continua de los grupos semÃ¡nticos; el contenido personalizado usa ademÃ¡s comparaciÃ³n lÃ©xica, sin un modelo semÃ¡ntico automÃ¡tico.
- Biblioteca de varias partidas simultÃ¡neas y estadÃ­sticas detalladas por jugador, si se solicita en una etapa posterior.
- VersiÃ³n release y firma de distribuciÃ³n, si se solicitan. Este entregable es APK debug local; no se publica.

Las variantes bÃ¡sicas anteriores estÃ¡n implementadas y documentadas como decisiones del MVP; no requieren confirmaciÃ³n para jugar. Los resultados de QA y la verificaciÃ³n final Android se registran en `TEST_REPORT.md`.
# RevisiÃ³n vigente 1.1.5+7

- Sin bloqueos pendientes para la correcciÃ³n de victoria/minijuegos. La suite completa vigente (102 pruebas), la integraciÃ³n Samsung y el APK quedaron verificados; los resultados estÃ¡n en `TEST_REPORT.md`.
- La meta exige tirada exacta y el sobretiro rebota en el recorrido. El usuario pidiÃ³ esta regla; se considera la regla vigente.
- Tras un comodÃ­n de movimiento individual se muestra la tarjeta del destino; el efecto de esa segunda casilla no se encadena automÃ¡ticamente.
- 21 es una versiÃ³n bÃ¡sica local: el jugador elige un valor 1â13 por turno, suma, toma al exceder 21 y elige un jugador al llegar a 21 exacto.
## QA pendiente (2026-10-29)
Completar la matriz exhaustiva de UI: ejecución detenida en 31/372 tras más de 90 s sin progreso; suite estándar pasó 107/107. Hay consignas individuales y modos interactivos Carta alta/Todito/Par o impar; no existe un motor independiente de minijuegos de destreza en solitario.
