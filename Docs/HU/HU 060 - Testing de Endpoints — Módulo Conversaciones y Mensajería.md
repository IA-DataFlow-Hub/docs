# HU-060 — Testing de Endpoints — Módulo Conversaciones y Mensajería

> **Asignado:** @dospina56-maker — David Ospina

## Archivos Principales

`apps/api/src/modules/conversations/` · `apps/api/test/conversations/` · `apps/api/src/modules/conversations/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Conversaciones y Mensajería (HU-045),  
**Para** garantizar que la creación y consulta de conversaciones funciona, que los mensajes se entregan en orden correcto, que solo los participantes pueden acceder y que los tipos de remitente (usuario, IA, sistema) se manejan correctamente.

**Dependencia:** Requiere HU-045 implementada. El adaptador de IA para mensajes generados se mockea en pruebas.

---

## Contexto

El módulo de Conversaciones combina mensajería entre usuarios con respuestas generadas por IA. Los errores más comunes en este tipo de módulos son: mensajes fuera de orden, acceso cruzado entre conversaciones de distintos usuarios y pérdida de mensajes bajo concurrencia. Las pruebas deben cubrir especialmente la **integridad del orden** y el **control de acceso por participante**.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/conversations/
├── application/
│   ├── use-cases/
│   │   ├── create-conversation.use-case.spec.ts    ← unitaria
│   │   ├── send-message.use-case.spec.ts           ← unitaria
│   │   └── get-conversation.use-case.spec.ts       ← unitaria
│   └── services/
│       └── conversations.service.spec.ts           ← unitaria
└── infrastructure/
    └── controllers/
        └── conversations.controller.spec.ts        ← unitaria

apps/api/test/
└── conversations/
    ├── conversations.integration.spec.ts           ← integración
    ├── conversations.ordering.spec.ts              ← orden de mensajes
    └── conversations.e2e.spec.ts                   ← flujo completo
```

---

## Pruebas Unitarias

### `create-conversation.use-case.spec.ts`

```typescript
describe('CreateConversationUseCase', () => {
  it('crea conversación con título y participante inicial', async () => {
    const result = await useCase.execute({ title: 'Conv Test', createdBy: 'u-1' })
    expect(repo.create).toHaveBeenCalledTimes(1)
    expect(result.title).toBe('Conv Test')
    expect(result.createdBy).toBe('u-1')
  })

  it('agrega al creador como participante automáticamente', async () => {
    await useCase.execute({ title: 'Conv Test', createdBy: 'u-1' })
    expect(participantRepo.add).toHaveBeenCalledWith(expect.objectContaining({ userId: 'u-1' }))
  })

  it('lanza BadRequestException si título vacío', async () => {
    await expect(useCase.execute({ title: '', createdBy: 'u-1' })).rejects.toThrow(BadRequestException)
  })
})
```

### `send-message.use-case.spec.ts`

```typescript
describe('SendMessageUseCase', () => {
  it('envía mensaje de tipo user correctamente', async () => {
    const result = await useCase.execute({
      conversationId: 'c-1', content: 'Hola', senderType: 'user', senderId: 'u-1'
    })
    expect(result.content).toBe('Hola')
    expect(result.senderType).toBe('user')
    expect(result.sentAt).toBeDefined()
  })

  it('lanza ForbiddenException si usuario no es participante de la conversación', async () => {
    participantRepo.isParticipant.mockResolvedValue(false)
    await expect(useCase.execute({ conversationId: 'c-1', content: 'X', senderId: 'u-99' }))
      .rejects.toThrow(ForbiddenException)
  })

  it('lanza BadRequestException si contenido vacío', async () => {
    await expect(useCase.execute({ conversationId: 'c-1', content: '', senderId: 'u-1' }))
      .rejects.toThrow(BadRequestException)
  })

  it('lanza NotFoundException si conversación no existe', async () => {
    convRepo.findById.mockResolvedValue(null)
    await expect(useCase.execute({ conversationId: 'no-existe', content: 'X', senderId: 'u-1' }))
      .rejects.toThrow(NotFoundException)
  })

  it('permite mensaje de tipo ai sin senderId de usuario', async () => {
    const result = await useCase.execute({
      conversationId: 'c-1', content: 'Respuesta IA', senderType: 'ai', senderId: null
    })
    expect(result.senderType).toBe('ai')
  })
})
```

---

## Pruebas de Integración

### `conversations.integration.spec.ts`

```typescript
describe('Conversations API — Integración', () => {
  // POST /api/conversations
  describe('POST /api/conversations', () => {
    it('201 — crea conversación con título válido', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/conversations')
        .set('Authorization', `Bearer ${token}`)
        .send({ title: 'Conversación de Prueba' })
      expect(res.status).toBe(201)
      expect(res.body.data.id).toBeDefined()
      expect(res.body.data.title).toBe('Conversación de Prueba')
    })

    it('400 — título vacío', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // GET /api/conversations
  describe('GET /api/conversations', () => {
    it('200 — lista solo las conversaciones del usuario autenticado', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/conversations')
        .set('Authorization', `Bearer ${userAToken}`)
      expect(res.status).toBe(200)
      // No debe incluir conversaciones de userB
      res.body.data.forEach((c: any) => {
        expect(c.participants.some((p: any) => p.userId === seedUserA.id)).toBe(true)
      })
    })

    it('200 — paginación funciona correctamente', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // GET /api/conversations/:id
  describe('GET /api/conversations/:id', () => {
    it('200 — participante puede ver la conversación', async () => { ... })
    it('403 — no participante no puede ver la conversación', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/conversations/${convOfUserA.id}`)
        .set('Authorization', `Bearer ${userBToken}`)
      expect(res.status).toBe(403)
    })
    it('404 — conversación inexistente', async () => { ... })
  })

  // POST /api/conversations/:id/messages
  describe('POST /api/conversations/:id/messages', () => {
    it('201 — participante envía mensaje', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/conversations/${convId}/messages`)
        .set('Authorization', `Bearer ${token}`)
        .send({ content: 'Hola, mundo' })
      expect(res.status).toBe(201)
      expect(res.body.data.content).toBe('Hola, mundo')
      expect(res.body.data.senderType).toBe('user')
      expect(res.body.data.sentAt).toBeDefined()
    })

    it('403 — no participante no puede enviar mensaje', async () => {
      const res = await request(app.getHttpServer())
        .post(`/api/conversations/${convOfUserA.id}/messages`)
        .set('Authorization', `Bearer ${userBToken}`)
        .send({ content: 'Intruso' })
      expect(res.status).toBe(403)
    })

    it('400 — contenido vacío rechazado', async () => { ... })
    it('404 — conversación inexistente', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // GET /api/conversations/:id/messages
  describe('GET /api/conversations/:id/messages', () => {
    it('200 — retorna mensajes paginados en orden cronológico', async () => {
      const res = await request(app.getHttpServer())
        .get(`/api/conversations/${convId}/messages?page=1&limit=20`)
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      const msgs = res.body.data
      for (let i = 1; i < msgs.length; i++) {
        expect(new Date(msgs[i].sentAt).getTime())
          .toBeGreaterThanOrEqual(new Date(msgs[i - 1].sentAt).getTime())
      }
    })

    it('403 — no participante no puede ver mensajes', async () => { ... })
    it('200 — lista vacía si no hay mensajes', async () => { ... })
  })

  // POST /api/conversations/:id/participants
  describe('POST /api/conversations/:id/participants', () => {
    it('200 — owner puede agregar participante', async () => { ... })
    it('403 — no owner no puede agregar participantes', async () => { ... })
    it('409 — usuario ya es participante', async () => { ... })
  })
})
```

### `conversations.ordering.spec.ts` — Orden de Mensajes

```typescript
describe('Conversations — Integridad del orden de mensajes', () => {
  it('10 mensajes enviados secuencialmente aparecen en orden correcto', async () => {
    for (let i = 1; i <= 10; i++) {
      await request(app.getHttpServer())
        .post(`/api/conversations/${convId}/messages`)
        .set('Authorization', `Bearer ${token}`)
        .send({ content: `Mensaje ${i}` })
    }
    const res = await request(app.getHttpServer())
      .get(`/api/conversations/${convId}/messages?limit=10`)
      .set('Authorization', `Bearer ${token}`)
    const contents = res.body.data.map((m: any) => m.content)
    expect(contents).toEqual(['Mensaje 1', 'Mensaje 2', ..., 'Mensaje 10'])
  })

  it('mensajes de distintos senderType aparecen entremezclados en orden temporal', async () => {
    // Simular conversación usuario ↔ IA
    // Verificar que el orden es correcto independientemente del senderType
  })
})
```

---

## Pruebas de Flujo (E2E)

### `conversations.e2e.spec.ts`

```typescript
describe('Flujo completo — Conversación entre usuario e IA', () => {
  it('Usuario crea conversación → envía mensaje → recibe respuesta IA → continúa diálogo', async () => {
    // 1. Crear conversación
    const conv = await request(app.getHttpServer())
      .post('/api/conversations')
      .set('Authorization', `Bearer ${token}`)
      .send({ title: 'Chat con IA' })
    const convId = conv.body.data.id

    // 2. Enviar mensaje de usuario
    const msg1 = await request(app.getHttpServer())
      .post(`/api/conversations/${convId}/messages`)
      .set('Authorization', `Bearer ${token}`)
      .send({ content: '¿Qué es el fine-tuning?' })
    expect(msg1.status).toBe(201)
    expect(msg1.body.data.senderType).toBe('user')

    // 3. Verificar que la conversación tiene 1 mensaje
    const msgs = await request(app.getHttpServer())
      .get(`/api/conversations/${convId}/messages`)
      .set('Authorization', `Bearer ${token}`)
    expect(msgs.body.data).toHaveLength(1)

    // 4. Verificar que la conversación aparece en la lista del usuario
    const list = await request(app.getHttpServer())
      .get('/api/conversations')
      .set('Authorization', `Bearer ${token}`)
    expect(list.body.data.some((c: any) => c.id === convId)).toBe(true)
  })

  it('UserB no puede acceder a conversaciones de UserA bajo ningún endpoint', async () => {
    const convId = await createConversation(app, userAToken)

    // Intentar GET directo
    const get = await request(app.getHttpServer())
      .get(`/api/conversations/${convId}`)
      .set('Authorization', `Bearer ${userBToken}`)
    expect(get.status).toBe(403)

    // Intentar enviar mensaje
    const send = await request(app.getHttpServer())
      .post(`/api/conversations/${convId}/messages`)
      .set('Authorization', `Bearer ${userBToken}`)
      .send({ content: 'Intruso' })
    expect(send.status).toBe(403)

    // Intentar ver mensajes
    const msgs = await request(app.getHttpServer())
      .get(`/api/conversations/${convId}/messages`)
      .set('Authorization', `Bearer ${userBToken}`)
    expect(msgs.status).toBe(403)
  })
})
```

---

## Criterios de Aceptación

| Nivel | Cobertura mínima | Foco especial |
|-------|-----------------|---------------|
| Unitaria | 80% use-cases | Validación de participante |
| Integración | 100% endpoints | Control de acceso por participante |
| Orden | 2 tests de ordering | 10 mensajes secuenciales |
| Flujo | 2 escenarios E2E | Diálogo completo, aislación |

---

## Tareas

1. [ ] Unitarias para los 3 use-cases principales.
2. [ ] Integración: CRUD de conversaciones + mensajes.
3. [ ] Tests de control de acceso: no participante recibe 403 en todos los endpoints.
4. [ ] Suite de ordering: verificar orden cronológico bajo carga.
5. [ ] E2E: flujo completo de conversación.
6. [ ] E2E: aislación estricta entre usuarios.
7. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **Control de acceso por participante**: es el invariante más crítico. Cada endpoint del módulo debe verificar que el usuario autenticado es participante de la conversación antes de cualquier operación. Probar explícitamente con un usuario válido pero no participante.
- **Orden determinístico**: los mensajes deben tener un campo `sentAt` con timestamp y la DB debe tener índice en `(conversationId, sentAt)`. Sin índice, el orden puede cambiar bajo carga.
- **Paginación hacia atrás** (scroll infinito): en chat, la paginación más natural es cursor-based (`?before=<messageId>`). Si el módulo lo soporta, probar que el cursor funciona correctamente y no pierde mensajes entre páginas.
- **senderType en respuesta**: siempre verificar en los asserts que `senderType` es el correcto (`user`, `ai`, `system`). Un mensaje de IA que aparece como `user` rompe la UI de chat.

## Prioridad

**Alta** — conversaciones es el núcleo de la interacción usuario-IA. Bugs de orden o acceso cruzado son inmediatamente visibles para el usuario final.
