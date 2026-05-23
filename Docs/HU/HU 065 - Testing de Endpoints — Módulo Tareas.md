# HU-065 — Testing de Endpoints — Módulo Tareas

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

## Archivos Principales

`apps/api/src/modules/tasks/` · `apps/api/test/tasks/` · `apps/api/src/modules/tasks/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Tareas (HU-046),  
**Para** garantizar que el CRUD de tareas, la asignación a miembros, los estados del flujo y los filtros funcionan correctamente y que solo los miembros del proyecto pueden operar sobre sus tareas.

**Dependencia:** Requiere HU-046 implementada. Requiere HU-042 (Teams/RBAC) para validar permisos por proyecto.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/tasks/
├── application/use-cases/
│   ├── create-task.use-case.spec.ts
│   ├── update-task.use-case.spec.ts
│   ├── assign-task.use-case.spec.ts
│   └── advance-task-status.use-case.spec.ts
└── infrastructure/controllers/
    └── tasks.controller.spec.ts

apps/api/test/tasks/
├── tasks.integration.spec.ts
├── tasks.status-flow.spec.ts              ← máquina de estados
└── tasks.e2e.spec.ts
```

---

## Pruebas Unitarias

### `create-task.use-case.spec.ts`

```typescript
describe('CreateTaskUseCase', () => {
  it('crea tarea con título, descripción y fecha límite', async () => {
    const result = await useCase.execute({
      projectId: 'p-1', title: 'Implementar login', createdBy: 'u-1',
      dueDate: '2026-12-31', priority: 'high'
    })
    expect(result.title).toBe('Implementar login')
    expect(result.status).toBe('todo')  // estado inicial siempre todo
    expect(result.priority).toBe('high')
  })

  it('estado inicial es siempre "todo" independientemente del input', async () => {
    const result = await useCase.execute({ ..., status: 'done' } as any)
    expect(result.status).toBe('todo')
  })

  it('lanza ForbiddenException si creador no pertenece al proyecto', async () => { ... })
  it('lanza BadRequestException si título vacío', async () => { ... })
  it('lanza BadRequestException si dueDate es fecha pasada', async () => { ... })
})
```

### `advance-task-status.use-case.spec.ts`

```typescript
describe('AdvanceTaskStatusUseCase', () => {
  // Flujo: todo → in_progress → in_review → done
  it('avanza de todo a in_progress', async () => { ... })
  it('avanza de in_progress a in_review', async () => { ... })
  it('avanza de in_review a done', async () => { ... })
  it('lanza ConflictException si tarea ya está en done', async () => { ... })
  it('permite mover a cancelled desde cualquier estado excepto done', async () => { ... })
  it('lanza ForbiddenException si usuario no está asignado ni es admin del proyecto', async () => { ... })
})
```

### `assign-task.use-case.spec.ts`

```typescript
describe('AssignTaskUseCase', () => {
  it('asigna tarea a miembro del proyecto', async () => { ... })
  it('lanza BadRequestException si assignee no es miembro del proyecto', async () => { ... })
  it('permite reasignar tarea ya asignada', async () => { ... })
  it('permite desasignar (assigneeId: null)', async () => { ... })
})
```

---

## Pruebas de Integración

### `tasks.integration.spec.ts`

```typescript
describe('Tasks API — Integración', () => {
  // POST /api/projects/:projectId/tasks
  describe('POST /api/projects/:projectId/tasks', () => {
    it('201 — crea tarea con estado inicial todo', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/projects/${seedProject.id}/tasks`)
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'Nueva Tarea', priority: 'medium', dueDate: '2026-12-31' })
      expect(res.status).toBe(201)
      expect(res.body.data.status).toBe('todo')
    })
    it('400 — título vacío', async () => { ... })
    it('400 — dueDate en el pasado', async () => { ... })
    it('403 — usuario externo al proyecto', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // GET /api/projects/:projectId/tasks
  describe('GET /api/projects/:projectId/tasks', () => {
    it('200 — lista tareas del proyecto con paginación', async () => { ... })
    it('200 — filtra por status=in_progress', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/projects/${seedProject.id}/tasks?status=in_progress`)
        .set('Authorization', `Bearer ${token}`)
      res.body.data.forEach((t: any) => expect(t.status).toBe('in_progress'))
    })
    it('200 — filtra por assigneeId', async () => { ... })
    it('200 — filtra por priority=high', async () => { ... })
    it('403 — externo al proyecto', async () => { ... })
  })

  // PATCH /api/tasks/:id
  describe('PATCH /api/tasks/:id', () => {
    it('200 — actualiza título y descripción', async () => { ... })
    it('200 — asigna a miembro del proyecto', async () => { ... })
    it('400 — asignar a usuario fuera del proyecto', async () => { ... })
    it('403 — usuario sin permiso de edición', async () => { ... })
  })

  // PATCH /api/tasks/:id/status
  describe('PATCH /api/tasks/:id/status', () => {
    it('200 — avanza estado a in_progress', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/tasks/${seedTask.id}/status`)
        .set('Authorization', `Bearer ${token}`)
        .send({ status: 'in_progress' })
      expect(res.status).toBe(200)
      expect(res.body.data.status).toBe('in_progress')
    })
    it('409 — tarea ya en done no puede avanzar', async () => { ... })
    it('400 — estado inválido', async () => { ... })
  })

  // DELETE /api/tasks/:id
  describe('DELETE /api/tasks/:id', () => {
    it('200 — soft delete por owner o admin', async () => { ... })
    it('403 — viewer no puede eliminar', async () => { ... })
  })
})
```

### `tasks.status-flow.spec.ts`

```typescript
describe('Tasks — Máquina de estados', () => {
  const VALID_TRANSITIONS = [
    ['todo',        'in_progress'],
    ['in_progress', 'in_review'],
    ['in_review',   'done'],
    ['todo',        'cancelled'],
    ['in_progress', 'cancelled'],
    ['in_review',   'cancelled'],
  ]

  const INVALID_TRANSITIONS = [
    ['done',     'in_progress'],
    ['done',     'todo'],
    ['done',     'cancelled'],
    ['cancelled','todo'],
    ['todo',     'done'],           // no se puede saltar pasos
    ['todo',     'in_review'],
  ]

  VALID_TRANSITIONS.forEach(([from, to]) => {
    it(`✓ ${from} → ${to} es válido`, async () => {
      const task = await createTaskInStatus(app, token, seedProject.id, from)
      const res = await request(app.getHttpServer())
        .patch(`/api/tasks/${task.id}/status`)
        .set('Authorization', `Bearer ${token}`)
        .send({ status: to })
      expect(res.status).toBe(200)
    })
  })

  INVALID_TRANSITIONS.forEach(([from, to]) => {
    it(`✗ ${from} → ${to} es inválido`, async () => {
      const task = await createTaskInStatus(app, token, seedProject.id, from)
      const res = await request(app.getHttpServer())
        .patch(`/api/tasks/${task.id}/status`)
        .set('Authorization', `Bearer ${token}`)
        .send({ status: to })
      expect(res.status).toBe(409)
    })
  })
})
```

---

## Pruebas de Flujo (E2E)

```typescript
describe('Flujo completo — Ciclo de vida de una tarea', () => {
  it('Crear → asignar → avanzar por todos los estados → completar', async () => {
    // 1. Crear
    const task = await createTask(app, token, projectId, 'Tarea E2E')
    expect(task.status).toBe('todo')

    // 2. Asignar
    await assignTask(app, token, task.id, seedMember.id)

    // 3. Avanzar todo → in_progress
    await advanceStatus(app, token, task.id, 'in_progress')

    // 4. Avanzar in_progress → in_review
    await advanceStatus(app, token, task.id, 'in_review')

    // 5. Avanzar in_review → done
    const done = await advanceStatus(app, token, task.id, 'done')
    expect(done.status).toBe('done')

    // 6. Intentar avanzar desde done — debe fallar
    const blocked = await request(app.getHttpServer())
      .patch(`/api/tasks/${task.id}/status`)
      .set('Authorization', `Bearer ${token}`)
      .send({ status: 'in_progress' })
    expect(blocked.status).toBe(409)
  })
})
```

---

## Tareas

1. [ ] Unitarias: CreateTask, AdvanceStatus (máquina de estados), AssignTask.
2. [ ] Verificación unitaria: estado inicial siempre `todo`.
3. [ ] Integración: CRUD completo + filtros (status, assignee, priority).
4. [ ] Suite `status-flow`: todas las transiciones válidas e inválidas.
5. [ ] Integración: control de acceso por rol de proyecto.
6. [ ] E2E: ciclo de vida completo de una tarea.
7. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **`it.each` para la máquina de estados**: la suite `status-flow` con tablas de transiciones válidas/inválidas es la forma más limpia de documentar y probar el flujo. Si el producto cambia el flujo, basta actualizar las tablas.
- **Estado inicial hardcodeado**: el estado `todo` nunca debe aceptarse como input en la creación — solo el backend lo asigna. Probar que enviar `status: 'done'` en el POST es ignorado.
- **Filtros combinados**: probar que `?status=in_progress&assigneeId=u-1` retorna solo las tareas que cumplen ambas condiciones.
- **Tareas de otros proyectos**: probar que `GET /projects/:id/tasks` nunca retorna tareas de otro proyecto, aunque el usuario tenga acceso a ambos.

## Prioridad

**Media-Alta** — Tareas es el módulo de seguimiento del trabajo diario del equipo. Bugs en la máquina de estados generan confusión en el flujo de trabajo.
