# chaos-generator — Generador de Datasets Caóticos

Genera datasets sintéticos con errores reales para fine-tuning de modelos de normalización.  
7 categorías · 8 formatos · fallback automático si LM Studio no está activo.  
Ubicación: `packages/chaos-generator/`

---

## Comandos

```bash
npm run generate:chaos           # Generación completa con LM Studio
npm run generate:chaos:fast      # Sin IA — temas predefinidos
npm run generate:chaos:dry       # Simular sin escribir archivos
npm run generate:chaos:clean     # Solo categoría DATOS_LIMPIOS
npm run generate:chaos:help      # Ver todos los parámetros
```

---

## Parámetros

```bash
--count <n>          # Archivos por tipo por categoría
--category <lista>   # Filtrar categorías (coma-separadas)
--type <lista>       # Filtrar tipos de archivo (csv, excel, json…)
--rows <n>           # Filas fijas por archivo
--only-clean         # Atajo para --category DATOS_LIMPIOS
--data-ia            # Filas generadas por IA en vez de faker
--no-ai              # Deshabilitar LM Studio
--dry-run            # Sin escribir archivos
--overwrite          # Sobreescribir existentes
```

### Ejemplos

```bash
# Solo CSVs de REDUNDANCIA, 3 archivos de 50 filas
npm run generate:chaos -- --category REDUNDANCIA --type csv --count 3 --rows 50

# Datos limpios con filas generadas por IA
npm run generate:chaos -- --only-clean --data-ia

# Prueba rápida sin escribir nada
npm run generate:chaos -- --no-ai --dry-run --count 1
```

---

## Categorías

| Categoría | Descripción |
|-----------|-------------|
| `REDUNDANCIA` | Duplicados exactos y fuzzy |
| `ESTRUCTURA_ROTA` | Columnas incompletas, BOM, delimitadores irregulares |
| `MULTI_ENTIDAD` | Múltiples entidades en una tabla |
| `TIPOS_INCONSISTENTES` | Fechas, monedas y números heterogéneos |
| `EXTRACCION` | Simulación de PDF escaneado o log de sistema |
| `ESQUEMA` | Requiere inferencia de tipos |
| `DATOS_LIMPIOS` | Datos normalizados listos para producción |

---

## Tipos de archivo

| Tipo | Extensión | Caos especial |
|------|-----------|---------------|
| `csv` | `.csv` | Data drift, BOM, comentarios inline |
| `excel` | `.xlsx` | Multi-hoja, hojas basura, estilos inconsistentes |
| `json` | `.json` | Pool compartido inter-archivo para duplicados |
| `jsonl` | `.jsonl` | Formato fine-tuning por línea |
| `log` | `.log` | Timestamps mixtos, stack traces |
| `xml` | `.xml` | Atributos vs elementos, CDATA |
| `pdf` | `.pdf` | Tablas difíciles de parsear |
| `toml` | `.toml` | Metadatos + registros estructurados |

---

## Configuración (`chaos.config.json`)

```jsonc
"lmstudio": {
  "baseUrl": "http://localhost:1234/v1",
  "model": "qwen/qwen3.5-9b",
  "timeoutMs": 600000,
  "maxTokens": 12000,
  "maxRetries": 2,
  "themesPerCategory": 2
}
```

> Si LM Studio no responde, el generador hace fallback a 48 temas predefinidos automáticamente.

---

## Salida

```
datasets/Generados/dataset_caos/
├── REDUNDANCIA/    CSV/ · EXCEL/ · JSON/
├── ESTRUCTURA_ROTA/
├── DATOS_LIMPIOS/
└── ...
```

Nombre de archivo: `{dominio}_{tema}_{NNN}.{ext}`

---

## Arquitectura

```
packages/chaos-generator/src/
├── index.js            ← Orquestador: CLI, progreso, resumen
├── ai-client.js        ← Cliente LM Studio con streaming y fallback
├── faker-helper.js     ← Datos fake en ES / EN / ZH_CN / AR
├── chaos-injector.js   ← 12 funciones de inyección de caos
├── fallback-themes.js  ← 48 temas predefinidos
└── generators/
    └── csv · excel · json · jsonl · log · pdf · toml · xml
```
