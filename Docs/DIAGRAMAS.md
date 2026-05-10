# DIAGRAMAS — Representaciones Visuales del Sistema

> Todos los diagramas están escritos en sintaxis **Mermaid** y pueden renderizarse en Obsidian (con el plugin Mermaid activado), GitHub, o cualquier visor compatible.

---

## 1. Diagrama Entidad-Relación (ER)

Representa el modelo de datos central del sistema IA-DataFlow Hub.

```mermaid
erDiagram
    USUARIO {
        int id PK
        string email
        string password_hash
        string nombre
        string organizacion
        datetime fecha_registro
        boolean activo
    }

    ROL {
        int id PK
        string nombre
        string descripcion
    }

    USUARIO_ROL {
        int usuario_id FK
        int rol_id FK
    }

    PROYECTO {
        int id PK
        int usuario_id FK
        string nombre
        string descripcion
        string estado
        datetime fecha_creacion
        datetime fecha_actualizacion
    }

    DATASET {
        int id PK
        int proyecto_id FK
        string nombre_archivo
        string formato
        bigint tamanio_bytes
        int total_filas
        int total_columnas
        string estado_procesamiento
        datetime fecha_carga
        string ruta_almacenamiento
    }

    TRANSFORMACION {
        int id PK
        int dataset_id FK
        string tipo_operacion
        text parametros_json
        text snapshot_anterior
        text snapshot_nuevo
        boolean reversible
        datetime timestamp
        string motor_ia
    }

    REPORTE {
        int id PK
        int dataset_id FK
        string tipo_dashboard
        string formato_exportacion
        string ruta_archivo
        datetime fecha_generacion
    }

    AUDITORIA {
        int id PK
        int usuario_id FK
        string accion
        string entidad_afectada
        int entidad_id
        datetime timestamp
        string ip_origen
    }

    CONFIGURACION_IA {
        int id PK
        int proyecto_id FK
        string motor_ia
        text system_prompt
        float temperatura
        int max_tokens
        boolean datos_sensibles
        string modelo_local
        string modelo_nube
    }

    COLA_PROCESAMIENTO {
        int id PK
        int dataset_id FK
        string estado
        int prioridad
        datetime fecha_encolado
        datetime fecha_inicio
        datetime fecha_fin
        text error_mensaje
    }

    USUARIO ||--o{ USUARIO_ROL : "tiene"
    ROL ||--o{ USUARIO_ROL : "asignado a"
    USUARIO ||--o{ PROYECTO : "crea"
    PROYECTO ||--o{ DATASET : "contiene"
    DATASET ||--o{ TRANSFORMACION : "registra"
    DATASET ||--o{ REPORTE : "genera"
    DATASET ||--|| COLA_PROCESAMIENTO : "gestiona"
    PROYECTO ||--o{ CONFIGURACION_IA : "configura"
    USUARIO ||--o{ AUDITORIA : "genera"
```

---

## 2. Flujo de Proceso ETL Completo

Representa el pipeline principal de datos desde la carga hasta la visualización.

```mermaid
flowchart TD
    A([👤 Usuario carga archivo\nCSV / Excel / JSON]) --> B[React Frontend\nWeb Worker divide en chunks]
    B --> C[NestJS API Gateway\nMulter + Streams]
    C --> D{¿Contiene\ndatos sensibles?}

    D -- Sí --> E[Llama 4 via Ollama\nIA LOCAL]
    E --> F[Anonimización PII\nNombres → Hash seguro]
    F --> G[Datos anonimizados\nlistos para nube]

    D -- No --> G

    G --> H[Compresión TOON\n45% reducción de tokens]
    H --> I[n8n Orquestador\nDispara flujo ETL]

    I --> J[OpenRefine + GREL\nLimpieza especializada]
    J --> K[Clustering y\nDeduplicación]
    K --> L[Gemini 2.5 Flash-Lite\nIA NUBE]

    L --> M[Normalización\nEstandarización de formatos]
    M --> N[Validación de calidad\nReglas de negocio]

    N --> O{¿Aprobado\npor IA?}
    O -- No → revisión --> P[Chat IA con usuario\nSugerencias de corrección]
    P --> A

    O -- Sí --> Q[Redis Queue\nGestión de prioridad]
    Q --> R{Volumen\nde datos}

    R -- Alto ≥50k filas --> S[PostgreSQL\nBulk Insert optimizado]
    R -- Normal < 50k --> T[MySQL\nBase de datos principal]

    S --> U[Power BI\nConsumo de datos limpios]
    T --> U

    U --> V[Dashboard Estratégico\nC-Level / KPIs globales]
    U --> W[Dashboard Táctico\nGestores / métricas área]
    U --> X[Dashboard Técnico\nAnalistas / calidad datos]
    U --> Y[Dashboard Operativo\nEjecutores / tareas diarias]

    style A fill:#4A90D9,color:#fff
    style E fill:#E8A838,color:#fff
    style L fill:#5CB85C,color:#fff
    style U fill:#9B59B6,color:#fff
```

---

## 3. Arquitectura de Capas del Sistema

```mermaid
graph TB
    subgraph PRESENTACION["🖥️ CAPA DE PRESENTACIÓN"]
        UI[React + Vite]
        CHARTS[Recharts / D3.js / ApexCharts / Plotly]
        STATE[Zustand - Estado Global]
        WS_CLIENT[Socket.IO Client]
    end

    subgraph BACKEND["⚙️ CAPA DE LÓGICA DE NEGOCIO"]
        API[NestJS API Gateway]
        AUTH[AuthModule - JWT]
        DATASET_SVC[DatasetService]
        AI_SVC[AIService]
        TRANSFORM_SVC[TransformationService]
        REPORT_SVC[ReportService]
        WS_SERVER[WebSocket Gateway]
    end

    subgraph ORQUESTACION["🔄 CAPA DE ORQUESTACIÓN"]
        N8N[n8n Self-Hosted]
        REDIS[Redis - Colas y Cache]
        WORKERS[Worker Threads Node.js]
    end

    subgraph IA["🤖 CAPA DE INTELIGENCIA ARTIFICIAL"]
        OLLAMA[Ollama - Llama 4\nDatos Privados/Locales]
        GEMINI[Gemini 2.5 Flash-Lite\nProcesamiento Masivo]
        OPENREFINE[OpenRefine + GREL\nLimpieza Especializada]
    end

    subgraph DATOS["🗄️ CAPA DE PERSISTENCIA"]
        MYSQL[(MySQL\nBase Principal)]
        POSTGRES[(PostgreSQL\nBulk Insert)]
        SQLSERVER[(SQL Server\nLegacy)]
        ORACLE[(Oracle\nLegacy)]
    end

    subgraph REPORTES["📊 CAPA DE VISUALIZACIÓN"]
        POWERBI[Power BI]
        DASH1[Estratégico]
        DASH2[Táctico]
        DASH3[Técnico]
        DASH4[Operativo]
    end

    UI --> API
    WS_CLIENT <--> WS_SERVER
    API --> AUTH
    API --> DATASET_SVC
    API --> AI_SVC
    API --> TRANSFORM_SVC
    API --> REPORT_SVC
    DATASET_SVC --> N8N
    AI_SVC --> OLLAMA
    AI_SVC --> GEMINI
    TRANSFORM_SVC --> OPENREFINE
    N8N --> REDIS
    N8N --> WORKERS
    REDIS --> MYSQL
    REDIS --> POSTGRES
    MYSQL --> POWERBI
    POSTGRES --> POWERBI
    SQLSERVER --> POWERBI
    ORACLE --> POWERBI
    POWERBI --> DASH1
    POWERBI --> DASH2
    POWERBI --> DASH3
    POWERBI --> DASH4
```

---

## 4. Diagrama de Secuencia — Flujo de Carga y Análisis

```mermaid
sequenceDiagram
    actor U as Usuario
    participant FE as React Frontend
    participant BE as NestJS Backend
    participant N8N as n8n Orquestador
    participant LLAMA as Llama 4 (Local)
    participant GEMINI as Gemini (Nube)
    participant DB as MySQL/PostgreSQL
    participant PBI as Power BI

    U->>FE: Carga archivo CSV/Excel
    FE->>FE: Web Worker divide en chunks
    FE->>BE: POST /api/datasets/upload (chunks)
    BE->>BE: Multer recibe y guarda archivo

    BE->>N8N: Webhook: "archivo_listo"
    BE-->>FE: WebSocket: "analizando..."
    FE-->>U: Notificación: procesando

    N8N->>LLAMA: Detectar datos sensibles
    LLAMA-->>N8N: PII encontrado / no encontrado

    alt Datos sensibles detectados
        N8N->>LLAMA: Anonimizar PII
        LLAMA-->>N8N: Datos anonimizados
    end

    N8N->>GEMINI: Analizar calidad (TOON comprimido)
    GEMINI-->>N8N: Anomalías + sugerencias

    N8N-->>BE: Resultado análisis
    BE-->>FE: WebSocket: sugerencias de limpieza
    FE-->>U: Chat IA con propuestas

    U->>FE: Acepta transformaciones
    FE->>BE: POST /api/datasets/:id/clean
    BE->>N8N: Webhook: "iniciar limpieza"

    N8N->>GEMINI: Limpiar y normalizar
    GEMINI-->>N8N: Dataset limpio

    N8N->>DB: Bulk Insert optimizado
    DB-->>N8N: Confirmación

    N8N-->>BE: Pipeline completado
    BE-->>FE: WebSocket: "listo"
    FE-->>U: Datos listos + vista previa

    U->>FE: Generar reporte
    FE->>BE: POST /api/reports/:id/export
    BE->>PBI: Push de datos estructurados
    PBI-->>U: 4 Dashboards disponibles
```

---

## 5. Diagrama de Privacidad — Flujo Ley 1581

```mermaid
flowchart LR
    INPUT[📂 Datos del usuario] --> DETECT{Detección\nde PII}

    DETECT -- Contiene PII\nnombres / docs / correos --> LOCAL[🔒 Procesamiento LOCAL\nLlama 4 en servidor propio]
    LOCAL --> ANON[Anonimización\nPII → Hash seguro]
    ANON --> MAPEO[(Mapa de\nanomización\nencriptado)]
    ANON --> SAFE[Datos sin PII]

    DETECT -- Sin datos sensibles --> SAFE

    SAFE --> TOON[Compresión TOON\n45% menos tokens]
    TOON --> CLOUD[☁️ Gemini 2.5 Flash-Lite\nSolo datos públicos]
    CLOUD --> RESULT[Resultado procesado]

    RESULT --> RECONSTRUCT{¿Requiere\ndatos originales?}
    RECONSTRUCT -- Sí --> MAPEO
    MAPEO --> RESTORE[Restaurar PII\npara reporte interno]
    RECONSTRUCT -- No --> FINAL[📊 Reporte / Dashboard\nDatos anonimizados]
    RESTORE --> FINAL

    style LOCAL fill:#E74C3C,color:#fff
    style CLOUD fill:#3498DB,color:#fff
    style MAPEO fill:#F39C12,color:#fff
```

---

## 6. Diagrama de Infraestructura — Docker Compose

```mermaid
graph TB
    subgraph HOST["🖥️ Servidor VPS (Hostinger KVM4: 16GB RAM / 4 vCPU)"]
        subgraph DOCKER["🐳 Docker Compose Network"]
            FE_CONT[frontend:3000\nReact + Vite]
            BE_CONT[backend:4000\nNestJS]
            N8N_CONT[n8n:5678\nOrquestador]
            OLLAMA_CONT[ollama:11434\nLlama 4]
            OPENREFINE_CONT[openrefine:3333\nLimpieza]
            MYSQL_CONT[mysql:3306\nBase Principal]
            PG_CONT[postgres:5432\nBulk Insert]
            REDIS_CONT[redis:6379\nColas / Cache]
        end
        VOL1[(mysql_data\nVolumen persistente)]
        VOL2[(n8n_data\nFlujos guardados)]
        VOL3[(ollama_models\nModelos IA)]
    end

    INTERNET((🌐 Internet)) --> FE_CONT
    FE_CONT --> BE_CONT
    BE_CONT --> N8N_CONT
    BE_CONT --> OLLAMA_CONT
    BE_CONT --> REDIS_CONT
    N8N_CONT --> OPENREFINE_CONT
    N8N_CONT --> MYSQL_CONT
    N8N_CONT --> PG_CONT
    MYSQL_CONT --- VOL1
    N8N_CONT --- VOL2
    OLLAMA_CONT --- VOL3

    style HOST fill:#ECF0F1
    style DOCKER fill:#D5E8D4
```

---

## 7. Diagrama de Casos de Uso

```mermaid
graph LR
    subgraph ACTORES["Actores"]
        USER[👤 Usuario\nPYME/Estudiante]
        ADMIN[👨‍💼 Administrador]
        IA_LOCAL[🤖 IA Local\nLlama 4]
        IA_CLOUD[☁️ IA Nube\nGemini]
        PBI_ACTOR[📊 Power BI]
    end

    subgraph CASOS["Casos de Uso"]
        UC1[Registrarse / Login]
        UC2[Crear Proyecto]
        UC3[Cargar Dataset]
        UC4[Ver Vista Previa]
        UC5[Limpiar Datos con IA]
        UC6[Revisar Sugerencias]
        UC7[Aprobar / Rechazar Cambios]
        UC8[Exportar a Power BI]
        UC9[Ver Dashboard]
        UC10[Gestionar Usuarios]
        UC11[Configurar Prompts IA]
        UC12[Anonimizar PII]
        UC13[Procesar en Lote]
        UC14[Ver Historial de Cambios]
    end

    USER --> UC1
    USER --> UC2
    USER --> UC3
    USER --> UC4
    USER --> UC5
    USER --> UC6
    USER --> UC7
    USER --> UC8
    USER --> UC9
    USER --> UC14

    ADMIN --> UC10
    ADMIN --> UC11
    ADMIN --> UC1

    UC5 --> IA_LOCAL
    UC5 --> IA_CLOUD
    IA_LOCAL --> UC12
    UC8 --> PBI_ACTOR
    UC13 --> IA_CLOUD
```
