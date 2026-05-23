# HU-064 — Testing de Endpoints — Módulo Archivos y Versionado

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

## Archivos Principales

`apps/api/src/modules/files/` · `apps/api/test/files/` · `apps/api/src/modules/files/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Archivos y Versionado (HU-044),  
**Para** garantizar que la subida, descarga, versionado y control de acceso de archivos funcionan correctamente y que nunca se expone un archivo de un proyecto al que el usuario no tiene acceso.

**Dependencia:** Requiere HU-044 implementada. El storage externo (S3/local) se mockea en pruebas.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/files/
├── application/use-cases/
│   ├── upload-file.use-case.spec.ts
│   ├── download-file.use-case.spec.ts
│   └── create-version.use-case.spec.ts
└── infrastructure/
    ├── controllers/files.controller.spec.ts
    └── storage/storage.adapter.spec.ts    ← mock del storage

apps/api/test/files/
├── files.integration.spec.ts
├── files.versioning.spec.ts              ← versionado
└── files.e2e.spec.ts
```

---

## Mock del Storage

```typescript
// test/mocks/storage.mock.ts
export const StorageMock = {
  upload:   jest.fn().mockResolvedValue({ key: 'files/mock-key', url: 'http://mock/file' }),
  download: jest.fn().mockResolvedValue(Buffer.from('contenido de prueba')),
  delete:   jest.fn().mockResolvedValue(true),
  exists:   jest.fn().mockResolvedValue(true),
}
```

---

## Pruebas Unitarias

### `upload-file.use-case.spec.ts`

```typescript
describe('UploadFileUseCase', () => {
  it('sube archivo y crea registro en DB con metadatos correctos', async () => {
    const result = await useCase.execute({
      projectId: 'p-1', uploadedBy: 'u-1',
      buffer: Buffer.from('test'), originalName: 'doc.pdf', mimeType: 'application/pdf'
    })
    expect(storage.upload).toHaveBeenCalledTimes(1)
    expect(fileRepo.create).toHaveBeenCalledWith(expect.objectContaining({
      originalName: 'doc.pdf', mimeType: 'application/pdf', uploadedBy: 'u-1'
    }))
    expect(result.id).toBeDefined()
  })

  it('lanza ForbiddenException si usuario no tiene acceso al proyecto', async () => {
    projectAccessService.hasAccess.mockResolvedValue(false)
    await expect(useCase.execute({ projectId: 'p-1', uploadedBy: 'u-99', ... }))
      .rejects.toThrow(ForbiddenException)
  })

  it('lanza BadRequestException si mimeType no está en lista blanca', async () => {
    await expect(useCase.execute({ ..., mimeType: 'application/x-executable' }))
      .rejects.toThrow(BadRequestException)
  })

  it('lanza BadRequestException si archivo supera tamaño máximo', async () => {
    const bigBuffer = Buffer.alloc(101 * 1024 * 1024) // 101 MB
    await expect(useCase.execute({ ..., buffer: bigBuffer }))
      .rejects.toThrow(BadRequestException)
  })

  it('crea versión 1 automáticamente en el primer upload', async () => {
    await useCase.execute({ ... })
    expect(versionRepo.create).toHaveBeenCalledWith(expect.objectContaining({ versionNumber: 1 }))
  })
})
```

### `create-version.use-case.spec.ts`

```typescript
describe('CreateVersionUseCase', () => {
  it('crea versión N+1 del archivo existente', async () => {
    versionRepo.getLatestVersion.mockResolvedValue({ versionNumber: 2 })
    const result = await useCase.execute({ fileId: 'f-1', uploadedBy: 'u-1', buffer: Buffer.from('v3') })
    expect(result.versionNumber).toBe(3)
  })

  it('mantiene todas las versiones anteriores — no elimina', async () => {
    await useCase.execute({ fileId: 'f-1', uploadedBy: 'u-1', buffer: Buffer.from('v3') })
    expect(storage.delete).not.toHaveBeenCalled()
  })

  it('lanza ForbiddenException si usuario no puede editar el archivo', async () => { ... })
})
```

---

## Pruebas de Integración

### `files.integration.spec.ts`

```typescript
describe('Files API — Integración', () => {
  // POST /api/projects/:projectId/files
  describe('POST /api/projects/:projectId/files — upload', () => {
    it('201 — sube archivo PDF válido', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/projects/${seedProject.id}/files`)
        .set('Authorization', `Bearer ${token}`)
        .attach('file', Buffer.from('contenido pdf'), { filename: 'doc.pdf', contentType: 'application/pdf' })
      expect(res.status).toBe(201)
      expect(res.body.data.originalName).toBe('doc.pdf')
      expect(res.body.data.versionNumber).toBe(1)
    })

    it('400 — tipo de archivo no permitido (.exe)', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/projects/${seedProject.id}/files`)
        .set('Authorization', `Bearer ${token}`)
        .attach('file', Buffer.from('virus'), { filename: 'virus.exe', contentType: 'application/x-executable' })
      expect(res.status).toBe(400)
    })

    it('400 — archivo demasiado grande', async () => { ... })
    it('403 — usuario sin acceso al proyecto', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // GET /api/projects/:projectId/files
  describe('GET /api/projects/:projectId/files', () => {
    it('200 — lista archivos del proyecto', async () => { ... })
    it('403 — usuario externo al proyecto', async () => { ... })
    it('200 — no retorna archivos de otros proyectos', async () => { ... })
  })

  // GET /api/files/:id/download
  describe('GET /api/files/:id/download', () => {
    it('200 — descarga archivo como stream/blob', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/files/${seedFile.id}/download`)
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      expect(res.headers['content-disposition']).toMatch(/attachment/)
    })
    it('403 — archivo de proyecto ajeno', async () => { ... })
    it('404 — archivo inexistente', async () => { ... })
  })

  // GET /api/files/:id/versions
  describe('GET /api/files/:id/versions', () => {
    it('200 — lista todas las versiones del archivo', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/files/${seedFile.id}/versions`)
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      expect(Array.isArray(res.body.data)).toBe(true)
      expect(res.body.data[0]).toHaveProperty('versionNumber')
    })
  })

  // POST /api/files/:id/versions — nueva versión
  describe('POST /api/files/:id/versions', () => {
    it('201 — sube nueva versión, incrementa versionNumber', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/files/${seedFile.id}/versions`)
        .set('Authorization', `Bearer ${token}`)
        .attach('file', Buffer.from('v2 content'), { filename: 'doc_v2.pdf', contentType: 'application/pdf' })
      expect(res.status).toBe(201)
      expect(res.body.data.versionNumber).toBe(2)
    })
    it('403 — usuario sin permiso de edición', async () => { ... })
  })

  // DELETE /api/files/:id
  describe('DELETE /api/files/:id', () => {
    it('200 — soft delete del archivo', async () => { ... })
    it('403 — no owner del archivo', async () => { ... })
  })
})
```

### `files.versioning.spec.ts`

```typescript
describe('Files — Versionado', () => {
  it('3 uploads del mismo archivo crean versiones 1, 2, 3', async () => {
    const fileId = await uploadAndGetId(app, token, seedProject.id, 'doc.pdf')
    await uploadNewVersion(app, token, fileId, 'doc_v2.pdf')
    await uploadNewVersion(app, token, fileId, 'doc_v3.pdf')

    const versions = await request(app.getHttpServer())
      .get(`/api/files/${fileId}/versions`).set('Authorization', `Bearer ${token}`)
    expect(versions.body.data.map((v: any) => v.versionNumber)).toEqual([1, 2, 3])
  })

  it('descargar versión anterior funciona correctamente', async () => {
    const res = await request(app.getHttpServer())
      .get(`/api/files/${fileId}/versions/1/download`)
      .set('Authorization', `Bearer ${token}`)
    expect(res.status).toBe(200)
  })

  it('eliminar archivo elimina todas las versiones', async () => {
    await request(app.getHttpServer())
      .delete(`/api/files/${fileId}`).set('Authorization', `Bearer ${token}`)
    const versions = await request(app.getHttpServer())
      .get(`/api/files/${fileId}/versions`).set('Authorization', `Bearer ${token}`)
    expect(versions.status).toBe(404)
  })
})
```

---

## Pruebas de Flujo (E2E)

```typescript
describe('Flujo completo — Upload, versiones y descarga', () => {
  it('Usuario sube archivo → crea versión 2 → descarga versión 1 → elimina archivo', async () => {
    // 1. Upload v1
    const upload = await uploadFile(app, token, projectId, 'reporte.pdf')
    const fileId = upload.id
    expect(upload.versionNumber).toBe(1)

    // 2. Upload v2
    const v2 = await uploadNewVersion(app, token, fileId, 'reporte_v2.pdf')
    expect(v2.versionNumber).toBe(2)

    // 3. Listar versiones
    const versions = await listVersions(app, token, fileId)
    expect(versions).toHaveLength(2)

    // 4. Descargar v1 específicamente
    const download = await request(app.getHttpServer())
      .get(`/api/files/${fileId}/versions/1/download`)
      .set('Authorization', `Bearer ${token}`)
    expect(download.status).toBe(200)

    // 5. Usuario externo no puede descargar
    const blocked = await request(app.getHttpServer())
      .get(`/api/files/${fileId}/download`)
      .set('Authorization', `Bearer ${externalToken}`)
    expect(blocked.status).toBe(403)
  })
})
```

---

## Tareas

1. [ ] Mock de storage (`StorageMock`) en `test/mocks/`.
2. [ ] Unitarias: upload, create-version, download.
3. [ ] Integración: upload con validación de tipo y tamaño.
4. [ ] Integración: versionado (versiones incrementales).
5. [ ] Integración: descarga de versión específica.
6. [ ] Integración: control de acceso por proyecto.
7. [ ] Suite de versionado: 3 versiones, descarga de anterior, eliminación en cascada.
8. [ ] E2E: ciclo completo.
9. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **Nunca llamar al storage real en pruebas**: usar `overrideProvider(StorageAdapter).useValue(StorageMock)`. Subir archivos reales en tests es lento, costoso y no determinístico.
- **Validar mimeType en el servidor**: el cliente puede mentir sobre el `Content-Type`. Verificar que el servidor detecta el tipo real con `file-type` o similar y rechaza ejecutables aunque vengan con `Content-Type: application/pdf`.
- **Descarga de versión anterior**: es el caso más olvidado. Siempre verificar que el endpoint `GET /files/:id/versions/:vn/download` existe y funciona.
- **Limpieza en afterAll**: los tests de upload crean registros en DB y referencias al mock de storage. Limpiar ambos en `afterAll` para no contaminar otras suites.

## Prioridad

**Alta** — archivos contienen datasets y documentación crítica del proyecto. Control de acceso incorrecto expone datos sensibles.
