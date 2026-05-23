-- ============================================================
-- IA DATAFLOW v3.4 - DATABASE STRUCTURE
-- MySQL 8+ / Prisma compatible
-- ============================================================
-- HU-016: ENUMs reemplazados por tablas de catálogo (FK).
-- HU-017: Auditoría completa y eliminación lógica.
-- HU-018: Proveedores de credenciales y historial de claves.
--   - Campos created_by, updated_by, deleted_at, deleted_by en todas las tablas.
--   - status_changed_at en tablas con FK de estado.
--   - Tabla "audits" para registro detallado de cambios (JSON).
--   - Queries deben filtrar WHERE deleted_at IS NULL.
-- HU-019: Sistema de configuración flexible clave-valor.
--   - Reemplaza user_preferences por configuration_keys + user_configurations.
--   - Elimina user_themes (absorbido por configuration_keys).
-- HU-020: Modelo de roles por equipo, proyecto y grupo personal.
--   - role_templates + role_template_permissions (plantillas globales).
--   - team_roles + team_role_permissions (roles independientes por equipo).
--   - user_team_roles / user_project_roles (asignación por ámbito).
--   - teams extendido con group_type + is_personal_group.
--   - Elimina roles, user_roles, role_permissions, team_members, team_member_roles.
-- HU-021: Proyectos con creación auditada + relación archivos ↔ conversaciones ↔ mensajes.
--   - projects: elimina id_user, created_by NOT NULL, agrega owner_user_id.
--   - files: agrega id_conversation + id_message para trazabilidad.
-- HU-022: Tracking y logging de AI_JOBS y procesos en segundo plano.
--   - ai_jobs: lifecycle completo, métricas, costos, origen, errores, reintentos.
--   - ai_job_events: log de eventos detallado por trabajo.
--   - ai_results: output enriquecido, is_successful, error_code.
-- ============================================================

CREATE DATABASE IF NOT EXISTS ia_dataflow;
USE ia_dataflow;

-- ============================================================
-- CATÁLOGOS (se crean primero para poder referenciarlos)
-- ============================================================

-- 1. user_statuses  (reemplaza users.status)
CREATE TABLE user_statuses (
    id_user_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO user_statuses (id_user_status, status_name, description) VALUES
(1, 'active',    'Usuario activo en el sistema'),
(2, 'inactive',  'Usuario inactivo, sin sesiones recientes'),
(3, 'suspended', 'Usuario suspendido por administración');

-- 4. ai_engine_types  (reemplaza ai_engines.engine_type)
CREATE TABLE ai_engine_types (
    id_ai_engine_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ai_engine_types (id_ai_engine_type, type_name, description) VALUES
(1, 'local', 'Motor de IA ejecutado localmente, datos no salen del sistema'),
(2, 'cloud', 'Motor de IA en la nube');

-- 5. project_privacy_levels  (reemplaza projects.privacy_level)
CREATE TABLE project_privacy_levels (
    id_project_privacy_level INT AUTO_INCREMENT PRIMARY KEY,
    level_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO project_privacy_levels (id_project_privacy_level, level_name, description) VALUES
(1, 'public',  'Visible para cualquier usuario del sistema'),
(2, 'team',    'Visible solo para el equipo del proyecto'),
(3, 'private', 'Privado, solo el creador. Fuerza uso de IA local');

-- 6. project_statuses  (reemplaza projects.status)
CREATE TABLE project_statuses (
    id_project_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO project_statuses (id_project_status, status_name, description) VALUES
(1, 'active',    'Proyecto en curso'),
(2, 'paused',    'Proyecto en pausa temporal'),
(3, 'completed', 'Proyecto completado'),
(4, 'archived',  'Proyecto archivado');

-- 7. project_phase_statuses  (reemplaza project_phases.status)
CREATE TABLE project_phase_statuses (
    id_project_phase_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO project_phase_statuses (id_project_phase_status, status_name, description) VALUES
(1, 'in_progress', 'Fase actualmente en ejecución'),
(2, 'completed',   'Fase completada'),
(3, 'skipped',     'Fase omitida en este proyecto');

-- 8. ai_job_statuses  (reemplaza ai_jobs.status)
CREATE TABLE ai_job_statuses (
    id_ai_job_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ai_job_statuses (id_ai_job_status, status_name, description) VALUES
(1, 'pending',    'Job encolado, aún no ejecutado'),
(2, 'processing', 'Job en ejecución'),
(3, 'completed',  'Job finalizado correctamente'),
(4, 'failed',     'Job finalizado con error');

-- 9. ai_result_types  (reemplaza ai_results.result_type)
CREATE TABLE ai_result_types (
    id_ai_result_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO ai_result_types (id_ai_result_type, type_name, description) VALUES
(1, 'summary',          'Resumen textual'),
(2, 'transformed_file', 'Archivo transformado o generado'),
(3, 'table',            'Tabla estructurada de datos'),
(4, 'chart',            'Gráfico'),
(5, 'suggestion',       'Sugerencia o recomendación'),
(6, 'error_report',     'Reporte de error');

-- 10. task_statuses  (reemplaza tasks.status)
CREATE TABLE task_statuses (
    id_task_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO task_statuses (id_task_status, status_name, description) VALUES
(1, 'pending',     'Tarea pendiente de iniciar'),
(2, 'in_progress', 'Tarea en curso'),
(3, 'completed',   'Tarea completada'),
(4, 'cancelled',   'Tarea cancelada');

-- 11. task_priorities  (reemplaza tasks.priority)
CREATE TABLE task_priorities (
    id_task_priority INT AUTO_INCREMENT PRIMARY KEY,
    priority_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO task_priorities (id_task_priority, priority_name, description) VALUES
(1, 'low',      'Prioridad baja'),
(2, 'medium',   'Prioridad media'),
(3, 'high',     'Prioridad alta'),
(4, 'critical', 'Prioridad crítica');

-- 12. message_sender_types  (reemplaza messages.sender_type)
CREATE TABLE message_sender_types (
    id_message_sender_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO message_sender_types (id_message_sender_type, type_name, description) VALUES
(1, 'user',     'Mensaje enviado por un usuario humano'),
(2, 'ai_local', 'Mensaje generado por motor de IA local'),
(3, 'ai_cloud', 'Mensaje generado por motor de IA cloud'),
(4, 'system',   'Mensaje generado automáticamente por el sistema');

-- 13. auth_methods  (reemplaza credentials.preferred_auth_method ENUM — HU-018)
CREATE TABLE auth_methods (
    id_auth_method INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO auth_methods (id_auth_method, method_name, description) VALUES
(1, 'password', 'Autenticación por contraseña local'),
(2, 'google',   'Autenticación mediante proveedor Google'),
(3, 'apple',    'Autenticación mediante proveedor Apple'),
(4, 'other',    'Otro proveedor de autenticación externo');

-- 14. identity_providers  (HU-018)
CREATE TABLE identity_providers (
    id_provider INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL
);

-- ============================================================
-- 1. USERS
-- ============================================================

CREATE TABLE users (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    profile_picture VARCHAR(255),
    id_user_status INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_users_status
        FOREIGN KEY (id_user_status)
        REFERENCES user_statuses(id_user_status)
        ON DELETE RESTRICT,

    CONSTRAINT fk_users_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_users_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_users_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 2. CREDENTIALS  (HU-018: soporte multi-proveedor)
-- ============================================================

CREATE TABLE credentials (
    id_credential INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,

    -- Proveedor externo (NULL = clave local)
    provider_id INT NULL,
    provider_user_id VARCHAR(255) NULL,
    provider_email VARCHAR(255) NULL,

    -- Clave local (NULL si usa proveedor externo)
    password_hash VARCHAR(255) NULL,
    password_salt VARCHAR(255) NULL,

    mfa_enabled BOOLEAN DEFAULT FALSE,
    last_password_change TIMESTAMP NULL,
    id_auth_method INT NOT NULL DEFAULT 1, -- password

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_credentials_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_credentials_provider
        FOREIGN KEY (provider_id)
        REFERENCES identity_providers(id_provider)
        ON DELETE SET NULL,

    CONSTRAINT fk_credentials_auth_method
        FOREIGN KEY (id_auth_method)
        REFERENCES auth_methods(id_auth_method)
        ON DELETE RESTRICT,

    CONSTRAINT fk_credentials_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_credentials_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_credentials_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 2B-2. PASSWORD_HISTORY  (HU-018: últimas 5 contraseñas)
-- ============================================================

CREATE TABLE password_history (
    id_history INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_pw_history_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ============================================================
-- 2B. CONFIGURATION_KEYS  (HU-019: sistema clave-valor flexible)
-- ============================================================

CREATE TABLE configuration_keys (
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

-- ============================================================
-- 2C. USER_CONFIGURATIONS  (HU-019: valores por usuario)
-- ============================================================

CREATE TABLE user_configurations (
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

-- ============================================================
-- 3. ROLE_TEMPLATES  (HU-020: plantillas globales de roles)
-- ============================================================

CREATE TABLE role_templates (
    id_role_template INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- ============================================================
-- 4. PERMISSIONS
-- ============================================================

CREATE TABLE permissions (
    id_permission INT AUTO_INCREMENT PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    module_name VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_permissions_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_permissions_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_permissions_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 5. ROLE_TEMPLATE_PERMISSIONS  (HU-020)
-- ============================================================

CREATE TABLE role_template_permissions (
    id_role_template_permission INT AUTO_INCREMENT PRIMARY KEY,
    id_role_template INT NOT NULL,
    id_permission INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_template_perm (id_role_template, id_permission),

    CONSTRAINT fk_rtp_template
        FOREIGN KEY (id_role_template)
        REFERENCES role_templates(id_role_template)
        ON DELETE CASCADE,

    CONSTRAINT fk_rtp_permission
        FOREIGN KEY (id_permission)
        REFERENCES permissions(id_permission)
        ON DELETE CASCADE
);

-- ============================================================
-- 6. TEAMS  (HU-020: extendido con group_type + is_personal_group)
-- ============================================================

CREATE TABLE teams (
    id_team INT AUTO_INCREMENT PRIMARY KEY,
    team_name VARCHAR(150) NOT NULL,
    description TEXT,
    group_type VARCHAR(50) NOT NULL DEFAULT 'standard',
    is_personal_group BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_teams_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_teams_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_teams_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 7. TEAM_ROLES  (HU-020: roles independientes por equipo)
-- ============================================================

CREATE TABLE team_roles (
    id_team_role INT AUTO_INCREMENT PRIMARY KEY,
    id_team INT NOT NULL,
    role_name VARCHAR(100) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    template_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_team_role (id_team, role_name),

    CONSTRAINT fk_team_roles_team
        FOREIGN KEY (id_team)
        REFERENCES teams(id_team)
        ON DELETE CASCADE,

    CONSTRAINT fk_team_roles_template
        FOREIGN KEY (template_id)
        REFERENCES role_templates(id_role_template)
        ON DELETE SET NULL
);

-- ============================================================
-- 8. TEAM_ROLE_PERMISSIONS  (HU-020)
-- ============================================================

CREATE TABLE team_role_permissions (
    id_team_role_permission INT AUTO_INCREMENT PRIMARY KEY,
    id_team_role INT NOT NULL,
    id_permission INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uk_team_role_perm (id_team_role, id_permission),

    CONSTRAINT fk_trp_team_role
        FOREIGN KEY (id_team_role)
        REFERENCES team_roles(id_team_role)
        ON DELETE CASCADE,

    CONSTRAINT fk_trp_permission
        FOREIGN KEY (id_permission)
        REFERENCES permissions(id_permission)
        ON DELETE CASCADE
);

-- ============================================================
-- 9. USER_TEAM_ROLES  (HU-020: asignación usuario ↔ equipo ↔ rol)
-- ============================================================

CREATE TABLE user_team_roles (
    id_user_team_role INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_team INT NOT NULL,
    id_team_role INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_user_team_role (id_user, id_team, id_team_role),

    CONSTRAINT fk_utr_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_utr_team
        FOREIGN KEY (id_team)
        REFERENCES teams(id_team)
        ON DELETE CASCADE,

    CONSTRAINT fk_utr_team_role
        FOREIGN KEY (id_team_role)
        REFERENCES team_roles(id_team_role)
        ON DELETE CASCADE
);

-- ============================================================
-- 10. USER_PROJECT_ROLES  (HU-020: sobrescritura de rol por proyecto)
-- ============================================================

CREATE TABLE user_project_roles (
    id_user_project_role INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    id_project INT NOT NULL,
    id_team_role INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uk_user_project_role (id_user, id_project),

    CONSTRAINT fk_upr_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_upr_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_upr_team_role
        FOREIGN KEY (id_team_role)
        REFERENCES team_roles(id_team_role)
        ON DELETE CASCADE
);

-- ============================================================
-- 11. WORKFLOW_PHASES
-- ============================================================

CREATE TABLE workflow_phases (
    id_phase INT AUTO_INCREMENT PRIMARY KEY,
    phase_name VARCHAR(100) NOT NULL UNIQUE,
    phase_order TINYINT NOT NULL DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_wf_phases_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_wf_phases_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_wf_phases_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 10. AI_ENGINES
-- ============================================================

CREATE TABLE ai_engines (
    id_engine INT AUTO_INCREMENT PRIMARY KEY,
    engine_name VARCHAR(100) NOT NULL UNIQUE,
    id_ai_engine_type INT NOT NULL,
    model_version VARCHAR(100),
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_ai_engines_type
        FOREIGN KEY (id_ai_engine_type)
        REFERENCES ai_engine_types(id_ai_engine_type)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ai_engines_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_ai_engines_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_ai_engines_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 11. PROJECTS
-- ============================================================

CREATE TABLE projects (
    id_project INT AUTO_INCREMENT PRIMARY KEY,
    id_team INT,
    project_name VARCHAR(255) NOT NULL,
    description TEXT,

    current_phase INT,
    owner_user_id INT NULL,

    id_project_privacy_level INT NOT NULL DEFAULT 2, -- team
    id_project_status INT NOT NULL DEFAULT 1,        -- active
    status_changed_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_projects_team
        FOREIGN KEY (id_team)
        REFERENCES teams(id_team)
        ON DELETE SET NULL,

    CONSTRAINT fk_projects_current_phase
        FOREIGN KEY (current_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE SET NULL,

    CONSTRAINT fk_projects_owner
        FOREIGN KEY (owner_user_id)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_projects_privacy
        FOREIGN KEY (id_project_privacy_level)
        REFERENCES project_privacy_levels(id_project_privacy_level)
        ON DELETE RESTRICT,

    CONSTRAINT fk_projects_status
        FOREIGN KEY (id_project_status)
        REFERENCES project_statuses(id_project_status)
        ON DELETE RESTRICT,

    CONSTRAINT fk_projects_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE CASCADE,

    CONSTRAINT fk_projects_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_projects_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 12. PROJECT_PHASES
-- ============================================================

CREATE TABLE project_phases (
    id_project_phase INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_phase INT NOT NULL,
    id_project_phase_status INT NOT NULL DEFAULT 1, -- in_progress
    status_changed_at TIMESTAMP NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL DEFAULT NULL,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_pp_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_pp_phase
        FOREIGN KEY (id_phase)
        REFERENCES workflow_phases(id_phase)
        ON DELETE CASCADE,

    CONSTRAINT fk_pp_status
        FOREIGN KEY (id_project_phase_status)
        REFERENCES project_phase_statuses(id_project_phase_status)
        ON DELETE RESTRICT,

    CONSTRAINT fk_pp_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_pp_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_pp_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 13. FILES
-- ============================================================

CREATE TABLE files (
    id_file INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_user INT,
    id_conversation INT NULL,
    id_message INT NULL,
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255),
    file_type VARCHAR(100),
    file_size BIGINT,
    storage_path TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_files_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_files_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_files_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_files_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_files_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_files_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_files_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 14. FILE_VERSIONS
-- ============================================================

CREATE TABLE file_versions (
    id_version INT AUTO_INCREMENT PRIMARY KEY,
    id_file INT NOT NULL,
    version_number INT NOT NULL,
    storage_path TEXT,
    changes_description TEXT,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_file_versions_file
        FOREIGN KEY (id_file)
        REFERENCES files(id_file)
        ON DELETE CASCADE,

    CONSTRAINT fk_file_versions_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_file_versions_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_file_versions_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT uq_file_versions UNIQUE (id_file, version_number)
);

-- ============================================================
-- 15. AI_JOBS
-- ============================================================

CREATE TABLE ai_jobs (
    id_job INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_file INT,
    id_engine INT NOT NULL,
    id_phase INT,
    requested_by INT,

    -- Contexto y tipo
    job_type VARCHAR(100) NOT NULL,
    prompt_text TEXT,
    prompt_metadata JSON NULL,
    input_data_reference TEXT NULL,
    is_private BOOLEAN DEFAULT FALSE,
    created_from VARCHAR(100) NULL,

    -- Estado y lifecycle (HU-022)
    id_ai_job_status INT NOT NULL DEFAULT 1, -- pending
    status_changed_at TIMESTAMP NULL,
    queued_at TIMESTAMP NULL,
    started_at TIMESTAMP NULL DEFAULT NULL,
    processing_at TIMESTAMP NULL,
    finished_at TIMESTAMP NULL DEFAULT NULL,
    failed_at TIMESTAMP NULL,
    cancelled_at TIMESTAMP NULL,
    requeued_at TIMESTAMP NULL,
    updated_source VARCHAR(100) NULL,

    -- Métricas de tokens (HU-022)
    tokens_prompt INT DEFAULT 0,
    tokens_completion INT DEFAULT 0,
    tokens_total INT GENERATED ALWAYS AS (tokens_prompt + tokens_completion) STORED,

    -- Métricas de tiempo
    processing_time_ms INT DEFAULT 0,
    elapsed_time_ms INT DEFAULT 0,

    -- Costos (HU-022)
    cost_estimated DECIMAL(12,6) NULL,
    cost_actual DECIMAL(12,6) NULL,

    -- Proveedor / modelo (HU-022)
    provider_request_id VARCHAR(255) NULL,
    model_version_snapshot VARCHAR(100) NULL,
    model_info JSON NULL,

    -- Origen contextual (HU-022)
    id_conversation INT NULL,
    id_message INT NULL,
    id_task INT NULL,

    -- Errores y reintentos (HU-022)
    error_message TEXT NULL,
    error_stack TEXT NULL,
    error_context JSON NULL,
    retries_attempted INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    next_retry_at TIMESTAMP NULL,
    final_error_code VARCHAR(100) NULL,

    -- Worker / cola (HU-022)
    worker_id VARCHAR(100) NULL,
    queue_name VARCHAR(100) NULL,

    -- Auditoría
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

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
        ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_status
        FOREIGN KEY (id_ai_job_status)
        REFERENCES ai_job_statuses(id_ai_job_status)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ai_jobs_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_task
        FOREIGN KEY (id_task)
        REFERENCES tasks(id_task)
        ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_ai_jobs_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 16. AI_JOB_EVENTS  (HU-022: log de eventos por trabajo)
-- ============================================================

CREATE TABLE ai_job_events (
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

-- ============================================================
-- 17. AI_RESULTS  (HU-022: output enriquecido + estado de resultado)
-- ============================================================

CREATE TABLE ai_results (
    id_result INT AUTO_INCREMENT PRIMARY KEY,
    id_job INT NOT NULL,
    id_ai_result_type INT NOT NULL DEFAULT 1, -- summary
    result_summary TEXT,
    output_path TEXT,

    -- HU-022: output enriquecido
    output_raw LONGTEXT NULL,
    output_json JSON NULL,
    result_metadata JSON NULL,
    result_source VARCHAR(100) NULL,

    -- HU-022: estado del resultado
    is_successful BOOLEAN DEFAULT TRUE,
    error_code VARCHAR(100) NULL,
    error_message TEXT NULL,
    finished_at TIMESTAMP NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_ai_results_job
        FOREIGN KEY (id_job)
        REFERENCES ai_jobs(id_job)
        ON DELETE CASCADE,

    CONSTRAINT fk_ai_results_type
        FOREIGN KEY (id_ai_result_type)
        REFERENCES ai_result_types(id_ai_result_type)
        ON DELETE RESTRICT,

    CONSTRAINT fk_ai_results_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_ai_results_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_ai_results_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 17. TASKS
-- ============================================================

CREATE TABLE tasks (
    id_task INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_phase INT,
    assigned_to INT,
    created_by INT,

    title VARCHAR(255) NOT NULL,
    description TEXT,

    id_task_status INT NOT NULL DEFAULT 1,   -- pending
    id_task_priority INT NOT NULL DEFAULT 2, -- medium
    status_changed_at TIMESTAMP NULL,
    due_date DATE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

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
        ON DELETE SET NULL,

    CONSTRAINT fk_tasks_status
        FOREIGN KEY (id_task_status)
        REFERENCES task_statuses(id_task_status)
        ON DELETE RESTRICT,

    CONSTRAINT fk_tasks_priority
        FOREIGN KEY (id_task_priority)
        REFERENCES task_priorities(id_task_priority)
        ON DELETE RESTRICT,

    CONSTRAINT fk_tasks_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_tasks_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 18. CONVERSATIONS
-- ============================================================

CREATE TABLE conversations (
    id_conversation INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    id_phase INT,
    created_by INT,
    title VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

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
        ON DELETE SET NULL,

    CONSTRAINT fk_conversations_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_conversations_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 19. MESSAGES
-- ============================================================

CREATE TABLE messages (
    id_message INT AUTO_INCREMENT PRIMARY KEY,
    id_conversation INT NOT NULL,
    id_user INT,
    id_engine INT,

    id_message_sender_type INT NOT NULL DEFAULT 1, -- user
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

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
        ON DELETE SET NULL,

    CONSTRAINT fk_messages_sender_type
        FOREIGN KEY (id_message_sender_type)
        REFERENCES message_sender_types(id_message_sender_type)
        ON DELETE RESTRICT,

    CONSTRAINT fk_messages_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_messages_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_messages_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 20. AUDIT_LOGS
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
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_audit_logs_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_logs_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE SET NULL,

    CONSTRAINT fk_audit_logs_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 21. SESSIONS
-- ============================================================

CREATE TABLE sessions (
    id_session INT AUTO_INCREMENT PRIMARY KEY,
    id_user INT NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    expires_at TIMESTAMP NULL DEFAULT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_sessions_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE,

    CONSTRAINT fk_sessions_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_sessions_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_sessions_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- 22. AUDITS  *** NUEVA — HU-017 ***
--     Registro detallado de cambios con JSON.
--     Complementa audit_logs con trazabilidad granular.
-- ============================================================

CREATE TABLE audits (
    id_audit INT AUTO_INCREMENT PRIMARY KEY,
    table_id INT NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    data_old JSON NULL,
    data_new JSON NULL,
    user_id INT NULL,
    deleted_at TIMESTAMP NULL,
    reverted BOOLEAN NOT NULL DEFAULT FALSE,
    reverted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_audits_user
        FOREIGN KEY (user_id)
        REFERENCES users(id_user)
        ON DELETE SET NULL
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

INSERT INTO ai_engines (engine_name, id_ai_engine_type, model_version, description)
VALUES
('Llama Ollama', 1, '3.1', 'Motor local para datos privados y sensibles. No sale del sistema.'),
('Gemini Pro',   2, '1.5', 'Motor cloud de Google para procesamiento general.');

-- ============================================================
-- DATOS INICIALES: PLANTILLAS DE ROLES (HU-020)
-- ============================================================

INSERT INTO role_templates (id_role_template, template_name, description)
VALUES
(1, 'user',       'Usuario estándar con permisos básicos de consumo'),
(2, 'admin',      'Administrador con acceso total de gestión'),
(3, 'supervisor', 'Supervisor con permisos de revisión y auditoría');

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
-- DATOS INICIALES: PERMISOS DE PLANTILLAS (HU-020)
-- (Depende de permissions, por eso va después)
-- ============================================================
-- user: diseñar, ejecutar, subir archivos, IA local
INSERT INTO role_template_permissions (id_role_template, id_permission)
SELECT 1, id_permission FROM permissions
WHERE permission_name IN ('phase_design','phase_execute','upload_files','use_ai_local');

-- admin: todos los permisos
INSERT INTO role_template_permissions (id_role_template, id_permission)
SELECT 2, id_permission FROM permissions;

-- supervisor: supervisar, optimizar, auditoría, IA local
INSERT INTO role_template_permissions (id_role_template, id_permission)
SELECT 3, id_permission FROM permissions
WHERE permission_name IN ('phase_supervise','phase_optimize','view_audit_logs','use_ai_local');

-- ============================================================
-- DATOS INICIALES: PROVEEDORES DE IDENTIDAD (HU-018)
-- ============================================================

INSERT INTO identity_providers (provider_name, description) VALUES
('google', 'Proveedor de autenticación Google OAuth 2.0'),
('apple',  'Proveedor de autenticación Apple Sign-In');

-- ============================================================
-- DATOS INICIALES: CONFIGURACIONES POR DEFECTO (HU-019)
-- ============================================================

INSERT INTO configuration_keys (key_name, display_name, description, category, value_type, default_value, is_required, validation_rules)
VALUES
('has_completed_tour', 'Tour completado',       'Indica si el usuario completó el tour de bienvenida',   'ui',            'boolean', 'false', FALSE, NULL),
('theme',              'Tema de interfaz',       'Tema visual de la aplicación',                          'ui',            'string',  'dark',  FALSE, '{"allowed_values": ["dark", "light", "system"]}'),
('language',           'Idioma',                 'Idioma preferido de la interfaz',                       'ui',            'string',  'es',    FALSE, '{"allowed_values": ["es", "en", "pt"]}'),
('notifications_enabled', 'Notificaciones',      'Habilitar o deshabilitar notificaciones',               'notifications', 'boolean', 'true',  FALSE, NULL);

-- ============================================================
-- INDEXES
-- ============================================================

-- FK / búsqueda indexes (HU-016)
CREATE INDEX idx_users_email                ON users(email);
CREATE INDEX idx_users_status               ON users(id_user_status);

-- HU-019: indexes para sistema de configuración
CREATE INDEX idx_config_keys_category       ON configuration_keys(category);
CREATE INDEX idx_user_configs_user          ON user_configurations(id_user);
CREATE INDEX idx_user_configs_key           ON user_configurations(id_config_key);

-- HU-020: indexes para modelo de roles por equipo/proyecto
CREATE INDEX idx_team_roles_team            ON team_roles(id_team);
CREATE INDEX idx_team_roles_template        ON team_roles(template_id);
CREATE INDEX idx_team_role_perms_role       ON team_role_permissions(id_team_role);
CREATE INDEX idx_team_role_perms_perm       ON team_role_permissions(id_permission);
CREATE INDEX idx_user_team_roles_user       ON user_team_roles(id_user);
CREATE INDEX idx_user_team_roles_team       ON user_team_roles(id_team);
CREATE INDEX idx_user_project_roles_user    ON user_project_roles(id_user);
CREATE INDEX idx_user_project_roles_project ON user_project_roles(id_project);
CREATE INDEX idx_teams_personal             ON teams(is_personal_group);

CREATE INDEX idx_ai_engines_type            ON ai_engines(id_ai_engine_type);

CREATE INDEX idx_projects_created_by        ON projects(created_by);
CREATE INDEX idx_projects_owner             ON projects(owner_user_id);
CREATE INDEX idx_projects_team              ON projects(id_team);
CREATE INDEX idx_projects_status            ON projects(id_project_status);
CREATE INDEX idx_projects_privacy           ON projects(id_project_privacy_level);

CREATE INDEX idx_project_phases_proj        ON project_phases(id_project);
CREATE INDEX idx_project_phases_status      ON project_phases(id_project_phase_status);

CREATE INDEX idx_files_project              ON files(id_project);
CREATE INDEX idx_files_user                 ON files(id_user);
-- HU-021: indexes para relación archivos ↔ conversaciones ↔ mensajes
CREATE INDEX idx_files_conversation         ON files(id_conversation);
CREATE INDEX idx_files_message              ON files(id_message);

CREATE INDEX idx_ai_jobs_project            ON ai_jobs(id_project);
CREATE INDEX idx_ai_jobs_engine             ON ai_jobs(id_engine);
CREATE INDEX idx_ai_jobs_status             ON ai_jobs(id_ai_job_status);
-- HU-022: indexes para tracking de AI jobs
CREATE INDEX idx_ai_jobs_conversation       ON ai_jobs(id_conversation);
CREATE INDEX idx_ai_jobs_message            ON ai_jobs(id_message);
CREATE INDEX idx_ai_jobs_task               ON ai_jobs(id_task);
CREATE INDEX idx_ai_jobs_queue              ON ai_jobs(queue_name);
CREATE INDEX idx_ai_jobs_worker             ON ai_jobs(worker_id);
CREATE INDEX idx_ai_jobs_error_code         ON ai_jobs(final_error_code);

-- HU-022: indexes para ai_job_events
CREATE INDEX idx_ai_job_events_job          ON ai_job_events(id_job);
CREATE INDEX idx_ai_job_events_type         ON ai_job_events(event_type);
CREATE INDEX idx_ai_job_events_created      ON ai_job_events(created_at);

CREATE INDEX idx_ai_results_type            ON ai_results(id_ai_result_type);
-- HU-022: indexes para ai_results enriquecido
CREATE INDEX idx_ai_results_successful      ON ai_results(is_successful);
CREATE INDEX idx_ai_results_source          ON ai_results(result_source);

CREATE INDEX idx_tasks_project              ON tasks(id_project);
CREATE INDEX idx_tasks_status               ON tasks(id_task_status);
CREATE INDEX idx_tasks_priority             ON tasks(id_task_priority);

CREATE INDEX idx_conversations_proj         ON conversations(id_project);

CREATE INDEX idx_messages_conv              ON messages(id_conversation);
CREATE INDEX idx_messages_sender_type       ON messages(id_message_sender_type);

CREATE INDEX idx_audit_logs_user            ON audit_logs(id_user);
CREATE INDEX idx_audit_logs_project         ON audit_logs(id_project);

-- Audits table indexes (HU-017)
CREATE INDEX idx_audits_action              ON audits(action);
CREATE INDEX idx_audits_table_name          ON audits(table_name);
CREATE INDEX idx_audits_user_id             ON audits(user_id);

-- Credentials / password_history indexes (HU-018)
CREATE INDEX idx_credentials_provider       ON credentials(provider_id);
CREATE INDEX idx_credentials_auth_method    ON credentials(id_auth_method);
CREATE INDEX idx_credentials_user           ON credentials(id_user);
CREATE INDEX idx_pw_history_user            ON password_history(id_user);

-- Soft-delete indexes — optimizan WHERE deleted_at IS NULL (HU-017)
CREATE INDEX idx_users_deleted              ON users(deleted_at);
CREATE INDEX idx_projects_deleted           ON projects(deleted_at);
CREATE INDEX idx_files_deleted              ON files(deleted_at);
CREATE INDEX idx_ai_jobs_deleted            ON ai_jobs(deleted_at);
CREATE INDEX idx_tasks_deleted              ON tasks(deleted_at);
CREATE INDEX idx_conversations_deleted      ON conversations(deleted_at);
CREATE INDEX idx_messages_deleted           ON messages(deleted_at);
CREATE INDEX idx_sessions_deleted           ON sessions(deleted_at);
