# HU 068 - Migración value_type de ENUM a Catálogo Escalable

> Generado el 26 de mayo de 2026
> **Asignado a:** María, Sebastián, Felipe

---

## HU-068: Reemplazar ENUM value_type por tabla catálogo en configuration_keys

**Como** desarrollador del sistema,
**quiero** que el tipo de valor de configuración (`value_type`) esté definido en una tabla catálogo en lugar de un ENUM,
**para** poder agregar nuevos tipos de valor en el futuro sin necesidad de alterar el esquema de la base de datos.

### Criterios de Aceptación

- El sistema debe tener una tabla catálogo `config_value_types` con `id_config_value_type INT AUTO_INCREMENT PRIMARY KEY`, `type_name VARCHAR(100) NOT NULL UNIQUE`, `description TEXT` e `is_active BOOLEAN DEFAULT TRUE`
- La tabla debe incluir seeds con los 6 tipos iniciales: `string`, `boolean`, `number`, `json`, `single_select`, `multi_select`
- La columna `value_type` en `configuration_keys` debe cambiar de `ENUM('string','boolean','number','json')` a `id_config_value_type INT NOT NULL`, con FK hacia `config_value_types`
- El sistema debe mantener los datos existentes en `configuration_keys` — la migración debe mapear los valores ENUM actuales a sus IDs correspondientes en el catálogo antes de eliminar la columna ENUM
- El modelo Prisma (`schema.prisma`) debe reflejar la nueva relación: `ConfigurationKey` → `ConfigValueType`
- Agregar nuevos tipos de valor no debe requerir `ALTER TABLE` ni cambio de ENUM — solo un `INSERT` en `config_value_types`

### Notas

- Sigue el patrón existente del esquema v4: catálogos con `INT AUTO_INCREMENT` (igual que `user_statuses`, `task_statuses`, etc.)
- La migración SQL debe ejecutarse en orden: (1) crear `config_value_types`, (2) insertar seeds, (3) agregar columna `id_config_value_type` en `configuration_keys`, (4) hacer `UPDATE` para poblar la nueva columna desde el ENUM, (5) eliminar columna `value_type` ENUM, (6) agregar FK constraint
- Tipos iniciales y sus IDs sugeridos: `1=string`, `2=boolean`, `3=number`, `4=json`, `5=single_select`, `6=multi_select`
- `single_select` y `multi_select` permiten definir opciones válidas en `validation_rules JSON` de la misma tabla
- Depende de: HU-019 (Sistema de Configuración Flexible), HU-030 (Migración UUID)
