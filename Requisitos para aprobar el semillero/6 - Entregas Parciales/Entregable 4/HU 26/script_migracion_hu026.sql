-- ============================================================
-- MIGRACIÓN HU-026: Gestión de Datasets, Tablas Generadas y Lineage
-- v3.7 → v3.8
--
-- Estrategia:
--   1. Crear generated_tables para metadata, almacenamiento físico y lineage.
--   2. Crear generated_table_columns para esquema/columnas.
--   3. Crear índices para consultas por proyecto/chat/IA y lineage.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. GENERATED_TABLES
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS generated_tables (
    id_generated_table INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_conversation INT NULL,
    id_message INT NULL,
    id_user INT NULL,
    id_job INT NULL,
    source_file_id INT NULL,
    parent_generated_table_id INT NULL,
    table_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255),
    description TEXT,
    storage_type ENUM('csv','json','parquet','xlsx') DEFAULT 'parquet',
    storage_path TEXT NOT NULL,
    preview_path TEXT NULL,
    schema_path TEXT NULL,
    rows_count BIGINT DEFAULT 0,
    columns_count INT DEFAULT 0,
    file_size BIGINT DEFAULT 0,
    generation_type ENUM('uploaded','ai_generated','transformed','imported') DEFAULT 'uploaded',
    status ENUM('processing','ready','failed','archived') DEFAULT 'ready',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_gt_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_gt_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_job
        FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_source_file
        FOREIGN KEY (source_file_id)
        REFERENCES files(id_file)
        ON DELETE SET NULL,

    CONSTRAINT fk_gt_parent
        FOREIGN KEY (parent_generated_table_id)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 2. GENERATED_TABLE_COLUMNS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS generated_table_columns (
    id_column INT AUTO_INCREMENT PRIMARY KEY,
    id_generated_table INT NOT NULL,
    column_name VARCHAR(255) NOT NULL,
    data_type VARCHAR(100),
    is_nullable BOOLEAN DEFAULT TRUE,
    is_primary_key BOOLEAN DEFAULT FALSE,
    is_foreign_key BOOLEAN DEFAULT FALSE,
    is_unique_column BOOLEAN DEFAULT FALSE,
    default_value TEXT,
    validations JSON NULL,
    column_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_gtc_table
        FOREIGN KEY (id_generated_table)
        REFERENCES generated_tables(id_generated_table)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 3. ÍNDICES
-- ------------------------------------------------------------

CREATE INDEX idx_gt_project                 ON generated_tables(id_project);
CREATE INDEX idx_gt_conversation            ON generated_tables(id_conversation);
CREATE INDEX idx_gt_message                 ON generated_tables(id_message);
CREATE INDEX idx_gt_user                    ON generated_tables(id_user);
CREATE INDEX idx_gt_job                     ON generated_tables(id_job);
CREATE INDEX idx_gt_source_file             ON generated_tables(source_file_id);
CREATE INDEX idx_gt_parent                  ON generated_tables(parent_generated_table_id);
CREATE INDEX idx_gt_status                  ON generated_tables(status);
CREATE INDEX idx_gt_generation_type         ON generated_tables(generation_type);
CREATE INDEX idx_gtc_table                  ON generated_table_columns(id_generated_table);
CREATE INDEX idx_gtc_column_name            ON generated_table_columns(column_name);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'generated_tables table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='generated_tables';
-- SELECT 'generated_table_columns table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='generated_table_columns';

COMMIT;
