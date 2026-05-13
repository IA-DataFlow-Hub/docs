# HU-016: Reemplazar ENUMs con Tablas de Catálogo para Flexibilidad

## Historia de Usuario
**Como** administrador de la base de datos del sistema IA-DataFlow,  
**Quiero** reemplazar todos los campos ENUM con tablas de catálogo separadas,  
**Para** permitir agregar nuevos valores de estado/tipo sin modificar el esquema de la base de datos, reduciendo riesgos de inflexibilidad y facilitando mantenimientos futuros.

## Criterios de Aceptación
- Todos los campos ENUM identificados deben ser reemplazados por claves foráneas a tablas de catálogo.
- Las tablas de catálogo deben incluir al menos los valores actuales como datos iniciales.
- Las migraciones deben preservar los datos existentes.
- El esquema debe ser compatible con MySQL y Prisma (si se usa).
- No debe haber pérdida de datos durante la migración.

## Análisis de ENUMs Actuales
Se han identificado los siguientes campos ENUM en el esquema actual que representan riesgos de inflexibilidad:

1. **users.status**: ENUM('active','inactive','suspended') DEFAULT 'active'
2. **user_preferences.theme**: ENUM('dark','light','system') DEFAULT 'dark'
3. **team_members.member_role**: ENUM('leader','analyst','designer','supervisor','developer') DEFAULT 'analyst'
4. **ai_engines.engine_type**: ENUM('local','cloud') NOT NULL
5. **projects.privacy_level**: ENUM('public','team','private') DEFAULT 'team'
6. **projects.status**: ENUM('active','paused','completed','archived') DEFAULT 'active'
7. **project_phases.status**: ENUM('in_progress','completed','skipped') DEFAULT 'in_progress'
8. **ai_jobs.status**: ENUM('pending','processing','completed','failed') DEFAULT 'pending'
9. **ai_results.result_type**: ENUM('summary','transformed_file','table','chart','suggestion','error_report') DEFAULT 'summary'
10. **tasks.status**: ENUM('pending','in_progress','completed','cancelled') DEFAULT 'pending'
11. **tasks.priority**: ENUM('low','medium','high','critical') DEFAULT 'medium'
12. **messages.sender_type**: ENUM('user','ai_local','ai_cloud','system') NOT NULL DEFAULT 'user'

## Cambios Requeridos
Para cada ENUM, se debe:

1. Crear una nueva tabla de catálogo con estructura:
   ```sql
   CREATE TABLE [entity]_statuses (
       id_[entity]_status INT AUTO_INCREMENT PRIMARY KEY,
       status_name VARCHAR(100) NOT NULL UNIQUE,
       description TEXT,
       is_active BOOLEAN DEFAULT TRUE,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );
   ```
   (Ajustar el nombre según el tipo: statuses, types, roles, etc.)

2. Insertar los valores actuales como datos iniciales.

3. Cambiar la columna en la tabla original de ENUM a INT, agregando FOREIGN KEY.

4. Actualizar las consultas, inserts y lógica de aplicación para usar los IDs en lugar de strings.

5. Crear índices apropiados.

6. Actualizar el archivo schema.prisma si existe.

## Tablas de Catálogo a Crear
- user_statuses
- user_themes
- team_member_roles
- ai_engine_types
- project_privacy_levels
- project_statuses
- project_phase_statuses
- ai_job_statuses
- ai_result_types
- task_statuses
- task_priorities
- message_sender_types

## Riesgos y Consideraciones
- Migración de datos: Asegurar que los valores existentes se mapeen correctamente a los nuevos IDs.
- Aplicación: Actualizar todo el código que usa estos ENUMs para trabajar con IDs y joins.
- Rendimiento: Los joins adicionales pueden afectar queries; considerar índices.
- Validación: Asegurar que solo se usen valores activos en las tablas de catálogo.

## Tareas Técnicas
1. Crear script de migración SQL para agregar tablas de catálogo.
2. Migrar datos existentes.
3. Modificar esquema de tablas existentes.
4. Actualizar constraints y índices.
5. Probar integridad referencial.
6. Actualizar documentación del esquema.

## Prioridad
Alta - Esta mejora previene problemas futuros de escalabilidad y mantenibilidad.