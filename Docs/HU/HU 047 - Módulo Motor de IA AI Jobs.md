# HU-047 — Módulo de Motor de IA (AI Jobs)

## Asignación de Tablas

`ai_jobs` · `ai_job_events` · `ai_results` · `ai_engines` · `ai_engine_types` · `ai_job_statuses` · `ai_result_types`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de AI Jobs siguiendo Clean Architecture,  
**Para** orquestar la ejecución de trabajos de inteligencia artificial, registrar el ciclo de vida completo (encolamiento → procesamiento → completado/fallo), gestionar reintentos automáticos con backoff, métricas de tokens y costos, y almacenar los resultados generados por cada motor.

**Dependencia:** Requiere HU-043 (Projects), HU-044 (Files), HU-045 (Conversations) y HU-046 (Tasks).

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/ai-jobs/
├── ai-jobs.module.ts
├── domain/
│   ├── entities/
│   │   ├── ai-job.entity.ts
│   │   ├── ai-job-event.entity.ts
│   │   └── ai-result.entity.ts
│   └── repositories/
│       ├── ai-job.repository.interface.ts
│       └── ai-engine.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── request-job.dto.ts
│   │   ├── complete-job.dto.ts
│   │   ├── fail-job.dto.ts
│   │   ├── job-response.dto.ts
│   │   └── job-result-response.dto.ts
│   ├── use-cases/
│   │   ├── trigger-ai-job.use-case.ts
│   │   ├── start-ai-job.use-case.ts
│   │   ├── complete-ai-job.use-case.ts
│   │   ├── fail-ai-job.use-case.ts
│   │   ├── retry-ai-job.use-case.ts
│   │   └── cancel-ai-job.use-case.ts
│   └── facades/
│       └── ai-jobs.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── ai-jobs.controller.ts
    └── persistence/
        ├── prisma-ai-job.repository.ts
        ├── prisma-ai-engine.repository.ts
        └── mappers/
            ├── ai-job.mapper.ts
            └── ai-result.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Restricción de motor cloud en proyecto privado

**Dado** que `RequestJobDto` incluye un `id_engine` cuyo `id_ai_engine_type = 2` (cloud)  
**Cuando** `TriggerAiJobUseCase` verifica el proyecto  
**Entonces:**
- Consulta `ProjectsFacade.isProjectPrivate(id_project)`.
- Si retorna `true`, lanza `CloudEngineNotAllowedException` con código `AI_ENGINE_RESTRICTED` antes de persistir ningún registro.
- Si el motor es local (`id_ai_engine_type = 1`), continúa con la creación del job.

### Escenario 2 — Ciclo de vida completo con eventos auditados

**Dado** que un `AiJob` es creado con `TriggerAiJobUseCase`  
**Cuando** pasa por cada etapa del ciclo de vida  
**Entonces** cada transición registra un evento en `ai_job_events`:

| Caso de uso | Estado resultante | `ai_job_events.event_type` | Campos actualizados |
|-------------|-------------------|---------------------------|---------------------|
| TriggerAiJobUseCase | pending | `created` | `queued_at` |
| StartAiJobUseCase | processing | `started` | `started_at`, `processing_at` |
| CompleteAiJobUseCase | completed | `completed` | `finished_at`, `tokens_*` |
| FailAiJobUseCase | failed/pending | `failed` o `retry` | `failed_at` o `next_retry_at` |
| CancelAiJobUseCase | cancelled | `cancelled` | `cancelled_at` |

### Escenario 3 — Cálculo de tokens y persistencia de resultado

**Dado** que `CompleteAiJobUseCase` recibe `CompleteJobDto` con `tokens_prompt`, `tokens_completion` y `output_raw`  
**Cuando** ejecuta  
**Entonces:**
- La entidad `AiJob` calcula `tokens_total = tokens_prompt + tokens_completion` antes de persistir (no es columna generada en la BD; la app calcula el valor).
- Dentro de una transacción `$transaction`:
  1. Actualiza `ai_jobs` con los tokens, `finished_at`, `cost_actual` y `id_ai_job_status = 3` (completed).
  2. Inserta en `ai_results` con `is_successful = true`, `output_raw` y `output_json` si aplica.
  3. Registra el evento `completed` en `ai_job_events`.
- Invoca `ConversationsFacade.createAiMessage()` con la respuesta si el job tiene `id_conversation`.

### Escenario 4 — Tolerancia a fallos y reintentos con backoff exponencial

**Dado** que `FailAiJobUseCase` recibe un error de timeout  
**Cuando** evalúa el estado de reintentos  
**Entonces:**
- Si `retries_attempted < max_retries` (3 por defecto):
  - Incrementa `retries_attempted + 1`.
  - Calcula `next_retry_at = now() + 2^retries_attempted * 30s` (backoff exponencial).
  - Cambia `id_ai_job_status = 1` (pending) para reencolamiento.
  - Registra evento `retry` en `ai_job_events`.
- Si `retries_attempted >= max_retries`:
  - Actualiza `id_ai_job_status = 4` (failed), `failed_at = now()`, `final_error_code`, `error_message` y `error_stack`.
  - Inserta en `ai_results` con `is_successful = false` y `error_code`.
  - Registra evento `failed`.
  - El job queda en estado terminal; nunca se elimina físicamente.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/projects/:projectId/ai-jobs` | Disparar job de IA |
| GET | `/projects/:projectId/ai-jobs` | Listar jobs del proyecto |
| GET | `/ai-jobs/:id` | Detalle del job con estado actual |
| GET | `/ai-jobs/:id/events` | Timeline de eventos del job |
| GET | `/ai-jobs/:id/results` | Resultados del job |
| POST | `/ai-jobs/:id/cancel` | Cancelar job pendiente |
| GET | `/ai-engines` | Listado de motores disponibles |

---

## Notas Técnicas

- La comunicación real con el motor de IA (Ollama, Gemini) se realiza a través de un `AiEngineAdapterInterface`, inyectado en `TriggerAiJobUseCase`. Cada motor tiene su propia implementación en `infrastructure/adapters/`.
- `AiJobsFacade` exporta `getJobStatus(id_job)` para ser consumido por HU-048 (ETL) al vincular jobs a ejecuciones ETL.
- Los catálogos `ai_job_statuses` y `ai_result_types` son de solo lectura. El `AiJobMapper` los resuelve al construir el DTO de respuesta.
- Los campos `worker_id` y `queue_name` se usan cuando se integra un sistema de colas (Bull/BullMQ); en la primera versión pueden dejarse nulos.
