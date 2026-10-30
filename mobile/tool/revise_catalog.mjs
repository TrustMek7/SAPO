import fs from 'node:fs';

const path = 'tool/catalog_editorial.json';
const items = JSON.parse(fs.readFileSync(path, 'utf8'));
const byId = new Map(items.map((item) => [item.id, item]));

function replace(ids, texts, {category, intensity, theme} = {}) {
  if (ids.length !== texts.length) throw new Error(`IDs/textos desbalanceados: ${ids.length}/${texts.length}`);
  ids.forEach((id, index) => {
    const item = byId.get(id);
    if (!item) throw new Error(`Falta ${id}`);
    item.text = texts[index];
    if (category != null) item.category = category;
    if (intensity != null) item.intensity = intensity[index] ?? intensity;
    if (theme != null) item.theme = theme[index] ?? theme;
  });
}

// The former HOT deck becomes ordinary Truth or Shot / Challenge content.
for (const item of items.filter((entry) => entry.category === 7)) {
  const challenge = item.id.startsWith('c7_') && Number(item.id.slice(3)) >= 31;
  item.category = challenge ? 3 : 1;
  item.concept = `${challenge ? 'reto' : 'verdad'}_${item.concept}`;
  if (challenge) {
    item.intensity = Number(item.id.slice(3)) <= 40 ? 1 : Number(item.id.slice(3)) <= 50 ? 2 : 3;
    item.theme = 'coqueteo_y_deseo';
  } else {
    item.intensity = Number(item.id.slice(3)) <= 10 ? 1 : Number(item.id.slice(3)) <= 20 ? 2 : 3;
    item.theme = 'deseo_y_sexualidad';
  }
  delete item.type;
}

replace(Array.from({length: 15}, (_, i) => `c1_${76+i}`), [
  '¿Qué deseo escondiste por miedo a que alguien te juzgara?',
  '¿Qué secreto amoroso guardaste incluso después de terminar una relación?',
  '¿Qué mentira contaste para parecer más interesante en una cita?',
  '¿Qué versión de una ruptura cuentas para quedar mejor?',
  '¿Qué fantasía de venganza tuviste después de que te rechazaran?',
  '¿A quién buscaste en redes justo después de una ruptura, aunque dijiste que no lo harías?',
  '¿Qué regla ajena rompiste cuando nadie podía descubrirte?',
  '¿Qué conversación borraste para que tu pareja o un ligue no la viera?',
  '¿Qué persona te atraía mientras fingías que te caía mal?',
  '¿Qué cumplido inventaste para acercarte a alguien?',
  '¿Qué secreto de tu vida amorosa te costó contar a tus amistades?',
  '¿Qué opinión fingiste compartir para gustarle a una cita?',
  '¿Qué parte de una historia romántica tuya siempre omites?',
  '¿Qué costumbre de una expareja copiaste después de criticarla?',
  '¿Qué contacto mantuviste en secreto porque sabías que levantaría sospechas?',
], {intensity: Array.from({length:15},(_,i)=>i<5?2:3),theme:'secretos_y_deseo'});

replace(['c1_101', ...Array.from({length:15},(_,i)=>`c1_${106+i}`), ...Array.from({length:10},(_,i)=>`c1_${121+i}`), ...Array.from({length:15},(_,i)=>`c1_${131+i}`)], [
  '¿Quién del grupo te ha sorprendido más por lo atractivo que se ve hoy?',
  '¿Cuál ha sido tu peor intento de ligar en persona?',
  '¿Qué beso te dio más vergüenza recordar al día siguiente?',
  '¿Qué secreto sobre una cita salió a la luz en el peor momento?',
  '¿A quién le mandaste un mensaje coqueto y luego fingiste que era para otra persona?',
  '¿Qué excusa ridícula usaste para quedarte a solas con alguien?',
  '¿Qué momento íntimo te hizo reír cuando intentabas parecer sensual?',
  '¿Qué persona te gustó aunque sabías que era una pésima idea?',
  '¿Qué hiciste para llamar la atención de alguien y te salió al revés?',
  '¿Qué rechazo te dolió más de lo que admitiste?',
  '¿Qué atracción inesperada te costó reconocer?',
  '¿Qué rumor romántico sobre ti te habría dado vergüenza confirmar?',
  '¿Qué cita abandonaste mentalmente mucho antes de irte?',
  '¿Qué mensaje de madrugada todavía te avergüenza?',
  '¿Qué persona presente crees que sería la más difícil de conquistar?',
  '¿Qué situación romántica te encontró completamente desprevenido?',
  '¿En qué lugar inesperado te han dado ganas de besar a alguien?',
  '¿Qué viaje o salida terminó con más tensión romántica de la prevista?',
  '¿Qué noche recuerdas por una decisión impulsiva relacionada con un ligue?',
  '¿Qué experiencia de una sola noche te dejó pensando más de lo esperado?',
  '¿Qué momento de una cita te hizo pensar «esto puede terminar muy bien»?',
  '¿Qué aventura romántica te habría gustado repetir?',
  '¿Qué decisión amorosa tomaste únicamente por química?',
  '¿Qué plan inocente terminó convirtiéndose en una cita?',
  '¿Qué despedida de una fiesta te habría gustado que durara más?',
  '¿Qué fantasía sexual has tenido con una persona que conoces?',
  '¿Qué situación sexual te hizo sentir más deseado?',
  '¿Qué deseo sexual te costó mucho admitir por primera vez?',
  '¿Qué detalle explícito te excita más de un encuentro sexual?',
  '¿Qué experiencia sexual repetirías sin cambiar nada?',
  '¿Qué práctica sexual probaste y decidiste que no era para ti?',
  '¿Qué te gusta hacer para excitarte cuando estás a solas?',
  '¿Con qué frecuencia te masturbas en una semana normal?',
  '¿Alguna vez fingiste un orgasmo? ¿Por qué?',
  '¿Cuál ha sido el lugar más arriesgado donde tuviste sexo?',
  '¿Has tenido sexo anal? ¿Qué te pareció la experiencia?',
  '¿Qué fantasía sexual todavía no te has atrevido a contar?',
  '¿Has tenido sexo con alguien de este grupo?',
  '¿Cuál ha sido tu mejor experiencia sexual y qué la hizo memorable?',
  '¿Qué parte de tu cuerpo disfrutas más que te acaricien durante el sexo?',
  '¿Qué palabra o frase te gusta escuchar durante el sexo?',
], {intensity: Array.from({length:41},(_,i)=>i<15?2:i<25?1:3),theme: 'deseo_relaciones_y_confesiones'});

replace(Array.from({length:10},(_,i)=>`c1_${141+i}`), [
  '¿Alguna vez has tenido sexo anal? ¿Lo repetirías?',
  '¿Con qué frecuencia te masturbas y qué suele excitarte?',
  '¿Alguna vez fingiste un orgasmo para terminar un encuentro?',
  '¿Cuál ha sido tu experiencia sexual más satisfactoria?',
  '¿Has tenido sexo en un lugar público o donde podían descubrirte?',
  '¿Qué fantasía sexual nunca le has contado a nadie?',
  '¿Has tenido sexo con alguien de este grupo?',
  '¿Qué práctica sexual te da curiosidad probar y todavía no has probado?',
  '¿Qué es lo más atrevido que has hecho para llegar a tener sexo con alguien?',
  '¿Qué detalle de tu vida sexual te sorprendería que el grupo supiera?',
], {intensity:3,theme:'sexo_explicito'});

replace(Array.from({length:40},(_,i)=>`c2_${21+i}`), [
  'Quienes hayan besado a alguien de esta reunión toman.',
  'Quienes hayan tenido una cita que acabó en beso inesperado toman.',
  'Quienes hayan stalkeado a un ex esta semana toman.',
  'Quienes hayan enviado un mensaje coqueto y luego se arrepintieron toman.',
  'Quienes hayan besado a más de una persona en una misma noche toman.',
  'Quienes hayan vuelto con una expareja toman.',
  'Quienes hayan tenido una cita solo por la posibilidad de ligar toman.',
  'Quienes hayan ocultado a sus amistades que alguien les gustaba toman.',
  'Quienes hayan tenido un crush con alguien que no les convenía toman.',
  'Quienes hayan recibido una propuesta atrevida por mensaje toman.',
  'Quienes hayan fingido no sentir celos toman.',
  'Quienes hayan tenido una cita a ciegas toman.',
  'Quienes hayan besado a alguien y después se arrepintieron toman.',
  'Quienes hayan tenido una aventura de una sola noche toman.',
  'Quienes hayan coqueteado para conseguir una cita toman.',
  'Quienes hayan sentido atracción por la pareja de una amistad toman.',
  'Quienes hayan tenido una relación secreta toman.',
  'Quienes hayan mandado una foto sugerente toman.',
  'Quienes hayan recibido una foto sugerente toman.',
  'Quienes hayan fingido estar ocupados para evitar una cita toman.',
  'Quienes hayan besado a alguien en una fiesta toman.',
  'Quienes hayan tenido sexo en una primera cita toman.',
  'Quienes hayan despertado junto a alguien cuyo apellido no sabían toman.',
  'Quienes hayan inventado una excusa para irse de una cita toman.',
  'Quienes hayan tenido una relación con alguien del trabajo toman.',
  'Quienes hayan borrado una conversación para evitar preguntas toman.',
  'Quienes hayan hecho match con alguien presente toman.',
  'Quienes hayan tenido una cita con alguien que conocieron esa misma noche toman.',
  'Quienes hayan mentido sobre cuántas parejas han tenido toman.',
  'Quienes hayan sentido química con alguien apenas lo conocieron toman.',
  'Quienes hayan compartido una fantasía sexual con una pareja toman.',
  'Quienes hayan comprado lencería o ropa íntima para una cita toman.',
  'Quienes hayan fingido un orgasmo toman.',
  'Quienes hayan probado un juguete sexual toman.',
  'Quienes hayan tenido sexo en un lugar poco privado toman.',
  'Quienes hayan enviado un mensaje sexual explícito toman.',
  'Quienes hayan tenido una aventura con alguien comprometido toman.',
  'Quienes hayan tenido sexo con una amistad toman.',
  'Quienes hayan hablado de una fantasía sexual en grupo toman.',
  'Quienes hayan tenido sexo con alguien de esta reunión toman.',
], {intensity: Array.from({length:40},(_,i)=>i<14?1:i<30?2:3),theme:'historias_de_fiesta'});

replace(Array.from({length:20},(_,i)=>`c2_${1+i}`), [
  'Quienes hayan tenido un crush secreto por más de un mes toman.',
  'Elige a quien tendría la cita más desastrosa contigo: esa persona toma.',
  'Quienes hayan besado a alguien para darle celos a otra persona toman.',
  'Quienes hayan tenido una cita que terminó mucho mejor de lo esperado toman.',
  'Quienes hayan revisado el perfil de una expareja después de una noche de fiesta toman.',
  'Quienes hayan mandado un mensaje sugerente y luego apagado el celular toman.',
  'El grupo vota quién tiene más labia; quien reciba más votos toma.',
  'Quienes hayan aceptado una cita sabiendo que no buscaban una relación toman.',
  'Elige a la persona presente con quien tendrías la cita más divertida: toma contigo.',
  'Quienes hayan tenido un amor platónico imposible toman.',
  'Quienes hayan usado una canción para lanzar una indirecta toman.',
  'Elige a quien crees que guarda el secreto más jugoso de una cita: esa persona toma.',
  'Quienes hayan besado a alguien sin saber su apellido toman.',
  'Quienes hayan tenido química inmediata con alguien que acaban de conocer toman.',
  'Quienes hayan fingido indiferencia para no parecer demasiado interesados toman.',
  'Quienes hayan vuelto a escribirle a alguien después de jurar que no lo harían toman.',
  'El jugador activo elige a alguien para un duelo de miradas; quien se ría primero toma.',
  'Quienes hayan tenido una cita que ocultaron a sus amistades toman.',
  'Quienes hayan pensado «con esta persona sí tendría algo» al conocerla toman.',
  'Todos señalan a quien creen que recibe más mensajes de ligue; quien tenga más votos toma.',
], {intensity: [1,2,1,1,2,2,1,2,1,1,1,2,2,1,1,2,2,2,1,1],theme:'coqueteo_y_reuniones'});

replace(['c3_1','c3_2','c3_7','c3_9','c3_11','c3_12','c3_17','c3_25','c3_28','c3_29','c3_31','c3_32','c3_33','c3_34','c3_35','c3_36','c3_37','c3_38','c3_39','c3_40','c3_41','c3_42','c3_43','c3_44','c3_45','c3_46','c3_47','c3_49','c3_50','c3_51','c3_52','c3_53','c3_54','c3_55','c3_56','c3_57','c3_58','c3_59','c3_60','c3_61','c3_62','c3_63','c3_64','c3_65','c3_66','c3_67','c3_68','c3_69','c3_70','c3_71','c3_72','c3_73','c3_74','c3_75','c3_76','c3_77'], [
  'Imita cómo ligas cuando te interesa alguien; el grupo adivina si es tu estilo real.',
  'Cuenta tu peor metedura de pata en una cita como si fuera una escena de telenovela.',
  'Haz una invitación a una cita tan convincente que el grupo quiera aceptar.',
  'Improvisa un anuncio sensual de tu mejor cualidad, sin quitarte ropa.',
  'Haz una mirada de seducción y mantén la compostura diez segundos.',
  'Dedica un brindis coqueto a alguien del grupo; esa persona puede aceptarlo o no.',
  'Improvisa un piropo ingenioso que no mencione el cuerpo de nadie.',
  'Vende tu peor hábito como si fuera irresistible en una primera cita.',
  'Describe tu beso ideal sin señalar a nadie presente.',
  'Haz una declaración apasionada a tu crush ficticio como protagonista de novela.',
  'Imita tu reacción cuando te escribe alguien que te encanta.',
  'Recrea cómo finges tranquilidad cuando alguien atractivo se sienta a tu lado.',
  'Cuenta una anécdota de ligue usando voz de documental dramático.',
  'Haz un horóscopo amoroso para la persona de tu derecha.',
  'Improvisa una escena de cita en la que intentas disimular que estás nervioso.',
  'Traduce tres frases típicas de una cita a lo que realmente significan.',
  'Inventa una disculpa encantadora para llegar tarde a una cita.',
  'Con alguien que acepte, improvisen un encuentro coqueto en una fiesta.',
  'Presenta a la persona de tu derecha como el soltero más codiciado de una gala.',
  'Recita una receta de cóctel como si fuera una declaración de deseo.',
  'Con un rival, alternen formas de iniciar una conversación de ligue; pierde quien repita.',
  'Haz una confesión romántica ficticia con total seriedad durante veinte segundos.',
  'Improvisa una respuesta elegante a un rechazo sin perder el humor.',
  'Interpreta una primera cita en la que ambos intentan parecer menos nerviosos.',
  'Describe qué te hace sentir atractivo con una pose y una frase.',
  'Mantén una mirada cómplice diez segundos con alguien que acepte; cualquiera puede parar.',
  'Haz una pose de portada de novela romántica y deja que el grupo invente el título.',
  'Di cinco cumplidos ingeniosos que no se repitan ni sean sobre el cuerpo.',
  'Interpreta cómo pedirías un beso con claridad y aceptarías un no sin insistir.',
  'Improvisa un audio coqueto de diez segundos para una pareja imaginaria.',
  'Inventa el nombre de una app de citas para gente con tus mismas red flags.',
  'Dedica un premio imaginario a quien tenga el mejor estilo para una cita.',
  'Cuenta una historia de ligue propia en treinta segundos, sin nombres.',
  'Describe cómo invitarías a alguien a pasar la noche sin crear presión.',
  'Di una cualidad tuya que te hace buena compañía en una cita.',
  'Haz una mini clase sobre cómo reconocer una indirecta que te lanzaron.',
  'Defiende durante veinte segundos que eres una excelente primera cita.',
  'Haz una llamada ficticia para invitar a alguien a una cita atrevida.',
  'Representa una conversación posterior a un beso inesperado.',
  'Improvisa una reseña de tu estilo de coqueteo como si fueras crítico.',
  'Propón una regla divertida para una primera cita y actúa cómo la explicarías.',
  'Con otra persona que quiera participar, inventen un saludo secreto coqueto.',
  'Representa tres maneras de reaccionar cuando alguien te dice que le gustas.',
  'Haz un sonido y una pose que describan tu personalidad al ligar.',
  'Cuenta qué harías en una cita perfecta, en modo tráiler de película.',
  'Presenta una fantasía romántica ficticia como si fuera una obra de teatro.',
  'Improvisa un diálogo entre tu yo atrevido y tu yo tímido antes de un beso.',
  'Con un rival, alternen preguntas ingeniosas para conocer a una cita; pierde quien repita.',
  'Con un rival, alternen planes originales para una cita; el grupo decide quién convence más.',
  'Cuenta una historia de coqueteo sin usar la palabra «gustar».',
  'Interpreta cómo anunciarías que una cita tuvo química, sin decir nombres.',
  'Describe una cita inolvidable usando solo tres frases.',
  'Haz una declaración sensual a una pareja imaginaria, sin contacto físico.',
  'Improvisa una invitación a bailar y acepta cualquier respuesta con buena actitud.',
  'Con alguien que acepte, actúen una escena de tensión romántica sin tocarse.',
  'Cuenta cuál sería el título de tu autobiografía amorosa y véndelo al grupo.',
], {intensity: Array.from({length:56},(_,i)=>i<20?1:i<40?2:3),theme:'coqueteo_y_actuacion'});

replace(['c3_3','c3_4','c3_5','c3_6','c3_8','c3_10','c3_13','c3_14','c3_15','c3_16','c3_18','c3_19','c3_20','c3_21','c3_22','c3_23','c3_24','c3_26','c3_27','c3_30','c3_48'], [
  'Haz un brindis de conquista para alguien imaginario con quien tendrías una cita.',
  'Cuenta una cita desastrosa como si fuera una confesión ante el grupo.',
  'Actúa cómo responderías al encontrar a tu ex en una fiesta con su nueva pareja.',
  'Defiende durante veinte segundos por qué serías el mejor beso de esta reunión.',
  'Interpreta una discusión entre tu deseo y tu sentido común sobre un crush.',
  'Describe a tu tipo ideal sin usar apariencia física; el grupo intenta adivinarlo.',
  'Con un rival, alternen frases para romper el hielo en una cita; quien repita pierde.',
  'Con alguien que acepte, improvisen una llamada para acordar una segunda cita.',
  'Cuenta una confesión romántica como si estuvieras en un reality de citas.',
  'Actúa como si acabaras de reconocer que tu cita está coqueteando con otra persona.',
  'Haz una rueda de prensa sobre el beso más inesperado de tu vida, sin nombres.',
  'Inventa un apodo coqueto para alguien ficticio y véndelo como irresistible.',
  'Representa tres formas de reaccionar al recibir una propuesta atrevida.',
  'Improvisa un rap de cuatro versos sobre tu peor decisión amorosa.',
  'Con un rival, alternen red flags que ignoraron por atracción; pierde quien se quede sin ejemplo.',
  'Convence al grupo de que tu última cita merece una segunda temporada.',
  'Narra un encuentro romántico como comentarista de una final deportiva.',
  'Di tres frases que jamás usarías para ligar y actúalas con total seguridad.',
  'Representa cómo pedirías un beso sin presionar y cómo recibirías un no.',
  'Con otro jugador que acepte, improvisen una escena de reencuentro con tensión romántica.',
  'Duelo de piedra, papel o tijera: quien pierda hace una declaración coqueta al aire.',
], {intensity: Array.from({length:21},(_,i)=>i<8?1:i<15?2:3),theme:'coqueteo_y_duelos'});

replace(['c7_41','c7_42','c7_43','c7_50','c7_51','c7_53','c7_55','c7_60'], [
  'Invita a alguien del grupo a sostener una mirada cómplice durante diez segundos.',
  'Con alguien del grupo, inventen una señal discreta para decir «me gustas».',
  'Invita a alguien del grupo a un beso breve en la mejilla; acepta con naturalidad cualquier respuesta.',
  'Improvisa con alguien una conversación después de un beso inesperado.',
  '¿Qué fantasía sexual te excita más, aunque no tengas intención de cumplirla?',
  '¿Qué curiosidad sexual te gustaría conversar con tu pareja?',
  'Inventa un personaje para un juego de roles sexual y su frase de entrada.',
  '¿Qué fantasía sexual te cuesta más admitir en voz alta?',
], {intensity:[2,2,2,2,3,3,3,3],theme:'deseo_y_coqueteo'});

replace(['c2_41','c3_7','c3_9','c3_11','c3_46','c3_50','c7_34'], [
  'Quienes hayan terminado una relación porque querían acuerdos distintos sobre la exclusividad toman.',
  'Imita tres estilos distintos de coqueteo y deja que el grupo elija el más convincente.',
  'Haz una entrada triunfal a una fiesta con la actitud de quien sabe que alguien vino por ti.',
  'Representa con un gesto tu reacción al notar que alguien atractivo te está mirando.',
  'Improvisa una confesión ficticia como si revelaras una verdad incómoda en un reality.',
  'Actúa cómo reaccionarías si alguien te propusiera un beso de forma inesperada.',
  '¿Qué hace que un beso te deje con ganas de repetirlo?',
], {intensity:[2,1,1,1,2,2,1],theme:['relaciones','coqueteo','coqueteo','atraccion','confesiones','deseo','besos_y_atraccion']});

// Correct intensity of explicit questions from migrated deck and preserve the five public categories.
for (const item of items) {
  if (item.category === 7) throw new Error(`Categoría HOT sin migrar: ${item.id}`);
  if (![1,2,3,4,5].includes(item.category)) throw new Error(`Categoría inválida: ${item.id}`);
  if (![1,2,3].includes(item.intensity)) throw new Error(`Intensidad inválida: ${item.id}`);
}
const ids = items.map((item) => item.id);
if (new Set(ids).size !== ids.length) throw new Error('IDs duplicados');
const normalized = (text) => text.toLocaleLowerCase('es').normalize('NFD').replace(/[\u0300-\u036f]/g,'').replace(/[^a-z0-9ñ ]/g,' ').replace(/\s+/g,' ').trim();
const texts = items.map((item) => normalized(item.text));
if (new Set(texts).size !== texts.length) throw new Error('Textos duplicados');
fs.writeFileSync(path, `${JSON.stringify(items, null, 2)}\n`, 'utf8');
console.log(JSON.stringify(Object.fromEntries([1,2,3,4,5].map((category) => [category, items.filter((item) => item.category === category).length]))));
