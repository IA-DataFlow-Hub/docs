# Guía: Generación de Datasets de Caos para Entrenamiento de IA

> **HU-015** · Responsable: Juan Diego Mejía · Estado: ✅ Completado

Esta guía explica cómo usar el script `chaos-generator` para producir los archivos de prueba que alimentan el fine-tuning del modelo de normalización de datos de DataFlow Hub.

---

## ¿Para qué sirven estos datasets?

El modelo de IA necesita aprender a **limpiar y normalizar datos del mundo real**, que llegan en formatos caóticos: columnas mezcladas, fechas en 7 formatos distintos, duplicados con errores tipográficos, archivos con encoding roto, etc.

Los datasets generados son pares **Input Caótico → Output Esperado**, donde el Input es lo que produce este script y el Output es lo que el modelo debe aprender a producir. La categoría `DATOS_LIMPIOS` provee los ejemplos de salida esperada.

---

## Requisitos previos

| Requisito | Versión mínima |
|---|---|
| Node.js | 18+ |
| npm | 10+ |
| LM Studio *(opcional)* | cualquier versión con servidor local habilitado |

Si vas a usar LM Studio para temas dinámicos:
1. Abre LM Studio → pestaña **Local Server**.
2. Carga el modelo configurado (`qwen/qwen3.5-9b` u otro disponible).
3. Presiona **Start Server** — por defecto queda en `http://localhost:1234`.

> Si LM Studio no está corriendo, el generador usa **48 temas predefinidos** automáticamente. No es un error, es el comportamiento esperado.

---

## Ejecución rápida

Desde la **raíz del proyecto**:

```bash
# Con LM Studio activo (temas dinámicos generados por IA)
npm run generate:chaos

# Sin LM Studio (temas predefinidos, más rápido)
npm run generate:chaos:fast

# Simulación (no escribe archivos, solo verifica la config)
npm run generate:chaos:dry

# Solo la categoría DATOS_LIMPIOS
npm run generate:chaos:clean

# Ver todos los parámetros disponibles
npm run generate:chaos:help
```

---

## Parámetros CLI

El generador acepta parámetros para controlar exactamente qué se genera sin tocar el `chaos.config.json`.
Se pasan después de `--` en los scripts de npm.

### Filtrado y escala

| Parámetro | Descripción | Ejemplo |
|---|---|---|
| `--count <n>` | Archivos por tipo por categoría | `--count 3` |
| `--category <lista>` | Solo las categorías indicadas, coma-separadas | `--category REDUNDANCIA,ESQUEMA` |
| `--type <lista>` | Solo los tipos de archivo, coma-separados | `--type csv,excel` |
| `--rows <n>` | Filas fijas por archivo (ignora min/max del config) | `--rows 100` |
| `--only-clean` | Atajo para `--category DATOS_LIMPIOS` | |

### Generación

| Parámetro | Descripción |
|---|---|
| `--data-ia` | Filas generadas por IA en lugar de faker (ver sección más abajo) |
| `--overwrite` | Sobreescribir archivos existentes sin preguntar |
| `--no-ai` | Deshabilitar LM Studio — usar temas predefinidos |
| `--dry-run` | Simular sin escribir ningún archivo en disco |
| `--help`, `-h` | Mostrar ayuda en consola |

### Ejemplos combinados

```bash
# Solo CSVs de REDUNDANCIA, 3 archivos de 50 filas
npm run generate:chaos -- --category REDUNDANCIA --type csv --count 3 --rows 50

# Datos limpios con filas generadas por IA
npm run generate:chaos -- --only-clean --data-ia

# Prueba rápida: 1 archivo por tipo, sin IA, sin escribir
npm run generate:chaos -- --no-ai --dry-run --count 1

# Dos archivos Excel por categoría, sobreescribiendo los existentes
npm run generate:chaos -- --type excel --count 2 --overwrite
```

---

## ¿Qué genera?

### Distribución de archivos

La distribución se configura en `chaos.config.json`. La distribución estándar completa:

| Categoría | CSV | Excel | JSON | JSONL | LOG | XML | PDF | TOML | Total |
|---|---|---|---|---|---|---|---|---|---|
| REDUNDANCIA | 10 | 10 | 3 | — | — | — | — | — | 23 |
| ESTRUCTURA_ROTA | 10 | 10 | — | — | 5 | — | — | — | 25 |
| MULTI_ENTIDAD | 10 | 10 | — | — | — | 3 | — | — | 23 |
| TIPOS_INCONSISTENTES | 10 | 10 | — | — | — | — | 3 | — | 23 |
| EXTRACCION | 5 | 5 | — | — | 5 | 2 | 2 | — | 19 |
| ESQUEMA | 5 | 5 | 7 | — | — | — | — | — | 17 |
| DATOS_LIMPIOS | 8 | 8 | 5 | 4 | — | — | — | 4 | 29 |

### Categorías de caos

| Categoría | Propósito técnico |
|---|---|
| **REDUNDANCIA** | Identificar duplicados exactos y difusos (fuzzy matching) |
| **ESTRUCTURA_ROTA** | Manejar nulos, filas vacías y archivos mal formados |
| **MULTI_ENTIDAD** | Unificar múltiples tablas/pestañas en un solo esquema |
| **TIPOS_INCONSISTENTES** | Normalizar fechas, monedas y formatos regionales |
| **EXTRACCION** | Parsear PDFs y Logs para convertirlos en tablas |
| **ESQUEMA** | Inferir tipos de datos correctos desde dumps |
| **DATOS_LIMPIOS** | Datos de referencia normalizados — el "output esperado" |

### Nomenclatura de archivos

Los archivos usan nombres descriptivos basados en el tema generado:

```
{dominio}_{palabras_del_tema}_{NNN}.ext
```

Ejemplos reales:
```
logistica_control_inventario_001.csv
salud_registros_pacientes_002.xlsx
finanzas_transacciones_bancarias_001.json
```

### Dónde se guardan

```
datasets/Generados/dataset_caos/
├── REDUNDANCIA/
│   ├── CSV/
│   ├── EXCEL/
│   └── JSON/
├── ESTRUCTURA_ROTA/
├── MULTI_ENTIDAD/
├── TIPOS_INCONSISTENTES/
├── EXTRACCION/
├── ESQUEMA/
└── DATOS_LIMPIOS/
    ├── CSV/
    ├── EXCEL/
    ├── JSON/
    ├── JSONL/
    └── TOML/
```

En modo acumulativo (`overwrite: false` en el config), los nuevos archivos se numeran continuando desde el último existente.

---

## Tipos de caos inyectados

### En todos los archivos (según configuración)

| Tipo de error | Descripción | Ejemplo |
|---|---|---|
| **Duplicados exactos** | Filas copiadas al 100% | Mismo registro aparece 2-3 veces |
| **Duplicados difusos** | Copias con errores tipográficos | `García` vs `G@rcía`, `Empresa S.A.` vs `Empreza S.A.` |
| **Valores nulos** | Múltiples representaciones de "sin dato" | `NULL`, `NaN`, `n/a`, `""`, `?`, `NULO`, `-` |
| **Fechas inconsistentes** | 8 formatos distintos en la misma columna | `2024-01-15`, `15/01/2024`, `January 15, 2024`, `1705276800` |
| **Monedas inconsistentes** | Distintas representaciones del valor | `$1234.56`, `USD 1234.56`, `COP 5.183.520`, `1234,56` |
| **Texto en números** | Strings donde va un número | `"PENDIENTE"`, `"VER ANEXO"`, `"N/D"` en columna de precio |
| **Multidioma** | ES, EN, 中文, عربي en el mismo archivo | `客户信息`, `معالجة البيانات` mezclados con español |
| **Caracteres especiales** | Emojis, símbolos y caracteres de escape | `😀`, `©`, `™`, `<b>bold</b>`, `=SUM(A1)` |
| **Errores de encoding** | UTF-8 interpretado como Latin-1 | `ñ` → `Ã±`, `é` → `Ã©` |

### Específicos por tipo de archivo

**CSV:**
- **Data drift**: el delimitador cambia de `,` a `;` a mitad del archivo
- **BOM inesperado**: algunos archivos incluyen `﻿` al inicio
- **Filas rotas**: columnas de más o de menos que el header
- **Comentarios inline**: líneas `# exportado el...` entre los datos

**Excel (.xlsx):**
- **Hojas basura**: pestañas `Copia_Temporal`, `HOJA_ANTIGUA_NO_BORRAR`, `Sheet3` con datos inútiles
- **Multi-hoja y multi-tabla**: entre 2 y 8 hojas con 1-3 tablas por hoja
- **Errores de fórmula**: `#REF!`, `###`, `#¡DIV/0!` en hojas basura

**JSON:**
- **Duplicados inter-archivo**: registros del pool compartido aparecen en varios JSONs (para deduplicación cross-file)
- **Versión de esquema inconsistente**: `_schema_version: "1.0"` vs `"2.0"`
- **Campos extra inesperados**: `_src: "legacy_abc123"` en algunos registros

**JSONL (.jsonl):**
- Formato de fine-tuning: `{"instruction": "...", "input": {...}, "output": "..."}` por línea
- Aleatoriamente puede emitir el registro plano sin envolver en instrucción
- Solo en DATOS_LIMPIOS (datos de referencia para entrenamiento)

**Log (.log):**
- **8 formatos de timestamp**: ISO, Unix, US, UTS, solo fecha, etc.
- **Niveles mezclados**: `INFO`, `info`, `WARN`, `WARNING`, `ERR`, `FATAL`
- **Stack traces completos** con `Caused by:` anidados
- **JSON inline**: payloads embebidos dentro de la línea de log

**XML:**
- **Atributos vs elementos hijo**: inconsistente entre registros del mismo archivo
- **CDATA**: algunos valores en secciones `<![CDATA[...]]>`
- **Campos extra desconocidos**: `<campo_desconocido_legacy>` sin schema

**PDF:**
- **Tablas difíciles de OCR**: celdas truncadas, columnas superpuestas
- **Metadatos dispersos**: referencias y códigos antes de la tabla
- **Páginas múltiples**: continúa en páginas siguientes con encabezados inconsistentes

**TOML (.toml):**
- Metadatos en `[metadata]`, registros como `[[records]]`
- Solo en DATOS_LIMPIOS (formato estructurado limpio)

---

## Cómo funciona la integración con LM Studio

### Temas dinámicos (siempre activo si hay conexión)

El generador pide al modelo sugerencias de **temas de negocio** para cada categoría. Esto hace que los datasets sean variados y con columnas realistas.

```
1. Detecta modelo cargado en localhost:1234
2. Para cada categoría:
   → Envía prompt pidiendo N temas de negocio con columnas en JSON
   → Respuesta: [{theme, domain, columns: [{name, type, examples}]}]
3. Genera los archivos usando esas columnas con Faker
4. Aplica caos sobre los datos generados
```

### Filas generadas por IA (`--data-ia`)

Con este flag el generador pide adicionalmente **~40 filas de datos realistas** por tema (una sola llamada, no una por archivo). Esas filas se reutilizan mezcladas y barajadas en todos los archivos de ese tema, y el caos se aplica encima igual.

```
5. Para cada tema único:
   → Envía prompt pidiendo 40 filas de datos para ese tema/columnas
   → Guarda el pool de filas en memoria
6. Al generar cada archivo, rellena con filas del pool (mezcladas)
7. Si falla para un tema → fallback a Faker automáticamente
```

Más lento que Faker, pero los valores son específicos del dominio (ej. nombres de medicamentos reales para un tema de farmacia).

### Flujo sin IA (fallback)

```
1. LM Studio no disponible o no responde en el timeout
2. Usa los 48 temas hardcodeados en fallback-themes.js
3. Continúa la generación normalmente — no es un error
```

### Compatibilidad con modelos de razonamiento

Modelos como **Qwen3**, **DeepSeek-R1** y similares generan un bloque `<think>...</think>` antes de responder. El generador los elimina automáticamente antes de parsear el JSON, y usa `maxTokens: 12000` para que el bloque de razonamiento no consuma todo el presupuesto de tokens.

El modelo configurado actualmente es **`qwen/qwen3.5-9b`**. Para cambiarlo, editar el campo `model` en `packages/chaos-generator/chaos.config.json`.

---

## Personalizar la generación

### Via CLI (sin tocar el config)

```bash
# Generar solo Excel de ESQUEMA, 5 archivos de 80 filas
npm run generate:chaos -- --category ESQUEMA --type excel --count 5 --rows 80

# Regenerar DATOS_LIMPIOS sobreescribiendo todo
npm run generate:chaos -- --only-clean --overwrite
```

### Via `chaos.config.json`

```jsonc
// Cambiar cantidad de registros por archivo
"registros_por_archivo": { "min": 60, "max": 220 }

// Desactivar un tipo de caos específico
"activacion_de_errores": {
  "encoding_errors": false  // desactiva corrupción de encoding
}

// Reducir tasas de error para datasets más "limpios"
"tasa_errores": {
  "duplicados_exactos": 0.05  // 5% en vez de 12%
}

// Generar más o menos archivos por categoría
"distribucion_categorias": {
  "REDUNDANCIA": { "csv": 20, "excel": 20, "json": 5 }
}

// Controlar LM Studio
"lmstudio": {
  "themesPerCategory": 4,   // más temas = más variedad
  "maxTokens": 12000,       // importante para modelos de razonamiento
  "maxRetries": 3
}
```

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `⚠ LM Studio: no disponible` | LM Studio no está corriendo | Usar `--no-ai` o iniciar LM Studio |
| `✘ Error API: Unexpected end of JSON input` | Modelo de razonamiento con `maxTokens` muy bajo | Verificar que `maxTokens` sea ≥ 8000 en el config |
| `Respuesta vacía del modelo` | Todo el contenido quedó en `reasoning_content` | El generador hace fallback a temas predefinidos automáticamente |
| `Error: ENOENT: no such file` | Directorio de salida no existe | El script lo crea automáticamente; verificar permisos |
| PDFs sin texto CJK | pdfkit no embebe fuentes CJK | Comportamiento esperado; se muestran como □ (caos intencional) |
| `--data-ia` genera filas repetidas | Pool de 40 filas se reutiliza mezclado | Normal; aumentar el count en `generateRowsForTheme` si se necesita más variedad |
| Archivos vacíos o sin columnas | Theme sin columnas válidas (JSON mal parseado) | Revisar logs — el script hace fallback a temas predefinidos |

---

## Referencia técnica

Para más detalles sobre la arquitectura interna del paquete, ver:

- [`packages/chaos-generator/README.md`](../packages/chaos-generator/README.md) — documentación técnica del paquete
- [`packages/chaos-generator/chaos.config.json`](../packages/chaos-generator/chaos.config.json) — configuración completa
- [`HU 015 - Clasificación de Dataset de Caos para Entrenamiento de IA.md`](./HU/HU%20015%20-%20Clasificaci%C3%B3n%20de%20Dataset%20de%20Caos%20para%20Entrenamiento%20de%20IA.md) — historia de usuario original
