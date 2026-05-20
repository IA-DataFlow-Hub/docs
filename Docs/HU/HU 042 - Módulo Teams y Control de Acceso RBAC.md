# HU-042 — Módulo de Equipos y Control de Acceso (RBAC)

## Asignación de Tablas

`teams` · `team_roles` · `team_role_permissions` · `user_team_roles` · `role_templates` · `permissions` · `role_template_permissions`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Equipos y RBAC siguiendo Clean Architecture,  
**Para** crear equipos (estándar y personales), definir roles con permisos, asignar usuarios a equipos con sus roles y gestionar la herencia desde plantillas de roles globales.

**Dependencia:** Requiere HU-041 (Users) para la creación del equipo personal post-registro.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/teams/
├── teams.module.ts
├── domain/
│   ├── entities/
│   │   ├── team.entity.ts
│   │   ├── team-role.entity.ts
│   │   └── permission.entity.ts
│   └── repositories/
│       ├── team.repository.interface.ts
│       └── team-role.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── create-team.dto.ts
│   │   ├── create-team-role.dto.ts
│   │   ├── assign-user-role.dto.ts
│   │   ├── team-response.dto.ts
│   │   └── team-role-response.dto.ts
│   ├── use-cases/
│   │   ├── create-team.use-case.ts
│   │   ├── create-personal-team.use-case.ts
│   │   ├── create-team-role.use-case.ts
│   │   ├── assign-user-to-team.use-case.ts
│   │   ├── remove-user-from-team.use-case.ts
│   │   └── sync-role-from-template.use-case.ts
│   └── facades/
│       └── teams.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── teams.controller.ts
    └── persistence/
        ├── prisma-team.repository.ts
        ├── prisma-team-role.repository.ts
        └── mappers/
            ├── team.mapper.ts
            └── team-role.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Creación automática de equipo personal post-registro

**Dado** que un nuevo usuario acaba de completar el registro  
**Cuando** `CreatePersonalTeamUseCase` es invocado (evento post-registro desde HU-040)  
**Entonces:**
- Crea un `Team` con `is_personal_group = true` y `group_type = 'personal'` usando el nombre completo del usuario como `team_name`.
- Crea un `TeamRole` con `role_name = 'owner'`, `is_default = true`, basado en `template_id = 2` (admin).
- Llama a `SyncRoleFromTemplateUseCase` para poblar `team_role_permissions` desde la plantilla.
- Inserta en `user_team_roles` asignando al usuario ese rol.
- Todo dentro de una transacción `$transaction` de Prisma para garantizar atomicidad.

### Escenario 2 — Sincronización de permisos desde plantilla global

**Dado** que se crea un `TeamRole` con `template_id` definido (ej: `template_id = 1` user)  
**Cuando** `SyncRoleFromTemplateUseCase` ejecuta  
**Entonces:**
- Consulta todos los permisos de `role_template_permissions` para el `id_role_template`.
- Inserta en `team_role_permissions` solo los permisos que no existan aún (la constraint `uk_team_role_perm` previene duplicados).
- Retorna el listado de permisos sincronizados.

### Escenario 3 — Verificación de permisos efectivos (AuthZ)

**Dado** que el `RolesGuard` (HU-036) necesita verificar si un usuario tiene el permiso `phase_execute` en un proyecto  
**Cuando** se consultan los permisos efectivos del usuario  
**Entonces:**
- Si existe `user_project_roles` para ese proyecto, resuelve el `team_role` desde ahí (tiene prioridad sobre el rol de equipo).
- Si no existe `user_project_roles`, usa el `team_role` de `user_team_roles` para el equipo del proyecto.
- Retorna el listado de `permission_name` activos para que el `RolesGuard` evalúe el acceso.

### Escenario 4 — Restricción de roles únicos por equipo

**Dado** que `CreateTeamRoleDto` incluye `role_name = 'editor'` para un `id_team` que ya tiene ese rol  
**Cuando** `CreateTeamRoleUseCase` intenta persistir  
**Entonces:**
- La capa de repositorio captura la violación de `uk_team_role (id_team, role_name)` y la traduce a `DuplicateTeamRoleException` con código `TEAM_ROLE_CONFLICT`.
- El controlador retorna HTTP 409.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/teams` | Crear equipo estándar |
| GET | `/teams` | Listar equipos del usuario autenticado |
| GET | `/teams/:id` | Detalle de equipo |
| PATCH | `/teams/:id` | Actualizar equipo |
| DELETE | `/teams/:id` | Soft-delete de equipo |
| POST | `/teams/:id/roles` | Crear rol en equipo |
| POST | `/teams/:id/members` | Asignar usuario con rol |
| DELETE | `/teams/:id/members/:userId` | Remover usuario del equipo |
| GET | `/teams/:id/members` | Listar miembros con sus roles |

---

## Notas Técnicas

- `TeamRepositoryInterface` y `TeamRoleRepositoryInterface` son exportadas para ser consumidas por HU-043 (Projects) y HU-047 (AI Jobs) en la verificación de permisos.
- El catálogo `role_templates` y `permissions` es de solo lectura desde este módulo (semilla ya cargada en la migración). No se exponen endpoints de escritura para estos catálogos.
- El `RolesGuard` de HU-036 debe invocar al `TeamsFacade` para resolver permisos efectivos.
