# HU-062 — Testing de Endpoints — Módulo Auth y Gestión de Sesiones

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre
> **Tamaño:** L — Complejo — 2 a 3 días (2–3 días)

## Archivos Principales

`apps/api/src/modules/auth/` · `apps/api/test/auth/` · `apps/api/src/modules/auth/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Auth y Gestión de Sesiones (HU-040),  
**Para** garantizar que el registro, login, OAuth, renovación de tokens y ciclo de vida de sesiones funcionan correctamente y que ningún endpoint protegido es accesible sin autenticación válida.

**Dependencia:** Requiere HU-040 implementada. Google OAuth se mockea en pruebas.

---

## Contexto

Auth es la puerta de entrada al sistema — todos los demás módulos dependen de que los tokens sean válidos. Los bugs aquí tienen el mayor impacto de seguridad: tokens que no expiran, refresh tokens reutilizables indefinidamente, sesiones de otros usuarios accesibles. Las pruebas deben cubrir especialmente el **ciclo de vida del token**, la **revocación de sesiones** y el **historial de contraseñas**.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/auth/
├── application/use-cases/
│   ├── register.use-case.spec.ts
│   ├── login.use-case.spec.ts
│   ├── refresh-token.use-case.spec.ts
│   ├── logout.use-case.spec.ts
│   └── change-password.use-case.spec.ts
└── infrastructure/controllers/
    └── auth.controller.spec.ts

apps/api/test/auth/
├── auth.integration.spec.ts
├── auth.token-lifecycle.spec.ts        ← ciclo de vida del token
├── auth.sessions.spec.ts               ← gestión de sesiones
└── auth.e2e.spec.ts
```

---

## Pruebas Unitarias

### `register.use-case.spec.ts`

```typescript
describe('RegisterUseCase', () => {
  it('registra usuario con email y password válidos', async () => {
    const result = await useCase.execute({ email: 'new@test.com', password: 'Pass123!', fullName: 'Test' })
    expect(result.accessToken).toBeDefined()
    expect(result.refreshToken).toBeDefined()
    expect(userRepo.create).toHaveBeenCalledTimes(1)
  })

  it('hashea la contraseña — no guarda plaintext', async () => {
    await useCase.execute({ email: 'new@test.com', password: 'Pass123!', fullName: 'Test' })
    const saved = userRepo.create.mock.calls[0][0]
    expect(saved.passwordHash).not.toBe('Pass123!')
    expect(saved.passwordHash).toMatch(/^\$2[ab]\$/)  // bcrypt
  })

  it('lanza ConflictException si email ya existe', async () => {
    userRepo.findByEmail.mockResolvedValue({ id: 'u-1' })
    await expect(useCase.execute({ email: 'dup@test.com', password: 'Pass123!', fullName: 'X' }))
      .rejects.toThrow(ConflictException)
  })

  it('lanza BadRequestException si password tiene menos de 8 caracteres', async () => {
    await expect(useCase.execute({ email: 'x@test.com', password: '123', fullName: 'X' }))
      .rejects.toThrow(BadRequestException)
  })
})
```

### `refresh-token.use-case.spec.ts`

```typescript
describe('RefreshTokenUseCase', () => {
  it('retorna nuevo accessToken con refreshToken válido', async () => {
    sessionRepo.findByRefreshToken.mockResolvedValue(validSession)
    const result = await useCase.execute({ refreshToken: 'valid-token' })
    expect(result.accessToken).toBeDefined()
  })

  it('lanza UnauthorizedException si refreshToken no existe en DB (opaque token)', async () => {
    sessionRepo.findByRefreshToken.mockResolvedValue(null)
    await expect(useCase.execute({ refreshToken: 'fake' })).rejects.toThrow(UnauthorizedException)
  })

  it('lanza UnauthorizedException si refreshToken está revocado', async () => {
    sessionRepo.findByRefreshToken.mockResolvedValue({ ...validSession, revokedAt: new Date() })
    await expect(useCase.execute({ refreshToken: 'revoked' })).rejects.toThrow(UnauthorizedException)
  })

  it('rota el refreshToken al renovar (refresh token rotation)', async () => {
    const result = await useCase.execute({ refreshToken: 'valid-token' })
    expect(sessionRepo.update).toHaveBeenCalledWith(expect.anything(), expect.objectContaining({
      refreshToken: expect.not.stringMatching('valid-token')
    }))
  })
})
```

### `change-password.use-case.spec.ts`

```typescript
describe('ChangePasswordUseCase', () => {
  it('cambia contraseña con currentPassword correcto', async () => { ... })
  it('lanza UnauthorizedException si currentPassword es incorrecto', async () => { ... })
  it('lanza ConflictException si newPassword está en historial de últimas 5', async () => {
    passwordHistoryRepo.findLast5.mockResolvedValue([
      { hash: await bcrypt.hash('OldPass1!', 10) },
    ])
    await expect(useCase.execute({ userId: 'u-1', currentPassword: 'Current1!', newPassword: 'OldPass1!' }))
      .rejects.toThrow(ConflictException)
  })
  it('revoca todas las sesiones activas al cambiar contraseña', async () => {
    await useCase.execute({ userId: 'u-1', currentPassword: 'Current1!', newPassword: 'NewPass1!' })
    expect(sessionRepo.revokeAllByUser).toHaveBeenCalledWith('u-1')
  })
})
```

---

## Pruebas de Integración

### `auth.integration.spec.ts`

```typescript
describe('Auth API — Integración', () => {
  // POST /api/auth/register
  describe('POST /api/auth/register', () => {
    it('201 — registra usuario y retorna tokens', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/register')
        .send({ email: 'new@test.com', password: 'TestPass123!', fullName: 'Nuevo Usuario' })
      expect(res.status).toBe(201)
      expect(res.body.data.accessToken).toBeDefined()
      expect(res.body.data.refreshToken).toBeDefined()
    })
    it('409 — email duplicado', async () => { ... })
    it('400 — password débil', async () => { ... })
    it('400 — email inválido', async () => { ... })
  })

  // POST /api/auth/login
  describe('POST /api/auth/login', () => {
    it('200 — login correcto retorna accessToken y refreshToken', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/auth/login')
        .send({ email: seedUser.email, password: 'TestPass123!' })
      expect(res.status).toBe(200)
      expect(res.body.data.accessToken).toBeDefined()
    })
    it('401 — password incorrecto', async () => { ... })
    it('401 — email no registrado', async () => { ... })
    it('400 — body vacío', async () => { ... })
  })

  // POST /api/auth/refresh
  describe('POST /api/auth/refresh', () => {
    it('200 — refreshToken válido retorna nuevo accessToken', async () => { ... })
    it('401 — refreshToken inválido', async () => { ... })
    it('401 — refreshToken ya usado (rotation)', async () => { ... })
  })

  // POST /api/auth/logout
  describe('POST /api/auth/logout', () => {
    it('200 — logout revoca la sesión actual', async () => { ... })
    it('401 — sin token', async () => { ... })
    it('401 — accessToken expirado o inválido', async () => { ... })
  })

  // POST /api/auth/change-password
  describe('POST /api/auth/change-password', () => {
    it('200 — cambia contraseña y revoca otras sesiones', async () => { ... })
    it('401 — currentPassword incorrecto', async () => { ... })
    it('409 — newPassword en historial', async () => { ... })
    it('400 — newPassword igual a currentPassword', async () => { ... })
  })

  // GET /api/auth/sessions
  describe('GET /api/auth/sessions', () => {
    it('200 — lista sesiones activas del usuario', async () => { ... })
    it('200 — no lista sesiones de otros usuarios', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // DELETE /api/auth/sessions/:id
  describe('DELETE /api/auth/sessions/:id', () => {
    it('200 — revoca sesión específica', async () => { ... })
    it('403 — sesión de otro usuario', async () => { ... })
    it('404 — sesión inexistente', async () => { ... })
  })
})
```

### `auth.token-lifecycle.spec.ts`

```typescript
describe('Auth — Ciclo de vida del token', () => {
  it('accessToken expirado rechazado en endpoint protegido', async () => {
    const expiredToken = generateExpiredToken(seedUser.id)
    const res = await request(app.getHttpServer())
      .get('/api/users/me')
      .set('Authorization', `Bearer ${expiredToken}`)
    expect(res.status).toBe(401)
  })

  it('refreshToken rota — token anterior rechazado tras renovación', async () => {
    const { refreshToken: oldToken } = await loginAndGetTokens(app)
    const renewed = await request(app.getHttpServer())
      .post('/api/auth/refresh').send({ refreshToken: oldToken })
    // Intentar usar el token viejo
    const reuse = await request(app.getHttpServer())
      .post('/api/auth/refresh').send({ refreshToken: oldToken })
    expect(reuse.status).toBe(401)
  })

  it('todos los accessTokens del usuario son inválidos tras cambio de contraseña', async () => {
    const { accessToken } = await loginAndGetTokens(app)
    await changePassword(app, accessToken)
    const res = await request(app.getHttpServer())
      .get('/api/users/me').set('Authorization', `Bearer ${accessToken}`)
    expect(res.status).toBe(401)
  })
})
```

---

## Pruebas de Flujo (E2E)

```typescript
describe('Flujo completo — Registro → Login → Renovación → Logout', () => {
  it('ciclo de vida completo de autenticación', async () => {
    // 1. Registro
    const reg = await request(app.getHttpServer())
      .post('/api/auth/register')
      .send({ email: 'e2e@test.com', password: 'E2EPass123!', fullName: 'E2E User' })
    expect(reg.status).toBe(201)
    const { accessToken, refreshToken } = reg.body.data

    // 2. Acceder a recurso protegido
    const me = await request(app.getHttpServer())
      .get('/api/users/me').set('Authorization', `Bearer ${accessToken}`)
    expect(me.status).toBe(200)

    // 3. Renovar token
    const refreshed = await request(app.getHttpServer())
      .post('/api/auth/refresh').send({ refreshToken })
    expect(refreshed.status).toBe(200)
    const newAccess = refreshed.body.data.accessToken

    // 4. Token viejo sigue funcionando hasta expirar (o ya no — según política)
    // 5. Logout
    await request(app.getHttpServer())
      .post('/api/auth/logout').set('Authorization', `Bearer ${newAccess}`)

    // 6. Tras logout, refreshToken revocado
    const postLogout = await request(app.getHttpServer())
      .post('/api/auth/refresh').send({ refreshToken: refreshed.body.data.refreshToken })
    expect(postLogout.status).toBe(401)
  })
})
```

---

## Tareas

1. [ ] Unitarias para los 5 use-cases (register, login, refresh, logout, change-password).
2. [ ] Verificación unitaria: passwords nunca guardados en plaintext.
3. [ ] Integración: todos los endpoints con casos positivos y negativos.
4. [ ] Suite `token-lifecycle`: expiración, rotación, invalidación por cambio de contraseña.
5. [ ] Suite `sessions`: aislación de sesiones entre usuarios.
6. [ ] E2E: ciclo completo registro → login → refresh → logout.
7. [ ] Cobertura ≥ 85% (auth es crítico, umbral más alto).

---

## Recomendaciones

- **Tokens con expiración corta en `.env.test`**: usar `JWT_EXPIRES_IN=5s` para poder probar expiración sin `sleep` largo.
- **Refresh token rotation obligatoria**: el token anterior debe ser inválido inmediatamente tras la renovación. Esta es la defensa contra robo de refresh tokens.
- **Probar historial de contraseñas con bcrypt real**: no mockear bcrypt en las pruebas de `change-password` — el hash real puede tener timing diferente y revelar bugs.
- **Sesiones por dispositivo**: si el módulo soporta múltiples sesiones, probar que `DELETE /sessions/:id` solo revoca esa sesión y no las demás.

## Prioridad

**Crítica** — Auth es la base de seguridad del sistema. Umbral de cobertura mínimo: 85%.
