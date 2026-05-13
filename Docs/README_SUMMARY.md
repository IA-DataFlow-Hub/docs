# IA-DataFlow Hub — Resumen Ejecutivo

## ¿Qué es IA-DataFlow Hub?

**IA-DataFlow Hub** es un sistema ETL (Extracción, Transformación y Carga) inteligente que democratiza el análisis de datos para PYMEs y entornos académicos. Permite a usuarios sin conocimientos técnicos avanzados cargar archivos con datos desordenados o incorrectos y obtener, de forma automática, datos limpios, normalizados y listos para visualizar en dashboards de Power BI.

El proyecto nace como semillero de investigación en la Fundación Universitaria del Área Andina, con el objetivo de combinar inteligencia artificial híbrida (local + nube) con un pipeline ETL robusto y seguro que cumpla la **Ley 1581 de 2012** (Protección de Datos Personales de Colombia).

---

## Problema que Resuelve

Las PYMEs colombianas enfrentan tres barreras para aprovechar sus datos:

1. **Calidad de datos:** Archivos con errores, duplicados, formatos inconsistentes y campos vacíos.
2. **Costo de herramientas:** Las soluciones empresariales de limpieza y BI son inaccesibles económicamente.
3. **Privacidad:** No pueden enviar datos sensibles a servicios en la nube sin violar regulaciones.

IA-DataFlow Hub resuelve los tres problemas con una arquitectura híbrida que procesa datos sensibles localmente y delega el procesamiento masivo a IA en la nube, con un ahorro de tokens del **45 %** gracias al estándar de compresión TOON.

---

## Propuesta de Valor

| Característica | Detalle |
|---|---|
| **Automatización ETL** | Detección y corrección de anomalías sin intervención manual |
| **IA Híbrida** | Llama 4 (local/privado) + Gemini 2.5 Flash-Lite (nube/masivo) |
| **Privacidad garantizada** | Datos sensibles nunca salen del servidor (Ley 1581) |
| **Ahorro de costos** | Compresión TOON reduce consumo de tokens un 45 % |
| **Visualización automática** | 4 tipos de dashboards Power BI generados automáticamente |
| **Orquestación sin código** | n8n gestiona los flujos de trabajo de forma visual |

---

## Arquitectura Principal

El sistema sigue una arquitectura de **N-Capas** desacoplada, orquestada por n8n y contenida en Docker:

```
┌───────────────────────────────────────────────────────────┐
│  PRESENTACIÓN                                             │
│  React + Vite · Recharts · D3.js · ApexCharts · Plotly  │
└─────────────────────────┬─────────────────────────────────┘
                          │ WebSocket (Socket.IO)
┌─────────────────────────▼─────────────────────────────────┐
│  LÓGICA DE NEGOCIO                                        │
│  NestJS · JWT Auth · Multer Streams · Worker Threads      │
└─────────────────────────┬─────────────────────────────────┘
                          │ Webhooks HTTP
┌─────────────────────────▼─────────────────────────────────┐
│  ORQUESTACIÓN                                             │
│  n8n (Self-Hosted) · Redis Queues · Event Triggers        │
└──────────┬──────────────────────────┬──────────────────────┘
           │                          │
┌──────────▼──────────┐  ┌────────────▼───────────────────┐
│  IA LOCAL           │  │  IA NUBE                       │
│  Llama 4 (Ollama)   │  │  Gemini 2.5 Flash-Lite         │
│  Datos sensibles    │  │  Volumen masivo (100k+ filas)  │
│  Anonimización      │  │  Deduplicación / Normalización │
└──────────┬──────────┘  └────────────┬───────────────────┘
           │                          │
┌──────────▼──────────────────────────▼──────────────────────┐
│  LIMPIEZA ESPECIALIZADA                                    │
│  OpenRefine + GREL · PapaParse · Transformaciones complejas│
└──────────────────────────────┬─────────────────────────────┘
                               │
┌──────────────────────────────▼─────────────────────────────┐
│  PERSISTENCIA                                              │
│  MySQL (primaria) · PostgreSQL (bulk insert)               │
│  SQL Server / Oracle (legacy support)                      │
└──────────────────────────────┬─────────────────────────────┘
                               │
┌──────────────────────────────▼─────────────────────────────┐
│  VISUALIZACIÓN                                             │
│  Power BI · 4 Dashboards: Estratégico / Táctico /          │
│  Técnico / Operativo                                       │
└────────────────────────────────────────────────────────────┘
```

---

## Stack Tecnológico

| Capa | Tecnología |
|---|---|
| Frontend | React + Vite, Recharts, D3.js, ApexCharts, Plotly.js, Zustand, Socket.IO |
| Backend | Node.js, NestJS (TypeScript), Multer, Worker Threads |
| Orquestación | n8n Self-Hosted |
| IA Local | Llama 4 vía Ollama |
| IA Nube | Google Gemini 2.5 Flash-Lite |
| Limpieza | OpenRefine + GREL, PapaParse |
| Bases de datos | MySQL, PostgreSQL, SQL Server, Oracle |
| Caching/Colas | Redis |
| Contenedores | Docker + Docker Compose |
| Reportería | Power BI, Microsoft Power Platform |

---

## Estado Actual del Proyecto

**Fase:** Fase 1 — Diseño y Documentación (activo desde marzo 2026)

| Hito | Estado |
|---|---|
| Propuesta aprobada (OPPROSE-02) | ✅ Completado |
| 6 Historias de Usuario documentadas | ✅ Completado |
| 6 Investigaciones técnicas | ✅ Completado |
| Selección de stack tecnológico | ✅ Completado |
| Análisis de infraestructura y costos | ✅ Completado |
| Implementación del backend NestJS | 🔄 En progreso |
| Frontend React con Web Workers | 🔄 Pendiente |
| Integración n8n | 🔄 Pendiente |
| Configuración Llama 4 local | 🔄 Pendiente |
| Dashboards Power BI | 🔄 Pendiente |

---

## Equipo

| Nombre | Rol Principal |
|---|---|
| Juan Diego Mejía | Arquitecto + Lead Dev (NestJS, Full Stack, Scrum) |
| Sebastián Bautista | DBA + Infraestructura (Oracle, SQL Server, AWS/Azure) |
| David Ospina | Backend Developer (.NET, Angular, APIs REST) |
| Oscar Antury | Frontend + Seguridad (React, Python, Docker, Ley 1581) |
| Andrés Andrade | QA + Testing IA (Backend PHP, Redes, Testing) |
| Brayan Monterrosa | Frontend Developer (React, JavaScript, Node.js) |
| Pohlman Cuartas | Seguridad y Soporte (C++, Ley 1581) |
| María Virginia Labarca | Soporte y Calidad (PowerShell, Scripting) |

---

## Repositorio y Recursos

- **Repositorio Git:** `https://github.com/IA-DataFlow-Hub/docs`
- **Prototipo en vivo:** `https://ia-dataflow.codigolimpio.com.co/`
- **Base de documentación:** Obsidian Vault sincronizado con Git
.
