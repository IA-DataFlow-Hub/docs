# HU-027 — Gestión de Templates ETL y Transformaciones Predefinidas

---

# Historia de Usuario

Como usuario del sistema IA-DataFlow-Hub,

quiero poder crear, guardar, reutilizar y ejecutar templates ETL predefinidos,

para automatizar procesos repetitivos de limpieza, transformación, validación y optimización de datos dentro de mis proyectos.

---

# Objetivo

Implementar un sistema de templates ETL reutilizables que permita:

- guardar transformaciones ETL
- reutilizar pipelines
- versionar procesos
- ejecutar workflows automáticos
- aplicar transformaciones con un clic
- registrar trazabilidad completa
- integrar IA en procesos ETL

---

# Problema Actual

Actualmente el sistema:

- puede procesar datasets
- puede ejecutar transformaciones IA
- maneja proyectos y conversaciones

Pero NO tiene soporte para:

- guardar pipelines ETL
- reutilizar transformaciones
- almacenar configuraciones ETL
- versionar flujos
- automatizar procesos repetitivos
- registrar pasos ETL
- manejar templates predefinidos

---

# Solución Propuesta

Crear un módulo ETL que permita:

✅ guardar templates reutilizables

✅ ejecutar transformaciones automáticas

✅ encadenar operaciones

✅ registrar historial de ejecución

✅ soportar workflows IA + ETL

---

# Requerimientos Funcionales

---

## RF-01 — Templates ETL

El sistema debe permitir crear templates ETL reutilizables.

Ejemplos:

- eliminar duplicados
- normalización
- validación
- enriquecimiento
- optimización esquema

---

## RF-02 — Ejecución con un clic

El usuario podrá ejecutar un template directamente sobre un dataset.

---

## RF-03 — Pipeline ETL

Un template debe soportar múltiples pasos ETL.

Ejemplo:

```text
Detectar duplicados
    ↓
Eliminar duplicados
    ↓
Normalizar fechas
    ↓
Validar datos
```

---

## RF-04 — Relación con proyectos

Cada template ETL podrá estar asociado a:

- proyecto
- usuario
- dataset
- conversación

---

## RF-05 — Historial de ejecución

El sistema debe registrar:

- cuándo se ejecutó
- quién lo ejecutó
- duración
- resultado
- dataset generado

---

## RF-06 — Templates predefinidos

El sistema debe incluir templates iniciales:

- Eliminación de duplicados
- Normalización
- Manejo de nulos
- Validación
- Enriquecimiento
- Optimización esquema

---

## RF-07 — Configuración dinámica

Cada template podrá tener:

- parámetros
- reglas
- configuraciones dinámicas

---

## RF-08 — Integración IA

Los templates podrán usar IA para:

- sugerir reglas
- detectar anomalías
- inferir tipos
- generar transformaciones

---

## RF-09 — Versionado

Los templates deben soportar:

- versiones
- snapshots
- historial de cambios

---

## RF-10 — Estado de ejecución

Las ejecuciones ETL deben manejar:

- pending
- running
- completed
- failed
- cancelled

---

# Diseño Técnico

---

# Tabla: etl_templates

```sql
CREATE TABLE etl_templates (
    id_template INT AUTO_INCREMENT PRIMARY KEY,

    id_project INT NULL,

    created_by INT NULL,

    template_name VARCHAR(255) NOT NULL,

    description TEXT,

    category ENUM(
        'cleaning',
        'transformation',
        'validation',
        'enrichment',
        'optimization'
    ) DEFAULT 'transformation',

    difficulty ENUM(
        'easy',
        'medium',
        'advanced'
    ) DEFAULT 'easy',

    estimated_time_minutes INT DEFAULT 5,

    icon VARCHAR(100),

    color VARCHAR(50),

    is_system BOOLEAN DEFAULT FALSE,

    is_public BOOLEAN DEFAULT FALSE,

    version VARCHAR(20) DEFAULT '1.0.0',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_templates_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_templates_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);
```

---

# Tabla: etl_template_steps

```sql
CREATE TABLE etl_template_steps (
    id_step INT AUTO_INCREMENT PRIMARY KEY,

    id_template INT NOT NULL,

    step_order INT NOT NULL,

    step_name VARCHAR(255) NOT NULL,

    operation_type ENUM(
        'remove_duplicates',
        'normalize',
        'fill_nulls',
        'validate',
        'enrich',
        'optimize_schema',
        'custom'
    ) NOT NULL,

    configuration JSON NULL,

    ai_enabled BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_steps_template
        FOREIGN KEY (id_template)
        REFERENCES etl_templates(id_template)
        ON DELETE CASCADE
);
```

---

# Tabla: etl_executions

```sql
CREATE TABLE etl_executions (
    id_execution INT AUTO_INCREMENT PRIMARY KEY,

    id_template INT NOT NULL,

    id_project INT NOT NULL,

    id_generated_table INT NOT NULL,

    executed_by INT NULL,

    id_conversation INT NULL,

    id_message INT NULL,

    execution_status ENUM(
        'pending',
        'running',
        'completed',
        'failed',
        'cancelled'
    ) DEFAULT 'pending',

    started_at TIMESTAMP NULL,

    finished_at TIMESTAMP NULL,

    execution_time_ms BIGINT DEFAULT 0,

    rows_processed BIGINT DEFAULT 0,

    output_generated_table_id INT NULL,

    logs_path TEXT NULL,

    error_message TEXT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_exec_template
        FOREIGN KEY (id_template)
        REFERENCES etl_templates(id_template)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_exec_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_exec_dataset
        FOREIGN KEY (id_generated_table)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_exec_user
        FOREIGN KEY (executed_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_etl_exec_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_etl_exec_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL
);
```

---

# Tabla: etl_execution_logs

```sql
CREATE TABLE etl_execution_logs (
    id_log INT AUTO_INCREMENT PRIMARY KEY,

    id_execution INT NOT NULL,

    log_level ENUM(
        'info',
        'warning',
        'error'
    ) DEFAULT 'info',

    message TEXT NOT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_logs_execution
        FOREIGN KEY (id_execution)
        REFERENCES etl_executions(id_execution)
        ON DELETE CASCADE
);
```

---

# Templates Iniciales del Sistema

---

## 1. Eliminación de Duplicados

```text
Categoría: cleaning
Dificultad: easy
```

Operaciones:

- identificar duplicados
- marcar duplicados
- eliminar registros

---

## 2. Normalización de Datos

```text
Categoría: transformation
Dificultad: medium
```

Operaciones:

- normalizar fechas
- normalizar texto
- normalizar números

---

## 3. Manejo de Valores Faltantes

```text
Categoría: cleaning
Dificultad: medium
```

Operaciones:

- detectar nulos
- sugerir estrategia
- rellenar datos

---

## 4. Validación de Datos

```text
Categoría: validation
Dificultad: medium
```

Operaciones:

- validar reglas
- detectar anomalías
- generar reporte

---

## 5. Enriquecimiento de Datos

```text
Categoría: enrichment
Dificultad: advanced
```

Operaciones:

- generar columnas
- calcular métricas
- enriquecer dataset

---

## 6. Optimización de Esquema

```text
Categoría: optimization
Dificultad: advanced
```

Operaciones:

- optimizar tipos
- detectar índices
- mejorar esquema

---

# Flujo Esperado

```text
Usuario selecciona dataset
    ↓
Selecciona template ETL
    ↓
Configura parámetros
    ↓
Ejecuta pipeline
    ↓
Sistema genera dataset derivado
    ↓
Se registra ejecución
```

---

# Casos de Uso

---

## Caso 1 — Limpieza automática

Usuario aplica:

```text
Eliminar Duplicados
```

Sistema:

- detecta duplicados
- genera nuevo dataset limpio
- registra lineage

---

## Caso 2 — Normalización IA

Sistema IA detecta:

- formatos inconsistentes

y propone:

```text
Normalización automática
```

---

## Caso 3 — Optimización esquema

Sistema analiza dataset grande y:

- optimiza tipos
- reduce peso
- genera índices sugeridos

---

# Beneficios

- Automatización ETL
- Reutilización de pipelines
- Escalabilidad
- Integración IA
- Mejor calidad de datos
- Trazabilidad
- Procesamiento enterprise
- Arquitectura data-platform

---

# Posibles Mejoras Futuras

- DAG visual
- Drag & Drop pipelines
- Integración Airflow
- Spark jobs
- Streaming ETL
- Scheduler automático
- Versionado Git-like
- Marketplace de templates
- IA generadora de pipelines
- Data Quality Score
- ETL distribuido
- Ejecución serverless

---