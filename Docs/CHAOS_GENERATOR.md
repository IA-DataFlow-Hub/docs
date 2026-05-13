# Guía: Generación de Datasets de Caos para Entrenamiento de IA

> **HU-015** · Responsable: Juan Diego Mejía · Estado: ✅ Completado

Esta guía explica cómo usar el script `chaos-generator` para producir los **130+ archivos de prueba** que alimentan el fine-tuning del modelo de normalización de datos de DataFlow Hub.

---

## ¿Para qué sirven estos datasets?

El modelo de IA necesita aprender a **limpiar y normalizar datos del mundo real**, que llegan en formatos caóticos: columnas mezcladas, fechas en 7 formatos distintos, duplicados con errores tipográficos, archivos con encoding roto, etc. 

Los datasets generados son pares **Input Caótico → Output Esperado**, donde el Input es lo que produce este script y el Output es lo que el modelo debe aprender a producir.

---

## Requisitos previos

| Requisito | Versión mínima |
|---|---|
| Node.js | 18+ |
| npm | 10+ |
| LM Studio *(opcional)* | cualquier versión con servidor local habilitado |

Si vas a usar LM Studio para temas dinámicos:
1. Abre LM Studio → pestaña **Local Server**.
2. Carga el modelo `microsoft/phi-4-reasoning-plus` (u otro disponible).
3. Presiona **Start Server** — por defecto queda en `http://localhost:1234`.

> Si LM Studio no está corriendo, el generador usa **48 temas predefinidos** automáticamente. No es un error, es el comportamiento esperado.

---

## Ejecución rápida

Desde la **raíz del proyecto**:

```bash
# Opción 1 — Con LM Studio activo (temas dinámicos generados por IA)
npm run generate:chaos

# Opción 2 — Sin LM Studio (temas predefinidos, más rápido)
npm run generate:chaos:fast

# Opción 3 — Simulación (no escribe archivos, solo verifica la config)
npm run generate:chaos:dry
```

La generación completa tarda entre **30 segundos y 3 minutos** dependiendo de la velocidad de LM Studio y la cantidad de archivos configurados.

---

## ¿Qué genera?

### Distribución de archivos (130 en total)

| Tipo | Cantidad | Categorías |
|---|---|---|
| `.csv` | 50 | Todas |
| `.xlsx` | 50 | Todas |
| `.json` | 10 | REDUNDANCIA (3), ESQUEMA (7) |
| `.log` | 10 | ESTRUCTURA\_ROTA (5), EXTRACCION (5) |
| `.xml` | 5 | MULTI\_ENTIDAD (3), EXTRACCION (2) |
| `.pdf` | 5 | TIPOS\_INCONSISTENTES (3), EXTRACCION (2) |

### Categorías de caos

| Categoría | Archivos | Propósito técnico |
|---|---|---|
| **REDUNDANCIA** | 23 | Identificar duplicados exactos y difusos (fuzzy matching) |
| **ESTRUCTURA\_ROTA** | 25 | Manejar nulos, filas vacías y archivos mal formados |
| **MULTI\_ENTIDAD** | 23 | Unificar múltiples tablas/pestañas en un solo esquema |
| **TIPOS\_INCONSISTENTES** | 23 | Normalizar fechas, monedas y formatos regionales |
| **EXTRACCION** | 19 | Parsear PDFs y Logs para convertirlos en tablas |
| **ESQUEMA** | 17 | Inferir tipos de datos correctos desde dumps |

### Nomenclatura de archivos

Todos los archivos siguen el estándar **`{CATEGORÍA}_{TIPO}_{ID}.ext`**:

```
REDUNDANCIA_CSV_001.csv
ESTRUCTURA_ROTA_XLSX_003.xlsx
MULTI_ENTIDAD_XML_002.xml
TIPOS_INCONSISTENTES_PDF_001.pdf
```

### Dónde se guardan

```
datasets/Generados/dataset_caos/
├── REDUNDANCIA/
├── ESTRUCTURA_ROTA/
├── MULTI_ENTIDAD/
├── TIPOS_INCONSISTENTES/
├── EXTRACCION/
└── ESQUEMA/
```

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
- **Hojas multi-entidad**: segunda hoja con entidad relacionada (para MULTI\_ENTIDAD)
- **Filas con columnas incorrectas**: celdas extra fuera del rango de columnas
- **Errores de fórmula**: `#REF!`, `###`, `#¡DIV/0!` en hojas basura

**JSON:**
- **Duplicados inter-archivo**: registros del pool compartido aparecen en varios JSONs (para pruebas de deduplicación cross-file)
- **Versión de esquema inconsistente**: `_schema_version: "1.0"` vs `"2.0"` 
- **Campos extra inesperados**: `_src: "legacy_abc123"` en algunos registros
- **Tipos mezclados**: número guardado como string en ciertos registros

**Log (.log):**
- **8 formatos de timestamp**: ISO, Unix, US, UTS, solo fecha, etc.
- **Niveles mezclados**: `INFO`, `info`, `WARN`, `WARNING`, `ERR`, `FATAL`
- **Stack traces completos**: con `Caused by:` anidados
- **JSON inline**: payloads embebidos dentro de la línea de log
- **Logs anidados**: `>> FORWARDED [ERROR] ...` dentro de otra entrada

**XML:**
- **Atributos vs elementos hijo**: inconsistente entre registros del mismo archivo
- **CDATA**: algunos valores en secciones `<![CDATA[...]]>`
- **Tags sin cerrar**: para ESTRUCTURA\_ROTA (intencional)
- **Campos extra desconocidos**: `<campo_desconocido_legacy>` sin schema

**PDF:**
- **Tablas difíciles de OCR**: celdas truncadas, columnas superpuestas
- **Metadatos dispersos**: referencias y códigos antes de la tabla
- **Páginas múltiples**: continúa en páginas siguientes con encabezados inconsistentes
- **Nota de pie caótica**: formatos mezclados de moneda explicados al pie

---

## Cómo funciona la integración con LM Studio

Cuando LM Studio está activo, el generador le pide al modelo sugerencias de temas de negocio para cada categoría. Esto hace que los datasets sean variados y realistas.

**Flujo con IA activa:**

```
1. Detecta modelo cargado en localhost:1234
2. Para cada categoría (6 total):
   → Envía prompt pidiendo 8 temas de negocio con columnas en JSON
   → Ejemplo respuesta: "Inventario Farmacia", "Expedientes Jurídicos", etc.
3. Genera los archivos usando esas columnas con Faker
4. Aplica caos sobre los datos generados
```

**Flujo sin IA (fallback):**

```
1. LM Studio no disponible o no responde
2. Usa los 48 temas hardcodeados en fallback-themes.js
3. Continúa la generación normalmente
```

El modelo configurado es **`microsoft/phi-4-reasoning-plus`**. Si usas otro modelo, actualiza el campo `model` en `packages/chaos-generator/chaos.config.json`.

---

## Personalizar la generación

Edita `packages/chaos-generator/chaos.config.json`:

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
```

---

## Solución de problemas

| Síntoma | Causa probable | Solución |
|---|---|---|
| `⚠ LM Studio: no disponible` | LM Studio no está corriendo | Usar `--no-ai` o iniciar LM Studio |
| `400 Failed to load model` | Modelo detectado pero no cargado | Cargar el modelo en LM Studio antes de generar |
| `Error: ENOENT: no such file` | Directorio de salida no existe | El script lo crea automáticamente; verificar permisos |
| PDFs sin texto CJK | pdfkit no embebe fuentes CJK | Comportamiento esperado; se muestran como □ (caos intencional) |
| Archivos vacíos | Theme sin columnas válidas | Verificar que `fallback-themes.js` tenga el fallback correcto |

---

## Referencia técnica

Para más detalles sobre la arquitectura interna del paquete, ver:

- [`packages/chaos-generator/README.md`](../packages/chaos-generator/README.md) — documentación técnica del paquete
- [`packages/chaos-generator/chaos.config.json`](../packages/chaos-generator/chaos.config.json) — configuración completa con comentarios
- [`HU 015 - Clasificación de Dataset de Caos para Entrenamiento de IA.md`](./HU/HU%20015%20-%20Clasificaci%C3%B3n%20de%20Dataset%20de%20Caos%20para%20Entrenamiento%20de%20IA.md) — historia de usuario original
