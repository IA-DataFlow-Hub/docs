-- ============================================================
-- MIGRACIÓN HU-019: user_preferences → configuration_keys + user_configurations
-- Reemplaza la tabla rígida por un sistema clave-valor flexible.
--
-- Estrategia:
--   1. Crear tablas nuevas (configuration_keys, user_configurations).
--   2. Insertar configuraciones iniciales en configuration_keys.
--   3. Migrar datos existentes de user_preferences a user_configurations.
--   4. Eliminar tabla user_preferences.
--   5. Eliminar tabla user_themes (ya no tiene dependencias).
--   6. Crear índices nuevos.
--
-- IMPORTANTE: Ejecutar dentro de una transacción / con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. CREAR TABLAS NUEVAS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS configuration_keys (
    id_config_key INT AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    value_type ENUM('string','boolean','number','json') NOT NULL,
    default_value TEXT NULL,
    is_required BOOLEAN DEFAULT FALSE,
    validation_rules JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_configurations (
    id_user_config INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_config_key INT NOT NULL,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_user_config (id_user, id_config_key),

    CONSTRAINT fk_user_config_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_config_key
        FOREIGN KEY (id_config_key)
        REFERENCES configuration_keys(id_config_key)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 2. INSERTAR CONFIGURACIONES INICIALES
-- ------------------------------------------------------------

INSERT IGNORE INTO configuration_keys
    (id_config_key, key_name, display_name, description, category, value_type, default_value, is_required, validation_rules)
VALUES
    (1, 'has_completed_tour', 'Tour completado',  'Indica si el usuario completó el tour de bienvenida',   'ui',            'boolean', 'false', FALSE, NULL),
    (2, 'theme',              'Tema de interfaz',  'Tema visual de la aplicación',                          'ui',            'string',  'dark',  FALSE, '{"allowed_values": ["dark", "light", "system"]}'),
    (3, 'language',           'Idioma',            'Idioma preferido de la interfaz',                       'ui',            'string',  'es',    FALSE, '{"allowed_values": ["es", "en", "pt"]}'),
    (4, 'notifications_enabled', 'Notificaciones', 'Habilitar o deshabilitar notificaciones',               'notifications', 'boolean', 'true',  FALSE, NULL);

-- ------------------------------------------------------------
-- 3. MIGRAR DATOS DE user_preferences → user_configurations
--    Solo migra valores que difieren del default para no llenar
--    la tabla innecesariamente. Si prefieres migrar TODOS los
--    valores, quita las condiciones WHERE.
-- ------------------------------------------------------------

-- 3a. has_completed_tour (config_key = 1)
INSERT INTO user_configurations (id_user, id_config_key, value, created_at, updated_at)
SELECT
    up.id_user,
    1,
    CASE WHEN up.has_completed_tour = TRUE THEN 'true' ELSE 'false' END,
    up.created_at,
    up.updated_at
FROM user_preferences up
WHERE up.deleted_at IS NULL;

-- 3b. theme (config_key = 2) — mapear id_user_theme → nombre del tema
INSERT INTO user_configurations (id_user, id_config_key, value, created_at, updated_at)
SELECT
    up.id_user,
    2,
    ut.theme_name,
    up.created_at,
    up.updated_at
FROM user_preferences up
JOIN user_themes ut ON ut.id_user_theme = up.id_user_theme
WHERE up.deleted_at IS NULL;

-- 3c. language (config_key = 3)
INSERT INTO user_configurations (id_user, id_config_key, value, created_at, updated_at)
SELECT
    up.id_user,
    3,
    up.language,
    up.created_at,
    up.updated_at
FROM user_preferences up
WHERE up.deleted_at IS NULL;

-- 3d. notifications_enabled (config_key = 4)
INSERT INTO user_configurations (id_user, id_config_key, value, created_at, updated_at)
SELECT
    up.id_user,
    4,
    CASE WHEN up.notifications_enabled = TRUE THEN 'true' ELSE 'false' END,
    up.created_at,
    up.updated_at
FROM user_preferences up
WHERE up.deleted_at IS NULL;

-- ------------------------------------------------------------
-- 4. ELIMINAR TABLA user_preferences
-- ------------------------------------------------------------

DROP TABLE IF EXISTS user_preferences;

-- ------------------------------------------------------------
-- 5. ELIMINAR TABLA user_themes (huérfana, sin dependencias)
-- ------------------------------------------------------------

DROP TABLE IF EXISTS user_themes;

-- ------------------------------------------------------------
-- 6. CREAR ÍNDICES
-- ------------------------------------------------------------

CREATE INDEX idx_config_keys_category  ON configuration_keys(category);
CREATE INDEX idx_user_configs_user     ON user_configurations(id_user);
CREATE INDEX idx_user_configs_key      ON user_configurations(id_config_key);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN (opcionales, deben dar > 0 si había datos)
-- ============================================================
-- SELECT 'config_keys insertadas' AS check_name, COUNT(*) FROM configuration_keys;
-- SELECT 'user_configs migradas',  COUNT(*) FROM user_configurations;
-- SELECT 'user_preferences existe', COUNT(*) FROM information_schema.tables WHERE table_schema = 'ia_dataflow' AND table_name = 'user_preferences';
-- SELECT 'user_themes existe',      COUNT(*) FROM information_schema.tables WHERE table_schema = 'ia_dataflow' AND table_name = 'user_themes';

COMMIT;
