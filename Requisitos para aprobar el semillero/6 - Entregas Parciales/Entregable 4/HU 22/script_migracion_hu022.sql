-- ============================================================
-- MIGRACIÓN HU-022: Tracking y logging de AI_JOBS y procesos
-- v3.3 → v3.4
--
-- Estrategia:
--   1. Extender ai_jobs con campos de lifecycle, métricas, origen, errores.
--   2. Crear ai_job_events para log de eventos.
--   3. Extender ai_results con output enriquecido y estado.
--   4. Crear índices nuevos.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. EXTENDER ai_jobs
-- ------------------------------------------------------------

-- 1a. Campos de contexto
ALTER TABLE ai_jobs
    ADD COLUMN prompt_metadata JSON NULL AFTER prompt_text,
    ADD COLUMN input_data_reference TEXT NULL AFTER prompt_metadata,
    ADD COLUMN created_from VARCHAR(100) NULL AFTER is_private;

-- 1b. Campos de lifecycle
ALTER TABLE ai_jobs
    ADD COLUMN queued_at TIMESTAMP NULL AFTER status_changed_at,
    ADD COLUMN processing_at TIMESTAMP NULL AFTER started_at,
    ADD COLUMN failed_at TIMESTAMP NULL AFTER finished_at,
    ADD COLUMN cancelled_at TIMESTAMP NULL AFTER failed_at,
    ADD COLUMN requeued_at TIMESTAMP NULL AFTER cancelled_at,
    ADD COLUMN updated_source VARCHAR(100) NULL AFTER requeued_at;

-- 1c. Renombrar tokens y agregar total calculado
ALTER TABLE ai_jobs
    CHANGE COLUMN tokens_input tokens_prompt INT DEFAULT 0,
    CHANGE COLUMN tokens_output tokens_completion INT DEFAULT 0;

ALTER TABLE ai_jobs
    ADD COLUMN tokens_total INT GENERATED ALWAYS AS (tokens_prompt + tokens_completion) STORED AFTER tokens_completion;

-- 1d. Campos de tiempo adicional
ALTER TABLE ai_jobs
    ADD COLUMN elapsed_time_ms INT DEFAULT 0 AFTER processing_time_ms;

-- 1e. Campos de costos
ALTER TABLE ai_jobs
    ADD COLUMN cost_estimated DECIMAL(12,6) NULL AFTER elapsed_time_ms,
    ADD COLUMN cost_actual DECIMAL(12,6) NULL AFTER cost_estimated;

-- 1f. Proveedor / modelo
ALTER TABLE ai_jobs
    ADD COLUMN provider_request_id VARCHAR(255) NULL AFTER cost_actual,
    ADD COLUMN model_version_snapshot VARCHAR(100) NULL AFTER provider_request_id,
    ADD COLUMN model_info JSON NULL AFTER model_version_snapshot;

-- 1g. Origen contextual
ALTER TABLE ai_jobs
    ADD COLUMN id_conversation INT NULL AFTER model_info,
    ADD COLUMN id_message INT NULL AFTER id_conversation,
    ADD COLUMN id_task INT NULL AFTER id_message;

ALTER TABLE ai_jobs
    ADD CONSTRAINT fk_ai_jobs_conversation
        FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE SET NULL,
    ADD CONSTRAINT fk_ai_jobs_message
        FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE SET NULL,
    ADD CONSTRAINT fk_ai_jobs_task
        FOREIGN KEY (id_task) REFERENCES tasks(id_task) ON DELETE SET NULL;

-- 1h. Errores y reintentos
ALTER TABLE ai_jobs
    ADD COLUMN error_message TEXT NULL AFTER id_task,
    ADD COLUMN error_stack TEXT NULL AFTER error_message,
    ADD COLUMN error_context JSON NULL AFTER error_stack,
    ADD COLUMN retries_attempted INT DEFAULT 0 AFTER error_context,
    ADD COLUMN max_retries INT DEFAULT 3 AFTER retries_attempted,
    ADD COLUMN next_retry_at TIMESTAMP NULL AFTER max_retries,
    ADD COLUMN final_error_code VARCHAR(100) NULL AFTER next_retry_at;

-- 1i. Worker / cola
ALTER TABLE ai_jobs
    ADD COLUMN worker_id VARCHAR(100) NULL AFTER final_error_code,
    ADD COLUMN queue_name VARCHAR(100) NULL AFTER worker_id;

-- ------------------------------------------------------------
-- 2. CREAR ai_job_events
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ai_job_events (
    id_job_event INT AUTO_INCREMENT PRIMARY KEY,
    id_job INT NOT NULL,
    event_type ENUM('created','queued','started','completed','failed','retry','cancelled','warning','info') NOT NULL,
    event_message TEXT NULL,
    event_data JSON NULL,
    actor_type ENUM('user','system','worker','scheduler') DEFAULT 'system',
    actor_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ai_job_events_job
        FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE CASCADE,

    CONSTRAINT fk_ai_job_events_actor
        FOREIGN KEY (actor_id)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 3. EXTENDER ai_results
-- ------------------------------------------------------------

ALTER TABLE ai_results
    ADD COLUMN output_raw LONGTEXT NULL AFTER output_path,
    ADD COLUMN output_json JSON NULL AFTER output_raw,
    ADD COLUMN result_metadata JSON NULL AFTER output_json,
    ADD COLUMN result_source VARCHAR(100) NULL AFTER result_metadata,
    ADD COLUMN is_successful BOOLEAN DEFAULT TRUE AFTER result_source,
    ADD COLUMN error_code VARCHAR(100) NULL AFTER is_successful,
    ADD COLUMN error_message TEXT NULL AFTER error_code,
    ADD COLUMN finished_at TIMESTAMP NULL AFTER error_message;

-- ------------------------------------------------------------
-- 4. CREAR ÍNDICES
-- ------------------------------------------------------------

-- ai_jobs: nuevos campos
CREATE INDEX idx_ai_jobs_conversation       ON ai_jobs(id_conversation);
CREATE INDEX idx_ai_jobs_message            ON ai_jobs(id_message);
CREATE INDEX idx_ai_jobs_task               ON ai_jobs(id_task);
CREATE INDEX idx_ai_jobs_queue              ON ai_jobs(queue_name);
CREATE INDEX idx_ai_jobs_worker             ON ai_jobs(worker_id);
CREATE INDEX idx_ai_jobs_error_code         ON ai_jobs(final_error_code);

-- ai_job_events
CREATE INDEX idx_ai_job_events_job          ON ai_job_events(id_job);
CREATE INDEX idx_ai_job_events_type         ON ai_job_events(event_type);
CREATE INDEX idx_ai_job_events_created      ON ai_job_events(created_at);

-- ai_results: nuevos campos
CREATE INDEX idx_ai_results_successful      ON ai_results(is_successful);
CREATE INDEX idx_ai_results_source          ON ai_results(result_source);

-- ------------------------------------------------------------
-- 5. MIGRAR DATOS (si existen jobs previos, crear evento inicial)
-- ------------------------------------------------------------

INSERT INTO ai_job_events (id_job, event_type, event_message, actor_type, created_at)
SELECT id_job, 'info', 'Evento creado retroactivamente por migración HU-022', 'system', created_at
FROM ai_jobs
WHERE deleted_at IS NULL;

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'ai_jobs columns', COUNT(*) FROM information_schema.columns
--     WHERE table_schema='ia_dataflow' AND table_name='ai_jobs' AND column_name='tokens_prompt';
-- SELECT 'ai_job_events', COUNT(*) FROM ai_job_events;
-- SELECT 'ai_results output_raw', COUNT(*) FROM information_schema.columns
--     WHERE table_schema='ia_dataflow' AND table_name='ai_results' AND column_name='output_raw';

COMMIT;
