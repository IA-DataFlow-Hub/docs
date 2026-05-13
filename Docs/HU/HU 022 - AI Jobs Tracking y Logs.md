# HU-022: Mejorar el Tracking y Logging de AI_JOBS y Procesos en Segundo Plano

## Historia de Usuario
**Como** administrador/integrador del sistema IA-DataFlow,  
**Quiero** que todos los trabajos de IA y procesos en segundo plano queden registrados con detalle,  
**Para** poder auditar la ejecución, analizar fallos, medir consumo y comprender exactamente qué hizo la IA en cada paso.

## Criterios de Aceptación
- Cada `ai_job` debe registrar su historial completo: creación, colas, ejecución, errores, reintentos y resultados.
- Debe existir un registro de eventos o log específico para cada trabajo de IA.
- Deben almacenarse los inputs y outputs relevantes del modelo, incluyendo prompt, respuesta y metadatos.
- Debe poderse trazar el trabajo desde su origen (proyecto, conversación, archivo, tarea) hasta el resultado final.
- Deben capturarse datos de uso del modelo: tokens, duración, memoria, costo estimado si aplica.
- Debe existir una distinción clara entre estado del trabajo y estado del resultado.
- Debe registrar la causa de fallo y si hubo reintentos automáticos.
- Debe soportar procesos en segundo plano asociados, como transformaciones, validaciones y pipelines.

## Puntos de Mejora
### 1. Registrar el lifecycle completo de AI jobs
- `created_at` y `updated_at` ya existen, pero falta trazabilidad de transición de estado.
- Agregar `queued_at`, `processing_at`, `failed_at`, `cancelled_at`, `requeued_at`.
- Registrar quién/qué desencadenó el cambio de estado (`updated_by`, `updated_source`).

### 2. Capturar eventos detallados por trabajo
- Crear tabla `ai_job_events` o `ai_job_logs` con:
  - `id_job_event`
  - `id_job`
  - `event_type` (created, queued, started, completed, failed, retry, cancelled, warning)
  - `event_message`
  - `event_data` JSON
  - `created_at`
  - `created_by` o `actor_type`

### 3. Guardar prompt/entrada y salida exacta
- `ai_jobs.prompt_text` debe complementarse con:
  - `prompt_metadata` JSON
  - `input_data_reference` si viene de un archivo/conversación
- `ai_results` debe tener:
  - `output_raw` o `output_json`
  - `result_metadata` JSON
  - `model_version` y `model_info` capturados en la ejecución

### 4. Mejorar métricas y costos
- Guardar tokens usados por paso: `tokens_prompt`, `tokens_completion`, `tokens_total`.
- Guardar duración real y latencia: `processing_time_ms`, `elapsed_time_ms`.
- Si se usa cloud, registrar `cost_estimated`, `cost_actual`, `region`, `provider_request_id`.

### 5. Diferenciar trabajo de resultado
- `ai_jobs.status` representa el trabajo en cola/executado.
- `ai_results` debería tener su propio `status` o `is_successful` y `error_code`.
- Registrar `result_type` y `result_source` para distinguir resumen, transformación, análisis, etc.

### 6. Asociaciones de origen y contexto
- Conectar `ai_jobs` con el origen real:
  - `id_project`
  - `id_file`
  - `id_conversation` si aplica
  - `id_message` si corresponde
  - `id_task` si el job surge de una tarea
- Esto permite ver qué chat disparó qué tarea de IA.

### 7. Almacenamiento de logs y datos de proceso en segundo plano
- Crear tabla `background_processes` o `job_runners` si hay pipelines separados.
- Registrar cada paso de pipeline con su resultado y estado.
- Registrar `worker_id`, `queue_name`, `retry_count`, `next_retry_at`.

### 8. Reportar errores y detalles de rollback
- Incluir campos para:
  - `error_message`
  - `error_stack`
  - `error_context` JSON
  - `retries_attempted`
  - `final_error_code`
- Registrar si el resultado fue revertido o invalidado.

## Impacto en el esquema actual
- `ai_jobs` necesita más campos de trazabilidad de estado y de proceso.
- `ai_results` necesita datos de output más ricos y éxito/fallo separados.
- Una tabla de eventos/logs complementa bien sin sobrecargar `ai_jobs`.
- La relación con `conversations` y `messages` debe reforzarse si el trabajo se origina desde un chat.

## Tareas Técnicas
1. Definir campos adicionales en `ai_jobs` para tiempos y estado.
2. Crear `ai_job_events` o `ai_job_logs`.
3. Extender `ai_results` con `output_raw`, `result_metadata`, `is_successful`, `error_code`.
4. Refactorizar guardado de prompts y outputs para conservar el contexto.
5. Agregar campos opcionales de costo/uso/modelo.
6. Actualizar lógica de negocio para llenar eventos y estados.
7. Documentar el flujo de trabajo completo en el esquema.

## Ejemplo SQL
```sql
-- Extiende ai_jobs con trazabilidad y métricas
ALTER TABLE ai_jobs
    ADD COLUMN created_by INT NULL,
    ADD COLUMN created_from VARCHAR(100) NULL,
    ADD COLUMN queued_at TIMESTAMP NULL,
    ADD COLUMN processing_at TIMESTAMP NULL,
    ADD COLUMN failed_at TIMESTAMP NULL,
    ADD COLUMN cancelled_at TIMESTAMP NULL,
    ADD COLUMN requeued_at TIMESTAMP NULL,
    ADD COLUMN updated_by INT NULL,
    ADD COLUMN updated_source VARCHAR(100) NULL,
    ADD COLUMN tokens_prompt INT DEFAULT 0,
    ADD COLUMN tokens_completion INT DEFAULT 0,
    ADD COLUMN tokens_total INT AS (tokens_prompt + tokens_completion) PERSISTENT,
    ADD COLUMN elapsed_time_ms INT DEFAULT 0,
    ADD COLUMN cost_estimated DECIMAL(12,6) NULL,
    ADD COLUMN cost_actual DECIMAL(12,6) NULL,
    ADD COLUMN provider_request_id VARCHAR(255) NULL,
    ADD COLUMN model_version VARCHAR(100) NULL,
    ADD COLUMN model_info JSON NULL,
    ADD COLUMN origin_conversation_id INT NULL,
    ADD COLUMN origin_message_id INT NULL;

CREATE TABLE ai_job_events (
    id_job_event INT AUTO_INCREMENT PRIMARY KEY,
    id_job INT NOT NULL,
    event_type ENUM('created','queued','started','completed','failed','retry','cancelled','warning','info') NOT NULL,
    event_message TEXT NULL,
    event_data JSON NULL,
    actor_type ENUM('user','system','worker','scheduler') DEFAULT 'system',
    actor_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_job_events_job FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE CASCADE
);

ALTER TABLE ai_results
    ADD COLUMN output_raw LONGTEXT NULL,
    ADD COLUMN output_json JSON NULL,
    ADD COLUMN result_metadata JSON NULL,
    ADD COLUMN is_successful BOOLEAN DEFAULT TRUE,
    ADD COLUMN error_code VARCHAR(100) NULL,
    ADD COLUMN error_message TEXT NULL,
    ADD COLUMN result_source VARCHAR(100) NULL,
    ADD COLUMN finished_at TIMESTAMP NULL;
```

## Prioridad
Alta - esencial para monitoreo, soporte, auditoría y mejora continua de los trabajos de IA.