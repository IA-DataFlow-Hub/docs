-- ============================================================
-- MIGRACIÓN HU-028: Feed de Actividad y Timeline de Eventos
-- v3.9 → v3.10
--
-- Estrategia:
--   1. Crear activity_feed (eventos cronológicos por proyecto).
--   2. Relacionar con: project, user, workflow_phase, conversation,
--      message, generated_table, ai_job, etl_execution, file.
--   3. Crear índices para feed cronológico y filtros.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. ACTIVITY_FEED
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS activity_feed (
    id_activity INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_user INT NULL,
    id_phase INT NULL,
    id_conversation INT NULL,
    id_message INT NULL,
    id_generated_table INT NULL,
    id_job INT NULL,
    id_execution INT NULL,
    id_file INT NULL,

    activity_type ENUM(
        'file_uploaded',
        'analysis_completed',
        'transformation_applied',
        'data_edited',
        'optimization_suggested',
        'etl_executed',
        'validation_completed',
        'comment_added',
        'dataset_generated',
        'error_detected',
        'export_generated',
        'user_login',
        'report_created'
    ) NOT NULL,

    activity_level ENUM('info','success','warning','error','critical') DEFAULT 'info',
    title VARCHAR(255) NOT NULL,
    description TEXT,
    metadata JSON NULL,
    is_system_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_activity_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_activity_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_phase
        FOREIGN KEY (id_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_dataset
        FOREIGN KEY (id_generated_table)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_job
        FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_execution
        FOREIGN KEY (id_execution)
        REFERENCES etl_executions(id_execution)
        ON DELETE SET NULL,

    CONSTRAINT fk_activity_file
        FOREIGN KEY (id_file)
        REFERENCES files(id_file)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 2. ÍNDICES (filtros del feed: por proyecto, usuario, tipo,
--    fase, fecha, conversación y dataset)
-- ------------------------------------------------------------

CREATE INDEX idx_activity_project           ON activity_feed(id_project);
CREATE INDEX idx_activity_user              ON activity_feed(id_user);
CREATE INDEX idx_activity_type              ON activity_feed(activity_type);
CREATE INDEX idx_activity_created           ON activity_feed(created_at);
CREATE INDEX idx_activity_phase             ON activity_feed(id_phase);
CREATE INDEX idx_activity_conversation      ON activity_feed(id_conversation);
CREATE INDEX idx_activity_dataset           ON activity_feed(id_generated_table);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'activity_feed', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='activity_feed';
-- SHOW INDEX FROM activity_feed;

COMMIT;
