# HU-059 — Testing de Endpoints — Módulo Perfil de Usuario y Configuración

> **Asignado:** @dospina56-maker — David Ospina

## Archivos Principales

`apps/api/src/modules/users/` · `apps/api/test/users/` · `apps/api/src/modules/users/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Perfil de Usuario y Configuración (HU-041),  
**Para** garantizar que los endpoints de consulta y edición del perfil funcionan correctamente, que cada usuario solo puede ver y modificar su propio perfil y que las configuraciones personales se persisten sin afectar a otros usuarios.

**Dependencia:** Requiere HU-041 implementada. Requiere HU-040 (Auth) operativa para obtener tokens de prueba.

---

## Contexto

El módulo de Perfil es el más accedido del sistema — cada sesión activa consulta el perfil del usuario autenticado. Los errores aquí (datos cruzados entre usuarios, configuraciones que no persisten, avatar que sobreescribe el de otro) tienen alto impacto visible. El foco de las pruebas es la **aislación entre usuarios** y la correcta persistencia de configuraciones clave-valor.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/users/
├── application/
│   ├── use-cases/
│   │   ├── get-profile.use-case.spec.ts            ← unitaria
│   │   ├── update-profile.use-case.spec.ts         ← unitaria
│   │   └── update-configuration.use-case.spec.ts   ← unitaria
│   └── services/
│       └── users.service.spec.ts                   ← unitaria
└── infrastructure/
    └── controllers/
        └── users.controller.spec.ts                ← unitaria

apps/api/test/
└── users/
    ├── users.integration.spec.ts                   ← integración
    └── users.e2e.spec.ts                           ← flujo completo
```

---

## Pruebas Unitarias

### `get-profile.use-case.spec.ts`

```typescript
describe('GetProfileUseCase', () => {
  it('retorna perfil completo del usuario autenticado', async () => {
    repo.findById.mockResolvedValue(seedUser)
    const result = await useCase.execute({ userId: seedUser.id })
    expect(result.id).toBe(seedUser.id)
    expect(result.email).toBe(seedUser.email)
  })

  it('no retorna el campo passwordHash en la respuesta', async () => {
    repo.findById.mockResolvedValue({ ...seedUser, passwordHash: 'hash-secreto' })
    const result = await useCase.execute({ userId: seedUser.id })
    expect(result).not.toHaveProperty('passwordHash')
  })

  it('lanza NotFoundException si userId no existe', async () => {
    repo.findById.mockResolvedValue(null)
    await expect(useCase.execute({ userId: 'no-existe' })).rejects.toThrow(NotFoundException)
  })
})
```

### `update-profile.use-case.spec.ts`

```typescript
describe('UpdateProfileUseCase', () => {
  it('actualiza fullName correctamente', async () => {
    const result = await useCase.execute({ userId: 'u-1', fullName: 'Nuevo Nombre' })
    expect(repo.update).toHaveBeenCalledWith('u-1', expect.objectContaining({ fullName: 'Nuevo Nombre' }))
  })

  it('lanza ForbiddenException si userId del token ≠ userId del recurso', async () => {
    await expect(useCase.execute({ userId: 'u-1', targetUserId: 'u-2', fullName: 'X' }))
      .rejects.toThrow(ForbiddenException)
  })

  it('no permite actualizar el campo email desde este endpoint', async () => {
    await useCase.execute({ userId: 'u-1', email: 'nuevo@test.com' } as any)
    expect(repo.update).not.toHaveBeenCalledWith(expect.anything(), expect.objectContaining({ email: expect.anything() }))
  })

  it('no permite actualizar el campo role', async () => {
    await useCase.execute({ userId: 'u-1', role: 'admin' } as any)
    expect(repo.update).not.toHaveBeenCalledWith(expect.anything(), expect.objectContaining({ role: 'admin' }))
  })
})
```

### `update-configuration.use-case.spec.ts`

```typescript
describe('UpdateConfigurationUseCase', () => {
  it('crea configuración nueva si clave no existe', async () => {
    configRepo.findByKey.mockResolvedValue(null)
    await useCase.execute({ userId: 'u-1', key: 'theme', value: 'dark' })
    expect(configRepo.create).toHaveBeenCalledWith({ userId: 'u-1', key: 'theme', value: 'dark' })
  })

  it('actualiza configuración existente si clave ya existe', async () => {
    configRepo.findByKey.mockResolvedValue({ id: 'c-1', key: 'theme', value: 'light' })
    await useCase.execute({ userId: 'u-1', key: 'theme', value: 'dark' })
    expect(configRepo.update).toHaveBeenCalledWith('c-1', { value: 'dark' })
    expect(configRepo.create).not.toHaveBeenCalled()
  })

  it('lanza BadRequestException si key está en lista negra (role, passwordHash, etc.)', async () => {
    await expect(useCase.execute({ userId: 'u-1', key: 'role', value: 'admin' }))
      .rejects.toThrow(BadRequestException)
  })
})
```

---

## Pruebas de Integración

### `users.integration.spec.ts`

```typescript
describe('Users API — Integración', () => {
  let app: INestApplication
  let userAToken: string
  let userBToken: string

  beforeAll(async () => {
    // Crear dos usuarios para probar aislación
    userAToken = await getAuthToken(app, { email: 'userA@test.com', password: 'PassA123!' })
    userBToken = await getAuthToken(app, { email: 'userB@test.com', password: 'PassB123!' })
  })

  // GET /api/users/me
  describe('GET /api/users/me', () => {
    it('200 — retorna perfil del usuario autenticado', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
      expect(res.status).toBe(200)
      expect(res.body.data.email).toBe('userA@test.com')
      expect(res.body.data).not.toHaveProperty('passwordHash')
    })

    it('401 — sin token', async () => {
      const res = await request(app.getHttpServer()).get('/api/users/me')
      expect(res.status).toBe(401)
    })

    it('no retorna datos de userB cuando se autentica como userA', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
      expect(res.body.data.email).not.toBe('userB@test.com')
    })
  })

  // PATCH /api/users/me
  describe('PATCH /api/users/me', () => {
    it('200 — actualiza fullName', async () => {
      const res = await request(app.getHttpServer())
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ fullName: 'Juan Actualizado' })
      expect(res.status).toBe(200)
      expect(res.body.data.fullName).toBe('Juan Actualizado')
    })

    it('400 — fullName vacío rechazado', async () => {
      const res = await request(app.getHttpServer())
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ fullName: '' })
      expect(res.status).toBe(400)
    })

    it('400 — no permite actualizar email desde este endpoint', async () => {
      const res = await request(app.getHttpServer())
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ email: 'hack@test.com' })
      // email debe ser ignorado o rechazado — nunca actualizado
      const profile = await request(app.getHttpServer())
        .get('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
      expect(profile.body.data.email).toBe('userA@test.com')
    })

    it('400 — no permite escalar rol a admin', async () => {
      const res = await request(app.getHttpServer())
        .patch('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ role: 'admin' })
      const profile = await request(app.getHttpServer())
        .get('/api/users/me')
        .set('Authorization', `Bearer ${userAToken}`)
      expect(profile.body.data.role).not.toBe('admin')
    })

    it('401 — sin token', async () => { ... })
  })

  // GET /api/users/:id (público o admin)
  describe('GET /api/users/:id', () => {
    it('200 — admin puede ver cualquier perfil', async () => { ... })
    it('200 — usuario puede ver su propio perfil por ID', async () => { ... })
    it('403 — usuario no puede ver perfil ajeno (si no es público)', async () => { ... })
    it('404 — ID inexistente', async () => { ... })
  })

  // GET /api/users/me/configurations
  describe('GET /api/users/me/configurations', () => {
    it('200 — retorna configuraciones del usuario', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/users/me/configurations')
        .set('Authorization', `Bearer ${userAToken}`)
      expect(res.status).toBe(200)
      expect(Array.isArray(res.body.data)).toBe(true)
    })

    it('no retorna configuraciones de otros usuarios', async () => {
      // Crear config para userB
      await request(app.getHttpServer())
        .put('/api/users/me/configurations/theme')
        .set('Authorization', `Bearer ${userBToken}`)
        .send({ value: 'dark' })
      // userA no debe ver la config de userB
      const res = await request(app.getHttpServer())
        .get('/api/users/me/configurations')
        .set('Authorization', `Bearer ${userAToken}`)
      const configs = res.body.data
      expect(configs.every((c: any) => c.userId === seedUserA.id)).toBe(true)
    })
  })

  // PUT /api/users/me/configurations/:key
  describe('PUT /api/users/me/configurations/:key', () => {
    it('200 — crea configuración nueva', async () => {
      const res = await request(app.getHttpServer())
        .put('/api/users/me/configurations/language')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ value: 'es' })
      expect(res.status).toBe(200)
      expect(res.body.data.key).toBe('language')
      expect(res.body.data.value).toBe('es')
    })

    it('200 — actualiza configuración existente (upsert)', async () => {
      await request(app.getHttpServer())
        .put('/api/users/me/configurations/language')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ value: 'en' })
      const res = await request(app.getHttpServer())
        .get('/api/users/me/configurations')
        .set('Authorization', `Bearer ${userAToken}`)
      const lang = res.body.data.find((c: any) => c.key === 'language')
      expect(lang.value).toBe('en')
    })

    it('400 — key en lista negra rechazada (role, passwordHash)', async () => {
      const res = await request(app.getHttpServer())
        .put('/api/users/me/configurations/role')
        .set('Authorization', `Bearer ${userAToken}`)
        .send({ value: 'admin' })
      expect(res.status).toBe(400)
    })
  })
})
```

---

## Pruebas de Flujo (E2E)

### `users.e2e.spec.ts`

```typescript
describe('Flujo completo — Perfil y Configuración', () => {
  it('Usuario actualiza perfil → verifica cambios → actualiza configuraciones → las configuraciones persisten entre sesiones', async () => {
    // 1. Obtener perfil inicial
    const initial = await request(app.getHttpServer())
      .get('/api/users/me').set('Authorization', `Bearer ${token}`)
    expect(initial.body.data.fullName).toBe('Test User')

    // 2. Actualizar perfil
    await request(app.getHttpServer())
      .patch('/api/users/me')
      .set('Authorization', `Bearer ${token}`)
      .send({ fullName: 'Nombre Actualizado', bio: 'Bio de prueba' })

    // 3. Verificar cambios
    const updated = await request(app.getHttpServer())
      .get('/api/users/me').set('Authorization', `Bearer ${token}`)
    expect(updated.body.data.fullName).toBe('Nombre Actualizado')
    expect(updated.body.data.bio).toBe('Bio de prueba')

    // 4. Guardar configuraciones
    await request(app.getHttpServer())
      .put('/api/users/me/configurations/theme')
      .set('Authorization', `Bearer ${token}`)
      .send({ value: 'dark' })
    await request(app.getHttpServer())
      .put('/api/users/me/configurations/language')
      .set('Authorization', `Bearer ${token}`)
      .send({ value: 'es' })

    // 5. Nueva sesión (nuevo token) — configuraciones persisten
    const newToken = await getAuthToken(app, { email: seedUser.email, password: 'TestPass123!' })
    const configs = await request(app.getHttpServer())
      .get('/api/users/me/configurations')
      .set('Authorization', `Bearer ${newToken}`)
    const theme = configs.body.data.find((c: any) => c.key === 'theme')
    expect(theme.value).toBe('dark')
  })

  it('UserA no puede ver ni modificar el perfil de UserB', async () => {
    const res = await request(app.getHttpServer())
      .patch(`/api/users/${seedUserB.id}`)
      .set('Authorization', `Bearer ${userAToken}`)
      .send({ fullName: 'Hackeado' })
    expect([403, 404]).toContain(res.status)

    const profile = await request(app.getHttpServer())
      .get('/api/users/me').set('Authorization', `Bearer ${userBToken}`)
    expect(profile.body.data.fullName).not.toBe('Hackeado')
  })
})
```

---

## Criterios de Aceptación

| Nivel | Cobertura mínima | Foco especial |
|-------|-----------------|---------------|
| Unitaria | 80% use-cases | Campos no editables (email, role) |
| Integración | 100% endpoints | Aislación entre usuarios |
| Flujo | 2 escenarios E2E | Persistencia entre sesiones, aislación |

---

## Tareas

1. [ ] Unitarias para `GetProfileUseCase`, `UpdateProfileUseCase`, `UpdateConfigurationUseCase`.
2. [ ] Integración: GET /me, PATCH /me, GET /configurations, PUT /configurations/:key.
3. [ ] Prueba explícita: campos `email` y `role` no son actualizables desde PATCH /me.
4. [ ] Prueba explícita: `passwordHash` nunca aparece en ninguna respuesta.
5. [ ] Prueba de aislación: configuraciones de userA no visibles para userB.
6. [ ] E2E: ciclo completo de actualización + persistencia entre sesiones.
7. [ ] E2E: aislación entre usuarios.
8. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **Dos usuarios en todos los tests de integración**: userA y userB deben existir desde el setup. Probar aislación de datos es el riesgo principal de este módulo.
- **Whitelist de campos actualizables**: documentar y probar explícitamente qué campos acepta PATCH /me. Campos no listados deben ser ignorados silenciosamente o rechazados con 400 — nunca procesados.
- **Configuraciones como upsert**: el endpoint PUT /configurations/:key debe ser idempotente. Llamarlo N veces con el mismo valor debe producir el mismo resultado.
- **No exponer passwordHash**: agregar un test específico que verifique que la respuesta de GET /me nunca incluye `passwordHash`, `salt` ni ningún campo de credenciales, incluso si el ORM los retorna por defecto.

## Prioridad

**Alta** — perfil es la primera pantalla tras login. Bugs de datos cruzados entre usuarios son críticos para la confianza en el sistema.
