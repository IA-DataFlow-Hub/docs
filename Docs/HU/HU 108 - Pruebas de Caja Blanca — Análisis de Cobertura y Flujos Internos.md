# HU 108 - Pruebas de Caja Blanca — Análisis de Cobertura y Flujos Internos

> **Asignado:** @POHLMAN1 — Pohlman Cuartas

> Generado el 29 de mayo de 2026
> **Asignado a:** @POHLMAN1 — Pohlman Cuartas
> **Prioridad:** Alta
> **Depende de:** HU-106

---

## HU-108: Pruebas de caja blanca — análisis de cobertura y flujos internos del código

**Como** responsable de calidad del proyecto,
**quiero** revisar el código interno de los use-cases y entidades para identificar caminos de ejecución, condiciones de borde y ramas no cubiertas por los tests existentes,
**para** garantizar que la lógica de negocio crítica tiene pruebas que validan cada rama posible.

### Criterios de Aceptación

#### Análisis de flujos por módulo prioritario
Para cada uno de estos módulos, leer el código de los use-cases y mapear sus ramas:

| Módulo | Use-cases críticos a analizar |
|--------|-------------------------------|
| Auth | `login`, `register`, `change-password`, `refresh-token` |
| Teams | `create-team`, `assign-user-to-team`, `sync-role-from-template` |
| Projects | `create-project`, `advance-project-phase`, `archive-project` |
| Tasks | `create-task`, `change-task-status` (máquina de estados) |
| AI Jobs | `trigger-ai-job`, `complete-ai-job`, `fail-ai-job` (lógica de retry) |
| Audit | `revert-change` |

#### Por cada use-case identificar y documentar
- Todas las ramas `if/else` y su condición
- Excepciones lanzadas y cuándo se disparan
- Condiciones de borde (ej: `canRetry()` en `ai-job.entity.ts`, transiciones de estado en `task.entity.ts`)
- Qué ramas YA tienen test en los `.spec.ts` existentes
- Qué ramas NO tienen test

#### Escribir tests faltantes para ramas críticas
- Para cada rama sin cobertura que sea **crítica para el negocio**, escribir el test unitario faltante en el `.spec.ts` correspondiente
- Priorizar: excepciones de dominio, máquinas de estado (Tasks, AiJobs), validaciones de permisos (Teams RBAC)
- Mínimo 3 tests nuevos agregados en módulos con baja cobertura

#### Reporte
- Crear `docs/QA/reporte-caja-blanca.md` con: use-case | ramas totales | ramas con test | ramas sin test | tests nuevos agregados

### Entregables
- `docs/QA/reporte-caja-blanca.md`
- Commits con tests nuevos en los `.spec.ts` existentes

### Notas
- Los archivos de entidad con lógica compleja: `ai-job.entity.ts` (retry, backoff), `task.entity.ts` (state machine)
- No crear nuevos archivos spec — agregar casos al spec correspondiente que ya existe
- Foco en lógica de dominio, no en infraestructura (no testear Prisma directamente)
