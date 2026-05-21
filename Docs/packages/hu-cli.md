# hu-cli — CLI de Gestión de HUs

CLI para gestionar Historias de Usuario en GitHub Projects desde la terminal.  
Ubicación: `packages/hu-cli/`

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

```bash
hu list                          # Todas las HUs
hu list --status Backlog         # Filtrar por estado (sin tildes, parcial)
hu list -s Progress
hu list -s Revision
```

### `hu advance` — Avanzar estado

```bash
hu advance 40                    # Siguiente estado del flujo
hu advance 40 --to Revision      # Estado específico (sin tildes, parcial)
hu advance 40 -t Done
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

---

## Flujo de estados

```
Pendientes / Backlog
  → Listo para trabajar / Ready
    → En Desarrollo / In Progress
      → En Revisión / In Review
        → Finalizado / Done
          → Archivado
```

| Estado | `hu update` | `hu advance` |
|--------|-------------|--------------|
| Pendientes / Backlog | ✏ Sí | ✓ |
| Listo para trabajar / Ready | ✏ Sí | ✓ |
| En Desarrollo / In Progress | 🔒 No | ✓ |
| En Revisión / In Review | 🔒 No | ✓ |
| Finalizado / Done | 🔒 No | ✓ |
| Archivado | 🔒 No | ✓ |

---

## Estructura del paquete

```
packages/hu-cli/src/
├── index.js
├── commands/   list · create · update · sync · advance
├── lib/        config · files · github
└── utils/      output
```
