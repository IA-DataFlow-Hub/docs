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

### Sincronización automática de `docs/` (GitHub Action)

Se agregó una GitHub Action que sincroniza la carpeta `docs/` del repositorio principal hacia el repositorio `IA-DataFlow-Hub/docs`. Características principales:

- Trigger: `push` en la rama `main` cuando hay cambios en `docs/**`.
- Remoto destino: `IA-DataFlow-Hub/docs` (la acción usa `actions/checkout@v4` con `repository` apuntando al repo destino).
- Autenticación: usa el secreto `SYNC_PAT` para hacer push al repo destino.
- Flujo: checkout del repo origen y destino, copia de `docs/` a `destination/Docs/`, commit y push si hay cambios.

Archivo de workflow: `.github/workflows/sync-docs-to-docrepo.yml`.

Uso típico: simplemente haga `git push` a `main` con cambios en `docs/`; la Action se encargará de sincronizar automáticamente.


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

## 4. Control de versiones de datos con DVC — Gestión de datasets

### ¿Qué se implementó?

Se utilizó **DVC (Data Version Control)** para versionar la carpeta de datasets del repositorio. El archivo de control principal es `datasets.dvc` en la raíz del proyecto, que actualmente referencia la carpeta `datasets/` (nfiles: 491, tamaño total registrado: 727548695 bytes, hash: md5). Esto permite mantener metadatos ligeros en Git mientras los archivos de datos grandes quedan gestionados por DVC.

### Objetivos

- Versionar datasets generados (`datasets/Generados/...`) sin almacenar los binarios en Git.
- Facilitar la replicabilidad: cualquier desarrollador puede descargar los datos necesarios con un solo comando.
- Integrar el flujo de generación de datos con control de versiones para auditar cambios en los conjuntos de datos.

### Cómo usarlo (comandos básicos)

Instalar DVC y luego, desde la raíz del repositorio:

```bash
# Descargar los datos referenciados por DVC (trae archivos grandes desde el remoto configurado)
dvc pull

# Comprobar estado local vs remoto
dvc status

# Añadir nuevos archivos o cambios en datos al control de DVC
dvc add path/to/data

# Enviar cambios al remoto (después de `dvc push` configurado con remote)
dvc push

# Registrar cambios en Git (commitará los .dvc y cambios en .gitignore)
git add datasets.dvc .dvc/config path/to/data.dvc
git commit -m "chore(dvc): actualizar datasets versionados"
```

### Cómo autenticarse (login) — Google Drive

Este repositorio usa un remoto DVC configurado con Google Drive (`gdrive`). Hay dos formas comunes de autenticarse:

- Flujo interactivo (recomendado para desarrolladores): simplemente ejecute `dvc pull` desde la raíz del repo; si DVC necesita autorización con Google Drive le mostrará una URL para abrir en el navegador y un código para pegar en la terminal. Ejemplo:

```bash
# Ejecutar y seguir el flujo interactivo de autorización en el navegador
dvc pull
```

- Configurar credenciales explícitas (útil en servidores o CI): registre un `client_id` y `client_secret` para Google Drive y configúrelos en el remote DVC, luego ejecute `dvc pull`:

```bash
# Configurar client id/secret (ejecutar una sola vez, opcionalmente con --local)
dvc remote modify gdrive gdrive_client_id <YOUR_CLIENT_ID>
dvc remote modify gdrive gdrive_client_secret <YOUR_CLIENT_SECRET>

# Después, descargar los datos
dvc pull
```

Alternativamente, puede usar una cuenta de servicio y apuntar a las credenciales con una variable de entorno o archivo según la guía de DVC para GDrive.

### Notas operativas

- El control de versiones de datos está diseñado para complementar los scripts de generación (`npm run generate`) — los archivos generados en `datasets/Generados/` quedan fuera del repositorio Git y se gestionan vía DVC.
- Si su entorno no tiene acceso al remoto de DVC, puede seguir trabajando con datasets locales; sin embargo, para replicar un entorno completo, ejecute `dvc pull` antes de ejecutar pipelines que dependan de los datos.

## Resumen de Números

| Componente | Cifra clave |
|---|---|
| Datasets generados | 159 archivos en 7 categorías × 8 formatos |
| Temas predefinidos (fallback) | 140 (20 por categoría) |
| Tipos de errores inyectados | 12 |
| Diagramas de arquitectura | 10 diagramas principales |
| Imágenes exportadas | 36 (18 PNG + 18 SVG) |
| Comandos de hu-cli | 5 (list, create, update, advance, sync) |


---

## Documentos relacionados

**Visión:** [[README_SUMMARY]] · [[ARQUITECTURA]] · [[Resumen del Proyecto Ecosistema IA-DataFlow]]
**Datos & IA:** [[CHAOS_GENERATOR]] · [[chaos-generator]] · [[DATASETS]] · [[csv-retail]]
**Investigación:** [[📚 Biblioteca de Investigación]]
**HUs:** [[✅ HU 015 - Clasificación de Dataset de Caos para Entrenamiento de IA|HU-015]] · [[HU 038 - Fine-Tuning y Preparación de Datasets de IA|HU-038]] · [[HU 039 - Entrenamiento y Fine-Tuning de Modelos de IA|HU-039]]
