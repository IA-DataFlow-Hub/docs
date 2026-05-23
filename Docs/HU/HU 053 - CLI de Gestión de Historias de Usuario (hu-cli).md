# HU-053 — CLI de Gestión de Historias de Usuario (hu-cli)

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

## Archivos Principales

`packages/hu-cli/src/index.js` · `packages/hu-cli/src/lib/config.js` · `packages/hu-cli/src/lib/github.js` · `packages/hu-cli/src/lib/files.js` · `packages/hu-cli/src/commands/`

---

## Historia de Usuario

**Como** miembro del equipo,  
**Quiero** gestionar las Historias de Usuario directamente desde la terminal,  
**Para** crear issues en GitHub, avanzar estados en el proyecto, asignar responsables y mantener los archivos `.md` sincronizados con GitHub Projects, sin depender de la interfaz web de GitHub.

**Dependencia:** Requiere `gh` CLI autenticado con scopes `project,read:project,write:org`.

---

## Contexto

El repositorio IA-DataFlow-Hub gestiona sus HUs como archivos Markdown en `docs/HU/`. Sin una CLI dedicada, actualizar el estado de una HU en GitHub Projects requiere navegar manualmente por la interfaz web. Con más de 50 HUs activas, el overhead de mantenimiento es alto. `hu-cli` automatiza el ciclo completo: creación de issues, avance de estados, asignación de responsables y sincronización del contenido.

---

## Estructura del Paquete

```
packages/hu-cli/
├── package.json
└── src/
    ├── index.js                    ← Entry point (commander)
    ├── commands/
    │   ├── list.js                 ← hu list
    │   ├── create.js               ← hu create
    │   ├── update.js               ← hu update
    │   ├── sync.js                 ← hu sync
    │   ├── advance.js              ← hu advance
    │   ├── assign.js               ← hu assign
    │   └── members.js              ← hu members
    ├── lib/
    │   ├── config.js               ← ORG, REPO, TEAM_MEMBERS, findMember()
    │   ├── files.js                ← getHuFiles(), setAssigneeInFile(), parseAssignee()
    │   └── github.js               ← GraphQL, gh CLI wrappers, setIssueAssignee()
    └── utils/
        └── output.js               ← ok, warn, err, info, head, dim
```

---

## Comandos Implementados

| Comando | Descripción |
|---------|-------------|
| `hu list [-s <estado>]` | Lista HUs con estado, tipo y asignado |
| `hu create [--draft]` | Crea issues desde archivos `.md` nuevos |
| `hu update <hu>` | Actualiza cuerpo del issue (solo Backlog / Ready) |
| `hu sync` | Crea nuevos + actualiza editables en un paso |
| `hu advance <hu> [-t <estado>]` | Mueve HU al siguiente estado o a uno específico |
| `hu assign <hu> <miembro>` | Asigna / reasigna miembro (actualiza `.md` + GitHub) |
| `hu members` | Lista el equipo con rol y célula |

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Listar HUs con filtro de estado

**Dado** que el proyecto tiene HUs en distintos estados  
**Cuando** se ejecuta `hu list -s progress`  
**Entonces:**
- Se muestran solo las HUs en estado `En Desarrollo / In Progress`.
- Cada fila incluye: código HU, módulo (truncado a 44 chars), estado coloreado, tipo (Issue / Draft) y asignado (`@username` o `—`).
- La búsqueda de estado es insensible a tildes y mayúsculas.

### Escenario 2 — Crear issue desde archivo `.md`

**Dado** que existe `docs/HU/HU 055 - ...md` sin issue correspondiente en GitHub  
**Cuando** se ejecuta `hu create`  
**Entonces:**
- Se crea un issue real en el repositorio con el título y cuerpo del archivo.
- El issue se agrega automáticamente al proyecto en estado `Backlog`.
- HUs ya existentes en GitHub no se duplican.

### Escenario 3 — Avanzar estado de una HU

**Dado** que `HU-040` está en `Listo para trabajar / Ready`  
**Cuando** se ejecuta `hu advance 40`  
**Entonces:**
- La HU pasa a `En Desarrollo / In Progress` en GitHub Projects.
- Se muestra el flujo visual con estado actual y destino resaltados.
- Con `--to revision` mueve a `En Revisión / In Review` directamente.

### Escenario 4 — Asignar miembro con búsqueda parcial

**Dado** que el equipo tiene 7 miembros registrados en `TEAM_MEMBERS`  
**Cuando** se ejecuta `hu assign 48 ospina`  
**Entonces:**
- Se resuelve `ospina` → `@dospina56-maker` (búsqueda parcial en username y nombre).
- El archivo `HU 048 - *.md` recibe / actualiza la línea `> **Asignado:** @dospina56-maker — David Ospina`.
- El GitHub Issue correspondiente queda con `dospina56-maker` como assignee.
- Si la HU tenía otro asignado, el anterior se remueve.

### Escenario 5 — `hu members` muestra el equipo

**Dado** que se ejecuta `hu members`  
**Entonces:**
- Se muestran 7 miembros agrupados en 2 células (Ingeniería, Infraestructura).
- Cada fila incluye username (cyan), nombre, rol (dim) y célula.

---

## Flujo de Estados

```
Pendientes / Backlog
  → Listo para trabajar / Ready
    → En Desarrollo / In Progress
      → En Revisión / In Review
        → Finalizado / Done
          → Archivado
```

---

## Instalación

```bash
npm install -w @ia-dataflow-hub/hu-cli
npm link -w @ia-dataflow-hub/hu-cli

# Autenticación gh
gh auth login
gh auth refresh -s project,read:project,write:org
```

---

## Tareas

1. [x] Scaffold del paquete con commander y ESM.
2. [x] `lib/github.js` — wrappers para `gh` CLI y GraphQL (getProjectData, listIssues, createIssue, addToProject, updateProjectStatus).
3. [x] `lib/files.js` — lectura de HU files desde `docs/HU/`, parseAssignee, setAssigneeInFile.
4. [x] Comando `hu list` con colores por estado y columna de asignado.
5. [x] Comando `hu create` y `hu create --draft`.
6. [x] Comando `hu update`.
7. [x] Comando `hu sync`.
8. [x] Comando `hu advance` con flujo visual y `--to`.
9. [x] `TEAM_MEMBERS` en config con 7 miembros y `findMember()` por búsqueda parcial.
10. [x] Comando `hu assign` — actualiza `.md` + GitHub issue assignees.
11. [x] Comando `hu members` — tabla agrupada por célula.
12. [ ] Tests unitarios para `findMember`, `parseAssignee`, `setAssigneeInFile`.
13. [ ] Soporte multi-asignado: `hu assign <hu> <m1> <m2>`.

---

## Notas Técnicas

- GraphQL se llama vía `gh api graphql --input <tmpfile>` para soportar queries largas sin límite de shell.
- `setAssigneeInFile` usa regex sobre el string completo del archivo para garantizar que no duplique la línea de asignado.
- `findMember` hace match exacto primero (username lowercase) y luego parcial (username o nombre) — evita ambigüedades en equipos pequeños.
- El campo `assignees(first: 5)` en el GraphQL cubre HUs con múltiples asignados sin romper la query.

## Prioridad

**Alta** — herramienta de productividad transversal a todo el equipo. Operativa desde HU-053.
