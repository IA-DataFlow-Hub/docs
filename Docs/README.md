# IA-DataFlow-Hub — Documentación

Índice central de toda la documentación del proyecto.

---

## Flujo recomendado

1. Abre el `README.md` raíz para la visión general y el arranque rápido.
2. Desde el `README.md` raíz, continúa en este `docs/README.md`.
3. Usa este índice para llegar a cualquier documento del proyecto.
4. Si necesitas gestionar HUs desde la terminal, ve a `docs/packages/hu-cli.md`.

---

## Documentación principal

| Documento | Descripción |
|-----------|-------------|
| [README_SUMMARY.md](README_SUMMARY.md) | Resumen ejecutivo del proyecto |
| [SETUP.md](SETUP.md) | Guía de instalación y configuración |
| [PRESENTACION_TECNICA.md](PRESENTACION_TECNICA.md) | Entregables clave y estado del proyecto |
| [DOCUMENTACION_TECNICA.md](DOCUMENTACION_TECNICA.md) | Detalle técnico de dependencias y configuraciones |
| [ARQUITECTURA.md](ARQUITECTURA.md) | Visión general del sistema y decisiones de diseño |
| [ESTRUCTURA.md](ESTRUCTURA.md) | Mapa completo del monorepo |
| [DOCKERIZACION.md](DOCKERIZACION.md) | Infraestructura Docker y servicios |
| [DATASETS.md](DATASETS.md) | Catálogo de datasets del proyecto |
| [CHAOS_GENERATOR.md](CHAOS_GENERATOR.md) | Estrategia de generación de datos caóticos |
| [sync-test.md](sync-test.md) | Pruebas de sincronización y validación |

---

## Apps

| Documento | Descripción |
|-----------|-------------|
| [apps/api.md](apps/api.md) | Backend NestJS — estructura y comandos |
| [apps/client.md](apps/client.md) | Frontend React/Vite — instalación y arranque |

---

## Paquetes

| Documento | Descripción |
|-----------|-------------|
| [packages/database.md](packages/database.md) | MySQL + Prisma + migraciones |
| [packages/hu-cli.md](packages/hu-cli.md) | CLI de HUs para GitHub Projects |
| [packages/chaos-generator.md](packages/chaos-generator.md) | Generador de datasets caóticos |

---

## Datos e IA

| Documento | Descripción |
|-----------|-------------|
| [DATASETS.md](DATASETS.md) | Catálogo general de datasets |
| [datasets/csv-retail.md](datasets/csv-retail.md) | Dataset retail con comportamiento |
| [CHAOS_GENERATOR.md](CHAOS_GENERATOR.md) | Generación de datos para IA |

---

## Diagramas

| Documento | Descripción |
|----------|-------------|
| [diagramas/README.md](diagramas/README.md) | Índice de diagramas |
| [diagramas/DIAGRAMAS.md](diagramas/DIAGRAMAS.md) | Marco general de diagramas |
| [diagramas/01-arquitectura-general/01-arquitectura-general.md](diagramas/01-arquitectura-general/01-arquitectura-general.md) | Arquitectura general |
| [diagramas/02-flujo-procesamiento-ia/02-flujo-procesamiento-ia.md](diagramas/02-flujo-procesamiento-ia/02-flujo-procesamiento-ia.md) | Flujo de procesamiento IA |
| [diagramas/03-modelo-base-de-datos/03-modelo-base-de-datos.md](diagramas/03-modelo-base-de-datos/03-modelo-base-de-datos.md) | Modelo relacional MySQL |
| [diagramas/04-flujo-autenticacion/04-flujo-autenticacion.md](diagramas/04-flujo-autenticacion/04-flujo-autenticacion.md) | Autenticación |
| [diagramas/05-roles-y-permisos/05-roles-y-permisos.md](diagramas/05-roles-y-permisos/05-roles-y-permisos.md) | Roles y permisos |
| [diagramas/06-flujo-etl/06-flujo-etl.md](diagramas/06-flujo-etl/06-flujo-etl.md) | Flujo ETL |
| [diagramas/07-ciclo-vida-ai-job/07-ciclo-vida-ai-job.md](diagramas/07-ciclo-vida-ai-job/07-ciclo-vida-ai-job.md) | AI Job |
| [diagramas/08-estructura-monorepo/08-estructura-monorepo.md](diagramas/08-estructura-monorepo/08-estructura-monorepo.md) | Estructura monorepo |
| [diagramas/09-privacidad-ley-1581/09-privacidad-ley-1581.md](diagramas/09-privacidad-ley-1581/09-privacidad-ley-1581.md) | Privacidad |
| [diagramas/10-flujo-conversaciones-chat/10-flujo-conversaciones-chat.md](diagramas/10-flujo-conversaciones-chat/10-flujo-conversaciones-chat.md) | Conversaciones |

---

## Historias de Usuario (HUs)

Las HUs están en [`HU/`](HU/) y todas son accesibles desde este índice central.

| Rango | Tema |
|-------|------|
| HU 000–010 | Investigación y diseño inicial |
| HU 011–015 | Infraestructura y base de datos |
| HU 016–029 | ETL, auditoría, reportes y configuraciones |
| HU 030–039 | IA, pruebas, n8n y diagramas |
| HU 040–052 | Módulos API, Auth, Feedback y Swagger |

---

## Investigaciones e informes

| Documento | Descripción |
|-----------|-------------|
| [Investigaciones/📚 Biblioteca de Investigación.md](Investigaciones/📚%20Biblioteca%20de%20Investigación.md) | Investigación del proyecto |
| [Informes/📊 Informe Ejecutivo – Capacidades del Equipo.md](Informes/📊%20Informe%20Ejecutivo%20–%20Capacidades%20del%20Equipo.md) | Informe ejecutivo |

---

## Resúmenes

| Documento | Descripción |
|-----------|-------------|
| [Resumenes/Resumen del Proyecto Ecosistema IA-DataFlow.md](Resumenes/Resumen%20del%20Proyecto%20Ecosistema%20IA-DataFlow.md) | Resumen del proyecto |

---

## Acceso rápido

- `README.md` raíz → inicio y arranque rápido
- `docs/README.md` → índice maestro de la documentación
- `docs/packages/hu-cli.md` → guía CLI de HUs


---

## Documentos relacionados

**Visión general:** [[README_SUMMARY]] · [[PRESENTACION_TECNICA]] · [[Resumen del Proyecto Ecosistema IA-DataFlow]]
**Arquitectura & infraestructura:** [[ARQUITECTURA]] · [[DOCKERIZACION]] · [[SETUP]] · [[DOCUMENTACION_TECNICA]] · [[ESTRUCTURA]]
**Apps:** [[api]] · [[client]] · [[mailer-service]]
**Paquetes:** [[database]] · [[chaos-generator]] · [[hu-cli]]
**Datos & IA:** [[DATASETS]] · [[CHAOS_GENERATOR]] · [[csv-retail]]
**Diagramas:** [[DIAGRAMAS]] · [[01-arquitectura-general]] · [[08-estructura-monorepo]]
**Historias de Usuario:** [[README|HU Index — 115 HUs]]
**Investigación:** [[📚 Biblioteca de Investigación]] · [[📊 Informe Ejecutivo – Capacidades del Equipo]]
