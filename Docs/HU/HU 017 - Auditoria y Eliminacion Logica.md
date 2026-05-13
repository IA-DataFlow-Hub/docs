# HU-017: Implementar Auditoría Completa y Eliminación Lógica

## Historia de Usuario
**Como** administrador del sistema IA-DataFlow,  
**Quiero** implementar auditoría completa y eliminación lógica en todas las tablas de la base de datos,  
**Para** rastrear todos los cambios (creación, actualización, eliminación), mantener integridad histórica de datos y permitir recuperación de registros eliminados.

## Criterios de Aceptación
- Todas las tablas deben tener eliminación lógica con campos `deleted_at` y `deleted_by`.
- Todas las tablas deben rastrear quién creó y actualizó registros con `created_by` y `updated_by`.
- Para tablas con estados (que serán FK después de HU-016), agregar `status_changed_at` para rastrear cambios de estado.
- Crear tabla `audits` para registro detallado de cambios.
- La lógica de aplicación debe poblar los campos de auditoría (created_by, updated_by, etc.) al crear/actualizar registros.
- Para eliminación lógica, la aplicación debe setear deleted_at y deleted_by en lugar de DELETE físico.
- No perder datos existentes durante migración.
- La tabla `audits` debe registrar cambios en JSON para data_old y data_new.
- Todas las tablas nuevas que se creen en el futuro deben incluir estos campos de auditoría.

## Análisis de Tablas y Cambios Requeridos
Se requiere modificar todas las tablas existentes para agregar campos de auditoría. Las tablas con estados (ENUMs que se convertirán en FK) también necesitan `status_changed_at`.

### Campos a Agregar por Tabla:
- **created_by** INT NULL (FK a users.id_user)
- **updated_by** INT NULL (FK a users.id_user)
- **deleted_at** TIMESTAMP NULL
- **deleted_by** INT NULL (FK a users.id_user)
- Para tablas con status: **status_changed_at** TIMESTAMP NULL

### Tablas a Modificar:
1. **users**: Agregar updated_by, deleted_at, deleted_by (ya tiene created_at, pero agregar created_by si no)
2. **credentials**: Agregar created_by, updated_by, deleted_at, deleted_by
3. **user_preferences**: Agregar created_by, updated_by, deleted_at, deleted_by
4. **roles**: Agregar created_by, updated_by, deleted_at, deleted_by
5. **permissions**: Agregar created_by, updated_by, deleted_at, deleted_by
6. **user_roles**: Agregar created_by, updated_by, deleted_at, deleted_by
7. **role_permissions**: Agregar created_by, updated_by, deleted_at, deleted_by
8. **teams**: Agregar updated_by, deleted_at, deleted_by (ya tiene created_by)
9. **team_members**: Agregar created_by, updated_by, deleted_at, deleted_by
10. **workflow_phases**: Agregar created_by, updated_by, deleted_at, deleted_by
11. **ai_engines**: Agregar created_by, updated_by, deleted_at, deleted_by
12. **projects**: Agregar updated_by, deleted_at, deleted_by, status_changed_at (ya tiene created_at, pero agregar created_by)
13. **project_phases**: Agregar created_by, updated_by, deleted_at, deleted_by, status_changed_at
14. **files**: Agregar created_by, updated_by, deleted_at, deleted_by
15. **file_versions**: Agregar updated_by, deleted_at, deleted_by (ya tiene created_by)
16. **ai_jobs**: Agregar created_by, updated_by, deleted_at, deleted_by, status_changed_at
17. **ai_results**: Agregar created_by, updated_by, deleted_at, deleted_by
18. **tasks**: Agregar updated_by, deleted_at, deleted_by, status_changed_at (ya tiene created_at, created_by)
19. **conversations**: Agregar updated_by, deleted_at, deleted_by (ya tiene created_at, created_by)
20. **messages**: Agregar created_by, updated_by, deleted_at, deleted_by
21. **audit_logs**: Ya es tabla de auditoría, agregar deleted_at, deleted_by si aplica
22. **sessions**: Agregar created_by, updated_by, deleted_at, deleted_by

### Tabla de Auditoría
Crear nueva tabla `audits` para registro detallado:

```sql
CREATE TABLE audits (
    id_audit INT AUTO_INCREMENT PRIMARY KEY,
    table_id INT NOT NULL,  -- ID del registro en la tabla afectada
    table_name VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,  -- INSERT, UPDATE, DELETE
    data_old JSON NULL,
    data_new JSON NULL,
    user_id INT NULL,  -- Usuario que realizó la acción
    deleted_at TIMESTAMP NULL,
    reverted BOOLEAN NOT NULL DEFAULT FALSE,
    reverted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_action (action),
    INDEX idx_table_name (table_name),
    INDEX idx_user_id (user_id),

    CONSTRAINT fk_audits_user
        FOREIGN KEY (user_id)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);
```

## Riesgos y Consideraciones
- **Rendimiento**: Los campos adicionales y la tabla audits pueden impactar queries; optimizar con índices.
- **Migración**: Poblar created_by con valores existentes donde sea posible (ej. created_by = id_user en projects).
- **Lógica de Aplicación**: Implementar en el código para insertar registros en audits al realizar cambios.
- **Privacidad**: Asegurar que data_old/data_new no exponga datos sensibles.
- **Eliminación Lógica**: Queries deben filtrar deleted_at IS NULL.
- **Cambio de Estado**: Actualizar status_changed_at solo cuando el status cambia.

## Tareas Técnicas
1. Crear script de migración para agregar campos a todas las tablas.
2. Crear tabla audits.
3. Actualizar lógica de aplicación para poblar campos de auditoría y manejar eliminación lógica.
4. Actualizar queries de aplicación para usar eliminación lógica.
5. Probar integridad y rendimiento.
6. Documentar cambios en schema.prisma.

## Dependencias
- Depende de HU-016 para conversión de ENUMs a FK, ya que status_changed_at se refiere a esos campos.

## Prioridad
Alta - Auditoría es crítica para compliance y debugging.