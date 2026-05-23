# HU-055 — Sincronización Automática de la Carpeta docs

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

## Archivos Principales

`.github/workflows/sync-docs.yml` · `scripts/sync-docs.js` (si aplica) · `docs/` · `.gitignore`

---

## Historia de Usuario

**Como** miembro del equipo,  
**Quiero** que los cambios en la carpeta `docs/` se sincronicen automáticamente al repositorio remoto,  
**Para** que la documentación siempre refleje el estado actual del proyecto sin requerir commits manuales separados, y cualquier miembro pueda consultar la versión más reciente sin `git pull` frecuentes.

**Dependencia:** Requiere acceso de escritura al repositorio y GitHub Actions habilitado.

---

## Contexto

La carpeta `docs/` concentra HUs, diagramas, guías de paquetes y el índice central. Con un equipo distribuido, es frecuente que cambios en documentación queden sin pushear durante horas, generando divergencias entre lo que el equipo ve localmente y lo que está en GitHub. La sincronización automática elimina esta fricción: cualquier cambio guardado en `docs/` se refleja en el repositorio de forma transparente.

---

## Estructura Relevante

```
.github/
└── workflows/
    └── sync-docs.yml               ← workflow de sincronización automática

docs/
├── README.md                       ← índice central de documentación
├── HU/                             ← historias de usuario (*.md)
├── packages/                       ← guías por paquete
├── diagramas/                      ← diagramas de arquitectura
└── setup/                          ← guías de configuración
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Sincronización en push a main

**Dado** que se hace `git push` con cambios en `docs/`  
**Cuando** el workflow `sync-docs.yml` se dispara  
**Entonces:**
- GitHub Actions detecta los cambios en `docs/**`.
- El job completa sin errores y los archivos quedan disponibles en la rama `main`.
- No se crean commits duplicados si no hubo cambios reales.

### Escenario 2 — Trigger solo en cambios de docs

**Dado** que se hace push con cambios solo en `packages/` (sin tocar `docs/`)  
**Cuando** el workflow evalúa el path filter  
**Entonces:**
- El workflow no se dispara (o se omite el job de sync) para evitar ejecuciones innecesarias.
- Los cambios en `docs/` en el mismo push sí activan el sync.

### Escenario 3 — Sincronización periódica (schedule)

**Dado** que el workflow tiene un trigger `schedule` configurado  
**Cuando** se cumple el cron (ej. cada hora / cada día)  
**Entonces:**
- Se verifica si hay cambios pendientes en `docs/` no commiteados.
- Si los hay, se crea un commit automático con mensaje estándar.
- Si no hay cambios, el job termina limpio (`nothing to commit`).

### Escenario 4 — Commit automático con mensaje descriptivo

**Dado** que el sync detecta cambios en `docs/`  
**Cuando** crea el commit automático  
**Entonces:**
- El mensaje sigue el formato: `docs: auto-sync [fecha ISO]` o similar.
- El commit author es el bot de GitHub Actions (`github-actions[bot]`).
- Los cambios son atómicos: todos los archivos modificados en `docs/` van en un solo commit.

### Escenario 5 — Sin conflictos con trabajo manual

**Dado** que un miembro empujó cambios manuales a `docs/` y el auto-sync se dispara simultáneamente  
**Entonces:**
- El workflow hace `git pull --rebase` antes de commitear para evitar conflictos.
- Si hay conflicto real, el workflow falla con error claro (no silencioso) para que el miembro lo resuelva.

---

## Configuración del Workflow

```yaml
# .github/workflows/sync-docs.yml
name: Sync docs

on:
  push:
    paths:
      - 'docs/**'
    branches:
      - main
  schedule:
    - cron: '0 * * * *'   # cada hora
  workflow_dispatch:       # trigger manual

jobs:
  sync:
    runs-on: ubuntu-latest
    permissions:
      contents: write

    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          token: ${{ secrets.GITHUB_TOKEN }}

      - name: Check for docs changes
        id: changes
        run: |
          git diff --name-only HEAD~1 HEAD -- docs/ || echo "no-prev-commit"
          echo "changed=$(git diff --name-only HEAD~1 HEAD -- docs/ | wc -l)" >> $GITHUB_OUTPUT

      - name: Commit and push if docs changed
        if: steps.changes.outputs.changed != '0'
        run: |
          git config user.name  "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add docs/
          git diff --cached --quiet || git commit -m "docs: auto-sync $(date -u +%Y-%m-%dT%H:%M:%SZ)"
          git pull --rebase origin main
          git push origin main
```

---

## Tareas

1. [x] Carpeta `docs/` con estructura base consolidada.
2. [x] `.github/workflows/sync-docs.yml` creado con trigger en `push` a `docs/**`.
3. [ ] Agregar trigger `schedule` (cron horario o diario según acuerdo del equipo).
4. [ ] Agregar `workflow_dispatch` para sync manual desde GitHub UI.
5. [ ] Validar que el workflow no genera commits vacíos con `git diff --cached --quiet`.
6. [ ] Documentar el comportamiento de auto-sync en `docs/README.md`.
7. [ ] Revisar permisos `contents: write` en la configuración del repositorio.
8. [ ] Evaluar si agregar `docs/diagramas/**` al path filter de forma separada (diagramas generados por herramientas externas).

---

## Notas Técnicas

- `permissions: contents: write` es obligatorio para que el bot pueda hacer push. Sin esto, el paso de push falla con 403.
- `fetch-depth: 0` en `actions/checkout` asegura el historial completo para `git diff HEAD~1`.
- Si el repositorio tiene protección de rama en `main`, puede ser necesario usar un PAT (Personal Access Token) con permisos de bypass, o crear una rama `docs/auto-sync` que se mergea automáticamente.
- Para repos con mucha actividad en `docs/`, considerar `schedule` con cron más espaciado (cada 6h) para reducir consumo de minutos de GitHub Actions.
- El auto-sync NO reemplaza los commits descriptivos del equipo: es un fallback para que ningún cambio quede perdido.

## Prioridad

**Media** — mejora la consistencia de la documentación sin bloquear ningún módulo funcional. Implementar en paralelo con cualquier HU de desarrollo activa.
