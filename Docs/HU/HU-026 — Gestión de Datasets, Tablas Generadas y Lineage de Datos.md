# HU-026 — Gestión de Datasets, Tablas Generadas y Lineage de Datos

---

# Historia de Usuario

Como usuario del sistema IA-DataFlow-Hub,

quiero que todas las tablas, datasets y transformaciones generadas dentro de un proyecto sean almacenadas y relacionadas con el chat, usuario y flujo que las produjo,

para mantener trazabilidad completa del origen de los datos, evitar sobrecargar la base de datos principal y permitir auditoría, versionado y reutilización eficiente de datasets.

---

# Objetivo

Implementar un sistema de gestión de datasets que permita:

- almacenar datasets pesados como archivos físicos
- guardar únicamente metadata en MySQL
- relacionar datasets con:
  - proyecto
  - conversación
  - mensaje
  - usuario
  - transformación IA
- manejar previews ligeros
- guardar estructura de tablas
- soportar lineage de datos
- soportar versionado y datasets derivados

---

# Problema Actual

Actualmente el sistema:

- guarda archivos en `files`
- maneja conversaciones y mensajes
- maneja jobs IA

Pero NO tiene una estructura especializada para:

- tablas generadas por IA
- datasets transformados
- previews de datos
- relaciones dataset ↔ chat
- lineage de datos
- metadata analítica
- datasets derivados

Además:

❌ Guardar datasets completos dentro de MySQL sería incorrecto debido a:

- alto consumo de almacenamiento
- degradación de rendimiento
- consultas pesadas
- crecimiento descontrolado
- mala arquitectura para Big Data/Data Engineering

---

# Solución Propuesta

El sistema debe:

✅ guardar datasets reales como archivos físicos

y guardar en MySQL solamente:

- metadata
- relaciones
- rutas
- schema
- previews
- estadísticas

---

# Requerimientos Funcionales

---

## RF-01 — Registro de datasets generados

El sistema debe registrar cualquier dataset generado desde:

- carga manual
- IA
- transformaciones
- imports externos
- procesos ETL

---

## RF-02 — Relación con proyecto

Cada dataset debe pertenecer obligatoriamente a:

- un proyecto

---

## RF-03 — Relación con conversación

El sistema debe permitir saber:

- en qué conversación fue generado
- en qué mensaje se originó
- qué usuario lo generó

---

## RF-04 — Relación con IA

El sistema debe poder identificar:

- qué job IA generó el dataset
- qué motor IA fue utilizado
- qué prompt originó el resultado

---

## RF-05 — Almacenamiento físico

Los datasets NO deben guardarse dentro de MySQL.

Se deben almacenar como archivos físicos:

- parquet
- csv
- json
- xlsx

---

## RF-06 — Formato optimizado

El formato recomendado por defecto será:

```text
parquet
```

por:

- compresión
- velocidad
- compatibilidad analítica
- optimización IA

---

## RF-07 — Metadata estructural

El sistema debe guardar:

- número de filas
- número de columnas
- tamaño
- schema
- tipos de datos
- validaciones
- relaciones

---

## RF-08 — Preview ligero

El sistema debe generar automáticamente:

- preview JSON
- primeras filas
- estadísticas básicas

sin cargar el dataset completo.

---

## RF-09 — Versionado

El sistema debe permitir:

- múltiples versiones
- snapshots
- datasets derivados

---

## RF-10 — Lineage de datos

El sistema debe permitir rastrear:

```text
Dataset origen
    ↓
Transformación IA
    ↓
Dataset derivado
```

---

## RF-11 — Estado de procesamiento

Los datasets deben manejar estados:

- processing
- ready
- failed
- archived

---

## RF-12 — Exportación

El sistema debe permitir exportar datasets en:

- csv
- parquet
- json
- excel

---

# Diseño Técnico

---

# Tabla: generated_tables

```sql
CREATE TABLE generated_tables (
    id_generated_table INT AUTO_INCREMENT PRIMARY KEY,

    id_project INT NOT NULL,

    id_conversation INT NULL,

    id_message INT NULL,

    id_user INT NULL,

    id_job INT NULL,

    source_file_id INT NULL,

    parent_generated_table_id INT NULL,

    table_name VARCHAR(255) NOT NULL,

    display_name VARCHAR(255),

    description TEXT,

    storage_type ENUM(
        'csv',
        'json',
        'parquet',
        'xlsx'
    ) DEFAULT 'parquet',

    storage_path TEXT NOT NULL,

    preview_path TEXT NULL,

    schema_path TEXT NULL,

    rows_count BIGINT DEFAULT 0,

    columns_count INT DEFAULT 0,

    file_size BIGINT DEFAULT 0,

    generation_type ENUM(
        'uploaded',
        'ai_generated',
        'transformed',
        'imported'
    ) DEFAULT 'uploaded',

    status ENUM(
        'processing',
        'ready',
        'failed',
        'archived'
    ) DEFAULT 'ready',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_gt_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_gt_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_job
        FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_source_file
        FOREIGN KEY (source_file_id)
        REFERENCES files(id_file)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_parent
        FOREIGN KEY (parent_generated_table_id)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE SET NULL
);
```

---

# Tabla: generated_table_columns

```sql
CREATE TABLE generated_table_columns (
    id_column INT AUTO_INCREMENT PRIMARY KEY,

    id_generated_table INT NOT NULL,

    column_name VARCHAR(255) NOT NULL,

    data_type VARCHAR(100),

    is_nullable BOOLEAN DEFAULT TRUE,

    is_primary_key BOOLEAN DEFAULT FALSE,

    is_foreign_key BOOLEAN DEFAULT FALSE,

    is_unique_column BOOLEAN DEFAULT FALSE,

    default_value TEXT,

    validations JSON NULL,

    column_order INT DEFAULT 0,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_gtc_table
        FOREIGN KEY (id_generated_table)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE CASCADE
);
```

---

# Estructura Física Recomendada

```text
/storage/projects/{project_id}/datasets/
```

Ejemplo:

```text
/storage/projects/15/datasets/
    ventas_raw.parquet
    ventas_clean.parquet
    ventas_final.parquet

    ventas_raw_schema.json
    ventas_preview.json
```

---

# Arquitectura Recomendada

```text
Frontend
    ↓
API Laravel
    ↓
Jobs/Queues
    ↓
Storage datasets (S3/MinIO/local)
    ↓
MySQL metadata
```

---

# Flujo Esperado

```text
Usuario sube archivo
    ↓
Sistema crea dataset base
    ↓
IA transforma dataset
    ↓
Se genera nuevo dataset derivado
    ↓
Sistema registra lineage
    ↓
Usuario puede visualizar preview
```

---

# Casos de Uso

---

## Caso 1 — Archivo subido

Usuario sube:

```text
ventas_2026.xlsx
```

Sistema:

- crea dataset
- genera schema
- genera preview
- guarda metadata

---

## Caso 2 — Transformación IA

IA elimina duplicados.

Sistema:

- genera nuevo parquet
- conecta dataset padre
- registra job IA

---

## Caso 3 — Vista de estructura

Usuario abre:

```text
Vista de Datos
```

y el sistema carga:

- columnas
- validaciones
- relaciones
- previews

sin cargar millones de registros.

---

# Beneficios

- Arquitectura escalable
- Optimización de almacenamiento
- Mejor rendimiento
- Compatibilidad analítica
- Soporte Big Data
- Lineage de datos
- Auditoría avanzada
- Trazabilidad completa
- Mejor integración con IA

---

# Posibles Mejoras Futuras

- Apache Arrow
- DuckDB
- Spark
- Delta Lake
- Versionado temporal
- Time travel queries
- Dataset diff
- Compresión automática
- Cache inteligente
- Data catalog
- Semantic layer
- Métricas de calidad
- IA para detección de anomalías

---