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

Muestra columnas: **HU · Pri · T (tamaño) · Módulo · Estado · Tipo · Asignado**

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

# Varias HUs a la vez
hu advance 56 57 58 59 -t archivado
hu advance 62 63 64              # Cada una avanza a su siguiente estado

# Atajo: archivar todos los Done
hu advance --all-done            # Archiva todas las HUs en "Finalizado / Done"
hu advance -A
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

### `hu priority` — Establecer prioridad de una o varias HUs

Actualiza la línea `> **Prioridad:**` en el archivo `.md` y asigna el campo **Priority** en GitHub Projects. Sin nivel muestra la tabla.

```bash
hu priority 40 urgent            # Urgente — Bloqueante
hu priority 40 high              # Alta — Crítica
hu priority 40 medium            # Media — Necesaria
hu priority 40 low               # Baja — Mejora

# Varias HUs a la vez (último arg = nivel)
hu priority 56 57 58 59 60 high
hu priority 62 63 64 65 66 67 medium

# Búsqueda parcial (español o inglés)
hu priority 40 urgen
hu priority 40 alta
hu priority 40 bloq
hu priority 40 medi

# Ver tabla de niveles disponibles
hu priority 40
```

### `hu size` — Establecer tamaño de una o varias HUs

Actualiza la línea `> **Tamaño:**` en el archivo `.md` y asigna el campo **Size** en GitHub Projects. Sin tamaño muestra la tabla.

```bash
hu size 40 XS                    # Trivial — < 2 horas
hu size 40 S                     # Simple — 2–4 horas
hu size 40 M                     # Estándar — 1 día
hu size 40 L                     # Complejo — 2–3 días
hu size 40 XL                    # Muy grande — 1 semana+

# Varias HUs a la vez (último arg = tamaño)
hu size 56 57 58 59 60 M
hu size 62 63 64 65 66 67 L

# Búsqueda parcial
hu size 40 xs
hu size 40 trivial
hu size 40 semana

# Ver tabla de tamaños
hu size 40
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

La prioridad se asigna como campo personalizado de selección única en GitHub Projects (igual que el campo Status). El campo debe llamarse **Priority** (o **Prioridad**) y tener opciones con nombres que incluyan: `urgent/urgente`, `high/alta`, `medium/media`, `low/baja`.

---

## Tamaños de HU

| T-shirt | Esfuerzo | Descripción |
|---------|----------|-------------|
| `XS` | < 2h | Trivial — fix de configuración, typo, ajuste menor |
| `S` | 2–4h | Simple — bug fix pequeño, endpoint sencillo |
| `M` | 4–8h | Estándar — un día completo, módulo pequeño |
| `L` | 2–3 días | Complejo — módulo completo, refactor significativo |
| `XL` | 1 sem+ | Muy grande — arquitectura, módulo pesado, integración externa |

El tamaño se asigna como campo personalizado de selección única en GitHub Projects (igual que Status y Priority). El campo debe llamarse **Size** (o **Tamaño**) con opciones: `XS`, `S`, `M`, `L`, `XL`.

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
> **Tamaño:** L — Complejo — 2 a 3 días (2–3 días)
```

Ambas líneas son opcionales e independientes. `hu assign` y `hu priority` las insertan o actualizan sin modificar el resto del contenido.

---

## Estructura del paquete

```
packages/hu-cli/src/
├── index.js
├── commands/
│   list · create · update · sync · advance · assign · members · priority · size
├── lib/
│   config    PRIORITIES, TEAM_MEMBERS, findPriority(), findMember()
│   files     getHuFiles(), findFileByHuNum(), setHuFileArchived()
│             parsePriority(), setPriorityInFile()
│             parseAssignee(), setAssigneeInFile()
│   github    getProjectData() (GraphQL con assignees + fieldValues)
│             getItemStatus(), getItemFieldValue(), updateProjectStatus()
│             setIssueAssignee(), createIssue(), updateIssueBody(), addToProject()
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
