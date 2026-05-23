# HU-054 — Versionado de Datasets con DVC

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

## Archivos Principales

`.dvc/` · `.dvcignore` · `data/` · `datasets/` · `.gitignore` (entradas DVC) · `dvc.yaml`

---

## Historia de Usuario

**Como** desarrollador de IA del equipo,  
**Quiero** versionar los datasets de entrenamiento y los modelos con DVC (Data Version Control),  
**Para** rastrear cambios en los datos junto con el código en Git, reproducir experimentos en cualquier punto del historial y compartir datasets pesados sin subirlos directamente a GitHub.

**Dependencia:** Requiere acceso a almacenamiento remoto (S3, GCS, SSH o local compartido) o al menos configuración local funcional.

---

## Contexto

El proyecto IA-DataFlow-Hub genera y consume datasets de gran tamaño (130+ archivos caóticos, modelos fine-tuned, datasets de entrenamiento para múltiples épocas). Git no es adecuado para archivos binarios o CSVs de varios GB. DVC extiende Git para datos: almacena punteros (`.dvc` files) en Git y los datos reales en un storage remoto o caché local. Esto permite `dvc pull` para obtener los datos y `git checkout` para navegar entre versiones del experimento completo.

---

## Estructura de Archivos

```
/
├── .dvc/
│   ├── config                      ← remote storage config
│   └── .gitignore
├── .dvcignore                      ← equivalente a .gitignore para DVC
├── data/
│   ├── raw/                        ← datos originales (trackeados por DVC)
│   ├── processed/                  ← datos procesados (trackeados por DVC)
│   └── .gitignore                  ← excluye los archivos pesados de Git
├── datasets/                       ← output del chaos-generator (trackeado por DVC)
│   └── .gitignore
├── models/                         ← checkpoints y modelos exportados
│   └── .gitignore
└── dvc.yaml                        ← pipeline de etapas (opcional para reproducibilidad)
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Inicialización y primer track

**Dado** que DVC está instalado (`pip install dvc`)  
**Cuando** se ejecuta `dvc init` y `dvc add datasets/`  
**Entonces:**
- Se crea `datasets/.gitignore` con la carpeta excluida de Git.
- Se crea `datasets.dvc` con el hash MD5 del contenido actual.
- `git status` muestra solo `datasets.dvc` y `.gitignore` como cambios.

### Escenario 2 — Push al remoto

**Dado** que hay un remote configurado (`dvc remote add`)  
**Cuando** se ejecuta `dvc push`  
**Entonces:**
- Los archivos de `datasets/` se suben al storage remoto.
- `git push` solo empuja los punteros `.dvc` (ligeros).

### Escenario 3 — Reproducir versión anterior

**Dado** que existe un commit de Git con estado anterior del dataset  
**Cuando** se ejecuta `git checkout <sha> datasets.dvc && dvc checkout`  
**Entonces:**
- `datasets/` contiene exactamente los archivos de ese commit.
- Sin necesidad de re-ejecutar el pipeline de generación.

### Escenario 4 — Pipeline reproducible (dvc.yaml)

**Dado** que `dvc.yaml` define etapas (preprocess → train → evaluate)  
**Cuando** se ejecuta `dvc repro`  
**Entonces:**
- Solo se re-ejecutan las etapas cuyos inputs cambiaron (cache hit en el resto).
- `dvc dag` muestra el grafo de dependencias completo.

### Escenario 5 — `.gitignore` correctos

**Dado** que `dvc add` crea los punteros  
**Entonces:**
- `git status` no muestra los archivos pesados como untracked.
- `dvc status` muestra si hay cambios locales no commiteados.

---

## Instalación y Configuración

```bash
pip install dvc

# Inicializar en el repo
dvc init
git add .dvc .dvcignore
git commit -m "chore: init DVC"

# Trackear datasets
dvc add datasets/
dvc add data/raw/

# Configurar remote (ejemplo: local)
dvc remote add -d localremote /path/to/shared/storage
dvc remote add -d s3remote s3://bucket/ia-dataflow-dvc

# Push inicial
dvc push
```

---

## Comandos Frecuentes

```bash
dvc status          # diferencias entre working dir y caché
dvc pull            # bajar datos del remoto (tras git pull)
dvc push            # subir datos al remoto (antes de git push)
dvc repro           # re-ejecutar pipeline si inputs cambiaron
dvc dag             # visualizar grafo del pipeline
dvc gc -w           # limpiar caché no referenciado por workspace actual
```

---

## Integración con Git

El flujo estándar del equipo con DVC:

```bash
# Antes de push
dvc add datasets/nuevos_datos/
git add datasets.dvc
git commit -m "feat(data): agrega dataset v3 con 130 archivos"
dvc push
git push
```

```bash
# Al clonar / después de pull
git pull
dvc pull
```

---

## Tareas

1. [x] `dvc init` ejecutado y archivos `.dvc/` commiteados.
2. [x] `dvc add` aplicado a `datasets/` y `data/raw/`.
3. [x] `.gitignore` generados automáticamente en cada carpeta trackeada.
4. [ ] Configurar remote de producción (S3 / GCS / SSH) en `.dvc/config`.
5. [ ] Documentar credenciales del remote en variables de entorno del equipo.
6. [ ] Definir `dvc.yaml` con etapas de pipeline para chaos-generator (HU-015) y fine-tuning (HU-038, HU-039).
7. [ ] Agregar `dvc pull` al onboarding de nuevos miembros del equipo.
8. [ ] CI: agregar step `dvc pull` antes de los jobs de entrenamiento.

---

## Notas Técnicas

- DVC almacena en `.dvc/cache/` localmente usando content-addressable storage (MD5). Nunca commiter la caché.
- `dvc add` es idempotente: re-ejecutar actualiza el `.dvc` file solo si el contenido cambió.
- Para LFS vs DVC: preferir DVC cuando los datos cambian frecuentemente o superan los 2 GB — Git LFS no soporta checkout parcial ni reproducibilidad de experimentos.
- Compatible con GitHub Actions: usar `iterative/setup-dvc` action + secretos de AWS/GCP.

## Prioridad

**Alta** — prerequisito para reproducibilidad de experimentos de IA (HU-038, HU-039). Sin DVC, no hay garantía de que dos ejecuciones del mismo pipeline produzcan el mismo resultado.
