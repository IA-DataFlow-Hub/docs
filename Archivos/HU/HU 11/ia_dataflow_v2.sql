-- ============================================================
-- IA DATAFLOW v2.0 - DATABASE STRUCTURE (IMPROVED)
-- MySQL Workbench Compatible
-- ============================================================
-- CAMBIOS PRINCIPALES vs v1:
--   1. Tabla central "projects" como columna vertebral
--   2. "project_phases" para rastrear el ciclo BPM por proyecto
--   3. "ai_engines" para manejar Llama (local) y Gemini (cloud)
--   4. Todas las tablas operativas ahora apuntan a un proyecto
--   5. Mensajes distinguen entre usuario e IA
--   6. file_versions guarda ruta al snapshot real del archivo
-- ============================================================

CREATE DATABASE IF NOT EXISTS ia_dataflow;
USE ia_dataflow;

-- ============================================================
-- 1. USERS  (sin cambios)
-- ============================================================

CREATE TABLE users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    profile_picture VARCHAR(255),
    status ENUM('active','inactive','suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- 2. CREDENTIALS  (sin cambios)
-- ============================================================

CREATE TABLE credentials (
    id_credential INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    mfa_enabled BOOLEAN DEFAULT FALSE,
    last_password_change TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_credentials_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ============================================================
-- 2B. USER_PREFERENCES  *** NUEVA ***
--     Almacena preferencias de UX por usuario:
--     tour completado, tema, idioma, notificaciones, etc.
-- ============================================================

CREATE TABLE user_preferences (
    id_user INT PRIMARY KEY,
    has_completed_tour BOOLEAN DEFAULT FALSE,
    theme ENUM('dark','light','system') DEFAULT 'dark',
    language VARCHAR(10) DEFAULT 'es',
    notifications_enabled BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_user_preferences_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ============================================================
-- 3. ROLES  (sin cambios)
-- ============================================================

CREATE TABLE roles (
    id_role INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT
);

-- ============================================================
-- 4. PERMISSIONS  (sin cambios)
-- ============================================================

CREATE TABLE permissions (
    id_permission INT AUTO_INCREMENT PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    module_name VARCHAR(100),
    description TEXT
);

-- ============================================================
-- 5. USER_ROLES  (sin cambios)
-- ============================================================

CREATE TABLE user_roles (
    id_user INT,
    id_role INT,

    PRIMARY KEY (id_user, id_role),

    CONSTRAINT fk_user_roles_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_user_roles_role
        FOREIGN KEY (id_role)
        REFERENCES roles(id_role)
        ON DELETE CASCADE
);

-- ============================================================
-- 6. ROLE_PERMISSIONS  (sin cambios)
-- ============================================================

CREATE TABLE role_permissions (
    id_role INT,
    id_permission INT,

    PRIMARY KEY (id_role, id_permission),

    CONSTRAINT fk_role_permissions_role
        FOREIGN KEY (id_role)
        REFERENCES roles(id_role)
        ON DELETE CASCADE,

    CONSTRAINT fk_role_permissions_permission
        FOREIGN KEY (id_permission)
        REFERENCES permissions(id_permission)
        ON DELETE CASCADE
);

-- ============================================================
-- 7. TEAMS  (sin cambios)
-- ============================================================

CREATE TABLE teams (
    id_team INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(150) NOT NULL,
    description TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_teams_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ============================================================
-- 8. TEAM_MEMBERS  (sin cambios)
-- ============================================================

CREATE TABLE team_members (
    id_team_member INT AUTO_INCREMENT PRIMARY KEY,
    id_team INT NOT NULL,
    id_user INT NOT NULL,
    member_role ENUM('leader','analyst','designer','supervisor','developer') DEFAULT 'analyst',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_team_members_team
        FOREIGN KEY (id_team)
        REFERENCES teams(id_team)
        ON DELETE CASCADE,

    CONSTRAINT fk_team_members_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ============================================================
-- 9. WORKFLOW_PHASES  (catalogo de las 4 fases BPM)
-- ============================================================

CREATE TABLE workflow_phases (
    id_phase INT AUTO_INCREMENT PRIMARY KEY,
    phase_name VARCHAR(100) NOT NULL UNIQUE,
    phase_order TINYINT NOT NULL DEFAULT 0,
    description TEXT
);

-- ============================================================
-- 10. AI_ENGINES  *** NUEVA ***
--     Catálogo de motores de IA disponibles.
--     Llama Ollama 3.1 = local/privado
--     Gemini Pro      = cloud/general
-- ============================================================

CREATE TABLE ai_engines (
    id_engine INT AUTO_INCREMENT PRIMARY KEY,
    engine_name VARCHAR(100) NOT NULL UNIQUE,
    engine_type ENUM('local','cloud') NOT NULL,
    model_version VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE
);

-- ============================================================
-- 11. PROJECTS  *** NUEVA — TABLA CENTRAL / MATRIZ ***
--     Se crea cuando el usuario inicia su primera interacción
--     con el chat. Es la columna vertebral que une:
--       archivos → jobs de IA → tareas → conversaciones
--     Todo flujo de trabajo vive dentro de un proyecto.
-- ============================================================

CREATE TABLE projects (
    id_project INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_team INT,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,

    -- En qué fase está ahora mismo este proyecto
    current_phase INT,

    -- Nivel de privacidad: determina si se puede usar IA cloud
    privacy_level ENUM('public','team','private') DEFAULT 'team',

    status ENUM('active','paused','completed','archived') DEFAULT 'active',

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_projects_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_projects_team
        FOREIGN KEY (id_team)
        REFERENCES teams(id_team)
        ON DELETE SET NULL,

    CONSTRAINT fk_projects_current_phase
        FOREIGN KEY (current_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE SET NULL
);

-- ============================================================
-- 12. PROJECT_PHASES  *** NUEVA ***
--     Historial de transiciones de fase de cada proyecto.
--     Registra cuándo el proyecto entró y salió de cada fase.
--     Así sabes la línea de tiempo completa del ciclo BPM.
-- ============================================================

CREATE TABLE project_phases (
    id_project_phase INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_phase INT NOT NULL,
    status ENUM('in_progress','completed','skipped') DEFAULT 'in_progress',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    notes TEXT,

    CONSTRAINT fk_pp_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_pp_phase
        FOREIGN KEY (id_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE CASCADE
);

-- ============================================================
-- 13. FILES  (MEJORADA: ahora apunta a un proyecto)
-- ============================================================

CREATE TABLE files (
    id_file INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_user INT,
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    file_type VARCHAR(100),
    file_size BIGINT,
    storage_path TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_files_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_files_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ============================================================
-- 14. FILE_VERSIONS  (MEJORADA: guarda ruta al snapshot)
-- ============================================================

CREATE TABLE file_versions (
    id_version INT AUTO_INCREMENT PRIMARY KEY,
    id_file INT NOT NULL,
    version_number INT NOT NULL,
    storage_path TEXT,
    changes_description TEXT,
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_file_versions_file
        FOREIGN KEY (id_file)
        REFERENCES files(id_file)
        ON DELETE CASCADE,

    CONSTRAINT fk_file_versions_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ============================================================
-- 15. AI_JOBS  (MEJORADA: vinculada a proyecto + motor de IA)
--     Ahora sabe: qué proyecto, qué archivo, qué motor,
--     en qué fase se ejecutó, y si es dato privado.
-- ============================================================

CREATE TABLE ai_jobs (
    id_job INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_file INT,
    id_engine INT NOT NULL,
    id_phase INT,
    requested_by INT,

    job_type VARCHAR(100) NOT NULL,
    prompt_text TEXT,

    -- Si es TRUE, fuerza uso de motor local aunque haya cloud disponible
    is_private BOOLEAN DEFAULT FALSE,

    status ENUM('pending','processing','completed','failed') DEFAULT 'pending',
    started_at TIMESTAMP NULL DEFAULT NULL,
    finished_at TIMESTAMP NULL DEFAULT NULL,

    -- Métricas de uso del modelo
    tokens_input INT DEFAULT 0,
    tokens_output INT DEFAULT 0,
    processing_time_ms INT DEFAULT 0,

    CONSTRAINT fk_ai_jobs_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_ai_jobs_file
        FOREIGN KEY (id_file)
        REFERENCES files(id_file)
        ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_engine
        FOREIGN KEY (id_engine)
        REFERENCES ai_engines(id_engine)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ai_jobs_phase
        FOREIGN KEY (id_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_user
        FOREIGN KEY (requested_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ============================================================
-- 16. AI_RESULTS  (MEJORADA: tipo de resultado)
-- ============================================================

CREATE TABLE ai_results (
    id_result INT AUTO_INCREMENT PRIMARY KEY,
    id_job INT NOT NULL,
    result_type ENUM('summary','transformed_file','table','chart','suggestion','error_report') DEFAULT 'summary',
    result_summary TEXT,
    output_path TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_ai_results_job
        FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE CASCADE
);

-- ============================================================
-- 17. TASKS  (MEJORADA: vinculada a proyecto)
-- ============================================================

CREATE TABLE tasks (
    id_task INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_phase INT,
    assigned_to INT,
    created_by INT,

    title VARCHAR(255) NOT NULL,
    description TEXT,

    status ENUM('pending','in_progress','completed','cancelled') DEFAULT 'pending',
    priority ENUM('low','medium','high','critical') DEFAULT 'medium',
    due_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT fk_tasks_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_tasks_phase
        FOREIGN KEY (id_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE SET NULL,

    CONSTRAINT fk_tasks_assigned_to
        FOREIGN KEY (assigned_to)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_tasks_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ============================================================
-- 18. CONVERSATIONS  (MEJORADA: vinculada a proyecto)
--     Una conversación pertenece a un proyecto y a una fase.
-- ============================================================

CREATE TABLE conversations (
    id_conversation INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_phase INT,
    created_by INT,
    title VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_conversations_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_conversations_phase
        FOREIGN KEY (id_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE SET NULL,

    CONSTRAINT fk_conversations_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL
);

-- ============================================================
-- 19. MESSAGES  (MEJORADA: distingue usuario vs IA)
--     sender_type = 'user' | 'ai_local' | 'ai_cloud' | 'system'
--     Si es mensaje de IA, id_user queda NULL y se usa id_engine.
-- ============================================================

CREATE TABLE messages (
    id_message INT AUTO_INCREMENT PRIMARY KEY,
    id_conversation INT NOT NULL,
    id_user INT,
    id_engine INT,

    sender_type ENUM('user','ai_local','ai_cloud','system') NOT NULL DEFAULT 'user',
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_messages_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE CASCADE,

    CONSTRAINT fk_messages_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_messages_engine
        FOREIGN KEY (id_engine)
        REFERENCES ai_engines(id_engine)
        ON DELETE SET NULL
);

-- ============================================================
-- 20. AUDIT_LOGS  (sin cambios estructurales)
-- ============================================================

CREATE TABLE audit_logs (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT,
    id_project INT,
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(100),
    entity_id INT,
    old_value TEXT,
    new_value TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_logs_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE SET NULL
);

-- ============================================================
-- 21. SESSIONS  (sin cambios)
-- ============================================================

CREATE TABLE sessions (
    id_session INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    session_token VARCHAR(255) NOT NULL,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL DEFAULT NULL,

    CONSTRAINT fk_sessions_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ============================================================
-- DATOS INICIALES: FASES BPM
-- ============================================================

INSERT INTO workflow_phases (phase_name, phase_order, description)
VALUES
('Diseñar',     1, 'Carga de documentos y análisis de su estructura'),
('Ejecutar',    2, 'Aplicar transformaciones con aprobación del usuario'),
('Supervisar',  3, 'Registrar todos los cambios para auditoría'),
('Optimizar',   4, 'Sugerir mejoras continuas sobre los datos');

-- ============================================================
-- DATOS INICIALES: MOTORES DE IA
-- ============================================================

INSERT INTO ai_engines (engine_name, engine_type, model_version, description)
VALUES
('Llama Ollama', 'local', '3.1', 'Motor local para datos privados y sensibles. No sale del sistema.'),
('Gemini Pro',   'cloud', '1.5', 'Motor cloud de Google para procesamiento general.');

-- ============================================================
-- DATOS INICIALES: ROLES POR DEFECTO
-- ============================================================

INSERT INTO roles (role_name, description)
VALUES
('admin',       'Administrador con acceso total al sistema'),
('leader',      'Líder de equipo, gestiona miembros y proyectos'),
('analyst',     'Analista de datos, acceso a Diseñar y Ejecutar'),
('supervisor',  'Supervisor, acceso a Supervisar y Optimizar'),
('viewer',      'Solo lectura, puede ver resultados');

-- ============================================================
-- DATOS INICIALES: PERMISOS POR MÓDULO/FASE
-- ============================================================

INSERT INTO permissions (permission_name, module_name, description)
VALUES
('phase_design',       'Diseñar',     'Acceso al módulo de Diseño'),
('phase_execute',      'Ejecutar',    'Acceso al módulo de Ejecución'),
('phase_supervise',    'Supervisar',  'Acceso al módulo de Supervisión'),
('phase_optimize',     'Optimizar',   'Acceso al módulo de Optimización'),
('manage_teams',       'Teams',       'Crear y gestionar equipos'),
('manage_users',       'Users',       'Administrar usuarios del sistema'),
('upload_files',       'Files',       'Subir archivos al sistema'),
('view_audit_logs',    'Audit',       'Ver registros de auditoría'),
('use_ai_local',       'AI',          'Usar motor de IA local (Llama)'),
('use_ai_cloud',       'AI',          'Usar motor de IA cloud (Gemini)');

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_users_email         ON users(email);
CREATE INDEX idx_projects_user       ON projects(id_user);
CREATE INDEX idx_projects_team       ON projects(id_team);
CREATE INDEX idx_projects_status     ON projects(status);
CREATE INDEX idx_project_phases_proj ON project_phases(id_project);
CREATE INDEX idx_files_project       ON files(id_project);
CREATE INDEX idx_files_user          ON files(id_user);
CREATE INDEX idx_ai_jobs_project     ON ai_jobs(id_project);
CREATE INDEX idx_ai_jobs_engine      ON ai_jobs(id_engine);
CREATE INDEX idx_ai_jobs_status      ON ai_jobs(status);
CREATE INDEX idx_tasks_project       ON tasks(id_project);
CREATE INDEX idx_tasks_status        ON tasks(status);
CREATE INDEX idx_conversations_proj  ON conversations(id_project);
CREATE INDEX idx_messages_conv       ON messages(id_conversation);
CREATE INDEX idx_audit_logs_user     ON audit_logs(id_user);
CREATE INDEX idx_audit_logs_project  ON audit_logs(id_project);
CREATE INDEX idx_sessions_token      ON sessions(session_token);
