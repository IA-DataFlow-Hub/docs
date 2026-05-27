# HU 070 - Desacoplar ETL Templates de Proyectos con Tabla Intermedia

> Generado el 26 de mayo de 2026
> **Asignado a:** María, Sebastián, Felipe

---

## HU-070: Desacoplar etl_templates de proyectos mediante tabla intermedia con archivos

**Como** desarrollador del sistema,
**quiero** que un template ETL no esté atado a un único proyecto sino que pueda aplicarse a múltiples proyectos y múltiples archivos mediante una tabla intermedia,
**para** que los templates sean reutilizables entre proyectos y se pueda rastrear exactamente cuándo se aplicó un template, en qué proyecto y sobre qué archivos específicos.

### Criterios de Aceptación

- La columna `id_project` debe eliminarse de `etl_templates` — un template no pertenece a ningún proyecto en particular
- El sistema debe tener una tabla `etl_template_assignments` que registre cada aplicación de un template a un proyecto:
  - `id_assignment CHAR(36) PK`
  - `id_template CHAR(36) NOT NULL` → FK `etl_templates`
  - `id_project CHAR(36) NOT NULL` → FK `projects`
  - `assigned_by CHAR(36) NULL` → FK `users`
  - `assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
  - `notes TEXT NULL`
- El sistema debe tener una tabla `etl_template_assignment_files` que registre los archivos sobre los que se aplica cada asignación:
  - `id_assignment_file CHAR(36) PK`
  - `id_assignment CHAR(36) NOT NULL` → FK `etl_template_assignments`
  - `id_file CHAR(36) NOT NULL` → FK `files`
  - `applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP`
  - `status ENUM('pending','processing','completed','failed') DEFAULT 'pending'`
  - `result_notes TEXT NULL`
  - UNIQUE KEY `(id_assignment, id_file)` — no duplicar el mismo archivo en la misma asignación
- Un mismo template puede aparecer en múltiples registros de `etl_template_assignments` (uno por proyecto donde se aplica)
- Una misma asignación puede tener múltiples archivos en `etl_template_assignment_files`
- El modelo Prisma (`schema.prisma`) debe reflejar ambas relaciones nuevas y eliminar `id_project` de `EtlTemplate`
- Los seeds y datos existentes en `etl_templates` no deben verse afectados — solo se elimina la columna `id_project` (que era NULL en todos los templates de sistema)

### Notas

- Orden de migración SQL: (1) crear `etl_template_assignments`, (2) crear `etl_template_assignment_files`, (3) eliminar columna `id_project` de `etl_templates`, (4) eliminar FK `fk_etl_templates_project`
- `etl_executions` ya tiene `id_project` e `id_generated_table` para rastrear la ejecución real — `etl_template_assignments` es el nivel previo: "este template está disponible/asignado a este proyecto sobre estos archivos"
- Si se quiere saber el historial completo: `etl_template_assignments` → qué templates usa el proyecto; `etl_template_assignment_files` → sobre qué archivos; `etl_executions` → resultado de cada ejecución real
- Depende de: HU-027 (Gestión de Templates ETL), HU-021 (Proyecto, Archivos)
