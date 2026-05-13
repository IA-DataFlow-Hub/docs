# HU-035 — Diagramas Clave del Proyecto

## Historia de Usuario

**Como** equipo de desarrollo,  
**Quiero** tener los diagramas más importantes del sistema documentados y actualizados,  
**Para** que cualquier integrante pueda entender cómo funciona el proyecto sin leer todo el código.

---

## Contexto

Un proyecto con múltiples equipos trabajando en paralelo (DB, backend, frontend, IA, n8n) necesita diagramas que sirvan como lenguaje común. Sin ellos, cada equipo tiene una visión distinta del sistema y los errores de integración se multiplican.

---

## Criterios de Aceptación

- [ ] Todos los diagramas están en `docs/diagramas/`.
- [ ] Cada diagrama tiene un archivo fuente editable (Mermaid, draw.io o PlantUML) además de la imagen exportada.
- [ ] Los diagramas están referenciados desde `docs/DIAGRAMAS.md` con una descripción de qué muestra cada uno.
- [ ] Cualquier integrante del equipo puede entender el sistema leyendo los diagramas sin conocimiento previo.
- [ ] Se actualiza el diagrama correspondiente cada vez que se aprueba una HU que cambia la arquitectura.

---

## Diagramas a Crear

---

### Diagrama 1 — Arquitectura General del Sistema

**Qué muestra:** Todos los servicios del sistema y cómo se comunican entre sí.

```
[Usuario] → [Frontend React]
                ↓
           [NestJS API]
           ↙    ↓    ↘
      [MySQL] [n8n] [Ollama/Gemini]
                ↓
         [Volumen de archivos]
```

Incluir: Frontend, API, MySQL, n8n, Ollama, Gemini, Nginx, Docker network.  
Formato sugerido: draw.io o Mermaid `graph TD`.

---

### Diagrama 2 — Flujo de Procesamiento de un Archivo con IA

**Qué muestra:** El recorrido completo desde que el usuario sube un archivo hasta que recibe el resultado procesado.

Pasos:
1. Usuario sube CSV desde el frontend.
2. Frontend llama al API.
3. API guarda el archivo y crea un AI Job.
4. API dispara webhook a n8n.
5. n8n llama a Ollama (o Gemini si falla, fallback).
6. n8n devuelve resultado al API.
7. API actualiza el job como completado.
8. API notifica al usuario en tiempo real (WebSocket).
9. Usuario ve el resultado en pantalla.

Formato sugerido: Mermaid `sequenceDiagram`.

---

### Diagrama 3 — Modelo de Base de Datos (Entidades Principales)

**Qué muestra:** Las tablas más importantes y sus relaciones, sin detallar todas las columnas.

Entidades a incluir:
- `users` ↔ `credentials`, `sessions`, `configurations`
- `teams` ↔ `team_members` ↔ `team_roles`
- `projects` ↔ `files` ↔ `conversations` ↔ `messages`
- `ai_jobs` ↔ `ai_job_events` ↔ `ai_results`
- `datasets` ↔ `generated_tables`
- `etl_templates` ↔ `etl_executions`
- `reports` ↔ `report_widgets`

Formato sugerido: Mermaid `erDiagram` (simplificado, no todas las columnas).

---

### Diagrama 4 — Flujo de Autenticación

**Qué muestra:** Cómo un usuario inicia sesión, obtiene tokens y cómo el API los valida en cada petición.

Pasos:
1. Usuario envía email + contraseña (o token de Google OAuth).
2. API valida credenciales contra la DB.
3. API genera `access_token` (15 min) y `refresh_token` (7 días).
4. Frontend guarda tokens.
5. Cada petición incluye `Authorization: Bearer <access_token>`.
6. API valida el token con el guard JWT.
7. Si expira → frontend usa `refresh_token` para obtener uno nuevo.
8. Si el refresh también expira → redirige al login.

Formato sugerido: Mermaid `sequenceDiagram`.

---

### Diagrama 5 — Modelo de Roles y Permisos

**Qué muestra:** Cómo se resuelve el acceso de un usuario a un recurso según su rol.

```
Global → Equipo → Proyecto
   ↓         ↓         ↓
role_templates → team_roles → user_project_roles
```

Incluir: jerarquía de roles, herencia, orden de resolución de permisos.  
Formato sugerido: Mermaid `graph TD`.

---

### Diagrama 6 — Flujo de un Pipeline ETL

**Qué muestra:** Cómo un template ETL se aplica a un archivo paso a paso.

Pasos:
1. Usuario selecciona template + archivo en el frontend.
2. API crea una `etl_execution`.
3. API envía a n8n: `{ file, steps[] }`.
4. n8n ejecuta cada paso en orden.
5. Si un paso falla → detiene y registra el error.
6. Si todos pasan → devuelve archivo transformado.
7. API guarda el resultado como nuevo dataset.
8. Lineage queda registrado: archivo original → transformación → dataset resultado.

Formato sugerido: Mermaid `flowchart TD`.

---

### Diagrama 7 — Ciclo de Vida de un AI Job

**Qué muestra:** Todos los estados posibles de un job de IA y las transiciones entre ellos.

```
PENDING → QUEUED → PROCESSING → COMPLETED
                       ↓
                     FAILED → (retry) → PROCESSING
                       ↓
                   CANCELLED
```

Incluir: qué evento dispara cada transición, quién la dispara (usuario, sistema, n8n).  
Formato sugerido: Mermaid `stateDiagram-v2`.

---

## Estructura de Archivos

```
docs/
├── DIAGRAMAS.md              ← índice con descripción de cada diagrama
└── diagramas/
    ├── 01-arquitectura-general.md        (Mermaid)
    ├── 01-arquitectura-general.png       (exportado)
    ├── 02-flujo-procesamiento-ia.md
    ├── 02-flujo-procesamiento-ia.png
    ├── 03-modelo-base-de-datos.md
    ├── 03-modelo-base-de-datos.png
    ├── 04-flujo-autenticacion.md
    ├── 04-flujo-autenticacion.png
    ├── 05-roles-y-permisos.md
    ├── 05-roles-y-permisos.png
    ├── 06-flujo-etl.md
    ├── 06-flujo-etl.png
    ├── 07-ciclo-vida-ai-job.md
    └── 07-ciclo-vida-ai-job.png
```

---

## Reglas para mantener los diagramas actualizados

- Cada HU que cambie la arquitectura debe incluir en sus tareas: "Actualizar diagrama X".
- Los diagramas en Mermaid se editan directamente en el `.md` y se renderizan en GitHub/GitLab.
- Si se usa draw.io, guardar también el `.drawio` en el repositorio junto a la imagen exportada.

## Prioridad

**Alta** — cuanto antes estén, más rápido el equipo puede trabajar de forma coordinada.
