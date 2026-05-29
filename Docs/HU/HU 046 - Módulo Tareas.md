# HU-046 — Módulo de Tareas

> **Prioridad:** 🟠 High / Alta — Crítica

**Prioridad:** Alta

## Asignación de Tablas

`tasks` · `task_statuses` · `task_priorities`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Tareas siguiendo Clean Architecture,  
**Para** gestionar el trabajo asignable a usuarios dentro de proyectos y fases, con control de estados, prioridades, fechas límite y auditoría completa de cambios.

**Dependencia:** Requiere HU-043 (Projects) para verificar membresía al proyecto.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/tasks/
├── tasks.module.ts
├── domain/
│   ├── entities/
│   │   └── task.entity.ts
│   └── repositories/
│       └── task.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── create-task.dto.ts
│   │   ├── update-task.dto.ts
│   │   ├── change-task-status.dto.ts
│   │   └── task-response.dto.ts
│   ├── use-cases/
│   │   ├── create-task.use-case.ts
│   │   ├── update-task.use-case.ts
│   │   ├── change-task-status.use-case.ts
│   │   ├── assign-task.use-case.ts
│   │   └── soft-delete-task.use-case.ts
│   └── facades/
│       └── tasks.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── tasks.controller.ts
    └── persistence/
        ├── prisma-task.repository.ts
        └── mappers/
            └── task.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Creación de tarea con defaults de dominio

**Dado** que se recibe `CreateTaskDto` con `title`, `id_project` e `id_phase` opcional  
**Cuando** `CreateTaskUseCase` ejecuta  
**Entonces:**
- La entidad `Task` aplica defaults: `id_task_status = 1` (pending) e `id_task_priority = 2` (medium) si no se especifican.
- Verifica que el usuario tenga acceso al proyecto (consulta `ProjectsFacade`).
- Persiste en `tasks` con `created_by` del usuario autenticado.
- El mapper resuelve los catálogos `task_statuses` y `task_priorities` para el `TaskResponseDto`.

### Escenario 2 — Cambio de estado con validación de transiciones

**Dado** que `ChangeTaskStatusDto` solicita pasar una tarea de `completed` a `in_progress`  
**Cuando** `ChangeTaskStatusUseCase` evalúa la transición  
**Entonces:**
- La entidad `Task` define las transiciones válidas:
  - `pending` → `in_progress`, `cancelled`
  - `in_progress` → `completed`, `cancelled`
  - `completed` → *(ninguna)*
  - `cancelled` → *(ninguna)*
- Si la transición no es válida, lanza `InvalidTaskTransitionException` con el estado actual y el solicitado.
- Si es válida, actualiza `id_task_status`, `status_changed_at = now()` y `updated_by`.

### Escenario 3 — Filtrado compuesto de tareas

**Dado** que el frontend envía query params `?id_project=5&id_phase=2&id_task_status=1&id_task_priority=3`  
**Cuando** el repositorio construye la query Prisma  
**Entonces:**
- Aplica todos los filtros recibidos como condiciones AND con `WHERE deleted_at IS NULL`.
- Soporta paginación estándar (`page`, `limit`) y ordenación por `due_date ASC` por defecto.
- El mapper resuelve los catálogos en el DTO de respuesta (nombres en lugar de IDs).

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/projects/:projectId/tasks` | Crear tarea |
| GET | `/projects/:projectId/tasks` | Listar tareas (con filtros) |
| GET | `/tasks/:id` | Detalle de tarea |
| PATCH | `/tasks/:id` | Actualizar datos de tarea |
| PATCH | `/tasks/:id/status` | Cambiar estado |
| PATCH | `/tasks/:id/assign` | Asignar a usuario |
| DELETE | `/tasks/:id` | Soft-delete |

---

## Notas Técnicas

- Los catálogos `task_statuses` y `task_priorities` son de solo lectura (sembrados en migración). Se expone `GET /tasks/catalogs` con ambos listados para que el frontend los use en los formularios.
- `TaskRepositoryInterface` es exportada y consumida por HU-047 (AI Jobs) para vincular un `ai_job` a una tarea específica (`id_task` en `ai_jobs`).
