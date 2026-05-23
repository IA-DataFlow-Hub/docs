-- ============================================================
-- MIGRACIÓN HU-025: Sistema de Notificaciones Individuales y Grupales
-- v3.6 → v3.7
--
-- Estrategia:
--   1. Crear notifications como entidad principal del evento notificado.
--   2. Crear notification_recipients para estado por usuario.
--   3. Crear notification_groups y notification_group_members para grupos.
--   4. Crear índices para bandeja, tiempo real, lectura y entrega.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. NOTIFICATIONS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS notifications (
    id_notification INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,

    notification_type ENUM('info','success','warning','error','critical') DEFAULT 'info',
    category ENUM('collaboration','ai','task','security','system','workflow','project','comment') DEFAULT 'system',

    sender_id INT NULL,
    id_project INT NULL,
    id_team INT NULL,
    id_team_role INT NULL,

    source_entity_type VARCHAR(100) NULL,
    source_entity_id INT NULL,
    action_url TEXT NULL,
    action_label VARCHAR(100) NULL,
    icon VARCHAR(100),
    is_global BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_notifications_sender
        FOREIGN KEY (sender_id)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_notifications_team
        FOREIGN KEY (id_team)
        REFERENCES teams(id_team)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_team_role
        FOREIGN KEY (id_team_role)
        REFERENCES team_roles(id_team_role)
        ON DELETE SET NULL,

    CONSTRAINT fk_notifications_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_notifications_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_notifications_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 2. NOTIFICATION_RECIPIENTS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS notification_recipients (
    id_notification_recipient INT AUTO_INCREMENT PRIMARY KEY,
    id_notification INT NOT NULL,
    id_user INT NOT NULL,

    delivery_status ENUM('pending','sent','delivered','failed') DEFAULT 'pending',
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    read_at TIMESTAMP NULL,
    failure_reason TEXT NULL,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

    CONSTRAINT uq_notification_recipient
        UNIQUE (id_notification, id_user),

    CONSTRAINT fk_nr_notification
        FOREIGN KEY (id_notification)
        REFERENCES notifications(id_notification)
        ON DELETE CASCADE,

    CONSTRAINT fk_nr_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 3. NOTIFICATION_GROUPS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS notification_groups (
    id_group_notification INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(150) NOT NULL,
    description TEXT,
    id_team INT NULL,
    id_project INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_by INT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    updated_by INT NULL,
    deleted_at TIMESTAMP NULL,
    deleted_by INT NULL,

    CONSTRAINT fk_notification_groups_team
        FOREIGN KEY (id_team)
        REFERENCES teams(id_team)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_groups_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE SET NULL,

    CONSTRAINT fk_notification_groups_created_by
        FOREIGN KEY (created_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_notification_groups_updated_by
        FOREIGN KEY (updated_by) REFERENCES users(id_user) ON DELETE SET NULL,

    CONSTRAINT fk_notification_groups_deleted_by
        FOREIGN KEY (deleted_by) REFERENCES users(id_user) ON DELETE SET NULL
);

-- ------------------------------------------------------------
-- 4. NOTIFICATION_GROUP_MEMBERS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS notification_group_members (
    id_group_notification INT NOT NULL,
    id_user INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id_group_notification, id_user),

    CONSTRAINT fk_ngm_group
        FOREIGN KEY (id_group_notification)
        REFERENCES notification_groups(id_group_notification)
        ON DELETE CASCADE,

    CONSTRAINT fk_ngm_user
        FOREIGN KEY (id_user)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 5. ÍNDICES
-- ------------------------------------------------------------

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

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'notifications table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='notifications';
-- SELECT 'notification_recipients table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='notification_recipients';
-- SELECT 'notification_groups table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='notification_groups';
-- SELECT 'notification_group_members table', COUNT(*) FROM information_schema.tables
--     WHERE table_schema='ia_dataflow' AND table_name='notification_group_members';

COMMIT;
