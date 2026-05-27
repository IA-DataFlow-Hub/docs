# HU 069 - Migración group_type de VARCHAR a Catálogo Escalable

> Generado el 26 de mayo de 2026
> **Asignado a:** María, Sebastián, Felipe

---

## HU-069: Reemplazar VARCHAR group_type por tabla catálogo en teams

**Como** desarrollador del sistema,
**quiero** que el tipo de grupo (`group_type`) esté definido en una tabla catálogo en lugar de un VARCHAR libre,
**para** tener control explícito sobre los tipos válidos, permitir agregar nuevos tipos sin riesgo de inconsistencias por strings arbitrarios, y mantener el patrón de catálogos del esquema v4.

### Criterios de Aceptación

- El sistema debe tener una tabla catálogo `team_group_types` con `id_team_group_type INT AUTO_INCREMENT PRIMARY KEY`, `type_name VARCHAR(100) NOT NULL UNIQUE`, `description TEXT` e `is_active BOOLEAN DEFAULT TRUE`
- La tabla debe incluir seeds con los 2 tipos iniciales: `standard` (Equipo colaborativo estándar) y `personal` (Grupo personal de usuario individual)
- La columna `group_type VARCHAR(50)` en `teams` debe cambiar a `id_team_group_type INT NOT NULL DEFAULT 1`, con FK hacia `team_group_types`
- La migración debe mapear los valores VARCHAR existentes (`'standard'` → `1`, `'personal'` → `2`) antes de eliminar la columna original
- El modelo Prisma (`schema.prisma`) debe reflejar la nueva relación: `Team` → `TeamGroupType`
- Agregar nuevos tipos de grupo (ej. `organization`, `department`, `external`) no debe requerir `ALTER TABLE` — solo un `INSERT` en `team_group_types`

### Notas

- Sigue el patrón existente del esquema v4: catálogos con `INT AUTO_INCREMENT` (igual que `user_statuses`, `task_statuses`, etc.)
- HU-020 ya anticipó la escalabilidad usando VARCHAR en lugar de ENUM — esta HU formaliza ese catálogo
- Orden de migración SQL: (1) crear `team_group_types`, (2) insertar seeds, (3) agregar columna `id_team_group_type` en `teams`, (4) `UPDATE` para mapear VARCHAR → INT, (5) eliminar columna `group_type` VARCHAR, (6) agregar FK constraint
- IDs sugeridos: `1=standard`, `2=personal`
- La lógica de negocio que filtra `group_type = 'personal'` (ej. al crear grupo personal en registro de usuario) debe actualizarse para filtrar por `id_team_group_type = 2`
- Depende de: HU-020 (Roles Equipo Proyecto Personal), HU-030 (Migración UUID)
