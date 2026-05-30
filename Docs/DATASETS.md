# Gestión de Datasets con DVC

Los datasets **no se guardan en git**. Se versionan con [DVC](https://dvc.org) y se almacenan en Google Drive.

## Cómo funciona

```
Git (GitHub)          DVC (Google Drive)
─────────────         ─────────────────────
datasets.dvc   ──────► files/md5/...  (archivos reales)
  (puntero ~1KB)
```

- `git push/pull` sincroniza el código y los punteros
- `dvc push/pull` sincroniza los archivos de datos reales

---

## Setup inicial (una sola vez por máquina)

### 1. Instalar DVC

```bash
pip install "dvc[gdrive]"
```

### 2. Clonar el repo

```bash
git clone git@github.com:IA-DataFlow-Hub/IA-DataFlow-Hub.git
cd IA-DataFlow-Hub
```

### 3. Configurar credenciales de Google Drive

Pídele al líder del proyecto el archivo `dvc-service-account.json` y guárdalo localmente (nunca lo subas a git).

```bash
dvc remote modify --local gdrive gdrive_use_service_account false
dvc remote modify --local gdrive gdrive_client_id "pongo el clientId del archivo que me paso el lider"
dvc remote modify --local gdrive gdrive_client_secret "pongo el client_secret del archivo que me paso el lider"
```

### 4. Descargar los datasets

```bash
dvc pull
```

Los archivos aparecerán en `datasets/` con la estructura original.

---

## Flujo de trabajo diario

### Descargar datos actualizados

```bash
git pull
dvc pull
```

### Agregar o actualizar datasets

```bash
# 1. Coloca los archivos nuevos en datasets/
# 2. Registra los cambios en DVC
dvc add datasets/

# 3. Sube los datos a Google Drive
dvc push

# 4. Sube el puntero actualizado a GitHub
git add datasets.dvc
git commit -m "datos: descripcion de los datasets agregados"
git push
```

### Verificar qué hay en el remote

```bash
dvc status -c
```

---

## Estructura de carpetas

```
datasets/
├── Buscados/
│   ├── Excel csv/
│   │   ├── CSV/          # Datasets públicos en formato CSV
│   │   └── Excel/        # Datasets públicos en formato Excel
│   └── json/             # Datasets en formato JSON
└── Generados/            # Datasets generados por el chaos-generator
    ├── csv/
    ├── json/
    ├── log/
    ├── pdf/
    └── xml/
```

---

## Comandos de referencia

| Comando | Descripción |
|---|---|
| `dvc pull` | Descargar datasets desde Google Drive |
| `dvc push` | Subir datasets a Google Drive |
| `dvc add datasets/` | Registrar cambios en los datos |
| `dvc status` | Ver si los datos locales están desactualizados |
| `dvc status -c` | Comparar datos locales vs remote |

---

## Acceso al Google Drive

La carpeta de almacenamiento es privada. Para acceder contacta al líder del proyecto para que comparta el archivo `dvc-service-account.json`.


---

## Documentos relacionados

**Datos:** [[csv-retail]] · [[chaos-generator]] · [[CHAOS_GENERATOR]]
**Diagramas:** [[02-flujo-procesamiento-ia]]
**HUs:** [[✅ HU 015 - Clasificación de Dataset de Caos para Entrenamiento de IA|HU-015]] · [[✅ HU 054 - Versionado de Datasets con DVC|HU-054]] · [[HU 038 - Fine-Tuning y Preparación de Datasets de IA|HU-038]]
