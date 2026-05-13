# HU-029 — Sistema de Reportes y Dashboards Persistentes

---

# Historia de Usuario

Como usuario del sistema IA-DataFlow-Hub,

quiero crear, guardar, versionar y reutilizar reportes y dashboards analíticos generados a partir de datasets y transformaciones ETL,

para visualizar métricas, tendencias, KPIs y análisis estratégicos sin tener que reconstruirlos cada vez.

---

# Objetivo

Implementar un módulo completo de reportes y dashboards persistentes que permita:

- crear dashboards
- guardar configuraciones visuales
- guardar widgets y métricas
- reutilizar reportes
- versionar reportes
- generar dashboards IA
- exportar reportes
- compartir reportes
- relacionar reportes con proyectos y datasets

---

# Problema Actual

Actualmente:

- existen datasets
- existen ETLs
- existen análisis IA
- existen transformaciones

Pero NO existe:

- persistencia de dashboards
- almacenamiento de widgets
- almacenamiento de métricas
- reportes reutilizables
- sistema de visualizaciones guardadas
- reportes históricos
- reportes compartidos

---

# Solución Propuesta

Crear un módulo de reportes persistentes basado en:

- dashboards
- widgets
- métricas
- snapshots
- configuraciones visuales
- datasets generados
- resultados ETL

Los reportes NO deben almacenar los datos completos procesados.

Solo deben almacenar:

- configuraciones
- filtros
- estructura visual
- referencias
- metadata
- snapshots opcionales

Los datos reales seguirán viviendo en:

- archivos parquet
- csv
- json
- duckdb
- storage externo

---

# Requerimientos Funcionales

---

## RF-01 — Crear reportes

El usuario podrá crear reportes:

- estratégicos
- tácticos
- operativos
- analíticos

---

## RF-02 — Relación con proyecto

Cada reporte debe pertenecer a:

- proyecto
- usuario creador

---

## RF-03 — Guardar dashboards

El sistema debe guardar:

- layout visual
- widgets
- gráficas
- filtros
- configuraciones
- métricas

---

## RF-04 — Widgets soportados

El sistema debe soportar:

- KPIs
- tablas
- gráficos barras
- líneas
- pie charts
- heatmaps
- cards
- indicadores
- métricas IA
- tendencias
- comparativos

---

## RF-05 — Reportes IA

El sistema podrá generar dashboards automáticos usando IA.

Ejemplo:

```text
"Crear dashboard de ventas trimestrales"
```

---

## RF-06 — Versionamiento

Cada modificación importante debe generar una nueva versión.

---

## RF-07 — Snapshots opcionales

El sistema podrá guardar snapshots ligeros para:

- histórico
- auditoría
- comparación temporal

---

## RF-08 — Exportación

El usuario podrá exportar:

- PDF
- Excel
- CSV
- PNG
- JSON

---

## RF-09 — Compartir reportes

Los reportes podrán ser:

- privados
- de equipo
- públicos

---

## RF-10 — Recomendaciones IA

El sistema podrá sugerir:

- métricas
- visualizaciones
- KPIs
- dashboards automáticos

---

# Diseño Técnico

---

# Tabla: reports

```sql
CREATE TABLE reports (
    id_report INT AUTO_INCREMENT PRIMARY KEY,

    id_project INT NOT NULL,
    created_by INT NOT NULL,

    report_name VARCHAR(255) NOT NULL,

    report_type ENUM(
        'strategic',
        'tactical',
        'operational',
        'analytical'
    ) NOT NULL,

    description TEXT,

    visibility ENUM(
        'private',
        'team',
        'public'
    ) DEFAULT 'team',

    status ENUM(
        'draft',
        'active',
        'archived'
    ) DEFAULT 'active',

    current_version INT DEFAULT 1,

    is_ai_generated BOOLEAN DEFAULT FALSE,

    last_generated_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_reports_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_reports_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);
```

---

# Tabla: report_versions

```sql
CREATE TABLE report_versions (
    id_version INT AUTO_INCREMENT PRIMARY KEY,

    id_report INT NOT NULL,

    version_number INT NOT NULL,

    configuration_path TEXT NOT NULL,

    snapshot_path TEXT NULL,

    changelog TEXT,

    created_by INT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_report_versions_report
        FOREIGN KEY (id_report)
        REFERENCES reports(id_report)
        ON DELETE CASCADE,

    CONSTRAINT fk_report_versions_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);
```

---

# Tabla: report_widgets

```sql
CREATE TABLE report_widgets (
    id_widget INT AUTO_INCREMENT PRIMARY KEY,

    id_report INT NOT NULL,

    widget_type ENUM(
        'kpi',
        'line_chart',
        'bar_chart',
        'pie_chart',
        'table',
        'heatmap',
        'metric_card',
        'trend',
        'ai_insight'
    ) NOT NULL,

    widget_title VARCHAR(255),

    dataset_source VARCHAR(255),

    config JSON NOT NULL,

    position_x INT DEFAULT 0,
    position_y INT DEFAULT 0,

    width INT DEFAULT 4,
    height INT DEFAULT 4,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_report_widgets_report
        FOREIGN KEY (id_report)
        REFERENCES reports(id_report)
        ON DELETE CASCADE
);
```

---

# Tabla: report_metrics

```sql
CREATE TABLE report_metrics (
    id_metric INT AUTO_INCREMENT PRIMARY KEY,

    id_report INT NOT NULL,

    metric_name VARCHAR(255) NOT NULL,

    metric_formula TEXT,

    aggregation_type ENUM(
        'sum',
        'avg',
        'count',
        'min',
        'max',
        'custom'
    ) DEFAULT 'sum',

    format_type ENUM(
        'currency',
        'percentage',
        'number',
        'decimal'
    ) DEFAULT 'number',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_report_metrics_report
        FOREIGN KEY (id_report)
        REFERENCES reports(id_report)
        ON DELETE CASCADE
);
```

---

# Tabla: report_exports

```sql
CREATE TABLE report_exports (
    id_export INT AUTO_INCREMENT PRIMARY KEY,

    id_report INT NOT NULL,

    exported_by INT NOT NULL,

    export_type ENUM(
        'pdf',
        'excel',
        'csv',
        'png',
        'json'
    ) NOT NULL,

    storage_path TEXT NOT NULL,

    file_size BIGINT,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_report_exports_report
        FOREIGN KEY (id_report)
        REFERENCES reports(id_report)
        ON DELETE CASCADE,

    CONSTRAINT fk_report_exports_user
        FOREIGN KEY (exported_by)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);
```

---

# Estructura Recomendada Storage

```text
storage/reports/
    project_1/
        report_5/
            versions/
            exports/
            snapshots/
            config/
```

---

# Archivos Persistidos

El sistema debe guardar:

- configuración dashboard JSON
- filtros
- metadata
- widgets
- snapshots
- exports

NO debe guardar:

- datasets completos
- tablas gigantes
- resultados masivos

---

# Tecnologías Recomendadas

---

## Backend

- Laravel
- Queue Jobs
- Redis
- WebSockets

---

## Visualización

- Apache ECharts
- Chart.js
- Recharts
- D3.js

---

## Persistencia

- MySQL → metadata
- Storage → archivos JSON
- DuckDB → consultas analíticas
- Parquet → datasets

---

# Flujo Esperado

```text
Usuario crea dashboard
    ↓
Sistema guarda configuración JSON
    ↓
Widgets se persisten
    ↓
Métricas se almacenan
    ↓
Usuario exporta reporte
    ↓
Sistema genera snapshot
```

---

# Ejemplo JSON Dashboard

```json
{
  "layout": "grid",
  "filters": {
    "date_range": "last_90_days"
  },
  "widgets": [
    {
      "type": "line_chart",
      "metric": "ventas",
      "dataset": "ventas_2026"
    }
  ]
}
```

---

# Casos de Uso

---

## Caso 1 — Dashboard Ejecutivo

Usuario crea:

```text
Dashboard Ejecutivo Q1
```

con:

- KPIs
- ingresos
- crecimiento
- clientes

---

## Caso 2 — Reporte Analítico

IA genera:

```text
Análisis Predictivo
```

usando tendencias históricas.

---

## Caso 3 — Exportación PDF

Usuario exporta dashboard.

Sistema genera:

```text
storage/reports/project_5/report_8/export.pdf
```

---

# Beneficios

- Dashboards persistentes
- Reutilización
- Menor carga BD
- Arquitectura escalable
- Visualización avanzada
- Reportería empresarial
- Auditoría histórica
- KPIs inteligentes

---

# Mejoras Futuras

- Reportes programados
- Alertas automáticas
- IA generativa dashboards
- Compartir por URL
- Embeds
- Multi tenant analytics
- Storytelling IA
- BI embebido
- Data warehouse
- OLAP cubes
- Métricas en tiempo real
- Reportes colaborativos

---