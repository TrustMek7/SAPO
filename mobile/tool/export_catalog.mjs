import fs from 'node:fs';

const catalog = JSON.parse(fs.readFileSync('tool/catalog_editorial.json', 'utf8'));
const labels = {1:'Verdad o Shot',2:'Bebe',3:'Reto',4:'Minijuego',5:'Evento'};
const intensity = {1:'Tranqui',2:'Picante',3:'Sin vergüenza'};
const lines = [
  '# SAPO — catálogo para revisión editorial',
  '',
  'SAPO es un juego de fiesta exclusivamente +18. Tranqui sigue siendo adulto; la intensidad mide incomodidad y explicitud. La participación y tomar son voluntarios. Un reto con otra persona requiere aceptación y su negativa no se penaliza.',
  '',
  `Fuente: mobile/tool/catalog_editorial.json · ${catalog.length} tarjetas · las preguntas antiguas HOT están migradas a Verdad o Shot y los retos HOT a Reto.`,
  '',
  '## Resumen',
  '',
  '| Categoría | Cantidad |',
  '|---|---:|',
  ...Object.entries(labels).map(([id,label]) => `| ${label} | ${catalog.filter(item => item.category === Number(id)).length} |`),
  '',
];
for (const [id, label] of Object.entries(labels)) {
  lines.push(`## ${label}`, '');
  const items = catalog.filter(item => item.category === Number(id));
  for (let level = 1; level <= 3; level++) {
    const section = items.filter(item => item.intensity === level);
    if (!section.length) continue;
    lines.push(`### ${intensity[level]}`, '');
    for (const item of section) {
      const extras = [item.theme, `concepto: ${item.concept}`, item.effect && `efecto: ${item.effect}`, item.amount != null && `cantidad: ${item.amount}`, item.kind && `minijuego: ${item.kind}`].filter(Boolean).join(' · ');
      lines.push(`- **${item.id}** (${extras}): ${item.text}`);
    }
    lines.push('');
  }
}
fs.writeFileSync('../.agents/CATALOGO_REVISION.md', `${lines.join('\n')}\n`, 'utf8');
