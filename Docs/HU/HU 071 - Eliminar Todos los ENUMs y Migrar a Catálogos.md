# HU 071 - Eliminar Todos los ENUMs y Migrar a Catálogos

> Generado el 26 de mayo de 2026
> **Asignado a:** María, Sebastián, Felipe

---

## HU-071: Reemplazar todos los ENUM del esquema por tablas catálogo escalables

**Como** desarrollador del sistema,
**quiero** que ninguna columna use ENUM en la base de datos,
**para** poder agregar nuevos valores sin ejecutar `ALTER TABLE`, mantener integridad referencial real con FK, permitir agregar metadata a cada valor (descripción, color, ícono, is_active) y evitar problemas de replicación y migraciones destructivas en MySQL.

---

### Por qué los ENUMs son un problema

| Problema | Impacto |
|---|---|
| Agregar un valor requiere `ALTER TABLE` | Bloqueo de tabla en producción con millones de registros |
| No se puede agregar metadata al valor | No hay descripción, ícono, color, orden ni estado activo/inactivo |
| No hay FK real | El motor no garantiza integridad — solo validación de string |
| Replicación MySQL | Cambios de ENUM pueden causar inconsistencias entre réplicas |
| Prisma genera `enum` de TypeScript acoplado | Agregar un valor requiere cambiar código, generar cliente y redesplegar |
| No se puede desactivar un valor | No existe `is_active` — el valor o existe en el ENUM o no existe |

---

### Criterios de Aceptación

- Ninguna columna del esquema debe usar el tipo `ENUM` de MySQL
- Cada campo que era ENUM debe migrar a `INT NOT NULL` con FK hacia su tabla catálogo correspondiente
- Cada tabla catálogo debe seguir el patrón estándar del esquema v4:
  ```sql
  id_X INT AUTO_INCREMENT PRIMARY KEY,
  type_name VARCHAR(100) NOT NULL UNIQUE,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  ```
- Las tablas catálogo marcadas como "puede compartirse" deben ser una sola tabla reutilizada por múltiples tablas
- Cada migración debe preservar los datos existentes: primero poblar el catálogo, luego hacer `UPDATE` del FK, luego eliminar la columna ENUM
- El `schema.prisma` debe reflejar todas las nuevas relaciones

---

### Inventario de ENUMs a migrar

#### Grupo A — Tienen HU propia (ya documentadas)

| Tabla | Columna ENUM | HU |
|---|---|---|
| `configuration_keys` | `value_type` | HU-068 |
| `teams` | `group_type` (VARCHAR, mismo problema) | HU-069 |

---

#### Grupo B — Compartibles (un catálogo para múltiples tablas)

Estos ENUMs tienen los mismos valores en varias tablas — crear **un solo catálogo compartido**:

| Catálogo nuevo | Tablas que lo usan | Valores iniciales |
|---|---|---|
| `severity_levels` | `notifications.notification_type`, `activity_feed.activity_level` | `info`, `success`, `warning`, `error`, `critical` |
| `visibility_levels` | `analytics_reports.visibility` | `private`, `team`, `public` |

> `reports.priority` puede reutilizar directamente `task_priorities` (mismos valores: `low`, `medium`, `high`, `critical`).

---

#### Grupo C — Catálogo propio por dominio

| Catálogo nuevo | Tabla origen | Columna | Valores iniciales |
|---|---|---|---|
| `ai_job_event_types` | `ai_job_events` | `event_type` | `created`, `queued`, `started`, `completed`, `failed`, `retry`, `cancelled`, `warning`, `info` |
| `ai_actor_types` | `ai_job_events` | `actor_type` | `user`, `system`, `worker`, `scheduler` |
| `storage_types` | `generated_tables` | `storage_type` | `csv`, `json`, `parquet`, `xlsx` |
| `generation_types` | `generated_tables` | `generation_type` | `uploaded`, `ai_generated`, `transformed`, `imported` |
| `generated_table_statuses` | `generated_tables` | `status` | `processing`, `ready`, `failed`, `archived` |
| `etl_categories` | `etl_templates` | `category` | `cleaning`, `transformation`, `validation`, `enrichment`, `optimization` |
| `etl_difficulties` | `etl_templates` | `difficulty` | `easy`, `medium`, `advanced` |
| `etl_operation_types` | `etl_template_steps` | `operation_type` | `remove_duplicates`, `normalize`, `fill_nulls`, `validate`, `enrich`, `optimize_schema`, `custom` |
| `etl_execution_statuses` | `etl_executions` | `execution_status` | `pending`, `running`, `completed`, `failed`, `cancelled` |
| `log_levels` | `etl_execution_logs` | `log_level` | `info`, `warning`, `error` |
| `feedback_types` | `message_feedback` | `feedback_type` | `like`, `dislike` |
| `report_types` | `reports` | `report_type` | `message`, `conversation`, `application` |
| `report_categories` | `reports` | `category` | `incorrect_response`, `false_information`, `offensive_content`, `technical_error`, `duplication`, `performance_issue`, `security_issue`, `ui_bug`, `auth_issue`, `loading_issue`, `flow_error`, `out_of_context`, `other` |
| `report_statuses` | `reports` | `status` | `pending`, `in_review`, `resolved`, `rejected` |
| `notification_categories` | `notifications` | `category` | `collaboration`, `ai`, `task`, `security`, `system`, `workflow`, `project`, `comment` |
| `delivery_statuses` | `notification_recipients` | `delivery_status` | `pending`, `sent`, `delivered`, `failed` |
| `activity_types` | `activity_feed` | `activity_type` | `file_uploaded`, `analysis_completed`, `transformation_applied`, `data_edited`, `optimization_suggested`, `etl_executed`, `validation_completed`, `comment_added`, `dataset_generated`, `error_detected`, `export_generated`, `user_login`, `report_created` |
| `analytics_report_types` | `analytics_reports` | `report_type` | `strategic`, `tactical`, `operational`, `analytical` |
| `analytics_report_statuses` | `analytics_reports` | `status` | `draft`, `active`, `archived` |
| `widget_types` | `analytics_report_widgets` | `widget_type` | `kpi`, `line_chart`, `bar_chart`, `pie_chart`, `table`, `heatmap`, `metric_card`, `trend`, `ai_insight` |
| `aggregation_types` | `analytics_report_metrics` | `aggregation_type` | `sum`, `avg`, `count`, `min`, `max`, `custom` |
| `format_types` | `analytics_report_metrics` | `format_type` | `currency`, `percentage`, `number`, `decimal` |
| `export_types` | `analytics_report_exports` | `export_type` | `pdf`, `excel`, `csv`, `png`, `json` |
| `device_types` | `sessions` | `device_type` | `desktop`, `mobile`, `tablet`, `bot`, `unknown` |
| `session_statuses` | `sessions` | `status` | `active`, `inactive`, `expired`, `revoked` |

---

### Orden de implementación recomendado

1. Crear todas las tablas catálogo del Grupo B y C con sus seeds
2. Agregar columnas `id_X INT NULL` en cada tabla afectada (NULL temporal para permitir el UPDATE)
3. Ejecutar `UPDATE` para poblar los nuevos FK desde los valores ENUM actuales
4. Cambiar las columnas `id_X` de `NULL` a `NOT NULL`
5. Eliminar las columnas ENUM originales
6. Agregar los FK constraints
7. Actualizar `schema.prisma`: eliminar `@db.VarChar` de los campos ENUM, agregar relaciones hacia los catálogos
8. Regenerar cliente Prisma

### Notas

- Total de ENUMs en el esquema actual: **30** (incluyendo HU-068 y HU-069)
- Esta HU cubre los **28 restantes**
- `etl_execution_statuses` tiene valores similares a `ai_job_statuses` (`pending`, `processing/running`, `completed`, `failed`) — evaluar si unificarlos en un solo catálogo `job_statuses` o mantenerlos separados por dominio
- `log_levels` es compartible en el futuro con cualquier sistema de logs del proyecto
- Depende de: HU-016 (Reemplazar ENUMs con Tablas — patrón base), HU-030 (UUID), HU-068, HU-069
