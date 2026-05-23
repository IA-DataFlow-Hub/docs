# HU-057 — Testing de Endpoints — Módulo Motor de IA y AI Jobs

> **Asignado:** @dospina56-maker — David Ospina

## Archivos Principales

`apps/api/src/modules/ai-jobs/` · `apps/api/test/ai-jobs/` · `apps/api/src/modules/ai-jobs/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo Motor de IA y AI Jobs (HU-047),  
**Para** garantizar que los endpoints de creación, monitoreo y cancelación de jobs de IA funcionan correctamente, que los estados se transicionan de forma válida y que los errores del motor externo se manejan con gracia.

**Dependencia:** Requiere HU-047 implementada. El motor de IA externo (LM Studio / OpenAI) debe mockearse en pruebas.

---

## Contexto

El módulo AI Jobs es el más crítico del sistema en términos de efectos secundarios: una llamada mal manejada puede dejar jobs en estado `running` indefinidamente, consumir créditos de API o corromper el dataset de entrenamiento. Las pruebas de este módulo deben ser especialmente rigurosas para el manejo de errores, timeouts y estados de fallo. El motor externo de IA **siempre se mockea** — nunca se llama en pruebas.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/ai-jobs/
├── application/
│   ├── use-cases/
│   │   ├── create-job.use-case.spec.ts            ← unitaria
│   │   ├── cancel-job.use-case.spec.ts             ← unitaria
│   │   └── poll-job-status.use-case.spec.ts        ← unitaria
│   └── services/
│       ├── ai-jobs.service.spec.ts                 ← unitaria
│       └── ai-engine.adapter.spec.ts               ← unitaria (mock del motor)
└── infrastructure/
    └── controllers/
        └── ai-jobs.controller.spec.ts              ← unitaria

apps/api/test/
├── ai-jobs/
│   ├── ai-jobs.integration.spec.ts                ← integración
│   └── ai-jobs.e2e.spec.ts                        ← flujo completo
└── mocks/
    └── ai-engine.mock.ts                          ← mock del motor externo
```

---

## Mock del Motor de IA

```typescript
// test/mocks/ai-engine.mock.ts
export const AiEngineMock = {
  submitJob: jest.fn().mockResolvedValue({ jobId: 'mock-job-001', status: 'queued' }),
  getJobStatus: jest.fn().mockResolvedValue({ status: 'completed', result: { accuracy: 0.94 } }),
  cancelJob: jest.fn().mockResolvedValue({ cancelled: true }),
}

// Para simular fallo del motor:
export function mockEngineFailure() {
  AiEngineMock.submitJob.mockRejectedValueOnce(new Error('Engine unavailable'))
}

// Para simular timeout:
export function mockEngineTimeout() {
  AiEngineMock.getJobStatus.mockResolvedValueOnce({ status: 'running' })
  AiEngineMock.getJobStatus.mockResolvedValueOnce({ status: 'running' })
  AiEngineMock.getJobStatus.mockResolvedValueOnce({ status: 'timeout' })
}
```

---

## Pruebas Unitarias

### `create-job.use-case.spec.ts`

```typescript
describe('CreateJobUseCase', () => {
  it('crea job con modelo y dataset válidos', async () => {
    engine.submitJob.mockResolvedValue({ jobId: 'j-001', status: 'queued' })
    const result = await useCase.execute({ modelId: 'm-1', datasetId: 'd-1', userId: 'u-1' })
    expect(result.status).toBe('queued')
    expect(result.externalJobId).toBe('j-001')
  })

  it('lanza NotFoundException si dataset no existe', async () => {
    datasetRepo.findById.mockResolvedValue(null)
    await expect(useCase.execute({ modelId: 'm-1', datasetId: 'inexistente', userId: 'u-1' }))
      .rejects.toThrow(NotFoundException)
  })

  it('lanza ServiceUnavailableException si motor externo falla', async () => {
    engine.submitJob.mockRejectedValue(new Error('Engine down'))
    await expect(useCase.execute({ ... })).rejects.toThrow(ServiceUnavailableException)
  })

  it('guarda el job en DB incluso si motor retorna inmediatamente', async () => {
    await useCase.execute({ ... })
    expect(jobRepo.save).toHaveBeenCalledTimes(1)
  })
})
```

### `cancel-job.use-case.spec.ts`

```typescript
describe('CancelJobUseCase', () => {
  it('cancela job en estado queued', async () => { ... })
  it('cancela job en estado running', async () => { ... })
  it('lanza ConflictException si job ya está completed', async () => { ... })
  it('lanza ConflictException si job ya está cancelled', async () => { ... })
  it('lanza ForbiddenException si usuario no es el owner del job', async () => { ... })
})
```

### `poll-job-status.use-case.spec.ts`

```typescript
describe('PollJobStatusUseCase', () => {
  it('actualiza status a completed cuando motor retorna completed', async () => { ... })
  it('actualiza status a failed cuando motor retorna error', async () => { ... })
  it('mantiene status running si motor aún procesa', async () => { ... })
  it('marca como timeout si supera MAX_POLL_ATTEMPTS', async () => { ... })
})
```

---

## Pruebas de Integración

### `ai-jobs.integration.spec.ts`

```typescript
describe('AI Jobs API — Integración', () => {
  beforeAll(async () => {
    const module = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(AiEngineAdapter)
      .useValue(AiEngineMock)           // ← SIEMPRE mockear el motor externo
      .compile()
    app = module.createNestApplication()
    await app.init()
    token = await getAuthToken(app)
  })

  // POST /api/ai-jobs
  describe('POST /api/ai-jobs', () => {
    it('201 — crea job con modelo y dataset válidos', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/ai-jobs')
        .set('Authorization', `Bearer ${token}`)
        .send({ modelId: seedModel.id, datasetId: seedDataset.id, type: 'fine-tune' })
      expect(res.status).toBe(201)
      expect(res.body.data.status).toBe('queued')
      expect(res.body.data.id).toBeDefined()
    })

    it('400 — falla sin modelId', async () => { ... })
    it('404 — dataset inexistente', async () => { ... })
    it('401 — sin token', async () => { ... })
    it('503 — motor externo no disponible', async () => {
      mockEngineFailure()
      const res = await request(app.getHttpServer())
        .post('/api/ai-jobs')
        .set('Authorization', `Bearer ${token}`)
        .send({ modelId: seedModel.id, datasetId: seedDataset.id })
      expect(res.status).toBe(503)
    })
  })

  // GET /api/ai-jobs
  describe('GET /api/ai-jobs', () => {
    it('200 — lista jobs del usuario autenticado', async () => { ... })
    it('200 — filtra por status=running', async () => { ... })
    it('200 — no retorna jobs de otros usuarios', async () => { ... })
  })

  // GET /api/ai-jobs/:id
  describe('GET /api/ai-jobs/:id', () => {
    it('200 — retorna job con logs si es propio', async () => { ... })
    it('403 — job de otro usuario', async () => { ... })
    it('404 — ID inexistente', async () => { ... })
  })

  // PATCH /api/ai-jobs/:id/cancel
  describe('PATCH /api/ai-jobs/:id/cancel', () => {
    it('200 — cancela job en estado queued', async () => { ... })
    it('200 — cancela job en estado running', async () => { ... })
    it('409 — job ya completado no se puede cancelar', async () => { ... })
    it('403 — no owner no puede cancelar', async () => { ... })
  })

  // GET /api/ai-jobs/:id/logs
  describe('GET /api/ai-jobs/:id/logs', () => {
    it('200 — retorna logs paginados', async () => { ... })
    it('200 — logs vacíos si job recién creado', async () => { ... })
  })
})
```

---

## Pruebas de Flujo (E2E)

### `ai-jobs.e2e.spec.ts`

```typescript
describe('Flujo completo — Ciclo de vida de un AI Job', () => {
  it('Usuario crea job → monitorea progreso → job completa → revisa resultado', async () => {
    // 1. Crear job
    const created = await request(app.getHttpServer())
      .post('/api/ai-jobs')
      .set('Authorization', `Bearer ${token}`)
      .send({ modelId: seedModel.id, datasetId: seedDataset.id, type: 'fine-tune' })
    expect(created.status).toBe(201)
    const jobId = created.body.data.id

    // 2. Verificar estado inicial queued
    const queued = await request(app.getHttpServer())
      .get(`/api/ai-jobs/${jobId}`)
      .set('Authorization', `Bearer ${token}`)
    expect(queued.body.data.status).toBe('queued')

    // 3. Simular polling → running
    AiEngineMock.getJobStatus.mockResolvedValueOnce({ status: 'running', progress: 45 })
    // (trigger poll endpoint o scheduler)

    // 4. Simular completion
    AiEngineMock.getJobStatus.mockResolvedValueOnce({ status: 'completed', result: { accuracy: 0.94 } })
    // (trigger poll)

    // 5. Verificar estado final
    const done = await request(app.getHttpServer())
      .get(`/api/ai-jobs/${jobId}`)
      .set('Authorization', `Bearer ${token}`)
    expect(done.body.data.status).toBe('completed')
    expect(done.body.data.result.accuracy).toBe(0.94)
  })

  it('Usuario crea job → cancela mientras está running', async () => {
    const jobId = await createAndGetJobId(app, token)
    // Simular running
    await setJobStatus(app, jobId, 'running')
    const cancelled = await request(app.getHttpServer())
      .patch(`/api/ai-jobs/${jobId}/cancel`)
      .set('Authorization', `Bearer ${token}`)
    expect(cancelled.status).toBe(200)
    expect(cancelled.body.data.status).toBe('cancelled')
  })

  it('Motor falla → job queda en failed → usuario puede relanzar', async () => {
    mockEngineFailure()
    // Verificar que no queda zombie en running
    // Verificar que se puede crear nuevo job con mismo dataset
  })
})
```

---

## Criterios de Aceptación

| Nivel | Cobertura mínima | Foco especial |
|-------|-----------------|---------------|
| Unitaria | 85% en use-cases | Máquina de estados del job |
| Integración | 100% endpoints + status codes | Motor mockeado siempre |
| Flujo | 3 escenarios críticos | Completion, cancel, fallo |

---

## Tareas

1. [ ] Crear `test/mocks/ai-engine.mock.ts` con helpers `mockEngineFailure()` y `mockEngineTimeout()`.
2. [ ] Pruebas unitarias para los 3 use-cases principales.
3. [ ] Prueba unitaria para `AiEngineAdapter` (asegurar que serializa correctamente los parámetros al motor externo).
4. [ ] Integración: todos los endpoints con motor mockeado, incluyendo casos de fallo 503.
5. [ ] E2E: flujo completo de ciclo de vida del job.
6. [ ] E2E: flujo de cancelación.
7. [ ] E2E: flujo de fallo del motor (job queda en `failed`, no en `running`).
8. [ ] Verificar que no quedan jobs zombie en `running` tras un fallo del servidor.
9. [ ] Cobertura ≥ 85% en use-cases y services.

---

## Recomendaciones

- **Mockear siempre el motor externo**: nunca llamar LM Studio / OpenAI en pruebas. Usar `overrideProvider` de NestJS testing para reemplazar el adapter.
- **Máquina de estados exhaustiva**: escribir un test por cada transición inválida (ej: `cancelled → running` debe ser imposible). Los bugs de estado son los más difíciles de detectar en producción.
- **Jobs zombie**: verificar específicamente que si el servidor cae mientras un job está `running`, al reiniciar haya un mecanismo de reconciliación que lo marque como `failed` o `unknown`.
- **Aislamiento de jobs entre usuarios**: prueba explícita de que `GET /api/ai-jobs` nunca retorna jobs de otros usuarios, incluso si comparten el mismo dataset.
- **Logs de jobs**: probar que los logs se crean correctamente durante el ciclo de vida. Logs mal formateados son difíciles de debuggear en producción.
- **Timeouts realistas en mocks**: simular que el motor tarda N segundos ayuda a encontrar bugs de timeout que no aparecen con mocks síncronos.

## Prioridad

**Muy Alta** — AI Jobs es el módulo de mayor riesgo técnico. Errores aquí implican consumo de recursos costosos y datos de entrenamiento corruptos.
