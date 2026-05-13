# HU-030 — Migración Estratégica de IDs Enteros a UUID/GUID para Escalabilidad y Seguridad

---

# Historia de Usuario

Como arquitecto y desarrollador del sistema IA-DataFlow-Hub,

quiero reemplazar los IDs enteros (INT AUTO_INCREMENT) por identificadores UUID/GUID en las tablas operativas y transaccionales,

para mejorar escalabilidad, seguridad, sincronización distribuida, interoperabilidad y evitar colisiones futuras en arquitecturas cloud y microservicios.

---

# Objetivo

Implementar una estrategia híbrida de identificadores:

- UUID/GUID para tablas operativas y transaccionales
- INT para catálogos pequeños y tablas estáticas

---

# Regla Arquitectónica

## Usar UUID/GUID cuando:

La tabla:

- crece constantemente
- almacena transacciones
- almacena actividad de usuarios
- puede distribuirse
- puede sincronizarse externamente
- puede exponerse vía API
- contiene datos sensibles
- puede superar cientos o miles de registros

---

## Mantener INT cuando:

La tabla:

- es catálogo estático
- tendrá menos de 20 registros
- representa estados
- representa tipos fijos
- cambia raramente

---

# Beneficios del Cambio

- Evitar enumeración de IDs
- Mejor seguridad en APIs
- Facilitar microservicios
- Facilitar sincronización offline
- Mejor compatibilidad cloud
- Replicación distribuida
- Integración multi-tenant
- Evitar colisiones entre ambientes
- Mejor arquitectura empresarial

---
TABLAS EXISTENTES QUE DEBEN MIGRAR DE INT → UUID/GUID

users
credentials
user_preferences
teams
team_members
projects
project_phases
files
file_versions
ai_jobs
ai_results
tasks
conversations
messages
audit_logs
sessions




# Tablas Nuevas que TAMBIÉN Deben Usar UUID

notifications
notification_recipients
activity_feed
generated_tables
generated_table_versions
generated_table_files
etl_templates
etl_template_steps
etl_executions
etl_execution_logs
reports
report_versions
report_widgets
report_metrics
report_exports
chat_feedback
chat_reports
report_categories
dashboard_snapshots
