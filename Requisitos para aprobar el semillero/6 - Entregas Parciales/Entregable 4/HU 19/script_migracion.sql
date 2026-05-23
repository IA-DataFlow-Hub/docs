-- ============================================================
-- MIGRACIÓN: ia_dataflow v2 -> v3
-- Reemplaza ENUMs por tablas de catálogo SIN pérdida de datos.
--
-- Estrategia (idempotente por bloques):
--   1. Crear tablas de catálogo + datos iniciales.
--   2. Añadir columna FK nueva (nullable) en cada tabla afectada.
--   3. UPDATE ... JOIN para mapear el string ENUM -> id catálogo.
--   4. Hacer la columna nueva NOT NULL + default + FK.
--   5. Eliminar la columna ENUM antigua.
--   6. Crear índices nuevos.
--
-- IMPORTANTE: Ejecutar dentro de una transacción / con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. CREAR CATÁLOGOS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS user_statuses (
    id_user_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO user_statuses (id_user_status, status_name, description) VALUES
(1,'active','Usuario activo'),
(2,'inactive','Usuario inactivo'),
(3,'suspended','Usuario suspendido');

CREATE TABLE IF NOT EXISTS user_themes (
    id_user_theme INT AUTO_INCREMENT PRIMARY KEY,
    theme_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO user_themes (id_user_theme, theme_name, description) VALUES
(1,'dark','Tema oscuro'),
(2,'light','Tema claro'),
(3,'system','Sigue al sistema');

CREATE TABLE IF NOT EXISTS team_member_roles (
    id_team_member_role INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO team_member_roles (id_team_member_role, role_name, description) VALUES
(1,'leader','Líder del equipo'),
(2,'analyst','Analista'),
(3,'designer','Diseñador'),
(4,'supervisor','Supervisor'),
(5,'developer','Desarrollador');

CREATE TABLE IF NOT EXISTS ai_engine_types (
    id_ai_engine_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO ai_engine_types (id_ai_engine_type, type_name, description) VALUES
(1,'local','Motor local'),
(2,'cloud','Motor cloud');

CREATE TABLE IF NOT EXISTS project_privacy_levels (
    id_project_privacy_level INT AUTO_INCREMENT PRIMARY KEY,
    level_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO project_privacy_levels (id_project_privacy_level, level_name, description) VALUES
(1,'public','Visible a todos'),
(2,'team','Visible al equipo'),
(3,'private','Privado, fuerza IA local');

CREATE TABLE IF NOT EXISTS project_statuses (
    id_project_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO project_statuses (id_project_status, status_name, description) VALUES
(1,'active','En curso'),
(2,'paused','En pausa'),
(3,'completed','Completado'),
(4,'archived','Archivado');

CREATE TABLE IF NOT EXISTS project_phase_statuses (
    id_project_phase_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO project_phase_statuses (id_project_phase_status, status_name, description) VALUES
(1,'in_progress','En progreso'),
(2,'completed','Completada'),
(3,'skipped','Omitida');

CREATE TABLE IF NOT EXISTS ai_job_statuses (
    id_ai_job_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO ai_job_statuses (id_ai_job_status, status_name, description) VALUES
(1,'pending','Pendiente'),
(2,'processing','Procesando'),
(3,'completed','Completado'),
(4,'failed','Falló');

CREATE TABLE IF NOT EXISTS ai_result_types (
    id_ai_result_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO ai_result_types (id_ai_result_type, type_name, description) VALUES
(1,'summary','Resumen'),
(2,'transformed_file','Archivo transformado'),
(3,'table','Tabla'),
(4,'chart','Gráfico'),
(5,'suggestion','Sugerencia'),
(6,'error_report','Reporte de error');

CREATE TABLE IF NOT EXISTS task_statuses (
    id_task_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO task_statuses (id_task_status, status_name, description) VALUES
(1,'pending','Pendiente'),
(2,'in_progress','En curso'),
(3,'completed','Completada'),
(4,'cancelled','Cancelada');

CREATE TABLE IF NOT EXISTS task_priorities (
    id_task_priority INT AUTO_INCREMENT PRIMARY KEY,
    priority_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO task_priorities (id_task_priority, priority_name, description) VALUES
(1,'low','Baja'),
(2,'medium','Media'),
(3,'high','Alta'),
(4,'critical','Crítica');

CREATE TABLE IF NOT EXISTS message_sender_types (
    id_message_sender_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT IGNORE INTO message_sender_types (id_message_sender_type, type_name, description) VALUES
(1,'user','Usuario humano'),
(2,'ai_local','IA local'),
(3,'ai_cloud','IA cloud'),
(4,'system','Sistema');

-- ------------------------------------------------------------
-- 2. USERS.status -> id_user_status
-- ------------------------------------------------------------
ALTER TABLE users ADD COLUMN id_user_status INT NULL AFTER profile_picture;
UPDATE users u JOIN user_statuses s ON s.status_name = u.status
    SET u.id_user_status = s.id_user_status;
ALTER TABLE users
    MODIFY COLUMN id_user_status INT NOT NULL DEFAULT 1,
    DROP COLUMN status,
    ADD CONSTRAINT fk_users_status FOREIGN KEY (id_user_status)
        REFERENCES user_statuses(id_user_status) ON DELETE RESTRICT;
CREATE INDEX idx_users_status ON users(id_user_status);

-- ------------------------------------------------------------
-- 3. USER_PREFERENCES.theme -> id_user_theme
-- ------------------------------------------------------------
ALTER TABLE user_preferences ADD COLUMN id_user_theme INT NULL AFTER has_completed_tour;
UPDATE user_preferences p JOIN user_themes t ON t.theme_name = p.theme
    SET p.id_user_theme = t.id_user_theme;
ALTER TABLE user_preferences
    MODIFY COLUMN id_user_theme INT NOT NULL DEFAULT 1,
    DROP COLUMN theme,
    ADD CONSTRAINT fk_user_preferences_theme FOREIGN KEY (id_user_theme)
        REFERENCES user_themes(id_user_theme) ON DELETE RESTRICT;
CREATE INDEX idx_user_preferences_theme ON user_preferences(id_user_theme);

-- ------------------------------------------------------------
-- 4. TEAM_MEMBERS.member_role -> id_team_member_role
-- ------------------------------------------------------------
ALTER TABLE team_members ADD COLUMN id_team_member_role INT NULL AFTER id_user;
UPDATE team_members tm JOIN team_member_roles r ON r.role_name = tm.member_role
    SET tm.id_team_member_role = r.id_team_member_role;
ALTER TABLE team_members
    MODIFY COLUMN id_team_member_role INT NOT NULL DEFAULT 2,
    DROP COLUMN member_role,
    ADD CONSTRAINT fk_team_members_role FOREIGN KEY (id_team_member_role)
        REFERENCES team_member_roles(id_team_member_role) ON DELETE RESTRICT;
CREATE INDEX idx_team_members_role ON team_members(id_team_member_role);

-- ------------------------------------------------------------
-- 5. AI_ENGINES.engine_type -> id_ai_engine_type
-- ------------------------------------------------------------
ALTER TABLE ai_engines ADD COLUMN id_ai_engine_type INT NULL AFTER engine_name;
UPDATE ai_engines e JOIN ai_engine_types t ON t.type_name = e.engine_type
    SET e.id_ai_engine_type = t.id_ai_engine_type;
ALTER TABLE ai_engines
    MODIFY COLUMN id_ai_engine_type INT NOT NULL,
    DROP COLUMN engine_type,
    ADD CONSTRAINT fk_ai_engines_type FOREIGN KEY (id_ai_engine_type)
        REFERENCES ai_engine_types(id_ai_engine_type) ON DELETE RESTRICT;
CREATE INDEX idx_ai_engines_type ON ai_engines(id_ai_engine_type);

-- ------------------------------------------------------------
-- 6. PROJECTS.privacy_level + status
-- ------------------------------------------------------------
ALTER TABLE projects
    ADD COLUMN id_project_privacy_level INT NULL AFTER privacy_level,
    ADD COLUMN id_project_status        INT NULL AFTER status;
UPDATE projects p JOIN project_privacy_levels l ON l.level_name = p.privacy_level
    SET p.id_project_privacy_level = l.id_project_privacy_level;
UPDATE projects p JOIN project_statuses s ON s.status_name = p.status
    SET p.id_project_status = s.id_project_status;
ALTER TABLE projects
    MODIFY COLUMN id_project_privacy_level INT NOT NULL DEFAULT 2,
    MODIFY COLUMN id_project_status        INT NOT NULL DEFAULT 1,
    DROP COLUMN privacy_level,
    DROP COLUMN status,
    ADD CONSTRAINT fk_projects_privacy FOREIGN KEY (id_project_privacy_level)
        REFERENCES project_privacy_levels(id_project_privacy_level) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_projects_status FOREIGN KEY (id_project_status)
        REFERENCES project_statuses(id_project_status) ON DELETE RESTRICT;
DROP INDEX idx_projects_status ON projects;
CREATE INDEX idx_projects_status  ON projects(id_project_status);
CREATE INDEX idx_projects_privacy ON projects(id_project_privacy_level);

-- ------------------------------------------------------------
-- 7. PROJECT_PHASES.status -> id_project_phase_status
-- ------------------------------------------------------------
ALTER TABLE project_phases ADD COLUMN id_project_phase_status INT NULL AFTER id_phase;
UPDATE project_phases pp JOIN project_phase_statuses s ON s.status_name = pp.status
    SET pp.id_project_phase_status = s.id_project_phase_status;
ALTER TABLE project_phases
    MODIFY COLUMN id_project_phase_status INT NOT NULL DEFAULT 1,
    DROP COLUMN status,
    ADD CONSTRAINT fk_pp_status FOREIGN KEY (id_project_phase_status)
        REFERENCES project_phase_statuses(id_project_phase_status) ON DELETE RESTRICT;
CREATE INDEX idx_project_phases_status ON project_phases(id_project_phase_status);

-- ------------------------------------------------------------
-- 8. AI_JOBS.status -> id_ai_job_status
-- ------------------------------------------------------------
ALTER TABLE ai_jobs ADD COLUMN id_ai_job_status INT NULL AFTER is_private;
UPDATE ai_jobs j JOIN ai_job_statuses s ON s.status_name = j.status
    SET j.id_ai_job_status = s.id_ai_job_status;
ALTER TABLE ai_jobs
    MODIFY COLUMN id_ai_job_status INT NOT NULL DEFAULT 1,
    DROP COLUMN status,
    ADD CONSTRAINT fk_ai_jobs_status FOREIGN KEY (id_ai_job_status)
        REFERENCES ai_job_statuses(id_ai_job_status) ON DELETE RESTRICT;
DROP INDEX idx_ai_jobs_status ON ai_jobs;
CREATE INDEX idx_ai_jobs_status ON ai_jobs(id_ai_job_status);

-- ------------------------------------------------------------
-- 9. AI_RESULTS.result_type -> id_ai_result_type
-- ------------------------------------------------------------
ALTER TABLE ai_results ADD COLUMN id_ai_result_type INT NULL AFTER id_job;
UPDATE ai_results r JOIN ai_result_types t ON t.type_name = r.result_type
    SET r.id_ai_result_type = t.id_ai_result_type;
ALTER TABLE ai_results
    MODIFY COLUMN id_ai_result_type INT NOT NULL DEFAULT 1,
    DROP COLUMN result_type,
    ADD CONSTRAINT fk_ai_results_type FOREIGN KEY (id_ai_result_type)
        REFERENCES ai_result_types(id_ai_result_type) ON DELETE RESTRICT;
CREATE INDEX idx_ai_results_type ON ai_results(id_ai_result_type);

-- ------------------------------------------------------------
-- 10. TASKS.status + priority
-- ------------------------------------------------------------
ALTER TABLE tasks
    ADD COLUMN id_task_status   INT NULL AFTER description,
    ADD COLUMN id_task_priority INT NULL AFTER status;
UPDATE tasks t JOIN task_statuses s ON s.status_name = t.status
    SET t.id_task_status = s.id_task_status;
UPDATE tasks t JOIN task_priorities p ON p.priority_name = t.priority
    SET t.id_task_priority = p.id_task_priority;
ALTER TABLE tasks
    MODIFY COLUMN id_task_status   INT NOT NULL DEFAULT 1,
    MODIFY COLUMN id_task_priority INT NOT NULL DEFAULT 2,
    DROP COLUMN status,
    DROP COLUMN priority,
    ADD CONSTRAINT fk_tasks_status FOREIGN KEY (id_task_status)
        REFERENCES task_statuses(id_task_status) ON DELETE RESTRICT,
    ADD CONSTRAINT fk_tasks_priority FOREIGN KEY (id_task_priority)
        REFERENCES task_priorities(id_task_priority) ON DELETE RESTRICT;
DROP INDEX idx_tasks_status ON tasks;
CREATE INDEX idx_tasks_status   ON tasks(id_task_status);
CREATE INDEX idx_tasks_priority ON tasks(id_task_priority);

-- ------------------------------------------------------------
-- 11. MESSAGES.sender_type -> id_message_sender_type
-- ------------------------------------------------------------
ALTER TABLE messages ADD COLUMN id_message_sender_type INT NULL AFTER id_engine;
UPDATE messages m JOIN message_sender_types t ON t.type_name = m.sender_type
    SET m.id_message_sender_type = t.id_message_sender_type;
ALTER TABLE messages
    MODIFY COLUMN id_message_sender_type INT NOT NULL DEFAULT 1,
    DROP COLUMN sender_type,
    ADD CONSTRAINT fk_messages_sender_type FOREIGN KEY (id_message_sender_type)
        REFERENCES message_sender_types(id_message_sender_type) ON DELETE RESTRICT;
CREATE INDEX idx_messages_sender_type ON messages(id_message_sender_type);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN (opcionales, deben dar 0 filas)
-- ============================================================
-- SELECT 'users sin status' AS check_name, COUNT(*) FROM users WHERE id_user_status IS NULL;
-- SELECT 'projects sin status', COUNT(*) FROM projects WHERE id_project_status IS NULL;
-- SELECT 'tasks sin status',   COUNT(*) FROM tasks    WHERE id_task_status   IS NULL;
-- SELECT 'messages sin sender',COUNT(*) FROM messages WHERE id_message_sender_type IS NULL;

COMMIT;
