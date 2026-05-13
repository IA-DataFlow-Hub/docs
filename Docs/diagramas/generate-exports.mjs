/**
 * Genera PNG y SVG para todos los diagramas Mermaid en docs/diagramas.
 *
 * Uso:
 *   node generate-exports.mjs              # regenera todos los diagramas
 *   node generate-exports.mjs 10 11        # solo diagramas 10 y 11
 *   node generate-exports.mjs --list       # muestra qué se generaría sin ejecutar
 */

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const args = process.argv.slice(2);
const DRY_RUN = args.includes('--list');
const FILTER = args.filter(a => !a.startsWith('--'));

// ── Extrae bloques Mermaid junto con el título de la sección que los precede ──
function extractBlocks(mdContent) {
  const lines = mdContent.split('\n');
  const blocks = [];
  let currentHeading = null;
  let inBlock = false;
  let buffer = [];

  for (const line of lines) {
    if (/^#{1,3}\s/.test(line) && !inBlock) {
      currentHeading = line.replace(/^#+\s*/, '').trim();
    }
    if (line.trim() === '```mermaid') {
      inBlock = true;
      buffer = [];
      continue;
    }
    if (inBlock && line.trim() === '```') {
      blocks.push({ heading: currentHeading, code: buffer.join('\n').trim() });
      inBlock = false;
      buffer = [];
      continue;
    }
    if (inBlock) buffer.push(line);
  }
  return blocks;
}

// ── Convierte un título de sección en un sufijo limpio para el nombre de archivo ──
function headingToSuffix(heading) {
  return heading
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')   // quita tildes
    .replace(/[^\w\s\-–—]/g, '')       // quita caracteres especiales
    .replace(/\s+/g, '-')
    .replace(/-{2,}/g, '-')
    .toLowerCase()
    .slice(0, 60);
}

// ── Genera un PNG y un SVG para un bloque Mermaid dado ──
function generate(code, outputBase) {
  const tmpFile = outputBase + '.tmp.mmd';
  fs.writeFileSync(tmpFile, code, 'utf8');
  try {
    for (const ext of ['png', 'svg']) {
      const out = `${outputBase}.${ext}`;
      execSync(
        `npx --yes @mermaid-js/mermaid-cli -i "${tmpFile}" -o "${out}" --backgroundColor white`,
        { stdio: 'pipe', timeout: 120_000 }
      );
      console.log(`    ✓ ${path.basename(out)}`);
    }
  } catch (err) {
    console.error(`    ✗ Error: ${err.message}`);
  } finally {
    if (fs.existsSync(tmpFile)) fs.unlinkSync(tmpFile);
  }
}

// ── Descubre todas las carpetas de diagramas ──
function discoverDiagrams() {
  return fs
    .readdirSync(__dirname, { withFileTypes: true })
    .filter(e => e.isDirectory())
    .map(e => e.name)
    .filter(name => /^\d{2}-/.test(name))
    .sort();
}

// ── Determina el nombre base de salida para cada bloque ──
function resolveOutputNames(folderName, blocks) {
  return blocks.map((block, i) => {
    if (i === 0) return folderName; // primer bloque → nombre del diagrama principal

    // Para bloques adicionales: usa el heading como sufijo si existe
    const suffix = block.heading ? headingToSuffix(block.heading) : `sub-${i + 1}`;
    return `${folderName} - ${suffix}`;
  });
}

// ── Main ──
const folders = discoverDiagrams().filter(f => {
  if (FILTER.length === 0) return true;
  return FILTER.some(n => f.startsWith(n.padStart(2, '0') + '-') || f.startsWith(n + '-'));
});

if (folders.length === 0) {
  console.error('No se encontraron diagramas que coincidan con el filtro:', FILTER);
  process.exit(1);
}

let total = 0;

for (const folder of folders) {
  const dir = path.join(__dirname, folder);
  const mdFile = fs.readdirSync(dir).find(f => f.endsWith('.md'));
  if (!mdFile) {
    console.warn(`⚠ ${folder}: sin archivo .md, omitido`);
    continue;
  }

  const mdContent = fs.readFileSync(path.join(dir, mdFile), 'utf8');
  const blocks = extractBlocks(mdContent);

  if (blocks.length === 0) {
    console.warn(`⚠ ${folder}: sin bloques Mermaid en ${mdFile}`);
    continue;
  }

  const outputNames = resolveOutputNames(folder, blocks);
  console.log(`\n📐 ${folder}  (${blocks.length} bloque${blocks.length > 1 ? 's' : ''})`);

  for (let i = 0; i < blocks.length; i++) {
    const outputBase = path.join(dir, outputNames[i]);
    console.log(`  → ${outputNames[i]}`);
    if (!DRY_RUN) {
      generate(blocks[i].code, outputBase);
      total += 2;
    }
  }
}

if (DRY_RUN) {
  console.log('\n(modo --list: no se generó ningún archivo)');
} else {
  console.log(`\n✓ Listo — ${total} archivos generados (${total / 2} PNG + ${total / 2} SVG)`);
}
