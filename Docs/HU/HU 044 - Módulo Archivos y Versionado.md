# HU-044 — Módulo de Archivos y Versionado

## Asignación de Tablas

`files` · `file_versions`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Archivos siguiendo Clean Architecture,  
**Para** gestionar la subida, almacenamiento referencial y el versionado de documentos vinculados a proyectos, conversaciones o mensajes, manteniendo trazabilidad completa del historial de cambios.

**Dependencia:** Requiere HU-043 (Projects) y HU-045 (Conversations) para las relaciones de FK.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/files/
├── files.module.ts
├── domain/
│   ├── entities/
│   │   ├── file.entity.ts
│   │   └── file-version.entity.ts
│   └── repositories/
│       └── file.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── upload-file.dto.ts
│   │   ├── create-file-version.dto.ts
│   │   ├── file-response.dto.ts
│   │   └── file-version-response.dto.ts
│   ├── use-cases/
│   │   ├── upload-file.use-case.ts
│   │   ├── create-file-version.use-case.ts
│   │   ├── get-file-versions.use-case.ts
│   │   └── soft-delete-file.use-case.ts
│   └── facades/
│       └── files.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── files.controller.ts
    └── persistence/
        ├── prisma-file.repository.ts
        └── mappers/
            └── file.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Subida de archivo con trazabilidad de chat

**Dado** que se recibe `UploadFileDto` con `id_project`, `id_conversation` e `id_message` opcionales  
**Cuando** `UploadFileUseCase` ejecuta  
**Entonces:**
- Valida que `id_project` exista y que el usuario tenga permiso `upload_files` en él (consulta `ProjectsFacade`).
- Persiste en `files` con `storage_path` referenciando la ubicación del archivo (URL o ruta interna), `file_type`, `file_size` y los FK opcionales `id_conversation` e `id_message`.
- Crea automáticamente el primer registro en `file_versions` con `version_number = 1`.
- Retorna `FileResponseDto` con todos los metadatos y la URL de acceso.

### Escenario 2 — Nueva versión de archivo existente

**Dado** que se recibe `CreateFileVersionDto` con `id_file` y nuevo `storage_path`  
**Cuando** `CreateFileVersionUseCase` ejecuta  
**Entonces:**
- Consulta el `MAX(version_number)` actual para ese `id_file` y asigna `version_number = MAX + 1`.
- Inserta en `file_versions` el nuevo registro.
- Actualiza `files.file_size`, `files.updated_at` y `files.updated_by` con los datos del nuevo upload.
- La constraint `uq_file_versions (id_file, version_number)` garantiza unicidad; si ocurre colisión por concurrencia, el repositorio reintenta con el siguiente número.

### Escenario 3 — Soft-delete de archivo con versiones

**Dado** que `SoftDeleteFileUseCase` recibe `id_file`  
**Cuando** el caso de uso ejecuta  
**Entonces:**
- Actualiza `files.deleted_at = now()` y `files.deleted_by`.
- **No elimina** los registros de `file_versions`; quedan accesibles para auditoría.
- Otros módulos que consulten archivos deben filtrar `WHERE deleted_at IS NULL`.
- Lanza `FileNotFoundException` si el `id_file` no existe o ya fue eliminado.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/projects/:projectId/files` | Subir archivo al proyecto |
| GET | `/projects/:projectId/files` | Listar archivos del proyecto |
| GET | `/files/:id` | Detalle de archivo |
| POST | `/files/:id/versions` | Crear nueva versión |
| GET | `/files/:id/versions` | Historial de versiones |
| DELETE | `/files/:id` | Soft-delete de archivo |

---

## Notas Técnicas

- Este módulo **no gestiona el almacenamiento físico** de archivos (S3, disco local, etc.); eso es responsabilidad de un servicio de storage inyectado vía interfaz (`StorageServiceInterface`). El módulo solo persiste los metadatos y rutas.
- `FileRepositoryInterface` es exportada y consumida por HU-047 (AI Jobs) y HU-048 (ETL) para vincular archivos a trabajos de IA y datasets.
- El controlador usa `@UseInterceptors(FileInterceptor('file'))` de NestJS para recibir el multipart/form-data.
