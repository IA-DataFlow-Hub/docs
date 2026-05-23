-- ============================================================
-- MIGRACIÓN HU-020: Modelo de roles por equipo, proyecto y grupo personal
-- v3.1 → v3.2
--
-- Estrategia:
--   1. Crear tablas nuevas (role_templates, role_template_permissions,
--      team_roles, team_role_permissions, user_team_roles, user_project_roles).
--   2. Extender teams con group_type + is_personal_group.
--   3. Insertar plantillas de roles globales.
--   4. Insertar permisos de plantillas.
--   5. Migrar datos existentes:
--      a. roles → role_templates (ya insertados manualmente).
--      b. Para cada equipo existente, crear team_roles basados en plantillas.
--      c. Copiar permisos de plantillas a team_role_permissions.
--      d. team_members → user_team_roles (mapear member_role → team_role).
--      e. user_roles → user_team_roles en personal_group del usuario.
--   6. Crear personal_group para usuarios sin equipo.
--   7. Eliminar tablas obsoletas.
--   8. Crear índices.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. CREAR TABLAS NUEVAS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS role_templates (
    id_role_template INT AUTO_INCREMENT PRIMARY KEY,
    template_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS role_template_permissions (
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

CREATE TABLE IF NOT EXISTS team_roles (
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

CREATE TABLE IF NOT EXISTS team_role_permissions (
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

CREATE TABLE IF NOT EXISTS user_team_roles (
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

CREATE TABLE IF NOT EXISTS user_project_roles (
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

-- ------------------------------------------------------------
-- 2. EXTENDER TABLA TEAMS
-- ------------------------------------------------------------

ALTER TABLE teams
    ADD COLUMN group_type VARCHAR(50) NOT NULL DEFAULT 'standard' AFTER description,
    ADD COLUMN is_personal_group BOOLEAN NOT NULL DEFAULT FALSE AFTER group_type;

-- ------------------------------------------------------------
-- 3. INSERTAR PLANTILLAS DE ROLES GLOBALES
-- ------------------------------------------------------------

INSERT IGNORE INTO role_templates (id_role_template, template_name, description) VALUES
(1, 'user',       'Usuario estándar con permisos básicos de consumo'),
(2, 'admin',      'Administrador con acceso total de gestión'),
(3, 'supervisor', 'Supervisor con permisos de revisión y auditoría');

-- ------------------------------------------------------------
-- 4. INSERTAR PERMISOS DE PLANTILLAS
-- ------------------------------------------------------------

-- user: diseñar, ejecutar, subir archivos, IA local
INSERT IGNORE INTO role_template_permissions (id_role_template, id_permission)
SELECT 1, id_permission FROM permissions
WHERE permission_name IN ('phase_design','phase_execute','upload_files','use_ai_local');

-- admin: todos los permisos
INSERT IGNORE INTO role_template_permissions (id_role_template, id_permission)
SELECT 2, id_permission FROM permissions;

-- supervisor: supervisar, optimizar, auditoría, IA local
INSERT IGNORE INTO role_template_permissions (id_role_template, id_permission)
SELECT 3, id_permission FROM permissions
WHERE permission_name IN ('phase_supervise','phase_optimize','view_audit_logs','use_ai_local');

-- ------------------------------------------------------------
-- 5. MIGRAR DATOS EXISTENTES
-- ------------------------------------------------------------

-- 5a. Crear roles por defecto (user, admin, supervisor) para cada equipo existente
INSERT INTO team_roles (id_team, role_name, description, is_default, template_id)
SELECT t.id_team, rt.template_name, rt.description, TRUE, rt.id_role_template
FROM teams t
CROSS JOIN role_templates rt
WHERE t.deleted_at IS NULL;

-- 5b. Copiar permisos de plantillas a cada team_role recién creado
INSERT INTO team_role_permissions (id_team_role, id_permission)
SELECT tr.id_team_role, rtp.id_permission
FROM team_roles tr
JOIN role_template_permissions rtp ON rtp.id_role_template = tr.template_id
WHERE tr.is_default = TRUE;

-- 5c. Migrar team_members → user_team_roles
--     Mapeamos team_member_roles a plantillas:
--       leader(1), supervisor(4) → admin template
--       analyst(2), designer(3), developer(5) → user template
INSERT INTO user_team_roles (id_user, id_team, id_team_role, assigned_at)
SELECT
    tm.id_user,
    tm.id_team,
    tr.id_team_role,
    tm.joined_at
FROM team_members tm
JOIN team_roles tr ON tr.id_team = tm.id_team
    AND tr.role_name = CASE
        WHEN tm.id_team_member_role IN (1, 4) THEN 'admin'
        ELSE 'user'
    END
WHERE tm.deleted_at IS NULL;

-- 5d. Crear personal_group para cada usuario que NO pertenece a ningún equipo
INSERT INTO teams (team_name, description, group_type, is_personal_group, created_by)
SELECT
    CONCAT('Personal - ', u.full_name),
    'Grupo personal creado automáticamente',
    'personal',
    TRUE,
    u.id_user
FROM users u
WHERE u.deleted_at IS NULL
  AND u.id_user NOT IN (
      SELECT DISTINCT id_user FROM team_members WHERE deleted_at IS NULL
  );

-- 5e. Crear roles por defecto para los personal_groups recién creados
INSERT INTO team_roles (id_team, role_name, description, is_default, template_id)
SELECT t.id_team, rt.template_name, rt.description, TRUE, rt.id_role_template
FROM teams t
CROSS JOIN role_templates rt
WHERE t.is_personal_group = TRUE
  AND NOT EXISTS (
      SELECT 1 FROM team_roles tr2
      WHERE tr2.id_team = t.id_team AND tr2.role_name = rt.template_name
  );

-- 5f. Copiar permisos de plantillas a los team_roles de personal_groups
INSERT INTO team_role_permissions (id_team_role, id_permission)
SELECT tr.id_team_role, rtp.id_permission
FROM team_roles tr
JOIN teams t ON t.id_team = tr.id_team
JOIN role_template_permissions rtp ON rtp.id_role_template = tr.template_id
WHERE t.is_personal_group = TRUE
  AND tr.is_default = TRUE
  AND NOT EXISTS (
      SELECT 1 FROM team_role_permissions trp2
      WHERE trp2.id_team_role = tr.id_team_role AND trp2.id_permission = rtp.id_permission
  );

-- 5g. Asignar rol 'admin' en su personal_group a cada usuario sin equipo
INSERT INTO user_team_roles (id_user, id_team, id_team_role, assigned_at)
SELECT
    t.created_by,
    t.id_team,
    tr.id_team_role,
    t.created_at
FROM teams t
JOIN team_roles tr ON tr.id_team = t.id_team AND tr.role_name = 'admin'
WHERE t.is_personal_group = TRUE;

-- 5h. Migrar user_roles globales → user_team_roles en personal_group
--     Solo para usuarios que YA tienen personal_group y un user_role asignado
INSERT IGNORE INTO user_team_roles (id_user, id_team, id_team_role, assigned_at)
SELECT
    ur.id_user,
    t.id_team,
    tr.id_team_role,
    ur.created_at
FROM user_roles ur
JOIN roles r ON r.id_role = ur.id_role
JOIN teams t ON t.created_by = ur.id_user AND t.is_personal_group = TRUE
JOIN team_roles tr ON tr.id_team = t.id_team AND tr.role_name = r.role_name
WHERE ur.deleted_at IS NULL;

-- ------------------------------------------------------------
-- 6. ELIMINAR TABLAS OBSOLETAS
--    Orden: primero dependientes, luego padres
-- ------------------------------------------------------------

DROP TABLE IF EXISTS team_members;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS team_member_roles;

-- ------------------------------------------------------------
-- 7. CREAR ÍNDICES
-- ------------------------------------------------------------

CREATE INDEX idx_team_roles_team            ON team_roles(id_team);
CREATE INDEX idx_team_roles_template        ON team_roles(template_id);
CREATE INDEX idx_team_role_perms_role       ON team_role_permissions(id_team_role);
CREATE INDEX idx_team_role_perms_perm       ON team_role_permissions(id_permission);
CREATE INDEX idx_user_team_roles_user       ON user_team_roles(id_user);
CREATE INDEX idx_user_team_roles_team       ON user_team_roles(id_team);
CREATE INDEX idx_user_project_roles_user    ON user_project_roles(id_user);
CREATE INDEX idx_user_project_roles_project ON user_project_roles(id_project);
CREATE INDEX idx_teams_personal             ON teams(is_personal_group);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'role_templates',       COUNT(*) FROM role_templates;
-- SELECT 'template_permissions', COUNT(*) FROM role_template_permissions;
-- SELECT 'team_roles',           COUNT(*) FROM team_roles;
-- SELECT 'team_role_permissions',COUNT(*) FROM team_role_permissions;
-- SELECT 'user_team_roles',      COUNT(*) FROM user_team_roles;
-- SELECT 'personal_groups',      COUNT(*) FROM teams WHERE is_personal_group = TRUE;
-- SELECT 'old_team_members?',    COUNT(*) FROM information_schema.tables WHERE table_schema='ia_dataflow' AND table_name='team_members';
-- SELECT 'old_roles?',           COUNT(*) FROM information_schema.tables WHERE table_schema='ia_dataflow' AND table_name='roles';

COMMIT;
