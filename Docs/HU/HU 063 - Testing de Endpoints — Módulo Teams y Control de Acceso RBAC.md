# HU-063 — Testing de Endpoints — Módulo Teams y Control de Acceso RBAC

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

## Archivos Principales

`apps/api/src/modules/teams/` · `apps/api/test/teams/` · `apps/api/src/modules/teams/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Teams y Control de Acceso RBAC (HU-042),  
**Para** garantizar que la creación de equipos, invitación de miembros y los permisos por rol funcionan correctamente y que ningún usuario puede escalar privilegios ni acceder a recursos de equipos a los que no pertenece.

**Dependencia:** Requiere HU-042 implementada.

---

## Contexto

El módulo de Teams es el sistema de autorización del proyecto. Un error en RBAC puede permitir que un miembro con rol `viewer` ejecute acciones de `admin`, o que un usuario externo acceda a datos privados del equipo. Las pruebas deben ser exhaustivas en las **matrices de permisos** — cada combinación de rol + acción debe tener un test explícito.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/teams/
├── application/use-cases/
│   ├── create-team.use-case.spec.ts
│   ├── invite-member.use-case.spec.ts
│   └── change-member-role.use-case.spec.ts
└── infrastructure/controllers/
    └── teams.controller.spec.ts

apps/api/test/teams/
├── teams.integration.spec.ts
├── teams.rbac.spec.ts                  ← matriz de permisos
└── teams.e2e.spec.ts
```

---

## Pruebas Unitarias

### `invite-member.use-case.spec.ts`

```typescript
describe('InviteMemberUseCase', () => {
  it('invita miembro con rol viewer por defecto', async () => {
    const result = await useCase.execute({ teamId: 't-1', email: 'new@test.com', invitedBy: 'u-admin' })
    expect(result.role).toBe('viewer')
  })

  it('lanza ForbiddenException si invitador no es admin del equipo', async () => {
    memberRepo.getRoleInTeam.mockResolvedValue('viewer')
    await expect(useCase.execute({ teamId: 't-1', email: 'x@test.com', invitedBy: 'u-viewer' }))
      .rejects.toThrow(ForbiddenException)
  })

  it('lanza ConflictException si usuario ya es miembro', async () => { ... })
  it('lanza NotFoundException si email no está registrado en el sistema', async () => { ... })
})
```

### `change-member-role.use-case.spec.ts`

```typescript
describe('ChangeMemberRoleUseCase', () => {
  it('admin puede cambiar rol de viewer a editor', async () => { ... })
  it('lanza ForbiddenException si quien cambia no es admin', async () => { ... })
  it('lanza ForbiddenException al intentar cambiar el rol del owner', async () => { ... })
  it('lanza BadRequestException si nuevo rol no es válido', async () => { ... })
  it('owner no puede quitarse a sí mismo el rol de owner', async () => { ... })
})
```

---

## Pruebas de Integración — Matriz RBAC

### `teams.rbac.spec.ts`

```typescript
// Roles: owner | admin | editor | viewer | (externo)
const ROLES = ['owner', 'admin', 'editor', 'viewer']

describe('Teams RBAC — Matriz de permisos', () => {
  // GET /api/teams/:id — lectura
  describe('GET /api/teams/:id', () => {
    ROLES.forEach(role => {
      it(`200 — ${role} puede ver el equipo`, async () => {
        const token = await getTokenForRole(app, role)
        const res = await request(app.getHttpServer())
          .get(`/api/teams/${teamId}`).set('Authorization', `Bearer ${token}`)
        expect(res.status).toBe(200)
      })
    })
    it('403 — externo no puede ver el equipo', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/teams/${teamId}`).set('Authorization', `Bearer ${externalToken}`)
      expect(res.status).toBe(403)
    })
  })

  // PATCH /api/teams/:id — editar equipo
  describe('PATCH /api/teams/:id', () => {
    it('200 — owner puede editar', async () => { ... })
    it('200 — admin puede editar', async () => { ... })
    it('403 — editor no puede editar configuración del equipo', async () => { ... })
    it('403 — viewer no puede editar', async () => { ... })
    it('403 — externo no puede editar', async () => { ... })
  })

  // POST /api/teams/:id/members — invitar
  describe('POST /api/teams/:id/members', () => {
    it('201 — owner puede invitar', async () => { ... })
    it('201 — admin puede invitar', async () => { ... })
    it('403 — editor no puede invitar', async () => { ... })
    it('403 — viewer no puede invitar', async () => { ... })
  })

  // PATCH /api/teams/:id/members/:userId/role — cambiar rol
  describe('PATCH /api/teams/:id/members/:userId/role', () => {
    it('200 — owner puede cambiar cualquier rol', async () => { ... })
    it('200 — admin puede cambiar roles (excepto owner)', async () => { ... })
    it('403 — admin no puede cambiar el rol del owner', async () => { ... })
    it('403 — editor no puede cambiar roles', async () => { ... })
    it('403 — viewer no puede cambiar roles', async () => { ... })
  })

  // DELETE /api/teams/:id/members/:userId — expulsar
  describe('DELETE /api/teams/:id/members/:userId', () => {
    it('200 — owner puede expulsar a cualquier miembro', async () => { ... })
    it('200 — admin puede expulsar editor/viewer', async () => { ... })
    it('403 — admin no puede expulsar a owner', async () => { ... })
    it('403 — editor no puede expulsar', async () => { ... })
    it('200 — cualquier miembro puede salir del equipo (self-leave)', async () => { ... })
    it('400 — owner no puede salir si es el único owner', async () => { ... })
  })

  // DELETE /api/teams/:id — eliminar equipo
  describe('DELETE /api/teams/:id', () => {
    it('200 — solo owner puede eliminar el equipo', async () => { ... })
    it('403 — admin no puede eliminar equipo', async () => { ... })
    it('403 — editor no puede eliminar equipo', async () => { ... })
  })
})
```

---

## Pruebas de Flujo (E2E)

```typescript
describe('Flujo completo — Creación de equipo y gestión de roles', () => {
  it('Owner crea equipo → invita admin → admin invita editor → editor intenta escalar rol → falla', async () => {
    // 1. Crear equipo
    const team = await createTeam(app, ownerToken, 'Equipo E2E')
    const teamId = team.id

    // 2. Owner invita admin
    await request(app.getHttpServer())
      .post(`/api/teams/${teamId}/members`)
      .set('Authorization', `Bearer ${ownerToken}`)
      .send({ email: adminUser.email, role: 'admin' })

    // 3. Admin invita editor
    await request(app.getHttpServer())
      .post(`/api/teams/${teamId}/members`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ email: editorUser.email, role: 'editor' })

    // 4. Editor intenta cambiarse a admin — debe fallar
    const escalate = await request(app.getHttpServer())
      .patch(`/api/teams/${teamId}/members/${editorUser.id}/role`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ role: 'admin' })
    expect(escalate.status).toBe(403)

    // 5. Editor intenta cambiar rol del owner — debe fallar
    const attackOwner = await request(app.getHttpServer())
      .patch(`/api/teams/${teamId}/members/${ownerUser.id}/role`)
      .set('Authorization', `Bearer ${editorToken}`)
      .send({ role: 'viewer' })
    expect(attackOwner.status).toBe(403)
  })
})
```

---

## Tareas

1. [ ] Unitarias para `InviteMemberUseCase` y `ChangeMemberRoleUseCase`.
2. [ ] Suite RBAC completa: probar cada acción con cada rol (incluido externo).
3. [ ] Test explícito: admin no puede tocar al owner.
4. [ ] Test explícito: nadie puede escalar su propio rol.
5. [ ] Test explícito: owner no puede salir si es el único.
6. [ ] E2E: ciclo completo con intento de escalada de privilegios.
7. [ ] Cobertura ≥ 85%.

---

## Recomendaciones

- **Tabla de permisos como fixture**: crear un objeto `PERMISSIONS` que mapea `{ role: { action: boolean } }` y usar `it.each` para generar los tests de la matriz automáticamente. Evita tests repetitivos y hace la matriz legible.
- **Escalada de privilegios como test obligatorio**: probar explícitamente que un `editor` no puede darse a sí mismo el rol `admin` enviando PATCH a su propio userId. Es el vector de ataque más común en RBAC.
- **Owner único**: el sistema debe impedir que el último owner salga o sea expulsado. Sin esta validación el equipo queda huérfano.
- **Tokens para cada rol**: crear un helper `getTokenForRole(app, role, teamId)` que retorna un token de usuario con ese rol en el equipo dado. Simplifica enormemente los tests de la matriz.

## Prioridad

**Crítica** — RBAC mal implementado puede comprometer datos de otros equipos. Cobertura mínima: 85%.
