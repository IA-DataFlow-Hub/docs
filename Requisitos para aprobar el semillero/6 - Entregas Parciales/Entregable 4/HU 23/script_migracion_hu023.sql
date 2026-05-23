-- ============================================================
-- MIGRACIÓN HU-023: Sistema de Feedback y Reporte de Chats
-- v3.4 → v3.5
--
-- Estrategia:
--   1. Crear message_feedback para like/dislike por usuario y mensaje.
--   2. Crear reports para incidencias sobre mensajes, conversaciones o aplicación.
--   3. Crear índices para consultas frecuentes y gestión administrativa.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. MESSAGE_FEEDBACK
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS message_feedback (
    id_feedback INT AUTO_INCREMENT PRIMARY KEY,
    id_message INT NOT NULL,
    id_user INT NOT NULL,
    feedback_type ENUM('like','dislike') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_feedback_unique
        UNIQUE (id_message, id_user),

    CONSTRAINT fk_feedback_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE CASCADE,

    CONSTRAINT fk_feedback_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 2. REPORTS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS reports (
    id_report INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,

    report_type ENUM('message','conversation','application') NOT NULL,
    id_message INT NULL,
    id_conversation INT NULL,
    id_project INT NULL,

    category ENUM(
        'incorrect_response',
        'false_information',
        'offensive_content',
        'technical_error',
        'duplication',
        'performance_issue',
        'security_issue',
        'ui_bug',
        'auth_issue',
        'loading_issue',
        'flow_error',
        'out_of_context',
        'other'
    ) DEFAULT 'other',

    priority ENUM('low','medium','high','critical') DEFAULT 'medium',
    description TEXT,
    status ENUM('pending','in_review','resolved','rejected') DEFAULT 'pending',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_reports_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_reports_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_reports_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_reports_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE SET NULL,

    CONSTRAINT fk_reports_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_reports_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT chk_reports_reference
        CHECK (
            (report_type = 'message' AND id_message IS NOT NULL)
            OR (report_type = 'conversation' AND id_conversation IS NOT NULL)
            OR (report_type = 'application')
        )
);

-- ------------------------------------------------------------
-- 3. ÍNDICES
-- ------------------------------------------------------------

CREATE INDEX idx_message_feedback_message   ON message_feedback(id_message);
CREATE INDEX idx_message_feedback_user      ON message_feedback(id_user);
CREATE INDEX idx_reports_user               ON reports(id_user);
CREATE INDEX idx_reports_type               ON reports(report_type);
CREATE INDEX idx_reports_status             ON reports(status);
CREATE INDEX idx_reports_priority           ON reports(priority);
CREATE INDEX idx_reports_message            ON reports(id_message);
CREATE INDEX idx_reports_conversation       ON reports(id_conversation);
CREATE INDEX idx_reports_project            ON reports(id_project);
CREATE INDEX idx_reports_deleted            ON reports(deleted_at);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'message_feedback table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='message_feedback';
-- SELECT 'reports table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='reports';
-- SELECT 'feedback unique', COUNT(*) FROM information_schema.table_constraints
--     WHERE table_schema='ia_dataflow' AND table_name='message_feedback' AND constraint_name='uq_feedback_unique';

COMMIT;
