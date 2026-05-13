# HU-031 — Plan de Pruebas y Esquema de Testing para IA-DataFlow-Hub

## Historia de Usuario

**Como** equipo de desarrollo de IA-DataFlow-Hub,  
**Quiero** implementar un esquema completo de pruebas automatizadas (unitarias, integración, E2E y contratos de API),  
**Para** garantizar la calidad, estabilidad y confiabilidad del sistema antes de cada entrega, reducir regresiones y acelerar el ciclo de desarrollo con confianza.

---

## Contexto y Motivación

El proyecto actualmente cuenta con:
- Un archivo `app.controller.spec.ts` de ejemplo en el backend (NestJS) — sin cobertura real.
- Sin ninguna prueba en el frontend (React + Vite).
- Sin pruebas E2E configuradas.
- Sin contratos de API validados automáticamente.

Dado que el sistema maneja **datos sensibles de usuarios y empresas**, procesa archivos CSV/Excel con IA, ejecuta pipelines ETL y genera dashboards en Power BI, es crítico tener un plan de pruebas sólido que proteja la integridad del negocio.

---

## Criterios de Aceptación

- [ ] El backend tiene cobertura ≥ 80% en servicios críticos (auth, ETL, AI jobs, datasets).
- [ ] El frontend tiene pruebas de componentes para todas las páginas principales.
- [ ] Existen pruebas de integración para cada endpoint REST documentado.
- [ ] Existen pruebas E2E que cubran los flujos de negocio más importantes.
- [ ] Las pruebas se ejecutan automáticamente en el pipeline de CI/CD (Turborepo).
- [ ] Los mocks de IA (Llama 4 / Gemini) están centralizados y son reutilizables.
- [ ] El reporte de cobertura se genera con cada build (`coverage/` en cada app).
- [ ] Ninguna prueba depende de servicios externos reales (AI, n8n, Power BI).

---

## Arquitectura del Plan de Pruebas

```
IA-DataFlow-Hub/
├── apps/
│   ├── api/                          ← NestJS Backend
│   │   ├── src/
│   │   │   └── **/__tests__/         ← Unit tests por módulo
│   │   └── test/
│   │       └── *.e2e-spec.ts         ← Integration / E2E de API
│   └── client/                       ← React Frontend
│       ├── src/
│       │   └── **/__tests__/         ← Component tests (Vitest + RTL)
│       └── e2e/
│           └── *.spec.ts             ← E2E con Playwright
├── packages/
│   └── database/
│       └── test/
│           └── seeds/                ← Datos de prueba reproducibles
└── turbo.json                        ← Pipeline: test, test:cov, test:e2e
```

---

## Niveles de Prueba

### Nivel 1 — Pruebas Unitarias (Backend)

**Herramienta:** Jest + `@nestjs/testing`  
**Ubicación:** `apps/api/src/**/__tests__/*.spec.ts`  
**Objetivo:** Probar la lógica de negocio aislada de infraestructura.

#### Módulos críticos a cubrir:

| Módulo | Servicio | Casos clave |
|--------|----------|-------------|
| Auth | `AuthService` | login válido, credenciales inválidas, refresh token, revocación de sesión |
| Usuarios | `UsersService` | creación, búsqueda por UUID, soft delete, actualización de preferencias |
| Datasets | `DatasetsService` | subida de archivo, validación de tipo, registro de lineage |
| AI Jobs | `AiJobsService` | creación de job, transición de estados, captura de error, retry |
| ETL | `EtlTemplatesService` | creación de template, ejecución de pasos, rollback en error |
| Roles | `RolesService` | asignación de rol, verificación de permiso por scope |
| Reportes | `ReportsService` | creación, versionado, exportación |

#### Ejemplo — `AiJobsService`:

```typescript
// apps/api/src/ai-jobs/__tests__/ai-jobs.service.spec.ts
import { Test, TestingModule } from '@nestjs/testing';
import { AiJobsService } from '../ai-jobs.service';
import { PrismaService } from '../../database/prisma.service';
import { mockPrismaService } from '../../../test/mocks/prisma.mock';

describe('AiJobsService', () => {
  let service: AiJobsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AiJobsService,
        { provide: PrismaService, useValue: mockPrismaService },
      ],
    }).compile();

    service = module.get<AiJobsService>(AiJobsService);
  });

  describe('createJob()', () => {
    it('debe crear un job con estado PENDING', async () => {
      mockPrismaService.ai_jobs.create.mockResolvedValue({
        id: 'uuid-123',
        status: 'PENDING',
        created_at: new Date(),
      });

      const result = await service.createJob({
        projectId: 'proj-uuid',
        fileId: 'file-uuid',
        prompt: 'Limpia y normaliza esta tabla',
      });

      expect(result.status).toBe('PENDING');
      expect(mockPrismaService.ai_jobs.create).toHaveBeenCalledTimes(1);
    });

    it('debe lanzar error si el archivo no existe', async () => {
      mockPrismaService.files.findUnique.mockResolvedValue(null);

      await expect(
        service.createJob({ fileId: 'no-existe', prompt: '...' })
      ).rejects.toThrow('Archivo no encontrado');
    });
  });

  describe('transitionStatus()', () => {
    it('debe registrar evento al cambiar de PENDING a PROCESSING', async () => {
      await service.transitionStatus('job-uuid', 'PROCESSING');

      expect(mockPrismaService.ai_job_events.create).toHaveBeenCalledWith(
        expect.objectContaining({ event_type: 'started' })
      );
    });
  });
});
```

---

### Nivel 2 — Pruebas de Componentes (Frontend)

**Herramienta:** Vitest + React Testing Library + jsdom  
**Ubicación:** `apps/client/src/**/__tests__/*.test.tsx`  
**Objetivo:** Verificar que cada componente renderiza correctamente y responde a interacciones.

#### Componentes críticos a cubrir:

| Componente | Casos clave |
|------------|-------------|
| `Login` | render, submit con credenciales válidas, mensaje de error en credenciales inválidas |
| `Register` | validación de formulario, contraseña fuerte, confirmación |
| `ProjectManager` | listado de proyectos, creación, soft-delete con confirmación |
| `FileUpload` | drag & drop de CSV, validación de tipo, progreso de subida |
| `AiJobStatus` | estado PENDING/PROCESSING/COMPLETED/FAILED, polling de estado |
| `ETLTemplates` | listado, selección, ejecución de template |
| `ActivityFeed` | renderizado de eventos, scroll infinito, filtros |
| `NotificationCenter` | badge de conteo, marcar como leída, agrupación |
| `ReportWidget` | render de gráfico, datos vacíos, error de carga |

#### Ejemplo — `FileUpload` component:

```tsx
// apps/client/src/components/__tests__/FileUpload.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { FileUpload } from '../FileUpload';
import { server } from '../../../test/mocks/server'; // MSW mock server
import { rest } from 'msw';

describe('FileUpload', () => {
  it('debe aceptar archivos CSV y mostrar preview', async () => {
    render(<FileUpload projectId="proj-uuid" onUploadComplete={jest.fn()} />);

    const csvFile = new File(
      ['nombre,edad\nJuan,30\nMaría,25'],
      'datos.csv',
      { type: 'text/csv' }
    );

    const input = screen.getByTestId('file-input');
    await userEvent.upload(input, csvFile);

    expect(screen.getByText('datos.csv')).toBeInTheDocument();
    expect(screen.getByText('3 filas detectadas')).toBeInTheDocument();
  });

  it('debe rechazar archivos con extensión no soportada', async () => {
    render(<FileUpload projectId="proj-uuid" onUploadComplete={jest.fn()} />);

    const invalidFile = new File(['...'], 'imagen.png', { type: 'image/png' });
    const input = screen.getByTestId('file-input');
    await userEvent.upload(input, invalidFile);

    expect(screen.getByText(/formato no soportado/i)).toBeInTheDocument();
  });

  it('debe mostrar progreso durante la subida', async () => {
    server.use(
      rest.post('/api/files/upload', async (req, res, ctx) => {
        return res(ctx.delay(100), ctx.json({ id: 'file-uuid' }));
      })
    );

    render(<FileUpload projectId="proj-uuid" onUploadComplete={jest.fn()} />);
    // ... interacción y assert de barra de progreso
    await waitFor(() =>
      expect(screen.getByRole('progressbar')).toBeInTheDocument()
    );
  });
});
```

---

### Nivel 3 — Pruebas de Integración (API)

**Herramienta:** Jest + Supertest + base de datos de prueba (MySQL en Docker)  
**Ubicación:** `apps/api/test/*.e2e-spec.ts`  
**Objetivo:** Probar los endpoints HTTP reales con base de datos real (no mocks de Prisma).

#### Endpoints críticos a cubrir:

| Endpoint | Método | Casos |
|----------|--------|-------|
| `/auth/login` | POST | login exitoso, credenciales inválidas, cuenta bloqueada |
| `/auth/refresh` | POST | token válido, token expirado, token revocado |
| `/projects` | GET/POST | listado paginado, creación, sin autenticación → 401 |
| `/projects/:id/files` | POST | subida válida, archivo muy grande, tipo inválido |
| `/ai-jobs` | POST | creación, sin permisos → 403 |
| `/ai-jobs/:id` | GET | job propio, job ajeno → 403, job inexistente → 404 |
| `/datasets/:id` | DELETE | soft delete, ya eliminado → 404 |
| `/reports` | POST | creación con widgets, validación de métricas |

#### Ejemplo — Auth integration test:

```typescript
// apps/api/test/auth.e2e-spec.ts
import { INestApplication } from '@nestjs/common';
import * as request from 'supertest';
import { createTestApp } from './helpers/create-test-app';
import { seedTestUser } from './helpers/seeds';

describe('AuthController (e2e)', () => {
  let app: INestApplication;

  beforeAll(async () => {
    app = await createTestApp();
    await seedTestUser({ email: 'test@dataflow.com', password: 'Test1234!' });
  });

  afterAll(async () => {
    await app.close();
  });

  describe('POST /auth/login', () => {
    it('debe retornar JWT con credenciales válidas', async () => {
      const res = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'test@dataflow.com', password: 'Test1234!' })
        .expect(200);

      expect(res.body).toHaveProperty('access_token');
      expect(res.body).toHaveProperty('refresh_token');
      expect(res.body.user.email).toBe('test@dataflow.com');
    });

    it('debe retornar 401 con contraseña incorrecta', async () => {
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'test@dataflow.com', password: 'Incorrecta' })
        .expect(401);
    });

    it('debe registrar la sesión en la base de datos', async () => {
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: 'test@dataflow.com', password: 'Test1234!' });

      // Verificar en DB que se creó registro en `sessions`
      const sessions = await prisma.sessions.findMany({
        where: { user_email: 'test@dataflow.com' },
      });
      expect(sessions.length).toBeGreaterThan(0);
    });
  });
});
```

---

### Nivel 4 — Pruebas End-to-End (E2E)

**Herramienta:** Playwright  
**Ubicación:** `apps/client/e2e/*.spec.ts`  
**Objetivo:** Simular flujos completos de usuario en el navegador real.

#### Flujos críticos a cubrir:

| Flujo | Descripción |
|-------|-------------|
| **F-01** | Registro → Login → Crear Proyecto → Subir CSV → Ver preview |
| **F-02** | Login → Seleccionar archivo → Ejecutar AI Job → Ver resultado limpio |
| **F-03** | Login → Aplicar template ETL → Descargar archivo procesado |
| **F-04** | Login → Crear reporte → Agregar widget de gráfico → Guardar versión |
| **F-05** | Login → Invitar usuario al equipo → Verificar email de invitación |
| **F-06** | Login fallido 5 veces → Cuenta bloqueada → Mensaje de error correcto |
| **F-07** | Subir Excel con múltiples hojas → Seleccionar hoja → Procesar |

#### Ejemplo — Flujo F-01:

```typescript
// apps/client/e2e/upload-flow.spec.ts
import { test, expect } from '@playwright/test';
import path from 'path';

test.describe('Flujo: Subir archivo CSV y procesar con IA', () => {
  test.beforeEach(async ({ page }) => {
    // Login rápido vía API para no repetir UI cada vez
    await page.request.post('/api/auth/login', {
      data: { email: 'e2e@dataflow.com', password: 'E2eTest1234!' },
    });
    await page.goto('/dashboard');
  });

  test('F-01: usuario puede crear proyecto y subir CSV', async ({ page }) => {
    // Crear proyecto
    await page.getByTestId('btn-new-project').click();
    await page.getByLabel('Nombre del proyecto').fill('Proyecto E2E Test');
    await page.getByRole('button', { name: 'Crear' }).click();

    await expect(page.getByText('Proyecto E2E Test')).toBeVisible();

    // Subir archivo CSV
    const csvPath = path.join(__dirname, 'fixtures', 'ventas_2024.csv');
    await page.getByTestId('file-upload-zone').setInputFiles(csvPath);

    await expect(page.getByText('ventas_2024.csv')).toBeVisible();
    await expect(page.getByText(/filas detectadas/i)).toBeVisible();
  });

  test('F-02: usuario puede ejecutar AI Job y ver resultado', async ({ page }) => {
    await page.goto('/projects/e2e-project-id/files');

    await page.getByTestId('file-ventas_2024').click();
    await page.getByRole('button', { name: 'Analizar con IA' }).click();
    await page.getByLabel('Instrucción').fill('Normaliza nombres y elimina duplicados');
    await page.getByRole('button', { name: 'Ejecutar' }).click();

    // Espera hasta que el job termine (máx 30s en E2E con mocks)
    await expect(page.getByTestId('job-status')).toHaveText('Completado', {
      timeout: 30_000,
    });

    await expect(page.getByText('Vista previa del resultado')).toBeVisible();
  });
});
```

---

### Nivel 5 — Pruebas de IA y ETL (Mocks)

**Objetivo:** Probar la lógica del sistema sin llamar a APIs de IA reales (Llama 4 / Gemini).

#### Estrategia de mocking para IA:

```typescript
// apps/api/test/mocks/ai-providers.mock.ts

export const mockGeminiResponse = (overrides = {}) => ({
  status: 'success',
  output: {
    cleaned_rows: 150,
    removed_duplicates: 12,
    normalized_columns: ['nombre', 'telefono', 'fecha'],
    transformations_applied: ['trim_whitespace', 'standardize_dates', 'remove_nulls'],
    confidence_score: 0.94,
  },
  tokens_used: { prompt: 1200, completion: 450, total: 1650 },
  model: 'gemini-2.5-flash-lite',
  processing_time_ms: 3200,
  ...overrides,
});

export const mockLlamaResponse = (overrides = {}) => ({
  status: 'success',
  output: {
    analysis: 'El dataset contiene 3 columnas con datos inconsistentes.',
    suggestions: ['Normalizar campo fecha', 'Eliminar columna vacía "observaciones"'],
  },
  model: 'llama-4-local',
  processing_time_ms: 8500,
  ...overrides,
});

// Mock de error controlado para probar reintentos
export const mockAiError = (code = 'TIMEOUT') => ({
  status: 'error',
  error_code: code,
  error_message: 'El servicio de IA no respondió a tiempo.',
  retry_after_ms: 5000,
});
```

#### Casos de prueba para el pipeline ETL:

```typescript
describe('ETL Pipeline — integración con IA mockeada', () => {
  it('debe limpiar dataset con Gemini y registrar transformaciones', async () => {
    jest.spyOn(geminiService, 'process').mockResolvedValue(
      mockGeminiResponse()
    );

    const result = await etlService.processFile({
      fileId: 'test-file-uuid',
      instructions: 'Normaliza y limpia',
      useCloud: true,
    });

    expect(result.transformations_applied).toContain('normalize_dates');
    expect(result.cleaned_rows).toBe(150);
    // Verificar que se registró en ai_job_events
    expect(mockPrisma.ai_job_events.createMany).toHaveBeenCalled();
  });

  it('debe hacer fallback a Llama local si Gemini falla', async () => {
    jest.spyOn(geminiService, 'process').mockRejectedValue(
      mockAiError('SERVICE_UNAVAILABLE')
    );
    jest.spyOn(llamaService, 'process').mockResolvedValue(
      mockLlamaResponse()
    );

    const result = await etlService.processFile({
      fileId: 'test-file-uuid',
      instructions: 'Analiza la estructura',
      useCloud: true, // Intentará Gemini primero
    });

    expect(result.model).toBe('llama-4-local');
    expect(llamaService.process).toHaveBeenCalledTimes(1);
  });
});
```

---

## Configuración de Herramientas

### Backend (Jest)

```json
// apps/api/package.json — sección jest
{
  "jest": {
    "moduleFileExtensions": ["js", "json", "ts"],
    "rootDir": "src",
    "testRegex": ".*\\.spec\\.ts$",
    "transform": { "^.+\\.(t|j)s$": "ts-jest" },
    "collectCoverageFrom": ["**/*.(t|j)s", "!**/*.module.ts", "!**/main.ts"],
    "coverageDirectory": "../coverage",
    "testEnvironment": "node",
    "coverageThreshold": {
      "global": { "branches": 70, "functions": 80, "lines": 80, "statements": 80 }
    }
  }
}
```

### Frontend (Vitest)

```typescript
// apps/client/vite.config.ts — sección test
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      thresholds: { lines: 70, functions: 75, branches: 65 },
      exclude: ['src/main.tsx', 'src/vite-env.d.ts', '**/*.stories.tsx'],
    },
  },
});
```

```typescript
// apps/client/src/test/setup.ts
import '@testing-library/jest-dom';
import { server } from './mocks/server';

beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));
afterEach(() => server.resetHandlers());
afterAll(() => server.close());
```

### Playwright (E2E)

```typescript
// playwright.config.ts (raíz del monorepo)
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './apps/client/e2e',
  fullyParallel: true,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: [['html', { outputFolder: 'playwright-report' }]],
  use: {
    baseURL: 'http://localhost:5173',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'Mobile Safari', use: { ...devices['iPhone 14'] } },
  ],
  webServer: {
    command: 'turbo dev --filter=client',
    url: 'http://localhost:5173',
    reuseExistingServer: !process.env.CI,
  },
});
```

### Turborepo — Pipeline de Pruebas

```json
// turbo.json — agregar tareas de test
{
  "$schema": "https://turborepo.org/schema.json",
  "tasks": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**"] },
    "test": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"],
      "env": ["DATABASE_URL", "JWT_SECRET"]
    },
    "test:cov": {
      "dependsOn": ["^build"],
      "outputs": ["coverage/**"]
    },
    "test:e2e": {
      "dependsOn": ["build"],
      "outputs": ["playwright-report/**"]
    }
  }
}
```

---

## Datos de Prueba (Seeds)

```typescript
// packages/database/test/seeds/index.ts

export const testUsers = {
  admin: {
    id: 'uuid-user-admin-001',
    email: 'admin@dataflow.test',
    password_hash: '$2b$10$...', // bcrypt de 'Admin1234!'
    role: 'ADMIN',
  },
  regular: {
    id: 'uuid-user-regular-001',
    email: 'user@dataflow.test',
    password_hash: '$2b$10$...', // bcrypt de 'User1234!'
    role: 'USER',
  },
  e2e: {
    id: 'uuid-user-e2e-001',
    email: 'e2e@dataflow.test',
    password_hash: '$2b$10$...',
    role: 'USER',
  },
};

export const testProjects = {
  withFiles: {
    id: 'uuid-project-001',
    name: 'Proyecto con Archivos',
    owner_id: 'uuid-user-regular-001',
  },
  empty: {
    id: 'uuid-project-002',
    name: 'Proyecto Vacío',
    owner_id: 'uuid-user-regular-001',
  },
};

export const testFiles = {
  csvClean: {
    id: 'uuid-file-csv-001',
    name: 'ventas_2024.csv',
    mime_type: 'text/csv',
    size_bytes: 15_240,
    project_id: 'uuid-project-001',
  },
  excelMultiSheet: {
    id: 'uuid-file-excel-001',
    name: 'reporte_trimestral.xlsx',
    mime_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    size_bytes: 48_300,
    project_id: 'uuid-project-001',
  },
};
```

---

## Cobertura Mínima Requerida por Módulo

| Módulo | Líneas | Funciones | Ramas | Tipo |
|--------|--------|-----------|-------|------|
| `AuthService` | 90% | 90% | 85% | Unitaria + Integración |
| `AiJobsService` | 85% | 85% | 80% | Unitaria + Mock IA |
| `DatasetsService` | 85% | 85% | 75% | Unitaria + Integración |
| `EtlTemplatesService` | 80% | 80% | 75% | Unitaria + Mock IA |
| `ReportsService` | 80% | 80% | 70% | Unitaria |
| `UsersService` | 80% | 80% | 70% | Unitaria + Integración |
| Frontend — Páginas | 70% | 75% | 65% | Componentes (RTL) |
| Frontend — Componentes UI | 65% | 70% | 60% | Componentes (RTL) |
| Flujos E2E críticos (F-01 a F-07) | — | — | — | Playwright |

---

## Tareas Técnicas

### Fase 1 — Infraestructura de Testing (Sprint 1)
1. [ ] Configurar Vitest + React Testing Library en `apps/client`.
2. [ ] Configurar MSW (Mock Service Worker) para mocks de API en frontend.
3. [ ] Crear helpers de test en backend: `createTestApp()`, `seedTestUser()`.
4. [ ] Crear `mockPrismaService` centralizado y reutilizable.
5. [ ] Crear mocks centralizados para Gemini y Llama 4.
6. [ ] Configurar Playwright en la raíz del monorepo.
7. [ ] Actualizar `turbo.json` con tareas `test`, `test:cov`, `test:e2e`.
8. [ ] Crear base de datos MySQL separada para pruebas: `dataflow_test`.

### Fase 2 — Pruebas de Backend (Sprint 2)
9. [ ] Escribir unit tests para `AuthService` (login, refresh, revoke).
10. [ ] Escribir unit tests para `AiJobsService` (CRUD + transición de estados).
11. [ ] Escribir unit tests para `DatasetsService` (upload, validación, lineage).
12. [ ] Escribir unit tests para `EtlTemplatesService` (crear, ejecutar, rollback).
13. [ ] Escribir integration tests E2E de API para auth, proyectos y archivos.

### Fase 3 — Pruebas de Frontend (Sprint 3)
14. [ ] Escribir component tests para `Login` y `Register`.
15. [ ] Escribir component tests para `FileUpload` (drag & drop, validación).
16. [ ] Escribir component tests para `AiJobStatus` (polling, estados).
17. [ ] Escribir component tests para `ProjectManager` (CRUD).
18. [ ] Escribir component tests para `NotificationCenter`.

### Fase 4 — Pruebas E2E (Sprint 4)
19. [ ] Implementar flujo E2E F-01: Registro → Login → Crear Proyecto → Subir CSV.
20. [ ] Implementar flujo E2E F-02: Ejecutar AI Job → Ver resultado.
21. [ ] Implementar flujo E2E F-03: Aplicar template ETL → Descargar.
22. [ ] Implementar flujo E2E F-04: Crear reporte con widgets.
23. [ ] Implementar flujo E2E F-06: Bloqueo por intentos fallidos.

---

## Dependencias a Instalar

### Backend

```bash
# Ya incluidas en NestJS por defecto
@nestjs/testing
jest
ts-jest
supertest
@types/supertest
```

### Frontend

```bash
# Vitest + RTL
vitest
@vitest/coverage-v8
@testing-library/react
@testing-library/user-event
@testing-library/jest-dom
jsdom

# Mock de API HTTP
msw

# E2E
@playwright/test
```

---

## Variables de Entorno para Pruebas

```bash
# .env.test
NODE_ENV=test
DATABASE_URL="mysql://root:root@localhost:3306/dataflow_test"
JWT_SECRET="test-secret-key-not-for-production"
JWT_REFRESH_SECRET="test-refresh-secret"
AI_GEMINI_API_KEY="mock-key-not-used-in-tests"
AI_OLLAMA_URL="http://localhost:11434"  # No se llama en tests (mockeado)
N8N_BASE_URL="http://localhost:5678"    # No se llama en tests (mockeado)
```

---

## Prioridad

**Alta** — sin un plan de pruebas robusto, cualquier cambio en el pipeline ETL, la lógica de IA o el esquema de base de datos puede romper el sistema silenciosamente. Implementar desde el primer sprint de desarrollo activo.

---

## Notas Adicionales

- **Datos reales nunca en pruebas:** Todos los datasets de prueba (`fixtures/`) deben ser sintéticos o anonimizados. Cumplimiento con Ley 1581.
- **Pruebas de IA son costosas:** Jamás llamar a Gemini o Llama 4 real en las pruebas automatizadas. Solo en pruebas manuales de validación de calidad de respuesta.
- **Playwright sobre Cypress:** Se elige Playwright por soporte multi-browser nativo, mejor integración con TypeScript, y licencia sin restricciones comerciales.
- **MSW sobre jest.mock para HTTP:** MSW intercepta a nivel de red (más realista), permite reutilizar mocks entre unit tests y E2E, y refleja mejor el comportamiento real del navegador.
