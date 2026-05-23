# hu-cli — CLI de Gestión de HUs

CLI para gestionar Historias de Usuario en GitHub Projects desde la terminal.  
Ubicación: `packages/hu-cli/`

> Flujo de documentación:
> 1. Empieza en `README.md` raíz.
> 2. Ve a `docs/README.md` para el índice central.
> 3. Desde ahí abre esta guía `docs/packages/hu-cli.md`.

---

## Instalación (una sola vez)

```bash
npm install -w @ia-dataflow-hub/hu-cli
npm link -w @ia-dataflow-hub/hu-cli
```

---

## Prerrequisitos

```bash
gh auth login
gh auth refresh -s project,read:project,write:org
```

---

## Comandos

### `hu list` — Ver HUs con su estado

Muestra columnas: **HU · Prioridad · Módulo · Estado · Tipo · Asignado**

```bash
hu list                          # Todas las HUs activas
hu list --status Backlog         # Filtrar por estado (sin tildes, parcial)
hu list -s Progress
hu list -s Revision
```

### `hu advance` — Avanzar estado

Al llegar a **Done** o **Archivado**, el archivo `.md` se renombra automáticamente con prefijo `✅` y se mueve a `docs/HU/archivado/`. Si se revierte a un estado anterior, el archivo regresa a `docs/HU/` sin el prefijo.

```bash
hu advance 40                    # Siguiente estado del flujo
hu advance 40 --to Revision      # Estado específico (sin tildes, parcial)
hu advance 40 -t Done
hu advance 40 -t archivado       # Mueve a archivado + mueve archivo a docs/HU/archivado/
```

### `hu create` — Crear issues desde archivos .md

```bash
hu create                        # Issues reales en el repositorio
hu create --draft                # Drafts en el proyecto
```

### `hu update` — Actualizar contenido de una HU

Solo funciona si la HU está en **Backlog** o **Ready**.

```bash
hu update 40
hu update HU-048
```

### `hu sync` — Sincronización completa

```bash
hu sync                          # Crear nuevas + actualizar editables
```

### `hu assign` — Asignar miembro a una HU

Actualiza la línea `> **Asignado:**` en el archivo `.md` y el assignee en el issue de GitHub. Si ya tiene asignado, lo reemplaza.

```bash
hu assign 40 juandiegows         # Username exacto
hu assign 40 juan                # Búsqueda parcial por username o nombre
hu assign HU-048 ospina          # Nombre parcial
```

### `hu priority` — Establecer prioridad de una HU

Actualiza la línea `> **Prioridad:**` en el archivo `.md` y asigna el label correspondiente en GitHub. Sin segundo argumento muestra la tabla de niveles.

```bash
hu priority 40 urgent            # Urgente — Bloqueante
hu priority 40 high              # Alta — Crítica
hu priority 40 medium            # Media — Necesaria
hu priority 40 low               # Baja — Mejora

# Búsqueda parcial (español o inglés)
hu priority 40 urgen
hu priority 40 alta
hu priority 40 bloq
hu priority 40 medi

# Ver tabla de niveles disponibles
hu priority 40
```

### `hu members` — Ver equipo

```bash
hu members                       # Lista todos los miembros con rol y célula
```

---

## Niveles de prioridad

| Código | Nivel | Descripción |
|--------|-------|-------------|
| `URG` | 🔴 Urgent / Urgente | **Bloqueante** — impide que el equipo avance. El proyecto se detiene sin esto. |
| `ALT` | 🟠 High / Alta | **Crítica** — debe estar lista para la próxima entrega o hito con el profesor Bareño. |
| `MED` | 🟡 Medium / Media | **Necesaria** — añade valor pero no detiene el desarrollo del core del sistema. |
| `BAJ` | 🟢 Low / Baja | **Mejora** — estético o deseable; puede esperar hasta que lo principal sea estable. |

Los labels se crean automáticamente en GitHub la primera vez que se asigna una prioridad.

---

## Flujo de estados

```
Pendientes / Backlog
  → Listo para trabajar / Ready
    → En Desarrollo / In Progress
      → En Revisión / In Review
        → Finalizado / Done          ← archivo renombrado ✅ y movido a archivado/
          → Archivado                ← ídem
```

| Estado | `hu update` | `hu advance` | Archivo `.md` |
|--------|-------------|--------------|---------------|
| Pendientes / Backlog | ✏ Sí | ✓ | `docs/HU/HU NNN - *.md` |
| Listo para trabajar / Ready | ✏ Sí | ✓ | `docs/HU/HU NNN - *.md` |
| En Desarrollo / In Progress | ✗ No | ✓ | `docs/HU/HU NNN - *.md` |
| En Revisión / In Review | ✗ No | ✓ | `docs/HU/HU NNN - *.md` |
| Finalizado / Done | ✗ No | ✓ | `docs/HU/archivado/✅ HU NNN - *.md` |
| Archivado | ✗ No | ✓ | `docs/HU/archivado/✅ HU NNN - *.md` |

---

## Metadatos en archivos `.md`

Cada HU puede tener estas líneas de metadatos al inicio, justo después del título `# HU-NNN`:

```markdown
# HU-040 — Módulo de Autenticación y Gestión de Sesiones

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre
> **Prioridad:** 🔴 Urgent / Urgente — Bloqueante
```

Ambas líneas son opcionales e independientes. `hu assign` y `hu priority` las insertan o actualizan sin modificar el resto del contenido.

---

## Estructura del paquete

```
packages/hu-cli/src/
├── index.js
├── commands/
│   list · create · update · sync · advance · assign · members · priority
├── lib/
│   config    PRIORITIES, TEAM_MEMBERS, findPriority(), findMember()
│   files     getHuFiles(), findFileByHuNum(), setHuFileArchived()
│             parsePriority(), setPriorityInFile()
│             parseAssignee(), setAssigneeInFile()
│   github    getProjectData() (GraphQL con assignees + labels)
│             setIssueAssignee(), setIssuePriority(), ensurePriorityLabels()
│             createIssue(), updateIssueBody(), addToProject()
└── utils/    output  (ok · warn · err · info · head · dim)
```

---

## Estructura de `docs/HU/`

```
docs/HU/
├── HU NNN - Título.md          ← HUs activas (Backlog → In Review)
└── archivado/
    └── ✅ HU NNN - Título.md   ← HUs completadas (Done / Archivado)
```

`hu list` solo muestra HUs activas. Las archivadas quedan en `archivado/` para consulta histórica.

---

## Equipo

| Célula | Username | Nombre | Rol |
|--------|----------|--------|-----|
| Ingeniería | @juandiegows | Juan Diego Mejía Maestre | Analista y Desarrollador |
| Ingeniería | @dospina56-maker | David Ospina | Tecnólogo en Desarrollo |
| Ingeniería | @andres-andrade5 | Andres Felipe Andrade | Analista de TI |
| Ingeniería | @oantury-glitch | Oscar Antury Avila | Tecnólogo en Multimedia |
| Infraestructura | @sbautista15 | Sebastián Bautista Martínez | Consultor Infraestructura y DBA |
| Infraestructura | @POHLMAN1 | Pohlman Cuartas | Ingeniero de Soporte |
| Infraestructura | @mlabarca-jpg | María Virginia Labarca | Analista de TI |

> Brayan Monterrosa Castillo — sin username GitHub registrado. Agregar en `packages/hu-cli/src/lib/config.js` → `TEAM_MEMBERS` cuando esté disponible.
