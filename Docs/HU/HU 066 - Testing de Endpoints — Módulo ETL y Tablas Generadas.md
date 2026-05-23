# HU-066 — Testing de Endpoints — Módulo ETL y Tablas Generadas

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

## Archivos Principales

`apps/api/src/modules/etl/` · `apps/api/test/etl/` · `apps/api/src/modules/etl/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo ETL y Tablas Generadas (HU-048),  
**Para** garantizar que los pipelines ETL se configuran, ejecutan y monitorean correctamente, que las tablas generadas son accesibles solo para el proyecto dueño y que los errores de transformación se reportan con detalle suficiente para debugging.

**Dependencia:** Requiere HU-048 implementada. El motor de ejecución ETL se mockea en pruebas.

---

## Contexto

El módulo ETL es el más complejo en términos de estado persistente: un pipeline puede estar en ejecución por minutos, generar tablas con miles de filas y fallar a mitad del proceso dejando datos parciales. Las pruebas deben cubrir especialmente el **manejo de fallos parciales** (rollback vs. datos corruptos), los **permisos de acceso a tablas generadas** y la **idempotencia de ejecuciones repetidas**.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/etl/
├── application/use-cases/
│   ├── create-pipeline.use-case.spec.ts
│   ├── run-pipeline.use-case.spec.ts
│   └── query-generated-table.use-case.spec.ts
└── infrastructure/
    ├── controllers/etl.controller.spec.ts
    └── engine/etl-engine.adapter.spec.ts

apps/api/test/etl/
├── etl.integration.spec.ts
├── etl.failure-handling.spec.ts        ← manejo de fallos
└── etl.e2e.spec.ts
```

---

## Mock del Motor ETL

```typescript
// test/mocks/etl-engine.mock.ts
export const EtlEngineMock = {
  runPipeline: jest.fn().mockResolvedValue({
    status: 'completed', rowsProcessed: 1000, tableId: 'tbl-mock-001'
  }),
  getPipelineStatus: jest.fn().mockResolvedValue({ status: 'completed', progress: 100 }),
  cancelPipeline: jest.fn().mockResolvedValue({ cancelled: true }),
}

export function mockPipelineFailure(errorMessage = 'Transform error on row 500') {
  EtlEngineMock.runPipeline.mockRejectedValueOnce(new Error(errorMessage))
}

export function mockPartialSuccess(rowsProcessed = 500) {
  EtlEngineMock.runPipeline.mockResolvedValueOnce({
    status: 'partial', rowsProcessed, errors: [{ row: 501, message: 'Invalid value' }]
  })
}
```

---

## Pruebas Unitarias

### `create-pipeline.use-case.spec.ts`

```typescript
describe('CreatePipelineUseCase', () => {
  it('crea pipeline con steps de transformación válidos', async () => {
    const result = await useCase.execute({
      projectId: 'p-1', name: 'ETL Test',
      sourceFileId: 'f-1',
      steps: [
        { type: 'filter', config: { column: 'age', operator: 'gt', value: 18 } },
        { type: 'rename', config: { from: 'nombre', to: 'name' } },
      ]
    })
    expect(result.steps).toHaveLength(2)
    expect(result.status).toBe('draft')
  })

  it('lanza BadRequestException si step tiene tipo desconocido', async () => {
    await expect(useCase.execute({ ..., steps: [{ type: 'unknown-step', config: {} }] }))
      .rejects.toThrow(BadRequestException)
  })

  it('lanza NotFoundException si sourceFileId no existe', async () => { ... })
  it('lanza ForbiddenException si usuario no accede al proyecto', async () => { ... })
})
```

### `run-pipeline.use-case.spec.ts`

```typescript
describe('RunPipelineUseCase', () => {
  it('ejecuta pipeline y crea tabla generada con metadatos', async () => {
    const result = await useCase.execute({ pipelineId: 'pl-1', triggeredBy: 'u-1' })
    expect(result.status).toBe('completed')
    expect(generatedTableRepo.create).toHaveBeenCalledTimes(1)
  })

  it('lanza ConflictException si pipeline ya está en ejecución', async () => {
    pipelineRepo.findById.mockResolvedValue({ status: 'running' })
    await expect(useCase.execute({ pipelineId: 'pl-1', triggeredBy: 'u-1' }))
      .rejects.toThrow(ConflictException)
  })

  it('marca pipeline como failed si motor falla — no queda en running', async () => {
    mockPipelineFailure()
    await expect(useCase.execute({ pipelineId: 'pl-1', triggeredBy: 'u-1' })).rejects.toThrow()
    expect(pipelineRepo.update).toHaveBeenCalledWith('pl-1', expect.objectContaining({ status: 'failed' }))
  })

  it('guarda detalles del error en el registro de ejecución', async () => {
    mockPipelineFailure('Column not found: edad')
    try { await useCase.execute({ pipelineId: 'pl-1', triggeredBy: 'u-1' }) } catch {}
    expect(runRepo.create).toHaveBeenCalledWith(expect.objectContaining({
      errorDetails: expect.stringContaining('Column not found')
    }))
  })
})
```

---

## Pruebas de Integración

### `etl.integration.spec.ts`

```typescript
describe('ETL API — Integración', () => {
  // POST /api/projects/:projectId/pipelines
  describe('POST /api/projects/:projectId/pipelines', () => {
    it('201 — crea pipeline con steps válidos', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/projects/${seedProject.id}/pipelines`)
        .set('Authorization', `Bearer ${token}`)
        .send({
          name: 'Pipeline Test',
          sourceFileId: seedFile.id,
          steps: [{ type: 'filter', config: { column: 'status', operator: 'eq', value: 'active' } }]
        })
      expect(res.status).toBe(201)
      expect(res.body.data.status).toBe('draft')
    })
    it('400 — step con tipo inválido', async () => { ... })
    it('404 — sourceFileId inexistente', async () => { ... })
    it('403 — usuario externo al proyecto', async () => { ... })
  })

  // POST /api/pipelines/:id/run
  describe('POST /api/pipelines/:id/run', () => {
    it('202 — lanza ejecución del pipeline', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/pipelines/${seedPipeline.id}/run`)
        .set('Authorization', `Bearer ${token}`)
      expect([200, 202]).toContain(res.status)
      expect(res.body.data.status).toMatch(/running|completed|queued/)
    })

    it('409 — pipeline ya en ejecución', async () => { ... })
    it('503 — motor ETL no disponible', async () => {
      mockPipelineFailure()
      const res = await request(app.getHttpServer())
        .post(`/api/pipelines/${seedPipeline.id}/run`)
        .set('Authorization', `Bearer ${token}`)
      expect([503, 500]).toContain(res.status)
      // El pipeline no debe quedar en status=running
      const pipeline = await getPipeline(app, token, seedPipeline.id)
      expect(pipeline.status).not.toBe('running')
    })
  })

  // GET /api/pipelines/:id/runs
  describe('GET /api/pipelines/:id/runs — historial de ejecuciones', () => {
    it('200 — lista ejecuciones con status y rowsProcessed', async () => { ... })
    it('200 — ejecución fallida incluye errorDetails', async () => { ... })
  })

  // GET /api/projects/:projectId/generated-tables
  describe('GET /api/projects/:projectId/generated-tables', () => {
    it('200 — lista tablas del proyecto', async () => { ... })
    it('403 — proyecto ajeno', async () => { ... })
    it('200 — no retorna tablas de otros proyectos', async () => { ... })
  })

  // GET /api/generated-tables/:id/rows
  describe('GET /api/generated-tables/:id/rows — consultar datos', () => {
    it('200 — retorna filas paginadas', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/generated-tables/${seedTable.id}/rows?page=1&limit=50`)
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      expect(Array.isArray(res.body.data)).toBe(true)
      expect(res.body.meta).toHaveProperty('total')
    })
    it('403 — tabla de proyecto ajeno', async () => { ... })
  })
})
```

### `etl.failure-handling.spec.ts`

```typescript
describe('ETL — Manejo de fallos', () => {
  it('pipeline que falla no deja registros parciales en tabla generada', async () => {
    mockPipelineFailure()
    try {
      await request(app.getHttpServer())
        .post(`/api/pipelines/${seedPipeline.id}/run`).set('Authorization', `Bearer ${token}`)
    } catch {}
    // Verificar que no se creó tabla generada con datos parciales
    const tables = await request(app.getHttpServer())
      .get(`/api/projects/${seedProject.id}/generated-tables`)
      .set('Authorization', `Bearer ${token}`)
    const failedTables = tables.body.data.filter((t: any) => t.pipelineId === seedPipeline.id && t.status === 'failed')
    failedTables.forEach((t: any) => {
      expect(t.rowCount).toBe(0)  // no debe haber datos parciales
    })
  })

  it('ejecución parcial (partial) registra filas procesadas y errores', async () => {
    mockPartialSuccess(500)
    const run = await runPipeline(app, token, seedPipeline.id)
    expect(run.status).toBe('partial')
    expect(run.rowsProcessed).toBe(500)
    expect(run.errors).toHaveLength(1)
  })

  it('re-ejecutar pipeline fallido es posible', async () => {
    // Primer run falla
    mockPipelineFailure()
    await runPipeline(app, token, seedPipeline.id).catch(() => {})
    // Segundo run exitoso
    EtlEngineMock.runPipeline.mockResolvedValueOnce({ status: 'completed', rowsProcessed: 1000 })
    const rerun = await runPipeline(app, token, seedPipeline.id)
    expect(rerun.status).toBe('completed')
  })
})
```

---

## Tareas

1. [ ] Mock del motor ETL con helpers para fallo y éxito parcial.
2. [ ] Unitarias: CreatePipeline, RunPipeline (incluye fallo → estado `failed`).
3. [ ] Integración: CRUD de pipelines + ejecución.
4. [ ] Integración: consulta de tablas generadas con paginación.
5. [ ] Suite `failure-handling`: fallo total, éxito parcial, re-ejecución.
6. [ ] Verificación: pipeline fallido no deja estado `running`.
7. [ ] E2E: ciclo completo crear → ejecutar → consultar tabla.
8. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **Estado `running` es peligroso**: el invariante más crítico es que si el motor falla, el pipeline pase a `failed` — nunca quede en `running`. Sin esto, el usuario no puede re-ejecutar y el sistema parece colgado.
- **Rollback vs. datos parciales**: definir y probar la política explícitamente. Si el motor procesa 500 de 1000 filas y falla, ¿la tabla generada tiene 500 filas o 0? La política debe ser consistente y probada.
- **Idempotencia de ejecución**: correr el mismo pipeline dos veces debe crear dos registros de ejecución distintos, no sobreescribir el anterior. Probar explícitamente.
- **Paginación en tablas grandes**: usar `limit` bajo (50) en pruebas para verificar que la paginación funciona, no cargar todas las filas.

## Prioridad

**Alta** — ETL procesa los datasets de entrenamiento de IA. Datos corruptos o parciales afectan directamente la calidad del fine-tuning (HU-038/039).
