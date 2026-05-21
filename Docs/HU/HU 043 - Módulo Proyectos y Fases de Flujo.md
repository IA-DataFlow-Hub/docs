# HU-043 — Módulo de Proyectos y Fases de Flujo

## Asignación de Tablas

`projects` · `project_phases` · `workflow_phases` · `project_statuses` · `project_privacy_levels` · `project_phase_statuses` · `user_project_roles`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Proyectos siguiendo Clean Architecture,  
**Para** crear espacios de trabajo de datos, gestionar el flujo BPM (Diseñar → Ejecutar → Supervisar → Optimizar), controlar niveles de privacidad y registrar el historial de cambios de estado y fase.

**Dependencia:** Requiere HU-042 (Teams) para asociar proyectos a equipos y verificar permisos.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/projects/
├── projects.module.ts
├── domain/
│   ├── entities/
│   │   ├── project.entity.ts
│   │   └── project-phase.entity.ts
│   └── repositories/
│       └── project.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── create-project.dto.ts
│   │   ├── update-project.dto.ts
│   │   ├── advance-phase.dto.ts
│   │   ├── assign-project-role.dto.ts
│   │   ├── project-response.dto.ts
│   │   └── project-phase-response.dto.ts
│   ├── use-cases/
│   │   ├── create-project.use-case.ts
│   │   ├── update-project.use-case.ts
│   │   ├── archive-project.use-case.ts
│   │   ├── advance-project-phase.use-case.ts
│   │   └── assign-project-role.use-case.ts
│   └── facades/
│       └── projects.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── projects.controller.ts
    └── persistence/
        ├── prisma-project.repository.ts
        └── mappers/
            └── project.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Creación de proyecto con privacidad y fase inicial

**Dado** que se recibe `CreateProjectDto` con `id_project_privacy_level = 3` (private) y `id_team` válido  
**Cuando** `CreateProjectUseCase` ejecuta  
**Entonces:**
- Verifica que el usuario autenticado tenga el permiso `manage_teams` o sea miembro del equipo indicado.
- Crea el `Project` con `id_project_status = 1` (active) y `current_phase = 1` (Diseñar).
- Dentro de la misma transacción, crea el primer `ProjectPhase` con `id_phase = 1` e `id_project_phase_status = 1` (in_progress).
- La entidad `Project` expone `isPrivate(): boolean` que retorna `true` cuando `id_project_privacy_level === 3`, método consumido por otros módulos para restringir motores cloud.

### Escenario 2 — Avance de fase BPM con validación de secuencia

**Dado** que un proyecto está en fase 1 (Diseñar) y se recibe `AdvancePhaseDto`  
**Cuando** `AdvanceProjectPhaseUseCase` ejecuta  
**Entonces:**
- Verifica que la `ProjectPhase` actual tenga `id_project_phase_status = 1` (in_progress); si ya está `completed`, lanza `PhaseAlreadyCompletedException`.
- Dentro de una transacción:
  1. Actualiza la `ProjectPhase` actual: `completed_at = now()`, `id_project_phase_status = 2` (completed).
  2. Crea la nueva `ProjectPhase` con la fase siguiente (`id_phase + 1`) y `id_project_phase_status = 1`.
  3. Actualiza `projects.current_phase` al nuevo `id_phase`.
- Si el proyecto ya está en la fase 4 (Optimizar) y se intenta avanzar, lanza `NoMorePhasesException`.

### Escenario 3 — Archivado de proyecto

**Dado** que el usuario con permiso `manage_teams` solicita archivar un proyecto activo  
**Cuando** `ArchiveProjectUseCase` ejecuta  
**Entonces:**
- Actualiza `id_project_status = 4` (archived) y `status_changed_at = now()`.
- No aplica soft-delete; el proyecto sigue visible pero en estado archivado.
- Lanza `ProjectAlreadyArchivedException` si el estado actual ya es `archived`.

### Escenario 4 — Asignación de rol específico por proyecto (override)

**Dado** que un usuario tiene rol `user` en el equipo pero necesita rol `supervisor` solo en un proyecto específico  
**Cuando** `AssignProjectRoleUseCase` recibe `AssignProjectRoleDto` con `id_user`, `id_project` e `id_team_role`  
**Entonces:**
- Verifica que el `TeamRole` pertenezca al equipo del proyecto.
- Hace UPSERT en `user_project_roles` usando `uk_user_project_role (id_user, id_project)`.
- Este rol tiene prioridad sobre `user_team_roles` al resolver permisos (según HU-042).

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/projects` | Crear proyecto |
| GET | `/projects` | Listar proyectos del usuario |
| GET | `/projects/:id` | Detalle de proyecto con fase actual |
| PATCH | `/projects/:id` | Actualizar proyecto |
| POST | `/projects/:id/advance-phase` | Avanzar a la siguiente fase |
| POST | `/projects/:id/archive` | Archivar proyecto |
| POST | `/projects/:id/roles` | Asignar rol específico en proyecto |
| GET | `/projects/:id/phases` | Historial de fases del proyecto |

---

## Notas Técnicas

- `ProjectRepositoryInterface` es exportada y consumida por HU-044 (Files), HU-045 (Conversations), HU-046 (Tasks), HU-047 (AI Jobs), HU-048 (ETL) y HU-050 (Notifications).
- `ProjectsFacade.isProjectPrivate(id_project)` es el método público que otros módulos invocan para verificar la privacidad sin acoplar al repositorio directamente.
- Los catálogos `workflow_phases`, `project_statuses`, `project_privacy_levels` y `project_phase_statuses` son de solo lectura (sembrados en migración). Se expone `GET /projects/phases/catalog` como endpoint de consulta para el frontend.
