-- ============================================================
-- MIGRACIÓN HU-027: Gestión de Templates ETL y Transformaciones Predefinidas
-- v3.8 → v3.9
--
-- Estrategia:
--   1. Crear etl_templates y etl_template_steps.
--   2. Crear etl_executions y etl_execution_logs.
--   3. Insertar templates iniciales del sistema.
--   4. Crear índices.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. ETL_TEMPLATES
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS etl_templates (
    id_template INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NULL,
    created_by INT NULL,
    template_name VARCHAR(255) NOT NULL,
    description TEXT,
    category ENUM('cleaning','transformation','validation','enrichment','optimization') DEFAULT 'transformation',
    difficulty ENUM('easy','medium','advanced') DEFAULT 'easy',
    estimated_time_minutes INT DEFAULT 5,
    icon VARCHAR(100),
    color VARCHAR(50),
    is_system BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT FALSE,
    version VARCHAR(20) DEFAULT '1.0.0',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_templates_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_templates_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 2. ETL_TEMPLATE_STEPS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS etl_template_steps (
    id_step INT AUTO_INCREMENT PRIMARY KEY,
    id_template INT NOT NULL,
    step_order INT NOT NULL,
    step_name VARCHAR(255) NOT NULL,
    operation_type ENUM(
        'remove_duplicates',
        'normalize',
        'fill_nulls',
        'validate',
        'enrich',
        'optimize_schema',
        'custom'
    ) NOT NULL,
    configuration JSON NULL,
    ai_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_steps_template
        FOREIGN KEY (id_template)
        REFERENCES etl_templates(id_template)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 3. ETL_EXECUTIONS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS etl_executions (
    id_execution INT AUTO_INCREMENT PRIMARY KEY,
    id_template INT NOT NULL,
    id_project INT NOT NULL,
    id_generated_table INT NOT NULL,
    executed_by INT NULL,
    id_conversation INT NULL,
    id_message INT NULL,

    execution_status ENUM('pending','running','completed','failed','cancelled') DEFAULT 'pending',
    started_at TIMESTAMP NULL,
    finished_at TIMESTAMP NULL,
    execution_time_ms BIGINT DEFAULT 0,
    rows_processed BIGINT DEFAULT 0,
    output_generated_table_id INT NULL,
    logs_path TEXT NULL,
    error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_exec_template
        FOREIGN KEY (id_template)
        REFERENCES etl_templates(id_template)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_exec_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_exec_dataset
        FOREIGN KEY (id_generated_table)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE CASCADE,

    CONSTRAINT fk_etl_exec_user
        FOREIGN KEY (executed_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_etl_exec_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_etl_exec_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_etl_exec_output_dataset
        FOREIGN KEY (output_generated_table_id)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 4. ETL_EXECUTION_LOGS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS etl_execution_logs (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_execution INT NOT NULL,
    log_level ENUM('info','warning','error') DEFAULT 'info',
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_etl_logs_execution
        FOREIGN KEY (id_execution)
        REFERENCES etl_executions(id_execution)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 5. SEED: templates iniciales del sistema
-- ------------------------------------------------------------

INSERT IGNORE INTO etl_templates (id_template, id_project, created_by, template_name, description, category, difficulty, estimated_time_minutes, icon, color, is_system, is_public, version)
VALUES
(1, NULL, NULL, 'Eliminación de Duplicados', 'Detecta y elimina registros duplicados', 'cleaning', 'easy', 5, 'copy-x', 'green', TRUE, TRUE, '1.0.0'),
(2, NULL, NULL, 'Normalización de Datos', 'Normaliza formatos comunes (fechas/texto/números)', 'transformation', 'medium', 10, 'sliders', 'blue', TRUE, TRUE, '1.0.0'),
(3, NULL, NULL, 'Manejo de Valores Faltantes', 'Detecta nulos y aplica estrategia de relleno', 'cleaning', 'medium', 10, 'droplet', 'teal', TRUE, TRUE, '1.0.0'),
(4, NULL, NULL, 'Validación de Datos', 'Valida reglas y detecta anomalías', 'validation', 'medium', 10, 'check-circle', 'purple', TRUE, TRUE, '1.0.0'),
(5, NULL, NULL, 'Enriquecimiento de Datos', 'Crea columnas derivadas y métricas', 'enrichment', 'advanced', 20, 'sparkles', 'orange', TRUE, TRUE, '1.0.0'),
(6, NULL, NULL, 'Optimización de Esquema', 'Sugiere/optimiza tipos para reducir peso', 'optimization', 'advanced', 20, 'zap', 'yellow', TRUE, TRUE, '1.0.0');

INSERT IGNORE INTO etl_template_steps (id_template, step_order, step_name, operation_type, configuration, ai_enabled)
VALUES
(1, 1, 'Eliminar duplicados', 'remove_duplicates', NULL, FALSE),
(2, 1, 'Normalizar', 'normalize', NULL, TRUE),
(3, 1, 'Rellenar nulos', 'fill_nulls', NULL, TRUE),
(4, 1, 'Validar', 'validate', NULL, TRUE),
(5, 1, 'Enriquecer', 'enrich', NULL, TRUE),
(6, 1, 'Optimizar esquema', 'optimize_schema', NULL, TRUE);

-- ------------------------------------------------------------
-- 6. ÍNDICES
-- ------------------------------------------------------------

CREATE INDEX idx_etl_templates_project      ON etl_templates(id_project);
CREATE INDEX idx_etl_templates_user         ON etl_templates(created_by);
CREATE INDEX idx_etl_templates_category     ON etl_templates(category);
CREATE INDEX idx_etl_templates_system       ON etl_templates(is_system);
CREATE INDEX idx_etl_steps_template         ON etl_template_steps(id_template);
CREATE INDEX idx_etl_steps_order            ON etl_template_steps(id_template, step_order);
CREATE INDEX idx_etl_exec_template          ON etl_executions(id_template);
CREATE INDEX idx_etl_exec_project           ON etl_executions(id_project);
CREATE INDEX idx_etl_exec_dataset           ON etl_executions(id_generated_table);
CREATE INDEX idx_etl_exec_output_dataset    ON etl_executions(output_generated_table_id);
CREATE INDEX idx_etl_exec_status            ON etl_executions(execution_status);
CREATE INDEX idx_etl_exec_conversation      ON etl_executions(id_conversation);
CREATE INDEX idx_etl_exec_message           ON etl_executions(id_message);
CREATE INDEX idx_etl_logs_execution         ON etl_execution_logs(id_execution);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'etl_templates', COUNT(*) FROM etl_templates;
-- SELECT 'etl_template_steps', COUNT(*) FROM etl_template_steps;
-- SELECT 'etl_executions', COUNT(*) FROM etl_executions;
-- SELECT 'etl_execution_logs', COUNT(*) FROM etl_execution_logs;

COMMIT;
