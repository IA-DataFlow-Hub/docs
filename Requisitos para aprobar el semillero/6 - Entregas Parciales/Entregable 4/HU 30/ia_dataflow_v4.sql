-- ============================================================
-- IA DATAFLOW v4.0 - DATABASE STRUCTURE
-- MySQL 8+ / Prisma compatible
-- ============================================================
-- HU-030: Migración estratégica INT → UUID (CHAR(36))
--   * Operativas: PK CHAR(36) NOT NULL DEFAULT (UUID()).
--   * Catálogos pequeños: INT AUTO_INCREMENT.
--   * created_by/updated_by/deleted_by: CHAR(36) (apuntan a users).
-- ============================================================
-- Hereda HU-016 → HU-029.
-- ============================================================

CREATE DATABASE IF NOT EXISTS ia_dataflow;
USE ia_dataflow;

-- ============================================================
-- CATÁLOGOS (INT)
-- ============================================================

CREATE TABLE user_statuses (
    id_user_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO user_statuses (id_user_status, status_name, description) VALUES
(1,'active','Activo'),(2,'inactive','Inactivo'),(3,'suspended','Suspendido');

CREATE TABLE ai_engine_types (
    id_ai_engine_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT, is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO ai_engine_types VALUES (1,'local','IA local',TRUE,NOW()),(2,'cloud','IA cloud',TRUE,NOW());

CREATE TABLE project_privacy_levels (
    id_project_privacy_level INT AUTO_INCREMENT PRIMARY KEY,
    level_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO project_privacy_levels VALUES (1,'public','Público',TRUE,NOW()),(2,'team','Team',TRUE,NOW()),(3,'private','Privado',TRUE,NOW());

CREATE TABLE project_statuses (
    id_project_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO project_statuses VALUES (1,'active','Activo',TRUE,NOW()),(2,'paused','Pausado',TRUE,NOW()),(3,'completed','Completado',TRUE,NOW()),(4,'archived','Archivado',TRUE,NOW());

CREATE TABLE project_phase_statuses (
    id_project_phase_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO project_phase_statuses VALUES (1,'in_progress','En curso',TRUE,NOW()),(2,'completed','Completada',TRUE,NOW()),(3,'skipped','Omitida',TRUE,NOW());

CREATE TABLE ai_job_statuses (
    id_ai_job_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO ai_job_statuses VALUES (1,'pending','Encolado',TRUE,NOW()),(2,'processing','En ejecución',TRUE,NOW()),(3,'completed','Completado',TRUE,NOW()),(4,'failed','Fallido',TRUE,NOW());

CREATE TABLE ai_result_types (
    id_ai_result_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO ai_result_types VALUES (1,'summary','Resumen',TRUE,NOW()),(2,'transformed_file','Archivo',TRUE,NOW()),(3,'table','Tabla',TRUE,NOW()),(4,'chart','Gráfico',TRUE,NOW()),(5,'suggestion','Sugerencia',TRUE,NOW()),(6,'error_report','Error',TRUE,NOW());

CREATE TABLE task_statuses (
    id_task_status INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO task_statuses VALUES (1,'pending','Pendiente',TRUE,NOW()),(2,'in_progress','En curso',TRUE,NOW()),(3,'completed','Completada',TRUE,NOW()),(4,'cancelled','Cancelada',TRUE,NOW());

CREATE TABLE task_priorities (
    id_task_priority INT AUTO_INCREMENT PRIMARY KEY,
    priority_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO task_priorities VALUES (1,'low','Baja',TRUE,NOW()),(2,'medium','Media',TRUE,NOW()),(3,'high','Alta',TRUE,NOW()),(4,'critical','Crítica',TRUE,NOW());

CREATE TABLE message_sender_types (
    id_message_sender_type INT AUTO_INCREMENT PRIMARY KEY,
    type_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO message_sender_types VALUES (1,'user','Usuario',TRUE,NOW()),(2,'ai_local','IA local',TRUE,NOW()),(3,'ai_cloud','IA cloud',TRUE,NOW()),(4,'system','Sistema',TRUE,NOW());

CREATE TABLE auth_methods (
    id_auth_method INT AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO auth_methods VALUES (1,'password','Local',TRUE,NOW()),(2,'google','Google',TRUE,NOW()),(3,'apple','Apple',TRUE,NOW()),(4,'other','Otro',TRUE,NOW());

CREATE TABLE configuration_keys (
    id_config_key INT AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(100) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    description TEXT, category VARCHAR(100) NOT NULL,
    value_type ENUM('string','boolean','number','json') NOT NULL,
    default_value TEXT NULL, is_required BOOLEAN DEFAULT FALSE,
    validation_rules JSON NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE role_templates (
    id_role_template INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(100) NOT NULL UNIQUE, description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
INSERT INTO role_templates (id_role_template, template_name, description) VALUES
(1,'user','Usuario estándar'),(2,'admin','Administrador'),(3,'supervisor','Supervisor');

-- ============================================================
-- USERS  (UUID — primera operativa)
-- ============================================================

CREATE TABLE users (
    id_user CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    profile_picture VARCHAR(255),
    id_user_status INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by CHAR(36) NULL,
    CONSTRAINT fk_users_status FOREIGN KEY (id_user_status) REFERENCES user_statuses(id_user_status) ON DELETE RESTRICT,
    CONSTRAINT fk_users_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_users_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_users_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE identity_providers (
    id_provider INT AUTO_INCREMENT PRIMARY KEY,
    provider_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT, is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_idp_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_idp_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_idp_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE credentials (
    id_credential CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NOT NULL,
    provider_id INT NULL,
    provider_user_id VARCHAR(255) NULL,
    provider_email VARCHAR(255) NULL,
    password_hash VARCHAR(255) NULL,
    password_salt VARCHAR(255) NULL,
    mfa_enabled BOOLEAN DEFAULT FALSE,
    last_password_change TIMESTAMP NULL,
    id_auth_method INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_credentials_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_credentials_provider FOREIGN KEY (provider_id) REFERENCES identity_providers(id_provider) ON DELETE SET NULL,
    CONSTRAINT fk_credentials_auth_method FOREIGN KEY (id_auth_method) REFERENCES auth_methods(id_auth_method) ON DELETE RESTRICT,
    CONSTRAINT fk_credentials_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_credentials_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_credentials_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE password_history (
    id_history CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_pw_history_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE
);

CREATE TABLE user_configurations (
    id_user_config CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NOT NULL,
    id_config_key INT NOT NULL,
    value TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_config (id_user, id_config_key),
    CONSTRAINT fk_user_config_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_user_config_key FOREIGN KEY (id_config_key) REFERENCES configuration_keys(id_config_key) ON DELETE CASCADE
);

CREATE TABLE permissions (
    id_permission INT AUTO_INCREMENT PRIMARY KEY,
    permission_name VARCHAR(100) NOT NULL UNIQUE,
    module_name VARCHAR(100), description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_permissions_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_permissions_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_permissions_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE role_template_permissions (
    id_role_template_permission INT AUTO_INCREMENT PRIMARY KEY,
    id_role_template INT NOT NULL,
    id_permission INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_template_perm (id_role_template, id_permission),
    CONSTRAINT fk_rtp_template FOREIGN KEY (id_role_template) REFERENCES role_templates(id_role_template) ON DELETE CASCADE,
    CONSTRAINT fk_rtp_permission FOREIGN KEY (id_permission) REFERENCES permissions(id_permission) ON DELETE CASCADE
);

CREATE TABLE teams (
    id_team CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    team_name VARCHAR(150) NOT NULL, description TEXT,
    group_type VARCHAR(50) NOT NULL DEFAULT 'standard',
    is_personal_group BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_teams_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_teams_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_teams_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE team_roles (
    id_team_role CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_team CHAR(36) NOT NULL,
    role_name VARCHAR(100) NOT NULL, description TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    template_id INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_team_role (id_team, role_name),
    CONSTRAINT fk_team_roles_team FOREIGN KEY (id_team) REFERENCES teams(id_team) ON DELETE CASCADE,
    CONSTRAINT fk_team_roles_template FOREIGN KEY (template_id) REFERENCES role_templates(id_role_template) ON DELETE SET NULL
);

CREATE TABLE team_role_permissions (
    id_team_role_permission CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_team_role CHAR(36) NOT NULL,
    id_permission INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uk_team_role_perm (id_team_role, id_permission),
    CONSTRAINT fk_trp_team_role FOREIGN KEY (id_team_role) REFERENCES team_roles(id_team_role) ON DELETE CASCADE,
    CONSTRAINT fk_trp_permission FOREIGN KEY (id_permission) REFERENCES permissions(id_permission) ON DELETE CASCADE
);

CREATE TABLE user_team_roles (
    id_user_team_role CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NOT NULL,
    id_team CHAR(36) NOT NULL,
    id_team_role CHAR(36) NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_team_role (id_user, id_team, id_team_role),
    CONSTRAINT fk_utr_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_utr_team FOREIGN KEY (id_team) REFERENCES teams(id_team) ON DELETE CASCADE,
    CONSTRAINT fk_utr_team_role FOREIGN KEY (id_team_role) REFERENCES team_roles(id_team_role) ON DELETE CASCADE
);

CREATE TABLE workflow_phases (
    id_phase INT AUTO_INCREMENT PRIMARY KEY,
    phase_name VARCHAR(100) NOT NULL UNIQUE,
    phase_order TINYINT NOT NULL DEFAULT 0,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_wf_phases_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_wf_phases_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_wf_phases_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE ai_engines (
    id_engine INT AUTO_INCREMENT PRIMARY KEY,
    engine_name VARCHAR(100) NOT NULL UNIQUE,
    id_ai_engine_type INT NOT NULL,
    model_version VARCHAR(100), description TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_ai_engines_type FOREIGN KEY (id_ai_engine_type) REFERENCES ai_engine_types(id_ai_engine_type) ON DELETE RESTRICT,
    CONSTRAINT fk_ai_engines_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_ai_engines_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_ai_engines_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE projects (
    id_project CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_team CHAR(36) NULL,
    project_name VARCHAR(255) NOT NULL, description TEXT,
    current_phase INT NULL,
    owner_user_id CHAR(36) NULL,
    id_project_privacy_level INT NOT NULL DEFAULT 2,
    id_project_status INT NOT NULL DEFAULT 1,
    status_changed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_projects_team FOREIGN KEY (id_team) REFERENCES teams(id_team) ON DELETE SET NULL,
    CONSTRAINT fk_projects_current_phase FOREIGN KEY (current_phase) REFERENCES workflow_phases(id_phase) ON DELETE SET NULL,
    CONSTRAINT fk_projects_owner FOREIGN KEY (owner_user_id) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_projects_privacy FOREIGN KEY (id_project_privacy_level) REFERENCES project_privacy_levels(id_project_privacy_level) ON DELETE RESTRICT,
    CONSTRAINT fk_projects_status FOREIGN KEY (id_project_status) REFERENCES project_statuses(id_project_status) ON DELETE RESTRICT,
    CONSTRAINT fk_projects_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_projects_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_projects_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE user_project_roles (
    id_user_project_role CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NOT NULL,
    id_project CHAR(36) NOT NULL,
    id_team_role CHAR(36) NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_user_project_role (id_user, id_project),
    CONSTRAINT fk_upr_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_upr_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_upr_team_role FOREIGN KEY (id_team_role) REFERENCES team_roles(id_team_role) ON DELETE CASCADE
);

CREATE TABLE project_phases (
    id_project_phase CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    id_phase INT NOT NULL,
    id_project_phase_status INT NOT NULL DEFAULT 1,
    status_changed_at TIMESTAMP NULL,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL, notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_pp_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_pp_phase FOREIGN KEY (id_phase) REFERENCES workflow_phases(id_phase) ON DELETE CASCADE,
    CONSTRAINT fk_pp_status FOREIGN KEY (id_project_phase_status) REFERENCES project_phase_statuses(id_project_phase_status) ON DELETE RESTRICT,
    CONSTRAINT fk_pp_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_pp_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_pp_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE conversations (
    id_conversation CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    id_phase INT NULL,
    created_by CHAR(36) NULL,
    title VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_conversations_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_conversations_phase FOREIGN KEY (id_phase) REFERENCES workflow_phases(id_phase) ON DELETE SET NULL,
    CONSTRAINT fk_conversations_user FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_conversations_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_conversations_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE messages (
    id_message CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_conversation CHAR(36) NOT NULL,
    id_user CHAR(36) NULL,
    id_engine INT NULL,
    id_message_sender_type INT NOT NULL DEFAULT 1,
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_messages_conversation FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE CASCADE,
    CONSTRAINT fk_messages_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_messages_engine FOREIGN KEY (id_engine) REFERENCES ai_engines(id_engine) ON DELETE SET NULL,
    CONSTRAINT fk_messages_sender_type FOREIGN KEY (id_message_sender_type) REFERENCES message_sender_types(id_message_sender_type) ON DELETE RESTRICT,
    CONSTRAINT fk_messages_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_messages_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_messages_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE files (
    id_file CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    id_user CHAR(36) NULL,
    id_conversation CHAR(36) NULL,
    id_message CHAR(36) NULL,
    file_name VARCHAR(255) NOT NULL,
    original_name VARCHAR(255), file_type VARCHAR(100), file_size BIGINT, storage_path TEXT,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_files_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_files_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_files_conversation FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE SET NULL,
    CONSTRAINT fk_files_message FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE SET NULL,
    CONSTRAINT fk_files_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_files_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_files_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE file_versions (
    id_version CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_file CHAR(36) NOT NULL,
    version_number INT NOT NULL,
    storage_path TEXT, changes_description TEXT, created_by CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    UNIQUE KEY uq_file_versions (id_file, version_number),
    CONSTRAINT fk_file_versions_file FOREIGN KEY (id_file) REFERENCES files(id_file) ON DELETE CASCADE,
    CONSTRAINT fk_file_versions_user FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_file_versions_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_file_versions_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE tasks (
    id_task CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    id_phase INT NULL,
    assigned_to CHAR(36) NULL,
    created_by CHAR(36) NULL,
    title VARCHAR(255) NOT NULL, description TEXT,
    id_task_status INT NOT NULL DEFAULT 1,
    id_task_priority INT NOT NULL DEFAULT 2,
    status_changed_at TIMESTAMP NULL, due_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_tasks_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_tasks_phase FOREIGN KEY (id_phase) REFERENCES workflow_phases(id_phase) ON DELETE SET NULL,
    CONSTRAINT fk_tasks_assigned_to FOREIGN KEY (assigned_to) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_tasks_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_tasks_status FOREIGN KEY (id_task_status) REFERENCES task_statuses(id_task_status) ON DELETE RESTRICT,
    CONSTRAINT fk_tasks_priority FOREIGN KEY (id_task_priority) REFERENCES task_priorities(id_task_priority) ON DELETE RESTRICT,
    CONSTRAINT fk_tasks_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_tasks_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- AI_JOBS / AI_JOB_EVENTS / AI_RESULTS  (UUID)
-- ============================================================

CREATE TABLE ai_jobs (
    id_job CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    id_file CHAR(36) NULL,
    id_engine INT NOT NULL,
    id_phase INT NULL,
    requested_by CHAR(36) NULL,
    job_type VARCHAR(100) NOT NULL,
    prompt_text TEXT, prompt_metadata JSON NULL,
    input_data_reference TEXT NULL,
    is_private BOOLEAN DEFAULT FALSE,
    created_from VARCHAR(100) NULL,
    id_ai_job_status INT NOT NULL DEFAULT 1,
    status_changed_at TIMESTAMP NULL,
    queued_at TIMESTAMP NULL, started_at TIMESTAMP NULL,
    processing_at TIMESTAMP NULL, finished_at TIMESTAMP NULL,
    failed_at TIMESTAMP NULL, cancelled_at TIMESTAMP NULL,
    requeued_at TIMESTAMP NULL,
    updated_source VARCHAR(100) NULL,
    tokens_prompt INT DEFAULT 0,
    tokens_completion INT DEFAULT 0,
    tokens_total INT GENERATED ALWAYS AS (tokens_prompt + tokens_completion) STORED,
    processing_time_ms INT DEFAULT 0,
    elapsed_time_ms INT DEFAULT 0,
    cost_estimated DECIMAL(12,6) NULL,
    cost_actual DECIMAL(12,6) NULL,
    provider_request_id VARCHAR(255) NULL,
    model_version_snapshot VARCHAR(100) NULL,
    model_info JSON NULL,
    id_conversation CHAR(36) NULL,
    id_message CHAR(36) NULL,
    id_task CHAR(36) NULL,
    error_message TEXT NULL, error_stack TEXT NULL, error_context JSON NULL,
    retries_attempted INT DEFAULT 0,
    max_retries INT DEFAULT 3,
    next_retry_at TIMESTAMP NULL,
    final_error_code VARCHAR(100) NULL,
    worker_id VARCHAR(100) NULL,
    queue_name VARCHAR(100) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_ai_jobs_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_ai_jobs_file FOREIGN KEY (id_file) REFERENCES files(id_file) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_engine FOREIGN KEY (id_engine) REFERENCES ai_engines(id_engine) ON DELETE RESTRICT,
    CONSTRAINT fk_ai_jobs_phase FOREIGN KEY (id_phase) REFERENCES workflow_phases(id_phase) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_user FOREIGN KEY (requested_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_status FOREIGN KEY (id_ai_job_status) REFERENCES ai_job_statuses(id_ai_job_status) ON DELETE RESTRICT,
    CONSTRAINT fk_ai_jobs_conversation FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_message FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_task FOREIGN KEY (id_task) REFERENCES tasks(id_task) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_ai_jobs_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE ai_job_events (
    id_job_event CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_job CHAR(36) NOT NULL,
    event_type ENUM('created','queued','started','completed','failed','retry','cancelled','warning','info') NOT NULL,
    event_message TEXT NULL, event_data JSON NULL,
    actor_type ENUM('user','system','worker','scheduler') DEFAULT 'system',
    actor_id CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ai_job_events_job FOREIGN KEY (id_job) REFERENCES ai_jobs(id_job) ON DELETE CASCADE,
    CONSTRAINT fk_ai_job_events_actor FOREIGN KEY (actor_id) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE ai_results (
    id_result CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_job CHAR(36) NOT NULL,
    id_ai_result_type INT NOT NULL DEFAULT 1,
    result_summary TEXT, output_path TEXT,
    output_raw LONGTEXT NULL, output_json JSON NULL,
    result_metadata JSON NULL, result_source VARCHAR(100) NULL,
    is_successful BOOLEAN DEFAULT TRUE,
    error_code VARCHAR(100) NULL, error_message TEXT NULL,
    finished_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_ai_results_job FOREIGN KEY (id_job) REFERENCES ai_jobs(id_job) ON DELETE CASCADE,
    CONSTRAINT fk_ai_results_type FOREIGN KEY (id_ai_result_type) REFERENCES ai_result_types(id_ai_result_type) ON DELETE RESTRICT,
    CONSTRAINT fk_ai_results_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_ai_results_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_ai_results_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- HU-026: GENERATED_TABLES + COLUMNS  (UUID)
-- ============================================================

CREATE TABLE generated_tables (
    id_generated_table CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    id_conversation CHAR(36) NULL,
    id_message CHAR(36) NULL,
    id_user CHAR(36) NULL,
    id_job CHAR(36) NULL,
    source_file_id CHAR(36) NULL,
    parent_generated_table_id CHAR(36) NULL,
    table_name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255), description TEXT,
    storage_type ENUM('csv','json','parquet','xlsx') DEFAULT 'parquet',
    storage_path TEXT NOT NULL,
    preview_path TEXT NULL, schema_path TEXT NULL,
    rows_count BIGINT DEFAULT 0,
    columns_count INT DEFAULT 0,
    file_size BIGINT DEFAULT 0,
    generation_type ENUM('uploaded','ai_generated','transformed','imported') DEFAULT 'uploaded',
    status ENUM('processing','ready','failed','archived') DEFAULT 'ready',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_gt_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_gt_conversation FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE SET NULL,
    CONSTRAINT fk_gt_message FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE SET NULL,
    CONSTRAINT fk_gt_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_gt_job FOREIGN KEY (id_job) REFERENCES ai_jobs(id_job) ON DELETE SET NULL,
    CONSTRAINT fk_gt_source_file FOREIGN KEY (source_file_id) REFERENCES files(id_file) ON DELETE SET NULL,
    CONSTRAINT fk_gt_parent FOREIGN KEY (parent_generated_table_id) REFERENCES generated_tables(id_generated_table) ON DELETE SET NULL
);

CREATE TABLE generated_table_columns (
    id_column CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_generated_table CHAR(36) NOT NULL,
    column_name VARCHAR(255) NOT NULL,
    data_type VARCHAR(100),
    is_nullable BOOLEAN DEFAULT TRUE,
    is_primary_key BOOLEAN DEFAULT FALSE,
    is_foreign_key BOOLEAN DEFAULT FALSE,
    is_unique_column BOOLEAN DEFAULT FALSE,
    default_value TEXT, validations JSON NULL,
    column_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_gtc_table FOREIGN KEY (id_generated_table) REFERENCES generated_tables(id_generated_table) ON DELETE CASCADE
);

-- ============================================================
-- HU-027: ETL  (UUID)
-- ============================================================

CREATE TABLE etl_templates (
    id_template CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NULL, created_by CHAR(36) NULL,
    template_name VARCHAR(255) NOT NULL, description TEXT,
    category ENUM('cleaning','transformation','validation','enrichment','optimization') DEFAULT 'transformation',
    difficulty ENUM('easy','medium','advanced') DEFAULT 'easy',
    estimated_time_minutes INT DEFAULT 5,
    icon VARCHAR(100), color VARCHAR(50),
    is_system BOOLEAN DEFAULT FALSE,
    is_public BOOLEAN DEFAULT FALSE,
    version VARCHAR(20) DEFAULT '1.0.0',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_etl_templates_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_etl_templates_user FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE etl_template_steps (
    id_step CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_template CHAR(36) NOT NULL,
    step_order INT NOT NULL,
    step_name VARCHAR(255) NOT NULL,
    operation_type ENUM('remove_duplicates','normalize','fill_nulls','validate','enrich','optimize_schema','custom') NOT NULL,
    configuration JSON NULL,
    ai_enabled BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_etl_steps_template FOREIGN KEY (id_template) REFERENCES etl_templates(id_template) ON DELETE CASCADE
);

CREATE TABLE etl_executions (
    id_execution CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_template CHAR(36) NOT NULL,
    id_project CHAR(36) NOT NULL,
    id_generated_table CHAR(36) NOT NULL,
    executed_by CHAR(36) NULL,
    id_conversation CHAR(36) NULL,
    id_message CHAR(36) NULL,
    execution_status ENUM('pending','running','completed','failed','cancelled') DEFAULT 'pending',
    started_at TIMESTAMP NULL, finished_at TIMESTAMP NULL,
    execution_time_ms BIGINT DEFAULT 0,
    rows_processed BIGINT DEFAULT 0,
    output_generated_table_id CHAR(36) NULL,
    logs_path TEXT NULL, error_message TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_etl_exec_template FOREIGN KEY (id_template) REFERENCES etl_templates(id_template) ON DELETE CASCADE,
    CONSTRAINT fk_etl_exec_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_etl_exec_dataset FOREIGN KEY (id_generated_table) REFERENCES generated_tables(id_generated_table) ON DELETE CASCADE,
    CONSTRAINT fk_etl_exec_user FOREIGN KEY (executed_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_etl_exec_conversation FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE SET NULL,
    CONSTRAINT fk_etl_exec_message FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE SET NULL,
    CONSTRAINT fk_etl_exec_output_dataset FOREIGN KEY (output_generated_table_id) REFERENCES generated_tables(id_generated_table) ON DELETE SET NULL
);

CREATE TABLE etl_execution_logs (
    id_log CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_execution CHAR(36) NOT NULL,
    log_level ENUM('info','warning','error') DEFAULT 'info',
    message TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_etl_logs_execution FOREIGN KEY (id_execution) REFERENCES etl_executions(id_execution) ON DELETE CASCADE
);

-- ============================================================
-- HU-023: MESSAGE_FEEDBACK + REPORTS  (UUID)
-- ============================================================

CREATE TABLE message_feedback (
    id_feedback CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_message CHAR(36) NOT NULL,
    id_user CHAR(36) NOT NULL,
    feedback_type ENUM('like','dislike') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_feedback_unique UNIQUE (id_message, id_user),
    CONSTRAINT fk_feedback_message FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE CASCADE,
    CONSTRAINT fk_feedback_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE
);

CREATE TABLE reports (
    id_report CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NOT NULL,
    report_type ENUM('message','conversation','application') NOT NULL,
    id_message CHAR(36) NULL,
    id_conversation CHAR(36) NULL,
    id_project CHAR(36) NULL,
    category ENUM('incorrect_response','false_information','offensive_content','technical_error','duplication','performance_issue','security_issue','ui_bug','auth_issue','loading_issue','flow_error','out_of_context','other') DEFAULT 'other',
    priority ENUM('low','medium','high','critical') DEFAULT 'medium',
    description TEXT,
    status ENUM('pending','in_review','resolved','rejected') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_reports_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_reports_message FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE SET NULL,
    CONSTRAINT fk_reports_conversation FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE SET NULL,
    CONSTRAINT fk_reports_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE SET NULL,
    CONSTRAINT fk_reports_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_reports_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT chk_reports_reference CHECK (
        (report_type = 'message' AND id_message IS NOT NULL)
        OR (report_type = 'conversation' AND id_conversation IS NOT NULL)
        OR (report_type = 'application' AND id_message IS NULL AND id_conversation IS NULL)
    )
);

-- ============================================================
-- HU-025: NOTIFICATIONS  (UUID)
-- ============================================================

CREATE TABLE notifications (
    id_notification CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    notification_type ENUM('info','success','warning','error','critical') DEFAULT 'info',
    category ENUM('collaboration','ai','task','security','system','workflow','project','comment') DEFAULT 'system',
    sender_id CHAR(36) NULL,
    id_project CHAR(36) NULL,
    id_team CHAR(36) NULL,
    id_team_role CHAR(36) NULL,
    source_entity_type VARCHAR(100) NULL,
    source_entity_id CHAR(36) NULL,
    action_url TEXT NULL, action_label VARCHAR(100) NULL,
    icon VARCHAR(100), is_global BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_notifications_sender FOREIGN KEY (sender_id) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_notifications_team FOREIGN KEY (id_team) REFERENCES teams(id_team) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_team_role FOREIGN KEY (id_team_role) REFERENCES team_roles(id_team_role) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_notifications_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE notification_recipients (
    id_notification_recipient CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_notification CHAR(36) NOT NULL,
    id_user CHAR(36) NOT NULL,
    delivery_status ENUM('pending','sent','delivered','failed') DEFAULT 'pending',
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP NULL, delivered_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL, failure_reason TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT uq_notification_recipient UNIQUE (id_notification, id_user),
    CONSTRAINT fk_nr_notification FOREIGN KEY (id_notification) REFERENCES notifications(id_notification) ON DELETE CASCADE,
    CONSTRAINT fk_nr_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE
);

CREATE TABLE notification_groups (
    id_group_notification CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    group_name VARCHAR(150) NOT NULL,
    description TEXT,
    id_team CHAR(36) NULL,
    id_project CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_notification_groups_team FOREIGN KEY (id_team) REFERENCES teams(id_team) ON DELETE SET NULL,
    CONSTRAINT fk_notification_groups_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE SET NULL,
    CONSTRAINT fk_notification_groups_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_notification_groups_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_notification_groups_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE notification_group_members (
    id_group_notification CHAR(36) NOT NULL,
    id_user CHAR(36) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_group_notification, id_user),
    CONSTRAINT fk_ngm_group FOREIGN KEY (id_group_notification) REFERENCES notification_groups(id_group_notification) ON DELETE CASCADE,
    CONSTRAINT fk_ngm_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE
);

-- ============================================================
-- HU-028: ACTIVITY_FEED  (UUID)
-- ============================================================

CREATE TABLE activity_feed (
    id_activity CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    id_user CHAR(36) NULL,
    id_phase INT NULL,
    id_conversation CHAR(36) NULL,
    id_message CHAR(36) NULL,
    id_generated_table CHAR(36) NULL,
    id_job CHAR(36) NULL,
    id_execution CHAR(36) NULL,
    id_file CHAR(36) NULL,
    activity_type ENUM('file_uploaded','analysis_completed','transformation_applied','data_edited','optimization_suggested','etl_executed','validation_completed','comment_added','dataset_generated','error_detected','export_generated','user_login','report_created') NOT NULL,
    activity_level ENUM('info','success','warning','error','critical') DEFAULT 'info',
    title VARCHAR(255) NOT NULL,
    description TEXT, metadata JSON NULL,
    is_system_generated BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_activity_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_activity_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_activity_phase FOREIGN KEY (id_phase) REFERENCES workflow_phases(id_phase) ON DELETE SET NULL,
    CONSTRAINT fk_activity_conversation FOREIGN KEY (id_conversation) REFERENCES conversations(id_conversation) ON DELETE SET NULL,
    CONSTRAINT fk_activity_message FOREIGN KEY (id_message) REFERENCES messages(id_message) ON DELETE SET NULL,
    CONSTRAINT fk_activity_dataset FOREIGN KEY (id_generated_table) REFERENCES generated_tables(id_generated_table) ON DELETE SET NULL,
    CONSTRAINT fk_activity_job FOREIGN KEY (id_job) REFERENCES ai_jobs(id_job) ON DELETE SET NULL,
    CONSTRAINT fk_activity_execution FOREIGN KEY (id_execution) REFERENCES etl_executions(id_execution) ON DELETE SET NULL,
    CONSTRAINT fk_activity_file FOREIGN KEY (id_file) REFERENCES files(id_file) ON DELETE SET NULL
);

-- ============================================================
-- HU-029: ANALYTICS_REPORTS  (UUID)
-- ============================================================

CREATE TABLE analytics_reports (
    id_report CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_project CHAR(36) NOT NULL,
    created_by CHAR(36) NOT NULL,
    report_name VARCHAR(255) NOT NULL,
    report_type ENUM('strategic','tactical','operational','analytical') NOT NULL,
    description TEXT,
    visibility ENUM('private','team','public') DEFAULT 'team',
    status ENUM('draft','active','archived') DEFAULT 'active',
    current_version INT DEFAULT 1,
    is_ai_generated BOOLEAN DEFAULT FALSE,
    last_generated_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_analytics_reports_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE CASCADE,
    CONSTRAINT fk_analytics_reports_user FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE CASCADE
);

CREATE TABLE analytics_report_versions (
    id_version CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_report CHAR(36) NOT NULL,
    version_number INT NOT NULL,
    configuration_path TEXT NOT NULL,
    snapshot_path TEXT NULL,
    changelog TEXT,
    created_by CHAR(36) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_arv_report FOREIGN KEY (id_report) REFERENCES analytics_reports(id_report) ON DELETE CASCADE,
    CONSTRAINT fk_arv_user FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT uq_arv_report_version UNIQUE (id_report, version_number)
);

CREATE TABLE analytics_report_widgets (
    id_widget CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_report CHAR(36) NOT NULL,
    widget_type ENUM('kpi','line_chart','bar_chart','pie_chart','table','heatmap','metric_card','trend','ai_insight') NOT NULL,
    widget_title VARCHAR(255), dataset_source VARCHAR(255),
    config JSON NOT NULL,
    position_x INT DEFAULT 0, position_y INT DEFAULT 0,
    width INT DEFAULT 4, height INT DEFAULT 4,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_arw_report FOREIGN KEY (id_report) REFERENCES analytics_reports(id_report) ON DELETE CASCADE
);

CREATE TABLE analytics_report_metrics (
    id_metric CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_report CHAR(36) NOT NULL,
    metric_name VARCHAR(255) NOT NULL,
    metric_formula TEXT,
    aggregation_type ENUM('sum','avg','count','min','max','custom') DEFAULT 'sum',
    format_type ENUM('currency','percentage','number','decimal') DEFAULT 'number',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_arm_report FOREIGN KEY (id_report) REFERENCES analytics_reports(id_report) ON DELETE CASCADE
);

CREATE TABLE analytics_report_exports (
    id_export CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_report CHAR(36) NOT NULL,
    exported_by CHAR(36) NOT NULL,
    export_type ENUM('pdf','excel','csv','png','json') NOT NULL,
    storage_path TEXT NOT NULL,
    file_size BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_are_report FOREIGN KEY (id_report) REFERENCES analytics_reports(id_report) ON DELETE CASCADE,
    CONSTRAINT fk_are_user FOREIGN KEY (exported_by) REFERENCES users(id_user) ON DELETE CASCADE
);

-- ============================================================
-- AUDIT_LOGS / SESSIONS / AUDITS  (UUID)
-- entity_id ahora CHAR(36) (puede apuntar a cualquier UUID).
-- ============================================================

CREATE TABLE audit_logs (
    id_log CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NULL,
    id_project CHAR(36) NULL,
    action VARCHAR(255) NOT NULL,
    entity_type VARCHAR(100),
    entity_id CHAR(36),
    old_value TEXT, new_value TEXT,
    ip_address VARCHAR(45),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_audit_logs_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_audit_logs_project FOREIGN KEY (id_project) REFERENCES projects(id_project) ON DELETE SET NULL,
    CONSTRAINT fk_audit_logs_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE sessions (
    id_session CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    id_user CHAR(36) NOT NULL,
    session_token VARCHAR(255) NOT NULL UNIQUE,
    refresh_token VARCHAR(255) NULL,
    ip_address VARCHAR(45), user_agent TEXT,
    browser_name VARCHAR(100), browser_version VARCHAR(50),
    operating_system VARCHAR(100), operating_system_version VARCHAR(50),
    device_type ENUM('desktop','mobile','tablet','bot','unknown') DEFAULT 'unknown',
    device_name VARCHAR(150),
    country VARCHAR(100), city VARCHAR(100),
    is_current BOOLEAN DEFAULT FALSE,
    status ENUM('active','inactive','expired','revoked') DEFAULT 'active',
    login_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_action VARCHAR(255) NULL,
    heartbeat_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, created_by CHAR(36) NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, updated_by CHAR(36) NULL,
    expires_at TIMESTAMP NULL, revoked_at TIMESTAMP NULL,
    revoke_reason VARCHAR(255),
    deleted_at TIMESTAMP NULL, deleted_by CHAR(36) NULL,
    CONSTRAINT fk_sessions_user FOREIGN KEY (id_user) REFERENCES users(id_user) ON DELETE CASCADE,
    CONSTRAINT fk_sessions_created_by FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_sessions_updated_by FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,
    CONSTRAINT fk_sessions_deleted_by FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

CREATE TABLE audits (
    id_audit CHAR(36) NOT NULL DEFAULT (UUID()) PRIMARY KEY,
    table_id CHAR(36) NOT NULL,
    table_name VARCHAR(255) NOT NULL,
    action VARCHAR(255) NOT NULL,
    data_old JSON NULL, data_new JSON NULL,
    user_id CHAR(36) NULL,
    deleted_at TIMESTAMP NULL,
    reverted BOOLEAN NOT NULL DEFAULT FALSE,
    reverted_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audits_user FOREIGN KEY (user_id) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ============================================================
-- DATOS INICIALES (catálogos)
-- ============================================================

INSERT INTO workflow_phases (phase_name, phase_order, description) VALUES
('Diseñar',1,'Carga de documentos y análisis'),
('Ejecutar',2,'Aplicar transformaciones'),
('Supervisar',3,'Registrar cambios para auditoría'),
('Optimizar',4,'Mejoras continuas');

INSERT INTO ai_engines (engine_name, id_ai_engine_type, model_version, description) VALUES
('Llama Ollama',1,'3.1','Motor local'),
('Gemini Pro',2,'1.5','Motor cloud Google');

INSERT INTO permissions (permission_name, module_name, description) VALUES
('phase_design','Diseñar','Acceso al módulo de Diseño'),
('phase_execute','Ejecutar','Acceso al módulo de Ejecución'),
('phase_supervise','Supervisar','Acceso al módulo de Supervisión'),
('phase_optimize','Optimizar','Acceso al módulo de Optimización'),
('manage_teams','Teams','Crear y gestionar equipos'),
('manage_users','Users','Administrar usuarios'),
('upload_files','Files','Subir archivos'),
('view_audit_logs','Audit','Ver auditoría'),
('use_ai_local','AI','Usar IA local'),
('use_ai_cloud','AI','Usar IA cloud');

INSERT INTO role_template_permissions (id_role_template, id_permission)
SELECT 1, id_permission FROM permissions
WHERE permission_name IN ('phase_design','phase_execute','upload_files','use_ai_local');

INSERT INTO role_template_permissions (id_role_template, id_permission)
SELECT 2, id_permission FROM permissions;

INSERT INTO role_template_permissions (id_role_template, id_permission)
SELECT 3, id_permission FROM permissions
WHERE permission_name IN ('phase_supervise','phase_optimize','view_audit_logs','use_ai_local');

INSERT INTO identity_providers (provider_name, description) VALUES
('google','Google OAuth 2.0'),
('apple','Apple Sign-In');

INSERT INTO configuration_keys (key_name, display_name, description, category, value_type, default_value, is_required, validation_rules) VALUES
('has_completed_tour','Tour completado','Indica si completó el tour','ui','boolean','false',FALSE,NULL),
('theme','Tema','Tema visual','ui','string','dark',FALSE,'{"allowed_values":["dark","light","system"]}'),
('language','Idioma','Idioma preferido','ui','string','es',FALSE,'{"allowed_values":["es","en","pt"]}'),
('notifications_enabled','Notificaciones','Habilitar notificaciones','notifications','boolean','true',FALSE,NULL);

-- HU-027 seeds: ETL system templates + steps
SET @t1 = UUID(); SET @t2 = UUID(); SET @t3 = UUID();
SET @t4 = UUID(); SET @t5 = UUID(); SET @t6 = UUID();

INSERT INTO etl_templates (id_template, id_project, created_by, template_name, description, category, difficulty, estimated_time_minutes, icon, color, is_system, is_public, version) VALUES
(@t1,NULL,NULL,'Eliminación de Duplicados','Detecta y elimina duplicados','cleaning','easy',5,'copy-x','green',TRUE,TRUE,'1.0.0'),
(@t2,NULL,NULL,'Normalización de Datos','Normaliza formatos','transformation','medium',10,'sliders','blue',TRUE,TRUE,'1.0.0'),
(@t3,NULL,NULL,'Manejo de Valores Faltantes','Detecta nulos','cleaning','medium',10,'droplet','teal',TRUE,TRUE,'1.0.0'),
(@t4,NULL,NULL,'Validación de Datos','Valida reglas','validation','medium',10,'check-circle','purple',TRUE,TRUE,'1.0.0'),
(@t5,NULL,NULL,'Enriquecimiento de Datos','Crea métricas derivadas','enrichment','advanced',20,'sparkles','orange',TRUE,TRUE,'1.0.0'),
(@t6,NULL,NULL,'Optimización de Esquema','Optimiza tipos','optimization','advanced',20,'zap','yellow',TRUE,TRUE,'1.0.0');

INSERT INTO etl_template_steps (id_template, step_order, step_name, operation_type, configuration, ai_enabled) VALUES
(@t1,1,'Eliminar duplicados','remove_duplicates',NULL,FALSE),
(@t2,1,'Normalizar','normalize',NULL,TRUE),
(@t3,1,'Rellenar nulos','fill_nulls',NULL,TRUE),
(@t4,1,'Validar','validate',NULL,TRUE),
(@t5,1,'Enriquecer','enrich',NULL,TRUE),
(@t6,1,'Optimizar esquema','optimize_schema',NULL,TRUE);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_users_email                ON users(email);
CREATE INDEX idx_users_status               ON users(id_user_status);
CREATE INDEX idx_users_deleted              ON users(deleted_at);

CREATE INDEX idx_config_keys_category       ON configuration_keys(category);
CREATE INDEX idx_user_configs_user          ON user_configurations(id_user);
CREATE INDEX idx_user_configs_key           ON user_configurations(id_config_key);

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
CREATE INDEX idx_projects_deleted           ON projects(deleted_at);

CREATE INDEX idx_project_phases_proj        ON project_phases(id_project);
CREATE INDEX idx_project_phases_status      ON project_phases(id_project_phase_status);

CREATE INDEX idx_files_project              ON files(id_project);
CREATE INDEX idx_files_user                 ON files(id_user);
CREATE INDEX idx_files_conversation         ON files(id_conversation);
CREATE INDEX idx_files_message              ON files(id_message);
CREATE INDEX idx_files_deleted              ON files(deleted_at);

CREATE INDEX idx_ai_jobs_project            ON ai_jobs(id_project);
CREATE INDEX idx_ai_jobs_engine             ON ai_jobs(id_engine);
CREATE INDEX idx_ai_jobs_status             ON ai_jobs(id_ai_job_status);
CREATE INDEX idx_ai_jobs_conversation       ON ai_jobs(id_conversation);
CREATE INDEX idx_ai_jobs_message            ON ai_jobs(id_message);
CREATE INDEX idx_ai_jobs_task               ON ai_jobs(id_task);
CREATE INDEX idx_ai_jobs_queue              ON ai_jobs(queue_name);
CREATE INDEX idx_ai_jobs_worker             ON ai_jobs(worker_id);
CREATE INDEX idx_ai_jobs_error_code         ON ai_jobs(final_error_code);
CREATE INDEX idx_ai_jobs_deleted            ON ai_jobs(deleted_at);

CREATE INDEX idx_ai_job_events_job          ON ai_job_events(id_job);
CREATE INDEX idx_ai_job_events_type         ON ai_job_events(event_type);
CREATE INDEX idx_ai_job_events_created      ON ai_job_events(created_at);

CREATE INDEX idx_ai_results_type            ON ai_results(id_ai_result_type);
CREATE INDEX idx_ai_results_successful      ON ai_results(is_successful);
CREATE INDEX idx_ai_results_source          ON ai_results(result_source);

CREATE INDEX idx_tasks_project              ON tasks(id_project);
CREATE INDEX idx_tasks_status               ON tasks(id_task_status);
CREATE INDEX idx_tasks_priority             ON tasks(id_task_priority);
CREATE INDEX idx_tasks_deleted              ON tasks(deleted_at);

CREATE INDEX idx_conversations_proj         ON conversations(id_project);
CREATE INDEX idx_conversations_deleted      ON conversations(deleted_at);

CREATE INDEX idx_messages_conv              ON messages(id_conversation);
CREATE INDEX idx_messages_sender_type       ON messages(id_message_sender_type);
CREATE INDEX idx_messages_deleted           ON messages(deleted_at);

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

CREATE INDEX idx_activity_project           ON activity_feed(id_project);
CREATE INDEX idx_activity_user              ON activity_feed(id_user);
CREATE INDEX idx_activity_type              ON activity_feed(activity_type);
CREATE INDEX idx_activity_created           ON activity_feed(created_at);
CREATE INDEX idx_activity_phase             ON activity_feed(id_phase);
CREATE INDEX idx_activity_conversation      ON activity_feed(id_conversation);
CREATE INDEX idx_activity_dataset           ON activity_feed(id_generated_table);

CREATE INDEX idx_ar_project                 ON analytics_reports(id_project);
CREATE INDEX idx_ar_user                    ON analytics_reports(created_by);
CREATE INDEX idx_ar_type                    ON analytics_reports(report_type);
CREATE INDEX idx_ar_visibility              ON analytics_reports(visibility);
CREATE INDEX idx_ar_status                  ON analytics_reports(status);
CREATE INDEX idx_arv_report                 ON analytics_report_versions(id_report);
CREATE INDEX idx_arw_report                 ON analytics_report_widgets(id_report);
CREATE INDEX idx_arw_type                   ON analytics_report_widgets(widget_type);
CREATE INDEX idx_arm_report                 ON analytics_report_metrics(id_report);
CREATE INDEX idx_are_report                 ON analytics_report_exports(id_report);
CREATE INDEX idx_are_user                   ON analytics_report_exports(exported_by);
CREATE INDEX idx_are_type                   ON analytics_report_exports(export_type);

CREATE INDEX idx_notifications_project      ON notifications(id_project);
CREATE INDEX idx_notifications_team         ON notifications(id_team);
CREATE INDEX idx_notifications_team_role    ON notifications(id_team_role);
CREATE INDEX idx_notifications_sender       ON notifications(sender_id);
CREATE INDEX idx_notifications_type         ON notifications(notification_type);
CREATE INDEX idx_notifications_category     ON notifications(category);
CREATE INDEX idx_notifications_created      ON notifications(created_at);
CREATE INDEX idx_notifications_global       ON notifications(is_global);
CREATE INDEX idx_notifications_deleted      ON notifications(deleted_at);
CREATE INDEX idx_nr_user                    ON notification_recipients(id_user);
CREATE INDEX idx_nr_notification            ON notification_recipients(id_notification);
CREATE INDEX idx_nr_read                    ON notification_recipients(is_read);
CREATE INDEX idx_nr_delivery                ON notification_recipients(delivery_status);
CREATE INDEX idx_ngroups_team               ON notification_groups(id_team);
CREATE INDEX idx_ngroups_project            ON notification_groups(id_project);
CREATE INDEX idx_ngroups_deleted            ON notification_groups(deleted_at);
CREATE INDEX idx_ngm_user                   ON notification_group_members(id_user);

CREATE INDEX idx_audit_logs_user            ON audit_logs(id_user);
CREATE INDEX idx_audit_logs_project         ON audit_logs(id_project);
CREATE INDEX idx_audit_logs_entity          ON audit_logs(entity_type, entity_id);

CREATE INDEX idx_audits_action              ON audits(action);
CREATE INDEX idx_audits_table_name          ON audits(table_name);
CREATE INDEX idx_audits_user_id             ON audits(user_id);

CREATE INDEX idx_credentials_provider       ON credentials(provider_id);
CREATE INDEX idx_credentials_auth_method    ON credentials(id_auth_method);
CREATE INDEX idx_credentials_user           ON credentials(id_user);
CREATE INDEX idx_pw_history_user            ON password_history(id_user);

CREATE INDEX idx_sessions_user              ON sessions(id_user);
CREATE INDEX idx_sessions_status            ON sessions(status);
CREATE INDEX idx_sessions_last_activity     ON sessions(last_activity_at);
CREATE INDEX idx_sessions_token             ON sessions(session_token);
CREATE INDEX idx_sessions_refresh_token     ON sessions(refresh_token);
CREATE INDEX idx_sessions_device_type       ON sessions(device_type);
CREATE INDEX idx_sessions_revoked_at        ON sessions(revoked_at);
CREATE INDEX idx_sessions_deleted           ON sessions(deleted_at);
