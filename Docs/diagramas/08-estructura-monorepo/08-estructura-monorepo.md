# Diagrama 8 — Estructura del Monorepo

**Qué muestra:** Cómo está organizado el monorepo con Turborepo, qué contiene cada workspace, el orden de build y las dependencias entre paquetes.

**Última actualización:** 2026-05-12

---

## 8a — Árbol de directorios y responsabilidades

```mermaid
graph TD
    ROOT["📦 IA-DataFlow-Hub — Workspace Root"]

    ROOT --> APPS["📂 apps/ — Aplicaciones desplegables"]
    ROOT --> PACKAGES["📂 packages/ — Librerías compartidas"]
    ROOT --> AI["📂 ai-services/ — Recursos de IA"]
    ROOT --> INFRA["📂 infra/ — Infraestructura"]
    ROOT --> DOCS["📂 docs/ — Documentación"]

    APPS --> CLIENT["⚛️ apps/client — React + Vite + Tailwind + shadcn"]
    APPS --> API["🟢 apps/api — NestJS 11 + TypeScript 5 + Node 20"]

    PACKAGES --> DB["🗄️ packages/database — Prisma ORM + schema + migrations"]
    PACKAGES --> TYPES["🔷 packages/shared-types — ApiResponse, PaginatedResponse, UserBase"]

    AI --> FINETUNE["🧠 ai-services/fine-tuning — Datasets y notebooks"]
    AI --> PROMPTS["💬 ai-services/prompts — Biblioteca de prompts reutilizables"]

    INFRA --> NGINX["🔀 infra/nginx — default.conf proxy inverso producción"]
    INFRA --> N8N["⚙️ infra/n8n/data — Flujos y credenciales persistentes"]

    CLIENT -->|consume tipos| TYPES
    API -->|consume tipos| TYPES
    API -->|consume cliente Prisma| DB

    style ROOT fill:#2D3748,color:#fff
    style APPS fill:#2B6CB0,color:#fff
    style PACKAGES fill:#276749,color:#fff
    style AI fill:#744210,color:#fff
    style INFRA fill:#63171B,color:#fff
    style DOCS fill:#44337A,color:#fff
```

---

## 8b — Pipeline de build con Turborepo

```mermaid
graph LR
    subgraph TURBO["⚡ Turborepo — turbo.json"]
        direction TB
        T1["shared-types — build"]
        T2["database — build + genera Prisma Client"]
        T3["api — build — depende de shared-types y database"]
        T4["client — build — depende de shared-types"]

        T1 --> T3
        T2 --> T3
        T1 --> T4
    end

    subgraph CACHE["💾 Caché inteligente"]
        C1["Sin cambios en el código — reutiliza output anterior"]
    end

    TURBO --> CACHE

    style TURBO fill:#D69E2E,color:#000
    style CACHE fill:#2D3748,color:#fff
```

---

## 8c — Dependencias entre workspaces

```mermaid
graph LR
    ST["packages/shared-types"]
    DB["packages/database"]
    API["apps/api"]
    CLIENT["apps/client"]

    ST -->|"@iadataflow/shared-types"| API
    ST -->|"@iadataflow/shared-types"| CLIENT
    DB -->|"@iadataflow/database — Prisma Client"| API
```

---

## Comandos clave

| Comando | Qué hace |
|---|---|
| `npm install` | Instala dependencias de todos los workspaces |
| `npm run dev` | Levanta API (NestJS watch) + Client (Vite HMR) en paralelo |
| `npm run build` | Compila todos los workspaces respetando el orden de dependencias |
| `npx prisma migrate dev` | Crea una nueva migración desde `packages/database/` |
| `npx prisma studio` | Abre UI visual de la base de datos |
| `docker-compose up --build` | Construye imágenes propias y levanta todos los servicios |

## Notas

- `packages/shared-types` no tiene dependencias internas — es la base de la cadena.
- `packages/database` genera el cliente Prisma en tiempo de build; la API lo importa como librería.
- Turborepo cachea los outputs por contenido de archivos, no por timestamps.
- Los directorios `infra/n8n/data/` y `infra/nginx/` no son workspaces — son configuración estática.


---

## Documentos relacionados

**Docs:** [[ARQUITECTURA]] · [[DOCKERIZACION]] · [[ESTRUCTURA]]
**HUs:** [[✅ HU 014 - Arquitectura Base y Monorepo|HU-014]] · [[✅ HU 036 - Estructura Base del API NestJS|HU-036]]
