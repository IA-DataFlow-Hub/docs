-- ============================================================
-- MIGRACIÓN HU-021: Proyectos con creación auditada +
--                   relación archivos ↔ conversaciones ↔ mensajes
-- v3.2 → v3.3
--
-- Estrategia:
--   1. projects: copiar id_user → created_by, eliminar id_user, agregar owner_user_id.
--   2. files: agregar id_conversation + id_message con FKs.
--   3. Crear índices nuevos.
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. PROJECTS: MIGRAR id_user → created_by
-- ------------------------------------------------------------

-- 1a. Copiar id_user a created_by donde created_by sea NULL
UPDATE projects SET created_by = id_user WHERE created_by IS NULL;

-- 1b. Cambiar created_by a NOT NULL
ALTER TABLE projects MODIFY COLUMN created_by INT NOT NULL;

-- 1c. Agregar owner_user_id (inicialmente igual al creador)
ALTER TABLE projects ADD COLUMN owner_user_id INT NULL AFTER current_phase;

UPDATE projects SET owner_user_id = created_by;

ALTER TABLE projects
    ADD CONSTRAINT fk_projects_owner
        FOREIGN KEY (owner_user_id)
        REFERENCES users(id_user)
        ON DELETE SET NULL;

-- 1d. Eliminar FK y columna id_user
ALTER TABLE projects DROP FOREIGN KEY fk_projects_user;
ALTER TABLE projects DROP COLUMN id_user;

-- 1e. Actualizar FK de created_by (era SET NULL, ahora CASCADE)
ALTER TABLE projects DROP FOREIGN KEY fk_projects_created_by;
ALTER TABLE projects
    ADD CONSTRAINT fk_projects_created_by
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE CASCADE;

-- ------------------------------------------------------------
-- 2. FILES: AGREGAR id_conversation + id_message
-- ------------------------------------------------------------

ALTER TABLE files
    ADD COLUMN id_conversation INT NULL AFTER id_user,
    ADD COLUMN id_message INT NULL AFTER id_conversation;

ALTER TABLE files
    ADD CONSTRAINT fk_files_conversation
        FOREIGN KEY (id_conversation)
        REFERENCES conversations(id_conversation)
        ON DELETE SET NULL;

ALTER TABLE files
    ADD CONSTRAINT fk_files_message
        FOREIGN KEY (id_message)
        REFERENCES messages(id_message)
        ON DELETE SET NULL;

-- ------------------------------------------------------------
-- 3. CREAR ÍNDICES
-- ------------------------------------------------------------

-- Reemplazar idx_projects_user por created_by + owner
DROP INDEX idx_projects_user ON projects;
CREATE INDEX idx_projects_created_by ON projects(created_by);
CREATE INDEX idx_projects_owner      ON projects(owner_user_id);

-- Nuevos indexes para files
CREATE INDEX idx_files_conversation  ON files(id_conversation);
CREATE INDEX idx_files_message       ON files(id_message);

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT 'projects sin created_by', COUNT(*) FROM projects WHERE created_by IS NULL;
-- SELECT 'files con conversation',  COUNT(*) FROM files WHERE id_conversation IS NOT NULL;
-- SELECT 'id_user en projects?', COUNT(*) FROM information_schema.columns
--     WHERE table_schema='ia_dataflow' AND table_name='projects' AND column_name='id_user';

COMMIT;
