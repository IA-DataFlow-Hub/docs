# IA-DataFlow-Hub — Documentación

Índice central de toda la documentación del proyecto.

---

## Inicio rápido

| Documento | Descripción |
|-----------|-------------|
| [SETUP.md](SETUP.md) | **Instalación completa** — Git, Node, Docker, VS Code, comandos y troubleshooting |
| [README_SUMMARY.md](README_SUMMARY.md) | Resumen ejecutivo — qué es el proyecto y su propósito |
| [PRESENTACION_TECNICA.md](PRESENTACION_TECNICA.md) | Entregables clave y estado del proyecto |

---

## Arquitectura y diseño

| Documento | Descripción |
|-----------|-------------|
| [ARQUITECTURA.md](ARQUITECTURA.md) | Visión general, stack, capas y decisiones de diseño |
| [DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md) | Dependencias, tecnologías y configuraciones técnicas |
| [ESTRUCTURA.md](ESTRUCTURA.md) | Mapa completo de archivos y carpetas del monorepo |
| [DOCKERIZACION.md](DOCKERIZACION.md) | Detalle de la infraestructura Docker y servicios |
| [diagramas/README.md](diagramas/README.md) | Diagramas de arquitectura, flujos y modelo de datos (Mermaid → PNG/SVG) |

---

## Apps

| Documento | Descripción |
|-----------|-------------|
| [apps/api.md](apps/api.md) | Backend NestJS — comandos, arquitectura y módulos |
| [apps/client.md](apps/client.md) | Frontend React/Vite — instalación y arranque |

---

## Paquetes

| Documento | Descripción |
|-----------|-------------|
| [packages/database.md](packages/database.md) | MySQL v4, Docker, Prisma y migraciones |
| [packages/hu-cli.md](packages/hu-cli.md) | CLI `hu` — gestión de HUs en GitHub Projects |
| [packages/chaos-generator.md](packages/chaos-generator.md) | Generador de datasets caóticos para fine-tuning |

---

## Datos e IA

| Documento | Descripción |
|-----------|-------------|
| [DATASETS.md](DATASETS.md) | Catálogo y descripción de datasets del proyecto |
| [CHAOS_GENERATOR.md](CHAOS_GENERATOR.md) | Estrategia de generación de datos caóticos para entrenamiento |
| [datasets/csv-retail.md](datasets/csv-retail.md) | Retail Intelligence — 108k registros de comportamiento |

---

## Diagramas

| Diagrama | Descripción |
|----------|-------------|
| [01 — Arquitectura general](diagramas/01-arquitectura-general/01-arquitectura-general.md) | Vista de alto nivel del sistema |
| [02 — Flujo procesamiento IA](diagramas/02-flujo-procesamiento-ia/02-flujo-procesamiento-ia.md) | Ciclo de vida de un job de IA |
| [03 — Modelo de base de datos](diagramas/03-modelo-base-de-datos/03-modelo-base-de-datos.md) | Esquema relacional MySQL v4 |
| [04 — Flujo autenticación](diagramas/04-flujo-autenticacion/04-flujo-autenticacion.md) | JWT, OAuth y sesiones |
| [05 — Roles y permisos](diagramas/05-roles-y-permisos/05-roles-y-permisos.md) | RBAC — equipos, roles y permisos |
| [06 — Flujo ETL](diagramas/06-flujo-etl/06-flujo-etl.md) | Pipeline de transformación de datos |
| [07 — Ciclo de vida AI Job](diagramas/07-ciclo-vida-ai-job/07-ciclo-vida-ai-job.md) | Estados y transiciones de un AI Job |
| [08 — Estructura monorepo](diagramas/08-estructura-monorepo/08-estructura-monorepo.md) | Organización de apps y packages |
| [09 — Privacidad ley 1581](diagramas/09-privacidad-ley-1581/09-privacidad-ley-1581.md) | Cumplimiento normativa colombiana |
| [10 — Flujo conversaciones](diagramas/10-flujo-conversaciones-chat/10-flujo-conversaciones-chat.md) | Chat y mensajería en tiempo real |

---

## Historias de Usuario (HUs)

Las HUs están en [`HU/`](HU/) organizadas por número.

| Rango | Descripción |
|-------|-------------|
| HU 000–010 | Investigación, roles y corpus |
| HU 011–015 | Base de datos, Docker e infraestructura |
| HU 016–029 | Esquema v4, ENUMs, auditoría, notificaciones, ETL, reportes |
| HU 030–039 | UUIDs, pruebas, IA, n8n, diagramas, fine-tuning |
| HU 040–052 | Módulos API: Auth, Usuarios, Teams, Proyectos, Archivos, Conversaciones, Tareas, AI Jobs, ETL, Feedback, Notificaciones, Auditoría, Swagger |

Usa `hu list` para ver el estado actual en GitHub Projects.

---

## Investigaciones e informes

| Documento | Descripción |
|-----------|-------------|
| [Investigaciones/📚 Biblioteca de Investigación.md](Investigaciones/📚%20Biblioteca%20de%20Investigación.md) | Referencias y estudios del equipo |
| [Informes/📊 Informe Ejecutivo – Capacidades del Equipo.md](Informes/📊%20Informe%20Ejecutivo%20–%20Capacidades%20del%20Equipo.md) | Capacidades técnicas del equipo |
| [Resumenes/Resumen del Proyecto Ecosistema IA-DataFlow.md](Resumenes/Resumen%20del%20Proyecto%20Ecosistema%20IA-DataFlow.md) | Visión del ecosistema completo |
