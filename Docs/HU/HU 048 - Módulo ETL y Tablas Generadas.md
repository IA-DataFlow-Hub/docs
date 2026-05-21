# HU-048 — Módulo de Tablas Generadas y ETL

## Asignación de Tablas

`generated_tables` · `generated_table_columns` · `etl_templates` · `etl_template_steps` · `etl_executions` · `etl_execution_logs`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de ETL y Datasets siguiendo Clean Architecture,  
**Para** registrar tablas de datos generadas por la IA (con sus esquemas de columnas), gestionar plantillas de transformación reutilizables, ejecutar pipelines ETL con trazabilidad completa de logs y mantener el lineage de datos entre datasets derivados.

**Dependencia:** Requiere HU-043 (Projects), HU-044 (Files), HU-045 (Conversations) y HU-047 (AI Jobs).

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/etl/
├── etl.module.ts
├── domain/
│   ├── entities/
│   │   ├── generated-table.entity.ts
│   │   ├── etl-template.entity.ts
│   │   └── etl-execution.entity.ts
│   └── repositories/
│       ├── generated-table.repository.interface.ts
│       └── etl-template.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── register-dataset.dto.ts
│   │   ├── column-definition.dto.ts
│   │   ├── execute-etl.dto.ts
│   │   ├── dataset-response.dto.ts
│   │   ├── etl-template-response.dto.ts
│   │   └── etl-execution-response.dto.ts
│   ├── use-cases/
│   │   ├── register-generated-table.use-case.ts
│   │   ├── save-table-schema.use-case.ts
│   │   ├── run-etl-transformation.use-case.ts
│   │   ├── get-table-lineage.use-case.ts
│   │   └── create-etl-template.use-case.ts
│   └── facades/
│       └── etl.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── etl.controller.ts
    └── persistence/
        ├── prisma-generated-table.repository.ts
        ├── prisma-etl-template.repository.ts
        └── mappers/
            ├── generated-table.mapper.ts
            └── etl-execution.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Registro de dataset con esquema de columnas

**Dado** que se recibe `RegisterDatasetDto` con `table_name`, `storage_path`, metadatos (`rows_count`, `file_size`) y un array `columns` de `ColumnDefinitionDto`  
**Cuando** `SaveTableSchemaUseCase` ejecuta  
**Entonces:**
- La entidad `GeneratedTable` valida que `storage_path` no esté vacío; si está vacío, lanza `DatasetStoragePathRequiredException`.
- Dentro de una transacción `$transaction`:
  1. Inserta el registro en `generated_tables` con `status = 'ready'` y `columns_count = columns.length`.
  2. Por cada elemento del array `columns`, inserta en `generated_table_columns` con su `column_order` correspondiente.
- Retorna `DatasetResponseDto` con el `id_generated_table` asignado y el esquema completo.

### Escenario 2 — Lineage de datos (árbol de derivación)

**Dado** que un dataset tiene `parent_generated_table_id` definido (es un dataset derivado)  
**Cuando** `GetTableLineageUseCase` ejecuta con el `id_generated_table` raíz  
**Entonces:**
- Recorre recursivamente la cadena de `parent_generated_table_id` mediante queries sucesivas hasta llegar al nodo raíz (`parent = null`).
- Retorna un árbol jerárquico: `{ id, table_name, children: [...] }` representando el linaje completo.
- Limita la profundidad a 10 niveles para prevenir loops circulares; lanza `LineageDepthExceededException` si se supera.

### Escenario 3 — Ejecución ETL con tracking de estado y logs

**Dado** que `ExecuteEtlDto` incluye `id_template` con pasos definidos e `id_generated_table` como dataset de entrada  
**Cuando** `RunEtlTransformationUseCase` ejecuta  
**Entonces:**
- Crea el registro en `etl_executions` con `execution_status = 'pending'`.
- Actualiza a `execution_status = 'running'` y `started_at = now()`.
- Por cada `EtlTemplateStep` (en orden de `step_order`):
  1. Ejecuta la operación correspondiente (`remove_duplicates`, `normalize`, `fill_nulls`, etc.).
  2. Inserta un `EtlExecutionLog` con `log_level = 'info'` y el resultado del paso.
  3. Si el paso falla, inserta log con `log_level = 'error'` y continúa o aborta según `ai_enabled`.
- Al finalizar: actualiza `execution_status = 'completed'` (o `'failed'`), `finished_at`, `execution_time_ms` y `rows_processed`.
- Los logs se insertan de forma no-bloqueante; un fallo en el log **no aborta** la transacción principal.

### Escenario 4 — Plantillas del sistema (solo lectura)

**Dado** que el frontend solicita las plantillas ETL disponibles  
**Cuando** `GET /etl/templates` es consultado  
**Entonces:**
- Retorna todas las plantillas con `is_system = true` o `is_public = true`, ordenadas por `category` y `difficulty`.
- Incluye los pasos de cada plantilla (`EtlTemplateStep`) como array en `EtlTemplateResponseDto`.
- Las plantillas con `is_system = true` **no pueden ser modificadas** desde la API; lanza `SystemTemplateReadOnlyException` si se intenta.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/projects/:projectId/datasets` | Registrar dataset generado |
| GET | `/projects/:projectId/datasets` | Listar datasets del proyecto |
| GET | `/datasets/:id` | Detalle del dataset con columnas |
| GET | `/datasets/:id/lineage` | Árbol de linaje del dataset |
| GET | `/etl/templates` | Listar plantillas ETL disponibles |
| POST | `/etl/templates` | Crear plantilla personalizada |
| POST | `/datasets/:id/execute-etl` | Ejecutar pipeline ETL sobre dataset |
| GET | `/etl/executions/:id` | Estado y logs de una ejecución |

---

## Notas Técnicas

- `GeneratedTableRepositoryInterface` es exportada y consumida por HU-047 (AI Jobs) para vincular el `id_job` que generó el dataset.
- Los 6 templates del sistema (`is_system = true`) ya están sembrados en la migración y no requieren endpoints de creación.
- El procesamiento real de transformaciones (remover duplicados, normalizar, etc.) se delega a un `EtlProcessorInterface` externo; este módulo solo orquesta y registra el estado.
