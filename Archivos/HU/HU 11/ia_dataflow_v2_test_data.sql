-- ============================================================
-- IA DATAFLOW v2.0 - DATOS DE PRUEBA
-- Ejecutar DESPUÉS de ia_dataflow_v2.sql
-- ============================================================

USE ia_dataflow;

-- ============================================================
-- USUARIOS DE PRUEBA
-- ============================================================

INSERT INTO users (full_name, email, phone, status) VALUES
('Andrés Administrador', 'andres@iadataflow.com', '3001234567', 'active'),
('María García', 'maria.garcia@iadataflow.com', '3009876543', 'active'),
('Carlos López', 'carlos.lopez@iadataflow.com', '3005551234', 'active'),
('Laura Martínez', 'laura.martinez@iadataflow.com', '3007778899', 'active'),
('Pedro Sánchez', 'pedro.sanchez@iadataflow.com', NULL, 'inactive');

-- ============================================================
-- CREDENCIALES (passwords hasheados ficticios)
-- ============================================================

INSERT INTO credentials (id_user, password_hash, mfa_enabled) VALUES
(1, '$2b$12$fakehash.admin.iadataflow000000000000000000000000', TRUE),
(2, '$2b$12$fakehash.maria.iadataflow000000000000000000000000', FALSE),
(3, '$2b$12$fakehash.carlos.iadataflow00000000000000000000000', FALSE),
(4, '$2b$12$fakehash.laura.iadataflow00000000000000000000000', FALSE),
(5, '$2b$12$fakehash.pedro.iadataflow00000000000000000000000', FALSE);

-- ============================================================
-- PREFERENCIAS DE USUARIO (tour, tema, etc.)
-- ============================================================

INSERT INTO user_preferences (id_user, has_completed_tour, theme, language, notifications_enabled) VALUES
(1, TRUE,  'dark',   'es', TRUE),   -- Andrés ya completó el tour
(2, TRUE,  'dark',   'es', TRUE),   -- María ya completó el tour
(3, FALSE, 'light',  'es', TRUE),   -- Carlos NO ha completado el tour (le aparecerá)
(4, FALSE, 'system', 'es', FALSE),  -- Laura tampoco
(5, FALSE, 'dark',   'en', TRUE);   -- Pedro tampoco

-- ============================================================
-- ASIGNAR ROLES A USUARIOS
-- ============================================================

-- Andrés = admin, María = leader, Carlos = analyst, Laura = supervisor, Pedro = viewer
INSERT INTO user_roles (id_user, id_role) VALUES
(1, 1),  -- Andrés -> admin
(2, 2),  -- María -> leader
(3, 3),  -- Carlos -> analyst
(4, 4),  -- Laura -> supervisor
(5, 5);  -- Pedro -> viewer

-- ============================================================
-- ASIGNAR PERMISOS A ROLES
-- ============================================================

-- Admin tiene todos los permisos (1 al 10)
INSERT INTO role_permissions (id_role, id_permission) VALUES
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10);

-- Leader: todas las fases + gestión equipos + subir archivos
INSERT INTO role_permissions (id_role, id_permission) VALUES
(2, 1), (2, 2), (2, 3), (2, 4), (2, 5), (2, 7), (2, 9), (2, 10);

-- Analyst: Diseñar + Ejecutar + subir archivos + IA
INSERT INTO role_permissions (id_role, id_permission) VALUES
(3, 1), (3, 2), (3, 7), (3, 9), (3, 10);

-- Supervisor: Supervisar + Optimizar + auditoría
INSERT INTO role_permissions (id_role, id_permission) VALUES
(4, 3), (4, 4), (4, 8);

-- Viewer: solo lectura (sin permisos de acción)

-- ============================================================
-- EQUIPO DE PRUEBA
-- ============================================================

INSERT INTO teams (team_name, description, created_by) VALUES
('Equipo Data Analytics', 'Equipo principal para análisis de datos corporativos', 1),
('Equipo Ventas', 'Procesamiento de reportes de ventas mensuales', 2);

-- ============================================================
-- MIEMBROS DEL EQUIPO
-- ============================================================

INSERT INTO team_members (id_team, id_user, member_role) VALUES
(1, 1, 'leader'),
(1, 2, 'analyst'),
(1, 3, 'developer'),
(1, 4, 'supervisor'),
(2, 2, 'leader'),
(2, 5, 'analyst');

-- ============================================================
-- PROYECTOS DE PRUEBA  (la tabla central!)
-- ============================================================

INSERT INTO projects (id_user, id_team, project_name, description, current_phase, privacy_level, status) VALUES
(1, 1, 'Análisis Ventas 2026', 'Limpieza y análisis del archivo ventas_2026.xlsx', 1, 'team', 'active'),
(2, 1, 'Migración Base de Datos', 'Convertir CSV legacy a estructura relacional', 2, 'private', 'active'),
(3, 2, 'Reporte Trimestral', 'Generar reporte Q1 2026 automáticamente', 1, 'team', 'active');

-- ============================================================
-- HISTORIAL DE FASES POR PROYECTO
-- ============================================================

-- Proyecto 1: ya pasó por Diseñar, ahora en Ejecutar... wait, current_phase=1 (Diseñar)
-- Dejemos coherente: Proyecto 1 está en fase 1 (Diseñar)
INSERT INTO project_phases (id_project, id_phase, status, started_at, completed_at) VALUES
(1, 1, 'in_progress', NOW(), NULL);

-- Proyecto 2: ya completó Diseñar, ahora está en Ejecutar
INSERT INTO project_phases (id_project, id_phase, status, started_at, completed_at) VALUES
(2, 1, 'completed', '2026-04-15 09:00:00', '2026-04-16 14:30:00'),
(2, 2, 'in_progress', '2026-04-16 14:30:00', NULL);

-- Proyecto 3: acaba de empezar
INSERT INTO project_phases (id_project, id_phase, status, started_at, completed_at) VALUES
(3, 1, 'in_progress', NOW(), NULL);

-- ============================================================
-- ARCHIVOS SUBIDOS
-- ============================================================

INSERT INTO files (id_project, id_user, file_name, original_name, file_type, file_size, storage_path) VALUES
(1, 1, 'ventas_2026_a1b2c3.xlsx', 'ventas_2026.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 2516582, '/storage/projects/1/ventas_2026_a1b2c3.xlsx'),
(1, 1, 'clientes_activos_d4e5f6.csv', 'clientes_activos.csv', 'text/csv', 345021, '/storage/projects/1/clientes_activos_d4e5f6.csv'),
(2, 2, 'legacy_db_export_g7h8i9.csv', 'legacy_db_export.csv', 'text/csv', 15728640, '/storage/projects/2/legacy_db_export_g7h8i9.csv'),
(3, 3, 'datos_q1_j0k1l2.pdf', 'datos_q1_2026.pdf', 'application/pdf', 4194304, '/storage/projects/3/datos_q1_j0k1l2.pdf');

-- ============================================================
-- VERSIONES DE ARCHIVOS
-- ============================================================

INSERT INTO file_versions (id_file, version_number, storage_path, changes_description, created_by) VALUES
(1, 1, '/storage/projects/1/versions/ventas_2026_v1.xlsx', 'Archivo original subido', 1),
(3, 1, '/storage/projects/2/versions/legacy_db_v1.csv', 'Archivo original subido', 2),
(3, 2, '/storage/projects/2/versions/legacy_db_v2.csv', 'Eliminados 234 duplicados por IA', 2);

-- ============================================================
-- JOBS DE IA
-- ============================================================

-- Job 1: Análisis de estructura con Gemini (proyecto público)
INSERT INTO ai_jobs (id_project, id_file, id_engine, id_phase, requested_by, job_type, prompt_text, is_private, status, started_at, finished_at, tokens_input, tokens_output, processing_time_ms) VALUES
(1, 1, 2, 1, 1, 'analyze_structure', 'Analiza la estructura del archivo Excel y detecta problemas', FALSE, 'completed', '2026-05-07 10:00:00', '2026-05-07 10:00:12', 1250, 890, 12000);

-- Job 2: Búsqueda de duplicados con Llama (proyecto privado)
INSERT INTO ai_jobs (id_project, id_file, id_engine, id_phase, requested_by, job_type, prompt_text, is_private, status, started_at, finished_at, tokens_input, tokens_output, processing_time_ms) VALUES
(2, 3, 1, 2, 2, 'find_duplicates', 'Busca registros duplicados en el CSV', TRUE, 'completed', '2026-04-16 15:00:00', '2026-04-16 15:02:30', 8500, 2100, 150000);

-- Job 3: En progreso (Gemini analizando PDF)
INSERT INTO ai_jobs (id_project, id_file, id_engine, id_phase, requested_by, job_type, prompt_text, is_private, status, started_at, finished_at, tokens_input, tokens_output, processing_time_ms) VALUES
(3, 4, 2, 1, 3, 'extract_tables', 'Extrae todas las tablas del PDF y conviértelas a formato estructurado', FALSE, 'processing', '2026-05-07 18:30:00', NULL, 0, 0, 0);

-- ============================================================
-- RESULTADOS DE IA
-- ============================================================

INSERT INTO ai_results (id_job, result_type, result_summary, output_path) VALUES
(1, 'summary', 'Archivo: 1250 filas, 8 columnas. Problemas detectados: 45 celdas vacías en columna "email", 12 formatos de fecha inconsistentes.', NULL),
(2, 'transformed_file', 'Se encontraron y eliminaron 234 registros duplicados. Archivo limpio generado.', '/storage/projects/2/results/legacy_db_clean.csv');

-- ============================================================
-- TAREAS
-- ============================================================

INSERT INTO tasks (id_project, id_phase, assigned_to, created_by, title, description, status, priority, due_date) VALUES
(1, 1, 3, 1, 'Revisar análisis de ventas_2026', 'Verificar que el análisis de IA detectó todos los problemas', 'in_progress', 'high', '2026-05-10'),
(1, 1, 4, 1, 'Aprobar correcciones sugeridas', 'Supervisar las correcciones antes de ejecutarlas', 'pending', 'medium', '2026-05-12'),
(2, 2, 2, 2, 'Ejecutar migración de datos', 'Aplicar la transformación del CSV a tablas SQL', 'in_progress', 'critical', '2026-05-08'),
(3, 1, 3, 3, 'Subir datos faltantes Q1', 'Faltan datos de marzo, conseguir con contabilidad', 'pending', 'low', '2026-05-15');

-- ============================================================
-- CONVERSACIONES Y MENSAJES
-- ============================================================

-- Conversación del Proyecto 1: Usuario chatea con IA
INSERT INTO conversations (id_project, id_phase, created_by, title) VALUES
(1, 1, 1, 'Análisis inicial ventas_2026.xlsx');

INSERT INTO messages (id_conversation, id_user, id_engine, sender_type, message) VALUES
(1, 1, NULL, 'user', 'Analiza este archivo de ventas y dime qué problemas tiene'),
(1, NULL, 2, 'ai_cloud', 'Archivo recibido: **ventas_2026.xlsx**\n\nAnalizando estructura y contenido...\n\n🔍 **Análisis Completo**\n- Total de Filas: 1250\n- Total de Columnas: 8\n\n**Problemas Detectados:**\n1. 45 celdas vacías en columna "email"\n2. 12 formatos de fecha inconsistentes\n3. 3 valores negativos en columna "total_venta"'),
(1, 1, NULL, 'user', '¿Puedes corregir los formatos de fecha automáticamente?'),
(1, NULL, 2, 'ai_cloud', 'Puedo normalizar las 12 fechas al formato YYYY-MM-DD. ¿Deseas que proceda con la corrección? Esto moverá el proyecto a la fase **Ejecutar**.');

-- Conversación del Proyecto 2: con Llama (privado)
INSERT INTO conversations (id_project, id_phase, created_by, title) VALUES
(2, 2, 2, 'Limpieza de duplicados - datos confidenciales');

INSERT INTO messages (id_conversation, id_user, id_engine, sender_type, message) VALUES
(2, 2, NULL, 'user', 'Busca duplicados en el archivo legacy. Son datos sensibles, usa solo procesamiento local.'),
(2, NULL, 1, 'ai_local', 'Procesando con motor local (Llama 3.1). Los datos NO saldrán del sistema.\n\nResultado: 234 registros duplicados encontrados.\n- 180 duplicados exactos\n- 54 duplicados parciales (mismo nombre, diferente email)\n\n¿Deseas eliminarlos o revisarlos primero?');

-- ============================================================
-- AUDIT LOGS (registro de acciones)
-- ============================================================

INSERT INTO audit_logs (id_user, id_project, action, entity_type, entity_id, old_value, new_value, ip_address) VALUES
(1, 1, 'upload_file', 'files', 1, NULL, 'ventas_2026.xlsx', '192.168.1.100'),
(1, 1, 'run_ai_job', 'ai_jobs', 1, NULL, 'analyze_structure', '192.168.1.100'),
(2, 2, 'upload_file', 'files', 3, NULL, 'legacy_db_export.csv', '192.168.1.101'),
(2, 2, 'run_ai_job', 'ai_jobs', 2, NULL, 'find_duplicates (LOCAL)', '192.168.1.101'),
(2, 2, 'phase_transition', 'project_phases', 2, 'Diseñar', 'Ejecutar', '192.168.1.101');

-- ============================================================
-- SESIONES ACTIVAS
-- ============================================================

INSERT INTO sessions (id_user, session_token, ip_address, user_agent, expires_at) VALUES
(1, 'tok_abc123def456ghi789jkl012mno345', '192.168.1.100', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/125.0', '2026-05-08 06:00:00'),
(2, 'tok_xyz987wvu654tsr321qpo098nml765', '192.168.1.101', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Firefox/126.0', '2026-05-08 06:00:00');

-- ============================================================
-- ¡LISTO! Ahora puedes probar con las queries de abajo.
-- ============================================================

-- ============================================================
-- QUERIES DE PRUEBA (copia y ejecuta una por una)
-- ============================================================

-- 1. Ver todos los proyectos con su fase actual
SELECT 
    p.id_project,
    p.project_name,
    u.full_name AS owner,
    t.team_name,
    wp.phase_name AS fase_actual,
    p.privacy_level,
    p.status
FROM projects p
JOIN users u ON p.id_user = u.id_user
LEFT JOIN teams t ON p.id_team = t.id_team
LEFT JOIN workflow_phases wp ON p.current_phase = wp.id_phase;

-- 2. Ver historial de fases de un proyecto (timeline BPM)
SELECT 
    p.project_name,
    wp.phase_name,
    pp.status,
    pp.started_at,
    pp.completed_at
FROM project_phases pp
JOIN projects p ON pp.id_project = p.id_project
JOIN workflow_phases wp ON pp.id_phase = wp.id_phase
WHERE pp.id_project = 2
ORDER BY wp.phase_order;

-- 3. ¿Qué motor de IA se usó en cada job?
SELECT 
    aj.id_job,
    p.project_name,
    ae.engine_name,
    ae.engine_type,
    aj.job_type,
    aj.status,
    aj.is_private,
    aj.tokens_input + aj.tokens_output AS total_tokens
FROM ai_jobs aj
JOIN projects p ON aj.id_project = p.id_project
JOIN ai_engines ae ON aj.id_engine = ae.id_engine;

-- 4. Conversaciones con mensajes (simula el chat)
SELECT 
    c.title AS conversacion,
    m.sender_type,
    COALESCE(u.full_name, ae.engine_name, 'Sistema') AS quien,
    LEFT(m.message, 80) AS mensaje_preview,
    m.sent_at
FROM messages m
JOIN conversations c ON m.id_conversation = c.id_conversation
LEFT JOIN users u ON m.id_user = u.id_user
LEFT JOIN ai_engines ae ON m.id_engine = ae.id_engine
ORDER BY c.id_conversation, m.sent_at;

-- 5. Tareas por usuario con su estado
SELECT 
    u.full_name,
    t.title,
    wp.phase_name AS fase,
    t.status,
    t.priority,
    t.due_date
FROM tasks t
JOIN users u ON t.assigned_to = u.id_user
LEFT JOIN workflow_phases wp ON t.id_phase = wp.id_phase
ORDER BY t.priority DESC;

-- 6. Permisos de un usuario (a través de su rol)
SELECT 
    u.full_name,
    r.role_name,
    p.permission_name,
    p.module_name
FROM users u
JOIN user_roles ur ON u.id_user = ur.id_user
JOIN roles r ON ur.id_role = r.id_role
JOIN role_permissions rp ON r.id_role = rp.id_role
JOIN permissions p ON rp.id_permission = p.id_permission
WHERE u.id_user = 3;  -- Carlos (analyst)

-- 7. Audit log: ¿Qué ha hecho cada usuario?
SELECT 
    u.full_name,
    al.action,
    al.entity_type,
    al.new_value,
    al.ip_address,
    al.created_at
FROM audit_logs al
JOIN users u ON al.id_user = u.id_user
ORDER BY al.created_at DESC;

-- 8. ¿Qué archivos tiene cada proyecto?
SELECT 
    p.project_name,
    f.original_name,
    f.file_type,
    ROUND(f.file_size / 1048576, 2) AS size_mb,
    f.uploaded_at
FROM files f
JOIN projects p ON f.id_project = p.id_project
ORDER BY p.id_project;

-- 9. Ver preferencias y estado del tour de todos los usuarios
SELECT 
    u.full_name,
    u.email,
    up.has_completed_tour,
    up.theme,
    up.language,
    up.notifications_enabled
FROM users u
JOIN user_preferences up ON u.id_user = up.id_user;

-- 10. ¿Quién NO ha completado el tour? (para mostrarles el onboarding)
SELECT 
    u.full_name,
    u.email
FROM users u
JOIN user_preferences up ON u.id_user = up.id_user
WHERE up.has_completed_tour = FALSE;

-- 11. Simular que Carlos (id=3) completó el tour
UPDATE user_preferences 
SET has_completed_tour = TRUE 
WHERE id_user = 3;

-- 12. Verificar el cambio
SELECT 
    u.full_name,
    up.has_completed_tour
FROM users u
JOIN user_preferences up ON u.id_user = up.id_user
WHERE u.id_user = 3;
