# HU-056 — Testing de Endpoints — Módulo Proyectos y Fases de Flujo

> **Asignado:** @dospina56-maker — David Ospina

## Archivos Principales

`apps/api/src/modules/projects/` · `apps/api/test/` · `jest.config.ts` · `apps/api/src/modules/projects/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Proyectos y Fases de Flujo (HU-043),  
**Para** garantizar que todos los endpoints funcionan correctamente, que las reglas de negocio se respetan y que los cambios futuros no rompen funcionalidad existente.

**Dependencia:** Requiere HU-043 implementada. Requiere base de datos de pruebas configurada.

---

## Contexto

El módulo de Proyectos gestiona el ciclo de vida completo de un proyecto: creación, configuración de fases, asignación de miembros y transición de estados. Sin pruebas automatizadas, cualquier cambio en los servicios o controladores puede romper flujos críticos silenciosamente. Esta HU cubre los tres niveles de prueba: unitarias (lógica aislada), integración (HTTP + DB real) y flujo (escenarios completos de usuario).

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/projects/
├── application/
│   ├── use-cases/
│   │   ├── create-project.use-case.spec.ts       ← unitaria
│   │   ├── update-project.use-case.spec.ts        ← unitaria
│   │   └── advance-phase.use-case.spec.ts         ← unitaria
│   └── services/
│       └── projects.service.spec.ts               ← unitaria
├── infrastructure/
│   └── controllers/
│       └── projects.controller.spec.ts            ← unitaria (con mocks)
└── ...

apps/api/test/
├── projects/
│   ├── projects.integration.spec.ts               ← integración (supertest + DB)
│   └── projects.e2e.spec.ts                       ← flujo completo
└── helpers/
    ├── auth.helper.ts                             ← obtener JWT para pruebas
    └── db.helper.ts                               ← seed y limpieza de DB
```

---

## Setup de Pruebas

### `jest.config.ts` (verificar que existe)

```typescript
export default {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: 'src',
  testRegex: '.*\\.spec\\.ts$',
  transform: { '^.+\\.(t|j)s$': 'ts-jest' },
  collectCoverageFrom: ['**/*.(t|j)s'],
  coverageDirectory: '../coverage',
  testEnvironment: 'node',
}
```

### `jest-e2e.config.ts` (para integración y flujo)

```typescript
export default {
  moduleFileExtensions: ['js', 'json', 'ts'],
  rootDir: '.',
  testRegex: '.e2e-spec.ts$|.integration.spec.ts$',
  transform: { '^.+\\.(t|j)s$': 'ts-jest' },
  testEnvironment: 'node',
}
```

### `test/helpers/auth.helper.ts`

```typescript
import * as request from 'supertest'

export async function getAuthToken(app, credentials = {
  email: 'test@dataflow.test',
  password: 'TestPass123!'
}): Promise<string> {
  const res = await request(app.getHttpServer())
    .post('/api/auth/login')
    .send(credentials)
  return res.body.data.access_token
}
```

### `test/helpers/db.helper.ts`

```typescript
import { DataSource } from 'typeorm'

export async function cleanProjectsTable(ds: DataSource) {
  await ds.query('DELETE FROM project_phases WHERE 1=1')
  await ds.query('DELETE FROM projects WHERE 1=1')
}
```

---

## Pruebas Unitarias

### `create-project.use-case.spec.ts`

```typescript
describe('CreateProjectUseCase', () => {
  let useCase: CreateProjectUseCase
  let repo: jest.Mocked<IProjectRepository>

  beforeEach(() => {
    repo = { create: jest.fn(), findById: jest.fn() } as any
    useCase = new CreateProjectUseCase(repo)
  })

  it('crea proyecto con nombre y descripción válidos', async () => {
    repo.create.mockResolvedValue({ id: 'uuid-1', name: 'Mi Proyecto', ...etc })
    const result = await useCase.execute({ name: 'Mi Proyecto', ownerId: 'user-1' })
    expect(repo.create).toHaveBeenCalledTimes(1)
    expect(result.name).toBe('Mi Proyecto')
  })

  it('lanza ConflictException si nombre duplicado para el mismo owner', async () => {
    repo.create.mockRejectedValue(new ConflictException())
    await expect(useCase.execute({ name: 'Dup', ownerId: 'user-1' })).rejects.toThrow(ConflictException)
  })

  it('lanza BadRequestException si nombre vacío', async () => {
    await expect(useCase.execute({ name: '', ownerId: 'user-1' })).rejects.toThrow(BadRequestException)
  })
})
```

### `advance-phase.use-case.spec.ts`

```typescript
describe('AdvancePhaseUseCase', () => {
  it('avanza fase en orden correcto (Draft → Active → Closed)', async () => { ... })
  it('lanza ForbiddenException si usuario no es owner ni admin del proyecto', async () => { ... })
  it('lanza ConflictException si fase ya está en estado final', async () => { ... })
  it('no permite saltar fases intermedias', async () => { ... })
})
```

---

## Pruebas de Integración

### `projects.integration.spec.ts`

```typescript
describe('Projects API — Integración', () => {
  let app: INestApplication
  let token: string

  beforeAll(async () => {
    const module = await Test.createTestingModule({ imports: [AppModule] }).compile()
    app = module.createNestApplication()
    app.setGlobalPrefix('api')
    app.useGlobalPipes(new ValidationPipe({ transform: true, whitelist: true }))
    await app.init()
    token = await getAuthToken(app)
  })

  afterAll(async () => {
    await cleanProjectsTable(app.get(DataSource))
    await app.close()
  })

  // POST /api/projects
  describe('POST /api/projects', () => {
    it('201 — crea proyecto con datos válidos', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({ name: 'Proyecto Test', description: 'Descripción de prueba' })
      expect(res.status).toBe(201)
      expect(res.body.data).toMatchObject({ name: 'Proyecto Test' })
      expect(res.body.data.id).toBeDefined()
    })

    it('400 — falla sin nombre', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/projects')
        .set('Authorization', `Bearer ${token}`)
        .send({ description: 'Sin nombre' })
      expect(res.status).toBe(400)
    })

    it('401 — falla sin token', async () => {
      const res = await request(app.getHttpServer()).post('/api/projects').send({ name: 'X' })
      expect(res.status).toBe(401)
    })
  })

  // GET /api/projects
  describe('GET /api/projects', () => {
    it('200 — retorna lista paginada', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/projects')
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      expect(Array.isArray(res.body.data)).toBe(true)
      expect(res.body.meta).toHaveProperty('total')
    })

    it('200 — filtra por estado', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/projects?status=active')
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      res.body.data.forEach((p: any) => expect(p.status).toBe('active'))
    })
  })

  // GET /api/projects/:id
  describe('GET /api/projects/:id', () => {
    it('200 — retorna proyecto por ID', async () => { ... })
    it('404 — ID inexistente', async () => { ... })
    it('403 — usuario sin acceso al proyecto', async () => { ... })
  })

  // PATCH /api/projects/:id
  describe('PATCH /api/projects/:id', () => {
    it('200 — actualiza nombre y descripción', async () => { ... })
    it('403 — usuario no owner no puede editar', async () => { ... })
    it('400 — nombre vacío rechazado', async () => { ... })
  })

  // DELETE /api/projects/:id
  describe('DELETE /api/projects/:id', () => {
    it('200 — elimina (soft delete) proyecto propio', async () => { ... })
    it('403 — no owner no puede eliminar', async () => { ... })
    it('404 — ID ya eliminado', async () => { ... })
  })

  // POST /api/projects/:id/phases
  describe('POST /api/projects/:id/phases', () => {
    it('201 — crea fase con nombre y orden válidos', async () => { ... })
    it('409 — orden duplicado dentro del mismo proyecto', async () => { ... })
  })

  // PATCH /api/projects/:id/phases/:phaseId/advance
  describe('PATCH /api/projects/:id/phases/:phaseId/advance', () => {
    it('200 — avanza fase al siguiente estado', async () => { ... })
    it('409 — fase en estado final no avanza', async () => { ... })
  })
})
```

---

## Pruebas de Flujo (E2E)

### `projects.e2e.spec.ts`

```typescript
describe('Flujo completo — Ciclo de vida de un Proyecto', () => {
  it('Owner crea proyecto → invita miembro → crea fases → avanza fases → cierra proyecto', async () => {
    // 1. Login como owner
    const ownerToken = await getAuthToken(app, { email: 'owner@test.com', password: '...' })

    // 2. Crear proyecto
    const proj = await request(app.getHttpServer())
      .post('/api/projects')
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ name: 'Proyecto E2E', description: 'Test' })
    const projectId = proj.body.data.id
    expect(proj.status).toBe(201)

    // 3. Crear fases
    const phase1 = await request(app.getHttpServer())
      .post(`/api/projects/${projectId}/phases`)
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ name: 'Análisis', order: 1 })
    expect(phase1.status).toBe(201)

    // 4. Avanzar fase
    const advanced = await request(app.getHttpServer())
      .patch(`/api/projects/${projectId}/phases/${phase1.body.data.id}/advance`)
      .set('Authorization', `Bearer ${ownerToken}`)
    expect(advanced.status).toBe(200)
    expect(advanced.body.data.status).toBe('active')

    // 5. Miembro sin permiso no puede avanzar
    const memberToken = await getAuthToken(app, { email: 'member@test.com', password: '...' })
    const blocked = await request(app.getHttpServer())
      .patch(`/api/projects/${projectId}/phases/${phase1.body.data.id}/advance`)
      .set('Authorization', `Bearer ${memberToken}`)
    expect(blocked.status).toBe(403)

    // 6. Cerrar proyecto
    const closed = await request(app.getHttpServer())
      .patch(`/api/projects/${projectId}`)
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ status: 'closed' })
    expect(closed.status).toBe(200)
    expect(closed.body.data.status).toBe('closed')
  })
})
```

---

## Criterios de Aceptación

| Nivel | Cobertura mínima | Herramienta |
|-------|-----------------|-------------|
| Unitaria | 80% líneas en use-cases y services | Jest + mocks |
| Integración | 100% endpoints (todos los status codes) | supertest + DB test |
| Flujo | 3 escenarios E2E críticos | supertest completo |

---

## Comandos

```bash
# Unitarias
npm run test --workspace=apps/api

# Cobertura
npm run test:cov --workspace=apps/api

# Integración + E2E
npm run test:e2e --workspace=apps/api

# Solo este módulo
npx jest --testPathPattern=projects --workspace=apps/api
```

---

## Tareas

1. [ ] Configurar base de datos de prueba (`.env.test` con DB separada o SQLite in-memory).
2. [ ] Crear helpers `auth.helper.ts` y `db.helper.ts` en `test/`.
3. [ ] Escribir pruebas unitarias para todos los use-cases del módulo.
4. [ ] Escribir pruebas de integración para los 6 grupos de endpoints (CRUD + fases).
5. [ ] Escribir 3 pruebas de flujo E2E que cubran ciclos completos.
6. [ ] Verificar cobertura ≥ 80% con `test:cov`.
7. [ ] Agregar script `test:e2e` al `package.json` de `apps/api` si no existe.
8. [ ] Integrar en CI (GitHub Actions): correr `test` y `test:e2e` en cada PR.

---

## Recomendaciones

- **DB de prueba aislada**: usar una base de datos separada (`ia_dataflow_test`) o SQLite in-memory para que las pruebas no contaminen datos de desarrollo.
- **Seed determinístico**: el helper de DB debe crear exactamente los usuarios y datos necesarios antes de cada suite y limpiarlos después (`afterAll`). Nunca usar `beforeEach` para crear datos pesados.
- **No mockear la DB en integración**: el valor de las pruebas de integración está en que usan la DB real. Mockear el repositorio solo en pruebas unitarias.
- **Tokens con vida corta en tests**: usar JWT con expiración de 5 minutos en `.env.test` para evitar tokens stale entre suites largas.
- **Orden de tests independiente**: cada `describe` debe poder correr solo sin depender del estado dejado por otro. Usar IDs únicos generados (`uuid()`) en cada test para evitar colisiones.
- **Cubrir casos negativos**: al menos un test de 401, 403 y 404 por cada endpoint protegido — son los bugs más frecuentes en auth middleware.
- **Snapshot de respuesta**: usar `toMatchObject` en lugar de `toEqual` para que cambios en campos no críticos no rompan tests.

## Prioridad

**Alta** — módulo de Proyectos es central para el sistema. Sin pruebas, cualquier refactor de fases o permisos puede romper el core del producto.
