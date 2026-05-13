# Diagramas — IA DataFlow Hub

Cada diagrama vive en su propia carpeta con tres archivos: el `.md` con el código Mermaid y las notas, y los exports `.png` y `.svg` listos para usar en documentación o presentaciones.

```
docs/diagramas/
├── 01-arquitectura-general/
├── 02-flujo-procesamiento-ia/
├── 03-modelo-base-de-datos/
├── 04-flujo-autenticacion/
├── 09-estructura-monorepo/
├── 10-privacidad-ley-1581/
├── 11-flujo-conversaciones-chat/
├── generate-exports.mjs   ← script de generación
└── README.md
```

---

## Generar los PNG y SVG

### Todos los diagramas

```bash
# Desde la raíz del proyecto
npm run diagrams

# O directamente desde esta carpeta
node docs/diagramas/generate-exports.mjs
```

### Solo uno o varios diagramas (por número)

```bash
node docs/diagramas/generate-exports.mjs 10
node docs/diagramas/generate-exports.mjs 10 11
node docs/diagramas/generate-exports.mjs 04 09
```

### Ver qué se generaría sin crear archivos

```bash
npm run diagrams:list

# O con filtro
node docs/diagramas/generate-exports.mjs 11 --list
```

---

## Cómo funciona el script

`generate-exports.mjs` recorre automáticamente todas las carpetas con prefijo numérico (`01-`, `02-`, …), extrae cada bloque ` ```mermaid ` del archivo `.md` y genera un par PNG + SVG por bloque.

| Bloque | Nombre de archivo generado |
|--------|---------------------------|
| Primero (diagrama principal) | `{carpeta}.png` / `.svg` |
| Segundo en adelante | `{carpeta} - {título de sección}.png` / `.svg` |

El título de la sección se toma del encabezado `##` inmediatamente anterior al bloque en el `.md`.

---

## Añadir un diagrama nuevo

1. Crear la carpeta: `docs/diagramas/NN-nombre-del-diagrama/`
2. Crear el `.md` con uno o más bloques ` ```mermaid `.
3. Ejecutar `npm run diagrams` — el script lo detecta y genera los exports automáticamente.

---

## Diagramas actuales

| # | Diagrama | Sub-diagramas |
|---|----------|---------------|
| 01 | Arquitectura general del sistema | — |
| 02 | Flujo de procesamiento de archivo con IA | — |
| 03 | Modelo de base de datos | — |
| 04 | Flujo de autenticación | 4a Login, 4b Petición con JWT |
| 09 | Estructura del monorepo | 9a Árbol, 9b Turborepo, 9c Dependencias |
| 10 | Privacidad y cumplimiento Ley 1581 | 10a Local vs nube, 10b PII, 10c Reglas |
| 11 | Flujo de conversaciones y chat con IA | 11a Secuencia, 11b Prompt, 11c Modelo datos, 11d Ciclo de vida |

---

## Requisitos

- **Node.js 18+** (el proyecto ya lo incluye)
- `@mermaid-js/mermaid-cli` se descarga automáticamente vía `npx` la primera vez; las siguientes ejecuciones usan la caché de npx.
