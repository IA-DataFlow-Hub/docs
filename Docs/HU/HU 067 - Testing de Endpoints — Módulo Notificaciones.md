# HU-067 — Testing de Endpoints — Módulo Notificaciones

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre
> **Prioridad:** 🟠 High / Alta — Crítica

## Archivos Principales

`apps/api/src/modules/notifications/` · `apps/api/test/notifications/` · `apps/api/src/modules/notifications/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Notificaciones (HU-050),  
**Para** garantizar que las notificaciones se entregan al usuario correcto, que las preferencias de notificación se respetan, que el marcado como leída es idempotente y que nunca se exponen notificaciones de otros usuarios.

**Dependencia:** Requiere HU-050 implementada. El canal de entrega externo (email, push) se mockea.

---

## Contexto

Las notificaciones son disparadas por eventos de otros módulos (tarea asignada, job completado, mensaje recibido). Los errores aquí suelen ser silenciosos: la notificación no llega, llega a otro usuario o se duplica. Las pruebas deben cubrir especialmente la **entrega al usuario correcto**, la **idempotencia del marcado como leída** y la **integración transversal** con los módulos que disparan eventos.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/notifications/
├── application/use-cases/
│   ├── create-notification.use-case.spec.ts
│   ├── mark-as-read.use-case.spec.ts
│   └── get-notifications.use-case.spec.ts
└── infrastructure/
    ├── controllers/notifications.controller.spec.ts
    └── channels/
        ├── email-channel.spec.ts               ← mock del email
        └── push-channel.spec.ts                ← mock de push

apps/api/test/notifications/
├── notifications.integration.spec.ts
├── notifications.delivery.spec.ts              ← entrega correcta
├── notifications.cross-module.spec.ts          ← integración transversal
└── notifications.e2e.spec.ts
```

---

## Mock de Canales de Entrega

```typescript
// test/mocks/notification-channels.mock.ts
export const EmailChannelMock = {
  send: jest.fn().mockResolvedValue({ messageId: 'mock-email-001', delivered: true }),
}

export const PushChannelMock = {
  send: jest.fn().mockResolvedValue({ pushId: 'mock-push-001', delivered: true }),
}

export function mockEmailFailure() {
  EmailChannelMock.send.mockRejectedValueOnce(new Error('SMTP error'))
}
```

---

## Pruebas Unitarias

### `create-notification.use-case.spec.ts`

```typescript
describe('CreateNotificationUseCase', () => {
  it('crea notificación para usuario específico con tipo y mensaje', async () => {
    const result = await useCase.execute({
      userId: 'u-1', type: 'task.assigned',
      title: 'Nueva tarea asignada', body: 'Te asignaron: Implementar login',
      metadata: { taskId: 't-1' }
    })
    expect(result.userId).toBe('u-1')
    expect(result.type).toBe('task.assigned')
    expect(result.read).toBe(false)  // siempre no leída al crear
  })

  it('no crea notificación si usuario desactivó ese tipo', async () => {
    prefsRepo.isEnabled.mockResolvedValue(false)
    await useCase.execute({ userId: 'u-1', type: 'task.assigned', title: 'X', body: 'Y' })
    expect(notifRepo.create).not.toHaveBeenCalled()
  })

  it('intenta enviar por canal email si usuario tiene email habilitado', async () => {
    prefsRepo.getChannels.mockResolvedValue(['email'])
    await useCase.execute({ userId: 'u-1', type: 'task.assigned', title: 'X', body: 'Y' })
    expect(emailChannel.send).toHaveBeenCalledTimes(1)
  })

  it('fallo del canal email no impide crear la notificación en DB', async () => {
    mockEmailFailure()
    const result = await useCase.execute({ userId: 'u-1', type: 'task.assigned', title: 'X', body: 'Y' })
    expect(result.id).toBeDefined()  // se guarda en DB aunque email falle
    expect(notifRepo.create).toHaveBeenCalledTimes(1)
  })
})
```

### `mark-as-read.use-case.spec.ts`

```typescript
describe('MarkAsReadUseCase', () => {
  it('marca notificación como leída', async () => {
    notifRepo.findById.mockResolvedValue({ id: 'n-1', userId: 'u-1', read: false })
    await useCase.execute({ notificationId: 'n-1', userId: 'u-1' })
    expect(notifRepo.update).toHaveBeenCalledWith('n-1', expect.objectContaining({ read: true, readAt: expect.any(Date) }))
  })

  it('segunda llamada a mark-as-read es idempotente', async () => {
    notifRepo.findById.mockResolvedValue({ id: 'n-1', userId: 'u-1', read: true, readAt: new Date() })
    await useCase.execute({ notificationId: 'n-1', userId: 'u-1' })
    expect(notifRepo.update).not.toHaveBeenCalled()  // no actualiza si ya está leída
  })

  it('lanza ForbiddenException si notificación no pertenece al usuario', async () => {
    notifRepo.findById.mockResolvedValue({ id: 'n-1', userId: 'u-otro', read: false })
    await expect(useCase.execute({ notificationId: 'n-1', userId: 'u-1' }))
      .rejects.toThrow(ForbiddenException)
  })
})
```

---

## Pruebas de Integración

### `notifications.integration.spec.ts`

```typescript
describe('Notifications API — Integración', () => {
  // GET /api/notifications
  describe('GET /api/notifications', () => {
    it('200 — retorna solo notificaciones del usuario autenticado', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/notifications')
        .set('Authorization', `Bearer ${userAToken}`)
      expect(res.status).toBe(200)
      res.body.data.forEach((n: any) => expect(n.userId).toBe(seedUserA.id))
    })

    it('200 — filtra por read=false (no leídas)', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/notifications?read=false')
        .set('Authorization', `Bearer ${token}`)
      res.body.data.forEach((n: any) => expect(n.read).toBe(false))
    })

    it('200 — filtra por type=task.assigned', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/notifications?type=task.assigned')
        .set('Authorization', `Bearer ${token}`)
      res.body.data.forEach((n: any) => expect(n.type).toBe('task.assigned'))
    })

    it('200 — paginación correcta', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // GET /api/notifications/unread-count
  describe('GET /api/notifications/unread-count', () => {
    it('200 — retorna conteo exacto de no leídas', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/notifications/unread-count')
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      expect(typeof res.body.data.count).toBe('number')
    })
  })

  // PATCH /api/notifications/:id/read
  describe('PATCH /api/notifications/:id/read', () => {
    it('200 — marca notificación como leída', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/notifications/${seedNotif.id}/read`)
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      expect(res.body.data.read).toBe(true)
      expect(res.body.data.readAt).toBeDefined()
    })

    it('200 — llamar dos veces es idempotente (no error)', async () => {
      await request(app.getHttpServer())
        .patch(`/api/notifications/${seedNotif.id}/read`)
        .set('Authorization', `Bearer ${token}`)
      const res = await request(app.getHttpServer())
        .patch(`/api/notifications/${seedNotif.id}/read`)
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
    })

    it('403 — notificación de otro usuario', async () => {
      const res = await request(app.getHttpServer())
        .patch(`/api/notifications/${seedNotif.id}/read`)
        .set('Authorization', `Bearer ${userBToken}`)
      expect(res.status).toBe(403)
    })

    it('404 — notificación inexistente', async () => { ... })
  })

  // PATCH /api/notifications/read-all
  describe('PATCH /api/notifications/read-all', () => {
    it('200 — marca todas las notificaciones del usuario como leídas', async () => {
      const res = await request(app.getHttpServer())
        .patch('/api/notifications/read-all')
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      // Verificar que el conteo queda en 0
      const count = await request(app.getHttpServer())
        .get('/api/notifications/unread-count')
        .set('Authorization', `Bearer ${token}`)
      expect(count.body.data.count).toBe(0)
    })

    it('no afecta notificaciones de otros usuarios', async () => {
      const beforeCount = await getUnreadCount(app, userBToken)
      await request(app.getHttpServer())
        .patch('/api/notifications/read-all')
        .set('Authorization', `Bearer ${userAToken}`)
      const afterCount = await getUnreadCount(app, userBToken)
      expect(afterCount).toBe(beforeCount)
    })
  })

  // GET /api/users/me/notification-preferences
  describe('GET + PUT /api/users/me/notification-preferences', () => {
    it('200 — retorna preferencias del usuario', async () => { ... })
    it('200 — actualiza preferencia de tipo (desactivar task.assigned)', async () => { ... })
    it('200 — desactivar email para un tipo no afecta push', async () => { ... })
  })
})
```

### `notifications.cross-module.spec.ts`

```typescript
describe('Notifications — Integración transversal', () => {
  it('asignar tarea genera notificación tipo task.assigned para el asignado', async () => {
    await assignTask(app, ownerToken, seedTask.id, seedMember.id)
    const notifs = await request(app.getHttpServer())
      .get('/api/notifications?type=task.assigned')
      .set('Authorization', `Bearer ${memberToken}`)
    expect(notifs.body.data.some((n: any) => n.metadata?.taskId === seedTask.id)).toBe(true)
  })

  it('job de IA completado genera notificación tipo ai_job.completed para el owner', async () => {
    await completeJob(app, seedJob.id)
    const notifs = await request(app.getHttpServer())
      .get('/api/notifications?type=ai_job.completed')
      .set('Authorization', `Bearer ${ownerToken}`)
    expect(notifs.body.data.some((n: any) => n.metadata?.jobId === seedJob.id)).toBe(true)
  })

  it('notificación NO se crea si usuario desactivó ese tipo en preferencias', async () => {
    await disableNotifType(app, memberToken, 'task.assigned')
    await assignTask(app, ownerToken, seedTask2.id, seedMember.id)
    const notifs = await request(app.getHttpServer())
      .get('/api/notifications?type=task.assigned')
      .set('Authorization', `Bearer ${memberToken}`)
    const newNotif = notifs.body.data.find((n: any) => n.metadata?.taskId === seedTask2.id)
    expect(newNotif).toBeUndefined()
  })
})
```

---

## Pruebas de Flujo (E2E)

```typescript
describe('Flujo completo — Notificaciones', () => {
  it('Usuario recibe notificación → la ve en lista → la marca leída → contador baja', async () => {
    // 1. Generar evento (asignar tarea)
    await assignTask(app, ownerToken, seedTask.id, seedUser.id)

    // 2. Verificar notificación en lista
    const list = await request(app.getHttpServer())
      .get('/api/notifications').set('Authorization', `Bearer ${token}`)
    const notif = list.body.data.find((n: any) => n.type === 'task.assigned')
    expect(notif).toBeDefined()
    expect(notif.read).toBe(false)

    // 3. Verificar contador de no leídas
    const count = await getUnreadCount(app, token)
    expect(count).toBeGreaterThan(0)

    // 4. Marcar como leída
    await request(app.getHttpServer())
      .patch(`/api/notifications/${notif.id}/read`)
      .set('Authorization', `Bearer ${token}`)

    // 5. Verificar contador bajó
    const newCount = await getUnreadCount(app, token)
    expect(newCount).toBe(count - 1)

    // 6. Notificación aparece como leída en la lista
    const updated = await request(app.getHttpServer())
      .get(`/api/notifications?read=true`).set('Authorization', `Bearer ${token}`)
    expect(updated.body.data.some((n: any) => n.id === notif.id)).toBe(true)
  })
})
```

---

## Tareas

1. [ ] Mock de canales (email, push) con helper `mockEmailFailure()`.
2. [ ] Unitarias: CreateNotification (preferencias, canal falla sin romper DB), MarkAsRead (idempotente).
3. [ ] Integración: GET /notifications con filtros (read, type, paginación).
4. [ ] Integración: mark-as-read idempotente + 403 en notificación ajena.
5. [ ] Integración: read-all — solo afecta al usuario autenticado.
6. [ ] Integración: preferencias de notificación.
7. [ ] Suite transversal: tarea asignada, job completado, preferencia desactivada.
8. [ ] E2E: ciclo completo recibir → ver → marcar leída.
9. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **Fallo de canal no debe romper el flujo**: si el servidor SMTP está caído, la notificación debe guardarse en DB de todas formas. El usuario la verá en la app aunque no llegue el email. Probar este caso explícitamente.
- **Idempotencia de mark-as-read**: llamar PATCH /notifications/:id/read dos veces debe retornar 200 ambas veces, no 409 ni 400. Muchos clientes frontend hacen doble-click.
- **read-all es atómico**: debe actualizar todas las notificaciones del usuario en una sola operación de DB (UPDATE WHERE userId = X AND read = false). Sin atomicidad, el contador puede quedar desfasado.
- **Contador de no leídas como métrica crítica**: el badge de notificaciones en la UI depende de este endpoint. Probar que el contador baja exactamente 1 tras cada mark-as-read y llega a 0 tras read-all.
- **Preferencias por tipo y canal**: la granularidad debe ser `(userId, notificationType, channel)`. Un usuario puede querer emails para ai_job pero no para task.assigned. Probar combinaciones.

## Prioridad

**Media** — Notificaciones no bloquean funcionalidad pero su mal funcionamiento (duplicadas, entregadas al usuario incorrecto) daña significativamente la experiencia de uso.
