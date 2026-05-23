-- ============================================================
-- MIGRACIÓN HU-024: Gestión Avanzada de Sesiones y Dispositivos
-- v3.5 → v3.6
--
-- Estrategia:
--   1. Extender sessions con refresh token, datos de dispositivo, ubicación,
--      estado, actividad, heartbeat y revocación.
--   2. Inicializar datos existentes con valores seguros.
--   3. Crear índices para consultas de sesiones activas y administración.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. EXTENDER sessions
-- ------------------------------------------------------------

ALTER TABLE sessions
    ADD COLUMN refresh_token VARCHAR(255) NULL AFTER session_token,
    ADD COLUMN browser_name VARCHAR(100) NULL AFTER user_agent,
    ADD COLUMN browser_version VARCHAR(50) NULL AFTER browser_name,
    ADD COLUMN operating_system VARCHAR(100) NULL AFTER browser_version,
    ADD COLUMN operating_system_version VARCHAR(50) NULL AFTER operating_system,
    ADD COLUMN device_type ENUM('desktop','mobile','tablet','bot','unknown') DEFAULT 'unknown' AFTER operating_system_version,
    ADD COLUMN device_name VARCHAR(150) NULL AFTER device_type,
    ADD COLUMN country VARCHAR(100) NULL AFTER device_name,
    ADD COLUMN city VARCHAR(100) NULL AFTER country,
    ADD COLUMN is_current BOOLEAN DEFAULT FALSE AFTER city,
    ADD COLUMN status ENUM('active','inactive','expired','revoked') DEFAULT 'active' AFTER is_current,
    ADD COLUMN login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER status,
    ADD COLUMN last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP AFTER login_at,
    ADD COLUMN last_action VARCHAR(255) NULL AFTER last_activity_at,
    ADD COLUMN heartbeat_at TIMESTAMP NULL AFTER last_action,
    ADD COLUMN revoked_at TIMESTAMP NULL DEFAULT NULL AFTER expires_at,
    ADD COLUMN revoke_reason VARCHAR(255) NULL AFTER revoked_at;

-- ------------------------------------------------------------
-- 2. INICIALIZAR SESIONES EXISTENTES
-- ------------------------------------------------------------

UPDATE sessions
SET
    login_at = COALESCE(created_at, CURRENT_TIMESTAMP),
    last_activity_at = COALESCE(updated_at, created_at, CURRENT_TIMESTAMP),
    status = CASE
        WHEN deleted_at IS NOT NULL THEN 'revoked'
        WHEN expires_at IS NOT NULL AND expires_at < CURRENT_TIMESTAMP THEN 'expired'
        ELSE 'active'
    END,
    revoked_at = CASE
        WHEN deleted_at IS NOT NULL THEN deleted_at
        ELSE revoked_at
    END,
    revoke_reason = CASE
        WHEN deleted_at IS NOT NULL THEN 'Migrated from soft-deleted session'
        ELSE revoke_reason
    END;

-- ------------------------------------------------------------
-- 3. ÍNDICES
-- ------------------------------------------------------------

CREATE INDEX idx_sessions_user              ON sessions(id_user);
CREATE INDEX idx_sessions_status            ON sessions(status);
CREATE INDEX idx_sessions_last_activity     ON sessions(last_activity_at);
CREATE INDEX idx_sessions_token             ON sessions(session_token);
CREATE INDEX idx_sessions_refresh_token     ON sessions(refresh_token);
CREATE INDEX idx_sessions_device_type       ON sessions(device_type);
CREATE INDEX idx_sessions_revoked_at        ON sessions(revoked_at);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'sessions status column', COUNT(*) FROM information_schema.columns
--     WHERE table_schema='ia_dataflow' AND table_name='sessions' AND column_name='status';
-- SELECT 'active sessions', COUNT(*) FROM sessions WHERE status = 'active' AND deleted_at IS NULL;
-- SELECT 'session indexes', COUNT(*) FROM information_schema.statistics
--     WHERE table_schema='ia_dataflow' AND table_name='sessions' AND index_name IN (
--         'idx_sessions_user', 'idx_sessions_status', 'idx_sessions_last_activity'
--     );

COMMIT;
