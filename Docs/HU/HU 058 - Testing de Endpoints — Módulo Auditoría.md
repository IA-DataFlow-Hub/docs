# HU-058 — Testing de Endpoints — Módulo Auditoría

> **Asignado:** @dospina56-maker — David Ospina

## Archivos Principales

`apps/api/src/modules/audit/` · `apps/api/test/audit/` · `apps/api/src/modules/audit/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Auditoría (HU-051),  
**Para** garantizar que todos los eventos del sistema se registran correctamente, que los endpoints de consulta retornan los datos esperados y que los logs de auditoría son inmutables una vez creados.

**Dependencia:** Requiere HU-051 implementada. Auditoría se dispara desde otros módulos — los tests deben verificar la integración transversal.

---

## Contexto

El módulo de Auditoría es transversal: registra eventos de todos los demás módulos (auth, proyectos, jobs, etc.). Su característica más importante es la **inmutabilidad** — ningún registro de auditoría puede modificarse o eliminarse. Los tests deben verificar tanto la API de consulta como la integración con los módulos que generan eventos. Este es el módulo con más superficie de integración del sistema.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/audit/
├── application/
│   ├── use-cases/
│   │   ├── log-event.use-case.spec.ts             ← unitaria
│   │   └── query-audit-log.use-case.spec.ts        ← unitaria
│   └── services/
│       └── audit.service.spec.ts                  ← unitaria
└── infrastructure/
    └── controllers/
        └── audit.controller.spec.ts               ← unitaria

apps/api/test/
├── audit/
│   ├── audit.integration.spec.ts                  ← integración
│   ├── audit.immutability.spec.ts                 ← pruebas de inmutabilidad
│   └── audit.cross-module.spec.ts                 ← integración transversal
```

---

## Pruebas Unitarias

### `log-event.use-case.spec.ts`

```typescript
describe('LogEventUseCase', () => {
  it('registra evento con todos los campos requeridos', async () => {
    const result = await useCase.execute({
      action: 'project.created',
      userId: 'u-1',
      resourceId: 'p-1',
      resourceType: 'project',
      metadata: { name: 'Mi Proyecto' },
      ip: '192.168.1.1',
    })
    expect(repo.create).toHaveBeenCalledTimes(1)
    expect(result.action).toBe('project.created')
    expect(result.createdAt).toBeDefined()
  })

  it('registra evento con userId null para acciones del sistema', async () => {
    const result = await useCase.execute({
      action: 'system.cleanup',
      userId: null,
      resourceType: 'system',
    })
    expect(result.userId).toBeNull()
    expect(result.action).toBe('system.cleanup')
  })

  it('no lanza si metadata es un objeto vacío', async () => {
    await expect(useCase.execute({ action: 'x', userId: 'u-1', resourceType: 'user', metadata: {} }))
      .resolves.not.toThrow()
  })

  it('lanza BadRequestException si action está vacía', async () => {
    await expect(useCase.execute({ action: '', userId: 'u-1', resourceType: 'user' }))
      .rejects.toThrow(BadRequestException)
  })
})
```

### `query-audit-log.use-case.spec.ts`

```typescript
describe('QueryAuditLogUseCase', () => {
  it('filtra por userId correctamente', async () => { ... })
  it('filtra por rango de fechas (from/to)', async () => { ... })
  it('filtra por action (ej: project.*)', async () => { ... })
  it('filtra por resourceType', async () => { ... })
  it('retorna resultados paginados con meta.total correcto', async () => { ... })
  it('ordena por createdAt DESC por defecto', async () => { ... })
})
```

### `audit.service.spec.ts` — Inmutabilidad

```typescript
describe('AuditService — Inmutabilidad', () => {
  it('no expone método update', () => {
    expect(typeof service.update).toBe('undefined')
  })

  it('no expone método delete', () => {
    expect(typeof service.delete).toBe('undefined')
  })

  it('el repositorio no llama update ni delete nunca', async () => {
    await service.log({ action: 'test', userId: 'u-1', resourceType: 'user' })
    expect(repo.update).not.toHaveBeenCalled()
    expect(repo.delete).not.toHaveBeenCalled()
  })
})
```

---

## Pruebas de Integración

### `audit.integration.spec.ts`

```typescript
describe('Audit API — Integración', () => {
  // GET /api/audit
  describe('GET /api/audit', () => {
    it('200 — admin obtiene todos los logs', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/audit')
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.status).toBe(200)
      expect(Array.isArray(res.body.data)).toBe(true)
      expect(res.body.meta).toHaveProperty('total')
      expect(res.body.meta).toHaveProperty('page')
    })

    it('403 — usuario sin rol admin no puede acceder', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/audit')
        .set('Authorization', `Bearer ${userToken}`)
      expect(res.status).toBe(403)
    })

    it('401 — sin token', async () => {
      const res = await request(app.getHttpServer()).get('/api/audit')
      expect(res.status).toBe(401)
    })

    it('200 — filtra por userId', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/audit?userId=${seedUser.id}`)
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.status).toBe(200)
      res.body.data.forEach((log: any) => expect(log.userId).toBe(seedUser.id))
    })

    it('200 — filtra por action parcial (project.*)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/audit?action=project')
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.status).toBe(200)
      res.body.data.forEach((log: any) => expect(log.action).toMatch(/^project/))
    })

    it('200 — filtra por rango de fechas', async () => {
      const from = new Date(Date.now() - 86400000).toISOString() // ayer
      const to   = new Date().toISOString()
      const res = await request(app.getHttpServer())
        .get(`/api/audit?from=${from}&to=${to}`)
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.status).toBe(200)
    })

    it('200 — paginación correcta (page=2, limit=5)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/audit?page=2&limit=5')
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.status).toBe(200)
      expect(res.body.data.length).toBeLessThanOrEqual(5)
      expect(res.body.meta.page).toBe(2)
    })
  })

  // GET /api/audit/:id
  describe('GET /api/audit/:id', () => {
    it('200 — retorna log específico', async () => { ... })
    it('404 — ID inexistente', async () => { ... })
    it('403 — no admin', async () => { ... })
  })

  // GET /api/audit/me (logs del usuario autenticado)
  describe('GET /api/audit/me', () => {
    it('200 — usuario ve solo sus propios logs', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/audit/me')
        .set('Authorization', `Bearer ${userToken}`)
      expect(res.status).toBe(200)
      res.body.data.forEach((log: any) => expect(log.userId).toBe(seedUser.id))
    })

    it('200 — no retorna logs de otros usuarios', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/audit/me')
        .set('Authorization', `Bearer ${userToken}`)
      const otherUserLogs = res.body.data.filter((l: any) => l.userId !== seedUser.id)
      expect(otherUserLogs).toHaveLength(0)
    })
  })
})
```

### `audit.immutability.spec.ts` — Pruebas de Inmutabilidad

```typescript
describe('Audit — Inmutabilidad de registros', () => {
  it('no existe endpoint PUT /api/audit/:id', async () => {
    const res = await request(app.getHttpServer())
      .put(`/api/audit/${seedLog.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ action: 'tampered' })
    expect(res.status).toBe(404) // ruta no existe
  })

  it('no existe endpoint PATCH /api/audit/:id', async () => {
    const res = await request(app.getHttpServer())
      .patch(`/api/audit/${seedLog.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
    expect(res.status).toBe(404)
  })

  it('no existe endpoint DELETE /api/audit/:id', async () => {
    const res = await request(app.getHttpServer())
      .delete(`/api/audit/${seedLog.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
    expect(res.status).toBe(404)
  })

  it('no existe endpoint DELETE /api/audit (bulk)', async () => {
    const res = await request(app.getHttpServer())
      .delete('/api/audit')
      .set('Authorization', `Bearer ${adminToken}`)
    expect(res.status).toBe(404)
  })

  it('registro en DB no cambia entre dos GET consecutivos', async () => {
    const first  = await request(app.getHttpServer()).get(`/api/audit/${seedLog.id}`).set('Authorization', `Bearer ${adminToken}`)
    const second = await request(app.getHttpServer()).get(`/api/audit/${seedLog.id}`).set('Authorization', `Bearer ${adminToken}`)
    expect(first.body.data).toEqual(second.body.data)
  })
})
```

---

## Pruebas de Integración Transversal

### `audit.cross-module.spec.ts`

```typescript
describe('Audit — Integración transversal (eventos generados por otros módulos)', () => {
  it('login exitoso genera evento auth.login en audit log', async () => {
    await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: seedUser.email, password: 'TestPass123!' })

    const logs = await request(app.getHttpServer())
      .get(`/api/audit?action=auth.login&userId=${seedUser.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
    expect(logs.body.data.length).toBeGreaterThanOrEqual(1)
    expect(logs.body.data[0].action).toBe('auth.login')
  })

  it('login fallido genera evento auth.login_failed', async () => {
    await request(app.getHttpServer())
      .post('/api/auth/login')
      .send({ email: seedUser.email, password: 'WrongPass' })

    const logs = await request(app.getHttpServer())
      .get('/api/audit?action=auth.login_failed')
      .set('Authorization', `Bearer ${adminToken}`)
    expect(logs.body.data.length).toBeGreaterThanOrEqual(1)
  })

  it('creación de proyecto genera evento project.created', async () => {
    await request(app.getHttpServer())
      .post('/api/projects')
      .set('Authorization', `Bearer ${userToken}`)
      .send({ name: 'Proyecto Audit Test' })

    const logs = await request(app.getHttpServer())
      .get(`/api/audit?action=project.created&userId=${seedUser.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
    expect(logs.body.data[0].action).toBe('project.created')
    expect(logs.body.data[0].metadata.name).toBe('Proyecto Audit Test')
  })

  it('eliminación de proyecto genera evento project.deleted', async () => { ... })
  it('creación de AI job genera evento ai_job.created', async () => { ... })
  it('cancelación de AI job genera evento ai_job.cancelled', async () => { ... })
  it('cambio de contraseña genera evento auth.password_changed', async () => { ... })
})
```

---

## Criterios de Aceptación

| Nivel | Cobertura mínima | Foco especial |
|-------|-----------------|---------------|
| Unitaria | 80% en use-cases | Inmutabilidad en servicio |
| Integración | 100% endpoints + filtros | Todos los query params |
| Inmutabilidad | 5 pruebas explícitas | PUT/PATCH/DELETE = 404 |
| Transversal | 1 test por módulo que genera eventos | auth, projects, ai-jobs |

---

## Comandos

```bash
# Solo módulo audit
npx jest --testPathPattern=audit --workspace=apps/api

# Pruebas de inmutabilidad
npx jest --testPathPattern=audit.immutability --workspace=apps/api

# Integración transversal
npx jest --testPathPattern=audit.cross-module --workspace=apps/api
```

---

## Tareas

1. [ ] Pruebas unitarias para `LogEventUseCase` y `QueryAuditLogUseCase`.
2. [ ] Prueba unitaria de inmutabilidad del servicio (no expone update/delete).
3. [ ] Integración: CRUD de consulta (GET /audit, GET /audit/:id, GET /audit/me).
4. [ ] Integración: filtros completos (userId, action, from, to, page, limit).
5. [ ] Suite de inmutabilidad: verificar que PUT, PATCH y DELETE retornan 404.
6. [ ] Integración transversal: al menos 1 test por módulo que genera eventos (auth, projects, ai-jobs).
7. [ ] Verificar que `createdAt` del log corresponde al momento de la acción (no hay lag).
8. [ ] Verificar que `ip` y `userAgent` se guardan correctamente desde los headers.
9. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **Separar suite de inmutabilidad**: mantener `audit.immutability.spec.ts` como archivo independiente — es un conjunto de invariantes del sistema que nunca deben fallar. Si alguien agrega por error un endpoint DELETE en el futuro, estas pruebas lo detectarán.
- **Pruebas transversales como documentación viva**: `audit.cross-module.spec.ts` sirve como documentación de qué eventos genera cada módulo. Mantenerlo actualizado cuando se agreguen nuevos módulos.
- **No limpiar la tabla audit entre tests**: a diferencia de otras tablas, los logs de auditoría se acumulan. Usar datos seed bien identificados (userId de test conocido) para filtrar en los asserts.
- **Verificar el IP real**: en pruebas de integración con supertest, el IP será `127.0.0.1`. Agregar un test que verifique que el campo no es null ni undefined.
- **Metadata estructurada**: verificar que la metadata guardada en el log tiene la estructura correcta (campos esperados), no solo que existe. Un log sin metadata útil no sirve para auditoría forense.
- **Ordenamiento descendente**: los logs siempre deben venir ordenados por `createdAt DESC`. Verificar explícitamente que el log más reciente está primero.
- **Volumen**: agregar una prueba que inserte 1000 logs y verifique que la paginación funciona correctamente bajo carga moderada.

## Prioridad

**Alta** — Auditoría es un requisito de compliance. Errores aquí implican logs forenses incorrectos o incompletos, lo que puede ser un problema legal o de seguridad.
