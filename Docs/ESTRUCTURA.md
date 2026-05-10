# ESTRUCTURA — Mapa de Archivos del Proyecto

> Este documento describe la organización completa del repositorio **IA-DataFlow Hub**, un vault de Obsidian gestionado con Git. Cada carpeta representa un módulo funcional de la documentación del semillero.

---

## Árbol de Directorios

```
IA-DataFlow Hub - Semillero/
│
├── 🎊 Bienvenidos a IA-DataFlow Hub.md
├── Readme.md
│
├── HU & Investigaciones/
│   ├── Internas/
│   │   ├── HU 01 - Infraestructura/
│   │   ├── HU 02 - IA y ETL/
│   │   ├── HU 03 - Stack Tecnológico/
│   │   ├── HU 04 - UX y Dashboards/
│   │   ├── HU 05 - Seguridad/
│   │   └── HU 06 - Arquitectura UML/
│   ├── Externas/
│   ├── Tareas.md
│   ├── Investigaciones Internas.md
│   └── Investigaciones Externas.md
│
├── Docs/
│   ├── Resumenes/
│   ├── Informes/
│   └── Investigaciones/
│
├── docs/                              ← (esta carpeta, generada automáticamente)
│   ├── README_SUMMARY.md
│   ├── ESTRUCTURA.md
│   ├── DIAGRAMAS.md
│   └── DOCUMENTACION_TECNICA.md
│
├── Actas/
│   ├── Febrero_2026/
│   ├── Marzo_2026/
│   ├── Abril_2026/
│   └── Excel/
│
├── Tutoriales/
│   ├── Git/
│   ├── Obsidian/
│   ├── Estilo/
│   └── Ruta de Aprendizaje/
│
├── Integrantes/
│   ├── Equipo 1/
│   └── Equipo 2/
│
├── Requisitos para aprobar el semillero/
│   ├── 1 - Propuesta (OPPROSE-02)/
│   ├── 2 - Aceptación y Asignación/
│   ├── 4 - CV-LAC/
│   ├── 6 - Entregas Parciales/
│   └── 9 - Uso de Obra - Socialización/
│
├── Archivos/
│   ├── Librerias/
│   ├── Diagramas/
│   └── Investigaciones/
│
├── DataSets/
│   └── Buscados/
│       ├── Excel/
│       ├── Excel csv/
│       ├── log/
│       └── json/
│
├── .obsidian/
├── .git/
└── .claude/
```

---

## Descripción por Módulo

### Raíz del proyecto

| Archivo | Descripción |
|---|---|
| `🎊 Bienvenidos a IA-DataFlow Hub.md` | Página de inicio del vault. Introduce el proyecto, el equipo y los objetivos del semillero. Punto de entrada para nuevos integrantes. |
| `Readme.md` | Guía técnica de sincronización Git + Obsidian. Explica cómo clonar, sincronizar y hacer commits desde el vault. |

---

### `HU & Investigaciones/` — Núcleo de Conocimiento Técnico

Contiene todas las Historias de Usuario (HU) e investigaciones que fundamentan el diseño del sistema.

#### `Internas/` — Historias de Usuario

Cada subcarpeta documenta una Historia de Usuario con su documento principal y un resumen ejecutivo. Las versiones alternativas de ciertos integrantes también se almacenan aquí.

| Carpeta | Tema | Contenido Principal |
|---|---|---|
| `HU 01 - Infraestructura/` | Infraestructura y viabilidad de servidores | Análisis de opciones de hosting (Hostinger VPS, DigitalOcean, AWS Lightsail), consumo de RAM, costos y recomendaciones |
| `HU 02 - IA y ETL/` | Inteligencia artificial y pipeline ETL | Comparativa de modelos IA (Gemini vs GPT-4o mini vs Claude), pipeline ETL, compresión TOON, agentes autónomos |
| `HU 03 - Stack Tecnológico/` | Selección del stack completo | Justificación de React + NestJS + Docker, comparativa de frameworks, decisiones arquitectónicas |
| `HU 04 - UX y Dashboards/` | Experiencia de usuario y visualizaciones | Diseño de interfaces, integración con Power BI, 4 tipos de dashboards, flujos UX |
| `HU 05 - Seguridad/` | Seguridad, privacidad y cumplimiento | Ley 1581 de Colombia, manejo de datos sensibles, JWT, cifrado, políticas de retención |
| `HU 06 - Arquitectura UML/` | Modelado UML y arquitectura de software | Diagramas de clases, secuencia, casos de uso, arquitectura de N-capas |

#### `Externas/` — Investigaciones de Tecnologías

| Archivo | Tecnología Investigada |
|---|---|
| `Informe de Investigación Automatización con n8n.md` | n8n como orquestador de flujos ETL (self-hosted, webhooks, nodos) |
| `Informe de Investigación Limpieza y Transformación con OpenRefine.md` | OpenRefine con GREL para limpieza avanzada, clustering, deduplicación |
| `Informe Google Colab y TOON en Procesos ETL con IA.md` | Google Colab para procesamiento GPU/TPU y estándar TOON (45 % ahorro de tokens) |
| `Informe de Investigación Microsoft Power Platform.md` | Power BI, Power Apps, Power Automate, Copilot Studio para visualización y automatización |
| `Informe IA Agentes y Power BI para Datos No Estructurados.md` | Agentes IA autónomos con Function Calling para datos no estructurados |
| `Requerimientos y Diseño de Arquitectura (UML).md` | RF/RNF, diagramas UML completos, modelo de datos |

| Archivo | Descripción |
|---|---|
| `Tareas.md` | Tablero de tareas del equipo (tipo Kanban en Obsidian) |
| `Investigaciones Internas.md` | Índice y estado de las investigaciones internas |
| `Investigaciones Externas.md` | Índice y estado de las investigaciones externas |

---

### `Docs/` — Documentación Formal del Proyecto

| Subcarpeta | Contenido |
|---|---|
| `Resumenes/` | Resumen del Proyecto Ecosistema IA-DataFlow: visión global del sistema, métricas y objetivos |
| `Informes/` | Informe Ejecutivo de Capacidades del Equipo: hardware disponible, nivel de experiencia, asignación de roles |
| `Investigaciones/` | Biblioteca de Investigación: referencias académicas, artículos, papers y fuentes consultadas |

---

### `docs/` — Documentación Técnica Autogenerada

> Esta carpeta fue generada automáticamente por Claude Code a partir del análisis del vault.

| Archivo | Descripción |
|---|---|
| `README_SUMMARY.md` | Resumen ejecutivo: qué hace el proyecto, arquitectura principal, stack y estado actual |
| `ESTRUCTURA.md` | Este archivo. Mapa completo de carpetas y módulos con descripciones |
| `DIAGRAMAS.md` | Diagramas Mermaid: entidad-relación, flujo de procesos y arquitectura |
| `DOCUMENTACION_TECNICA.md` | Dependencias, endpoints, clases principales y guías de configuración |

---

### `Actas/` — Registro de Reuniones

| Subcarpeta | Contenido |
|---|---|
| `Febrero_2026/` | Acta de inicio del semillero: objetivos, integrantes, metodología |
| `Marzo_2026/` | Protocolo de Fase 1: acuerdos de trabajo, distribución de tareas |
| `Abril_2026/` | Cierre de requisitos: validación de HU, aprobación de stack |
| `Excel/` | `ACTAS SEMILLERO PROYECTO IA - DATAFLOW.xlsx`: registro formal en formato Areandina |

---

### `Tutoriales/` — Guías de Onboarding

| Subcarpeta | Archivo | Audiencia |
|---|---|---|
| `Git/` | Manual de Sincronización Git + GitHub | Todos los integrantes |
| `Obsidian/` | Guía de Instalación Obsidian + Sincronización Git | Nuevos integrantes |
| `Estilo/` | Guía Maestra de Estilo en Obsidian | Autores de contenido |
| `Ruta de Aprendizaje/` | Tutoriales: ruta de aprendizaje recomendada | Perfiles junior |

---

### `Integrantes/` — Perfiles del Equipo

Organizado por equipos de trabajo. Cada integrante tiene una carpeta con su perfil profesional.

| Equipo | Integrantes |
|---|---|
| Equipo 1 | María Virginia Labarca |
| Equipo 2 | Andrés Felipe Andrade, David Ospina |

> Nota: Los perfiles restantes del equipo están pendientes de agregarse al vault.

---

### `Requisitos para aprobar el semillero/`

Carpetas exigidas por el reglamento de semilleros de Areandina:

| Carpeta | Descripción |
|---|---|
| `1 - Propuesta (OPPROSE-02)/` | Formulario oficial de propuesta de semillero |
| `2 - Aceptación y Asignación/` | Carta de aceptación y asignación de director |
| `4 - CV-LAC/` | Hojas de vida en formato CvLAC (plataforma Colciencias/MinCiencias) |
| `6 - Entregas Parciales/` | Reportes de avance por corte académico |
| `9 - Uso de Obra - Socialización/` | Cesión de derechos de autor y documentos de socialización |

---

### `Archivos/` — Recursos Estáticos

| Subcarpeta | Contenido |
|---|---|
| `Librerias/` | PDFs de investigación académica y técnica consultados |
| `Diagramas/` | Diagramas UML, RF/RNF, flujos ETL e IA en formatos de imagen |
| `Investigaciones/` | Reportes PDF formales generados por el equipo |

---

### `DataSets/Buscados/` — Datos de Prueba

Contiene los archivos de datos utilizados para validar el pipeline ETL.

| Subcarpeta | Contenido |
|---|---|
| `Excel/` | Archivos XLSX con datos reales sucios: inventarios, activos, datos empresariales (1000 registros) |
| `Excel csv/` | Versiones CSV de los mismos: datos duplicados, erróneos, con muchas columnas |
| `log/` | Logs del sistema: Android, Apache, HDFS, Hadoop — con versiones `_structured` y `_templates` |
| `json/` | Salidas JSON estructuradas del sistema (ejemplo de output de IA-DataFlow) |

**Archivos CSV destacados:**

| Archivo | Descripción |
|---|---|
| `csv_1000_datos_duplicados_1.csv` | 1000 registros con duplicados intencionales para test de deduplicación |
| `datos_erroneos_150_registros.csv` | 150 registros con errores de formato, nulos y tipos incorrectos |
| `datos_muy_erroneos_muchas_columnas.csv` | Dataset caótico con columnas extra y datos mixtos |
| `ventas_entorno_pruebas_*.csv` | Escenarios de ventas de 800–1000 registros para test de transformación |

---

### `.obsidian/` — Configuración del Vault

Contiene los archivos de configuración de Obsidian: plugins activos, tema visual, atajos de teclado y configuración de Graph View. No debe modificarse manualmente.

### `.git/` — Control de Versión

Historial de commits del proyecto. El vault usa Git como sistema de backup y colaboración, con sincronización automática configurada según las guías en `Tutoriales/Git/`.

### `.claude/` — Configuración de Claude Code

Configuración del entorno de Claude Code para este proyecto: permisos, settings y preferencias del asistente IA.
