# Diagrama 3 — Modelo de Base de Datos (Entidades Principales)

**Qué muestra:** Las tablas más importantes del sistema y sus relaciones. Versión simplificada: solo se muestran las columnas clave, no todas las columnas de cada tabla.

**Última actualización:** 2026-05-12

---

```mermaid
erDiagram
    users {
        uuid id PK
        string email
        string name
        string password_hash
        boolean is_active
        datetime created_at
    }

    credentials {
        uuid id PK
        uuid user_id FK
        string provider
        string token_hash
        datetime expires_at
    }

    sessions {
        uuid id PK
        uuid user_id FK
        string refresh_token_hash
        string device_info
        datetime expires_at
    }

    configurations {
        uuid id PK
        uuid user_id FK
        string key
        text value
    }

    teams {
        uuid id PK
        string name
        uuid created_by FK
    }

    team_members {
        uuid id PK
        uuid team_id FK
        uuid user_id FK
        datetime joined_at
    }

    team_roles {
        uuid id PK
        uuid team_id FK
        string role_name
        json permissions
    }

    projects {
        uuid id PK
        uuid created_by FK
        string name
        string status
        datetime created_at
    }

    files {
        uuid id PK
        uuid project_id FK
        string original_name
        string mime_type
        bigint size_bytes
        string storage_path
        datetime uploaded_at
    }

    conversations {
        uuid id PK
        uuid project_id FK
        uuid user_id FK
        string title
        datetime created_at
    }

    messages {
        uuid id PK
        uuid conversation_id FK
        string role
        text content
        datetime created_at
    }

    ai_jobs {
        uuid id PK
        uuid file_id FK
        uuid project_id FK
        string status
        string ai_engine
        datetime created_at
        datetime completed_at
    }

    ai_job_events {
        uuid id PK
        uuid job_id FK
        string event_type
        text payload
        datetime occurred_at
    }

    ai_results {
        uuid id PK
        uuid job_id FK
        text result_json
        float quality_score
        datetime created_at
    }

    datasets {
        uuid id PK
        uuid project_id FK
        uuid source_file_id FK
        string name
        int total_rows
        int total_columns
        string status
    }

    generated_tables {
        uuid id PK
        uuid dataset_id FK
        string table_name
        json schema_json
        datetime created_at
    }

    etl_templates {
        uuid id PK
        string name
        json steps_json
        uuid created_by FK
    }

    etl_executions {
        uuid id PK
        uuid template_id FK
        uuid dataset_id FK
        string status
        text error_message
        datetime started_at
        datetime finished_at
    }

    reports {
        uuid id PK
        uuid project_id FK
        string title
        string type
        datetime created_at
    }

    report_widgets {
        uuid id PK
        uuid report_id FK
        string widget_type
        json config_json
        int position
    }

    %% Relaciones de usuarios
    users ||--o{ credentials : "tiene"
    users ||--o{ sessions : "abre"
    users ||--o{ configurations : "configura"

    %% Relaciones de equipos
    teams ||--o{ team_members : "agrupa"
    teams ||--o{ team_roles : "define"
    users ||--o{ team_members : "pertenece a"

    %% Relaciones de proyectos
    users ||--o{ projects : "crea"
    projects ||--o{ files : "contiene"
    projects ||--o{ conversations : "tiene"
    conversations ||--o{ messages : "acumula"

    %% Relaciones de AI Jobs
    files ||--o{ ai_jobs : "origina"
    ai_jobs ||--o{ ai_job_events : "registra"
    ai_jobs ||--|| ai_results : "produce"

    %% Relaciones de datasets
    projects ||--o{ datasets : "genera"
    files ||--o{ datasets : "origen de"
    datasets ||--o{ generated_tables : "produce"

    %% Relaciones de ETL
    etl_templates ||--o{ etl_executions : "se aplica en"
    datasets ||--o{ etl_executions : "es procesado por"

    %% Relaciones de reportes
    projects ||--o{ reports : "tiene"
    reports ||--o{ report_widgets : "compone"
```

---

## Grupos de entidades

| Grupo | Tablas |
|---|---|
| Identidad | `users`, `credentials`, `sessions`, `configurations` |
| Equipos | `teams`, `team_members`, `team_roles` |
| Proyectos | `projects`, `files`, `conversations`, `messages` |
| IA | `ai_jobs`, `ai_job_events`, `ai_results` |
| Datos | `datasets`, `generated_tables` |
| ETL | `etl_templates`, `etl_executions` |
| Reportes | `reports`, `report_widgets` |

## Notas

- Todos los IDs son **UUID v4** (HU-030 — migración de INT a UUID).
- Las eliminaciones son lógicas mediante `deleted_at` (soft delete) según HU-017.
- El campo `status` en `ai_jobs` sigue el ciclo: `PENDING → QUEUED → PROCESSING → COMPLETED / FAILED / CANCELLED`.


---

## Documentos relacionados

**Docs:** [[DOCUMENTACION_TECNICA]] · [[ARQUITECTURA]]
**Paquetes:** [[database]]
**HUs:** [[✅ HU 011 - Diseño y Creación de la Base de Datos Relacional (MySQL)|HU-011]] · [[✅ HU 012 - Implementación del Esquema con Prisma ORM|HU-012]] · [[✅ HU 016 - Reemplazar ENUMs con Tablas|HU-016]] · [[✅ HU 030 - Migración Estratégica de IDs Enteros a UUID|HU-030]]
