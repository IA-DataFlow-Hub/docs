-- ============================================================
-- MIGRACIÓN HU-029: Sistema de Reportes y Dashboards Persistentes
-- v3.10 → v3.11
--
-- Estrategia:
--   1. analytics_reports: dashboards/reportes con visibilidad y versión.
--   2. analytics_report_versions: snapshots de configuración por versión.
--   3. analytics_report_widgets: visualizaciones (KPI, charts, tables, IA).
--   4. analytics_report_metrics: métricas y fórmulas.
--   5. analytics_report_exports: archivos exportados (PDF/Excel/CSV/PNG/JSON).
--
-- NOTA: prefijo analytics_ para evitar colisión con la tabla `reports`
--       creada en HU-023 (incidencias/feedback de chats).
--
-- IMPORTANTE: Ejecutar con backup previo.
-- ============================================================

USE ia_dataflow;

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. ANALYTICS_REPORTS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS analytics_reports (
    id_report INT AUTO_INCREMENT PRIMARY KEY,
    id_project INT NOT NULL,
    created_by INT NOT NULL,
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

    CONSTRAINT fk_analytics_reports_project
        FOREIGN KEY (id_project)
        REFERENCES projects(id_project)
        ON DELETE CASCADE,

    CONSTRAINT fk_analytics_reports_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 2. ANALYTICS_REPORT_VERSIONS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS analytics_report_versions (
    id_version INT AUTO_INCREMENT PRIMARY KEY,
    id_report INT NOT NULL,
    version_number INT NOT NULL,
    configuration_path TEXT NOT NULL,
    snapshot_path TEXT NULL,
    changelog TEXT,
    created_by INT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_arv_report
        FOREIGN KEY (id_report)
        REFERENCES analytics_reports(id_report)
        ON DELETE CASCADE,

    CONSTRAINT fk_arv_user
        FOREIGN KEY (created_by)
        REFERENCES users(id_user)
        ON DELETE SET NULL,

    CONSTRAINT uq_arv_report_version UNIQUE (id_report, version_number)
);

-- ------------------------------------------------------------
-- 3. ANALYTICS_REPORT_WIDGETS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS analytics_report_widgets (
    id_widget INT AUTO_INCREMENT PRIMARY KEY,
    id_report INT NOT NULL,
    widget_type ENUM(
        'kpi',
        'line_chart',
        'bar_chart',
        'pie_chart',
        'table',
        'heatmap',
        'metric_card',
        'trend',
        'ai_insight'
    ) NOT NULL,
    widget_title VARCHAR(255),
    dataset_source VARCHAR(255),
    config JSON NOT NULL,
    position_x INT DEFAULT 0,
    position_y INT DEFAULT 0,
    width INT DEFAULT 4,
    height INT DEFAULT 4,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_arw_report
        FOREIGN KEY (id_report)
        REFERENCES analytics_reports(id_report)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 4. ANALYTICS_REPORT_METRICS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS analytics_report_metrics (
    id_metric INT AUTO_INCREMENT PRIMARY KEY,
    id_report INT NOT NULL,
    metric_name VARCHAR(255) NOT NULL,
    metric_formula TEXT,
    aggregation_type ENUM('sum','avg','count','min','max','custom') DEFAULT 'sum',
    format_type ENUM('currency','percentage','number','decimal') DEFAULT 'number',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_arm_report
        FOREIGN KEY (id_report)
        REFERENCES analytics_reports(id_report)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 5. ANALYTICS_REPORT_EXPORTS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS analytics_report_exports (
    id_export INT AUTO_INCREMENT PRIMARY KEY,
    id_report INT NOT NULL,
    exported_by INT NOT NULL,
    export_type ENUM('pdf','excel','csv','png','json') NOT NULL,
    storage_path TEXT NOT NULL,
    file_size BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_are_report
        FOREIGN KEY (id_report)
        REFERENCES analytics_reports(id_report)
        ON DELETE CASCADE,

    CONSTRAINT fk_are_user
        FOREIGN KEY (exported_by)
        REFERENCES users(id_user)
        ON DELETE CASCADE
);

-- ------------------------------------------------------------
-- 6. ÍNDICES
-- ------------------------------------------------------------

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

-- ============================================================
-- VALIDACIONES POST-MIGRACIÓN
-- ============================================================
-- SELECT TABLE_NAME FROM information_schema.tables
--   WHERE TABLE_SCHEMA='ia_dataflow'
--     AND TABLE_NAME LIKE 'analytics_report%';

COMMIT;
