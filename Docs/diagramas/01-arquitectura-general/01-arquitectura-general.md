# Diagrama 1 — Arquitectura General del Sistema

**Qué muestra:** Todos los servicios del sistema y cómo se comunican entre sí dentro de la red Docker `iadataflow_net`.

**Última actualización:** 2026-05-12

---

```mermaid
graph TD
    subgraph INTERNET["🌐 Internet"]
        USER([👤 Usuario])
    end

    subgraph NGINX["🔀 Nginx — Proxy Inverso"]
        NG[nginx — iadataflow.com / api / n8n]
    end

    subgraph DOCKER["🐳 Docker Network — iadataflow_net"]
        FE[React + Vite — puerto 5173]
        API[NestJS API — puerto 3000]
        N8N[n8n Orquestador — puerto 5678]
        DB[(MySQL 8.0 — puerto 3307)]
        PMA[phpMyAdmin — puerto 8080]
    end

    subgraph HOST["🖥️ Host Windows"]
        LM[LM Studio — host.docker.internal:1234]
    end

    subgraph CLOUD["☁️ Nube"]
        GEMINI[Gemini 2.5 Flash-Lite]
    end

    subgraph VOLS["💾 Volúmenes Persistentes"]
        V1[(db_data)]
        V2[(n8n_data)]
    end

    USER --> NG
    NG -->|iadataflow.com| FE
    NG -->|api.iadataflow.com| API
    NG -->|n8n.iadataflow.com| N8N

    FE -->|REST + WebSocket| API
    API -->|Webhook HTTP| N8N
    API -->|Prisma ORM| DB
    API -->|OpenAI-compat API| LM

    N8N -->|SQL queries| DB
    N8N -->|LM Studio API| LM
    N8N -->|API REST| GEMINI

    PMA --> DB
    DB --- V1
    N8N --- V2

    style DOCKER fill:#D5E8D4,stroke:#82B366
    style HOST fill:#DAE8FC,stroke:#6C8EBF
    style CLOUD fill:#FFF2CC,stroke:#D6B656
    style VOLS fill:#F8CECC,stroke:#B85450
```

---

## Notas de implementación

| Servicio | Imagen | Puerto externo | Puerto interno |
|---|---|---|---|
| Frontend | `iadataflow/client:latest` | 5173 | 80 |
| API NestJS | `iadataflow/api:latest` | 3000 | 3000 |
| MySQL | `mysql:8.0` | 3307 | 3306 |
| n8n | `n8nio/n8n:latest` | 5678 | 5678 |
| phpMyAdmin | `phpmyadmin:latest` | 8080 | 80 |
| LM Studio | Host Windows | 1234 | — |

- Puerto MySQL externo es **3307** porque el 3306 está ocupado por la instalación local del host.
- LM Studio corre en el host Windows y es accesible desde Docker vía `host.docker.internal`.
- Nginx no está activo en desarrollo local; cada servicio es directamente accesible por su puerto.


---

## Documentos relacionados

**Docs:** [[ARQUITECTURA]] · [[DOCKERIZACION]] · [[DOCUMENTACION_TECNICA]]
**Apps:** [[api]] · [[client]] · [[mailer-service]]
**Paquetes:** [[database]]
**HUs:** [[✅ HU 014 - Arquitectura Base y Monorepo|HU-014]] · [[✅ HU 036 - Estructura Base del API NestJS|HU-036]] · [[✅ HU 013 - Configuración de Infraestructura de Datos (Docker)|HU-013]]
