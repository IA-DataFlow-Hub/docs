# IA-DataFlow-Hub — Presentación Técnica

> Resumen ejecutivo de los entregables clave del proyecto.

---

## 1. Generador de Datasets Caóticos (`chaos-generator`) — HU-015

### ¿Qué es?

Un paquete que genera datasets sintéticos con errores reales, diseñados para entrenar modelos de IA en la tarea de **normalización y limpieza de datos**. El objetivo es que el modelo aprenda a detectar y corregir los tipos de caos más comunes en datos del mundo real.

### ¿Qué produce?

**159 archivos** distribuidos en **7 categorías** y **8 formatos**.

| Categoría | Problema que representa |
|---|---|
| `REDUNDANCIA` | Duplicados exactos y fuzzy |
| `ESTRUCTURA_ROTA` | Columnas incompletas, BOM, encoding corrupto |
| `MULTI_ENTIDAD` | Entidades desnormalizadas en una sola tabla |
| `TIPOS_INCONSISTENTES` | Fechas y monedas en formatos heterogéneos |
| `EXTRACCION` | PDFs y logs no estructurados |
| `ESQUEMA` | Requiere inferencia de tipos |
| `DATOS_LIMPIOS` | Datos correctamente normalizados (baseline) |

**Formatos generados:** CSV · Excel · JSON · JSONL · Log · XML · PDF · TOML

### ¿Cómo funciona?

```
LM Studio (local) ──► genera temas por categoría (ej: "Registro de Pacientes")
       │
       ▼
  Faker Helper ──────► genera filas de datos realistas por tema
       │
       ▼
  Chaos Injector ────► inyecta 12 tipos de errores deliberados
       │
       ▼
  8 Generadores ─────► escribe CSV, Excel, JSON, PDF, etc.
       │
       ▼
  datasets/Generados/dataset_caos/{CATEGORIA}/{FORMATO}/
```

**LM Studio como motor de temas:** el generador se conecta vía API compatible con OpenAI a `http://localhost:1234/v1`. Le pide al modelo que invente descripciones de datasets por categoría (ej: "Inventario de repuestos automotrices", "Historiales clínicos de urgencias"). Si LM Studio no está disponible, usa un banco de **140 temas predefinidos** (20 por categoría) como fallback automático.

**12 tipos de caos inyectados:** data drift, redundancia exacta, redundancia fuzzy, valores nulos, tipos inconsistentes (fechas/monedas), mezcla texto-número, multidioma, caracteres especiales, encoding errors, estructura rota, pestañas basura, multi-entidad.

### Uso

```bash
# Generar todo con LM Studio activo
npm run generate

# Generar sin IA (temas predefinidos, más rápido)
npm run generate:fast

# Solo categoría de datos limpios
npm run generate:clean

# Control fino: 3 CSVs de REDUNDANCIA con 50 filas
npm run generate -- --category REDUNDANCIA --type csv --count 3 --rows 50

# Simular sin escribir archivos
npm run generate:dry
```

### Por qué importa

Sin datos de entrenamiento con errores reales, un modelo de normalización solo aprende con datos perfectos. El `chaos-generator` provee el "lado sucio" necesario para que el modelo aprenda a distinguir, clasificar y corregir problemas de calidad de datos.

---

## 2. Diagramas de Arquitectura en Mermaid + `diagram-exporter` — HU-035

### ¿Qué es?

El sistema de documentación visual del proyecto. En lugar de imágenes estáticas editadas en Figma o draw.io, **todos los diagramas viven como código Mermaid** dentro de archivos `.md`. Esto los hace versionables, modificables con texto, y regenerables automáticamente.

### ¿Qué se documentó?

**10 diagramas principales** (algunos con sub-diagramas), cubriendo toda la arquitectura del sistema:

| # | Diagrama | Qué muestra |
|---|---|---|
| 01 | Arquitectura General | Stack completo: Nginx, Docker, React, NestJS, MySQL, n8n, LM Studio, Gemini |
| 02 | Flujo Procesamiento IA | Pipeline de ingesta y análisis de archivos con IA |
| 03 | Modelo de Base de Datos | Relaciones del schema Prisma |
| 04 | Flujo de Autenticación | Login + peticiones autenticadas con JWT |
| 05 | Roles y Permisos | RBAC del sistema |
| 06 | Flujo ETL | Extract, Transform, Load |
| 07 | Ciclo de Vida AI Job | Estados de un job de procesamiento |
| 08 | Estructura Monorepo | Árbol de directorios + pipeline Turborepo + dependencias entre workspaces |
| 09 | Privacidad Ley 1581 | Cumplimiento normativo colombiano + clasificación PII |
| 10 | Flujo Conversaciones Chat | Estructura de prompts + modelo de datos + ciclo de vida |

**Total de archivos generados:** 36 (18 PNG + 18 SVG), incluyendo sub-diagramas de diagramas compuestos.

### ¿Por qué Mermaid?

- El diagrama **vive junto al código** — cuando cambia la arquitectura, se edita el `.md` y se regenera
- Compatible con GitHub (renderiza automáticamente en el navegador)
- No requiere licencias ni herramientas externas
- Los cambios en diagramas aparecen en git como diferencias de texto, no como "imagen modificada"

### `diagram-exporter` — cómo se generan los PNG y SVG

El script `docs/diagramas/generate-exports.mjs` automatiza la conversión de bloques Mermaid a imágenes. Detecta cuántos bloques `mermaid` hay en cada `.md`, y genera un archivo de imagen por bloque, nombrándolos con el título del diagrama.

```bash
# Generar todos los diagramas (PNG + SVG)
npm run diagrams

# Solo uno o varios diagramas por número
npm run diagrams:only -- 10
npm run diagrams:only -- 04 08 09

# Ver qué se generaría sin crear archivos
npm run diagrams:list
```

**Flujo interno del exporter:**

```
Lee *.md en docs/diagramas/
       │
       ▼
Extrae bloques ```mermaid``` (puede haber N por archivo)
       │
       ▼
Por cada bloque ─► @mermaid-js/mermaid-cli (via npx)
       │
       ▼
Genera {nombre-diagrama}.svg + {nombre-diagrama}.png
```

Usa `@mermaid-js/mermaid-cli` descargado automáticamente vía `npx`, por lo que no requiere instalación global adicional.

---

## 3. `hu-cli` — CLI de Gestión de Historias de Usuario

### ¿Qué es?

Una herramienta de línea de comandos que conecta los archivos `.md` locales de Historias de Usuario con **GitHub Projects**, eliminando el trabajo manual de abrir la interfaz web para crear, actualizar o mover tarjetas.

### ¿Por qué existe?

El flujo sin `hu-cli` era: editar el `.md` → abrir GitHub → buscar el issue → editar el contenido → mover la tarjeta. Con `hu-cli`, todo eso se hace desde la terminal sin salir del contexto de trabajo.

### Comandos

```bash
hu list                          # Ver todas las HUs con su estado actual
hu list --status "In Progress"   # Filtrar por estado

hu create                        # Crear issues en GitHub desde los .md locales nuevos
hu create --draft                # Crear como drafts en el Project (sin abrir issue aún)

hu update <HU-N>                 # Actualizar el contenido del issue en GitHub
hu update 40                     # (solo aplica en estados Backlog y Ready)

hu advance <HU-N>                # Avanzar al siguiente estado en el flujo
hu advance 40 --to "In Review"   # O mover directamente a un estado específico

hu sync                          # Crear las nuevas + actualizar las editables (todo en uno)
```

### Flujo de estados

```
Backlog → Ready → In Progress → In Review → Done → Archivado
```

`hu update` solo está permitido en `Backlog` y `Ready` (antes de que alguien empiece a trabajar). `hu advance` funciona en cualquier estado.

### Arquitectura interna

```
packages/hu-cli/src/
├── index.js            ← Entry point, define los 5 comandos con Commander.js
├── commands/           ← Un archivo por comando (list, create, update, advance, sync)
├── lib/
│   ├── config.js       ← Constantes y configuración de estados
│   ├── files.js        ← Lee/escribe archivos .md locales
│   └── github.js       ← Llamadas a la GitHub CLI (gh)
└── utils/output.js     ← Output coloreado con Chalk
```

**Dependencias:** `commander` (parsing de args) + `chalk` (colores en terminal)  
**Requisito:** `gh` CLI autenticado con permisos de Projects

### Instalación y uso

```bash
npm install -w @ia-dataflow-hub/hu-cli
npm link -w @ia-dataflow-hub/hu-cli
# Desde aquí, `hu` está disponible globalmente en la terminal
```

---

## Resumen de Números

| Componente | Cifra clave |
|---|---|
| Datasets generados | 159 archivos en 7 categorías × 8 formatos |
| Temas predefinidos (fallback) | 140 (20 por categoría) |
| Tipos de errores inyectados | 12 |
| Diagramas de arquitectura | 10 diagramas principales |
| Imágenes exportadas | 36 (18 PNG + 18 SVG) |
| Comandos de hu-cli | 5 (list, create, update, advance, sync) |
