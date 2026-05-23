# HU-061 — Testing de Endpoints — Módulo Feedback y Reportes

> **Asignado:** @dospina56-maker — David Ospina

## Archivos Principales

`apps/api/src/modules/feedback/` · `apps/api/test/feedback/` · `apps/api/src/modules/feedback/**/*.spec.ts`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** una suite de pruebas completa para el módulo de Feedback y Reportes (HU-049),  
**Para** garantizar que los usuarios pueden enviar feedback sobre mensajes de IA, que los reportes se generan correctamente y que los administradores pueden consultar métricas de calidad sin acceder a datos privados de otros usuarios.

**Dependencia:** Requiere HU-049 implementada. Requiere HU-045 (Conversaciones) para tener mensajes sobre los que hacer feedback.

---

## Contexto

El módulo de Feedback y Reportes tiene dos responsabilidades distintas: (1) feedback de usuarios sobre la calidad de las respuestas de IA (thumbs up/down, comentarios) y (2) reportes agregados para administradores sobre el rendimiento del sistema. Los errores más comunes aquí son: feedback duplicado en el mismo mensaje, reportes que exponen datos privados de usuarios y métricas calculadas incorrectamente. Las pruebas deben cubrir especialmente la **idempotencia del feedback** y la **privacidad en reportes**.

---

## Estructura de Archivos de Prueba

```
apps/api/src/modules/feedback/
├── application/
│   ├── use-cases/
│   │   ├── submit-feedback.use-case.spec.ts        ← unitaria
│   │   ├── get-feedback.use-case.spec.ts           ← unitaria
│   │   └── generate-report.use-case.spec.ts        ← unitaria
│   └── services/
│       ├── feedback.service.spec.ts                ← unitaria
│       └── reports.service.spec.ts                 ← unitaria
└── infrastructure/
    └── controllers/
        └── feedback.controller.spec.ts             ← unitaria

apps/api/test/
└── feedback/
    ├── feedback.integration.spec.ts                ← integración
    ├── feedback.idempotency.spec.ts                ← idempotencia
    └── feedback.e2e.spec.ts                        ← flujo completo
```

---

## Pruebas Unitarias

### `submit-feedback.use-case.spec.ts`

```typescript
describe('SubmitFeedbackUseCase', () => {
  it('crea feedback positivo (thumbsUp) para un mensaje', async () => {
    const result = await useCase.execute({
      messageId: 'm-1', userId: 'u-1', rating: 'positive', comment: 'Muy útil'
    })
    expect(result.rating).toBe('positive')
    expect(result.messageId).toBe('m-1')
    expect(result.userId).toBe('u-1')
  })

  it('crea feedback negativo (thumbsDown) sin comentario', async () => {
    const result = await useCase.execute({
      messageId: 'm-1', userId: 'u-1', rating: 'negative'
    })
    expect(result.rating).toBe('negative')
    expect(result.comment).toBeUndefined()
  })

  it('actualiza feedback si el usuario ya calificó el mismo mensaje (upsert)', async () => {
    feedbackRepo.findByMessageAndUser.mockResolvedValue({ id: 'f-1', rating: 'negative' })
    await useCase.execute({ messageId: 'm-1', userId: 'u-1', rating: 'positive' })
    expect(feedbackRepo.update).toHaveBeenCalledWith('f-1', { rating: 'positive' })
    expect(feedbackRepo.create).not.toHaveBeenCalled()
  })

  it('lanza BadRequestException si rating no es positive/negative/neutral', async () => {
    await expect(useCase.execute({ messageId: 'm-1', userId: 'u-1', rating: 'invalid' as any }))
      .rejects.toThrow(BadRequestException)
  })

  it('lanza NotFoundException si messageId no existe', async () => {
    messageRepo.findById.mockResolvedValue(null)
    await expect(useCase.execute({ messageId: 'no-existe', userId: 'u-1', rating: 'positive' }))
      .rejects.toThrow(NotFoundException)
  })

  it('lanza ForbiddenException si mensaje no pertenece a una conversación del usuario', async () => {
    participantRepo.isParticipant.mockResolvedValue(false)
    await expect(useCase.execute({ messageId: 'm-99', userId: 'u-1', rating: 'positive' }))
      .rejects.toThrow(ForbiddenException)
  })
})
```

### `generate-report.use-case.spec.ts`

```typescript
describe('GenerateReportUseCase', () => {
  it('genera reporte de satisfacción con totales positivos, negativos y neutros', async () => {
    feedbackRepo.getStats.mockResolvedValue({ positive: 80, negative: 15, neutral: 5, total: 100 })
    const result = await useCase.execute({ type: 'satisfaction', from: '2026-01-01', to: '2026-05-31' })
    expect(result.positive).toBe(80)
    expect(result.satisfactionRate).toBe(0.8)
  })

  it('reporte no incluye datos identificables del usuario (solo conteos)', async () => {
    const result = await useCase.execute({ type: 'satisfaction', from: '2026-01-01', to: '2026-05-31' })
    expect(result).not.toHaveProperty('userIds')
    expect(result).not.toHaveProperty('emails')
  })

  it('retorna reporte vacío sin errores si no hay feedback en el rango', async () => {
    feedbackRepo.getStats.mockResolvedValue({ positive: 0, negative: 0, neutral: 0, total: 0 })
    const result = await useCase.execute({ type: 'satisfaction', from: '2020-01-01', to: '2020-01-02' })
    expect(result.total).toBe(0)
    expect(result.satisfactionRate).toBe(0)
  })
})
```

---

## Pruebas de Integración

### `feedback.integration.spec.ts`

```typescript
describe('Feedback API — Integración', () => {
  // POST /api/feedback
  describe('POST /api/feedback', () => {
    it('201 — feedback positivo creado correctamente', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/feedback')
        .set('Authorization', `Bearer ${token}`)
        .send({ messageId: seedMessage.id, rating: 'positive', comment: 'Excelente respuesta' })
      expect(res.status).toBe(201)
      expect(res.body.data.rating).toBe('positive')
      expect(res.body.data.id).toBeDefined()
    })

    it('201 — feedback negativo sin comentario', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/feedback')
        .set('Authorization', `Bearer ${token}`)
        .send({ messageId: seedMessage2.id, rating: 'negative' })
      expect(res.status).toBe(201)
    })

    it('200 — segundo feedback del mismo usuario en el mismo mensaje hace upsert', async () => {
      await request(app.getHttpServer())
        .post('/api/feedback')
        .set('Authorization', `Bearer ${token}`)
        .send({ messageId: seedMessage.id, rating: 'negative' })
      const res = await request(app.getHttpServer())
        .post('/api/feedback')
        .set('Authorization', `Bearer ${token}`)
        .send({ messageId: seedMessage.id, rating: 'positive' })
      expect([200, 201]).toContain(res.status)
      // Verificar que no hay duplicado en DB
      const list = await request(app.getHttpServer())
        .get(`/api/feedback?messageId=${seedMessage.id}`)
        .set('Authorization', `Bearer ${adminToken}`)
      const userFeedbacks = list.body.data.filter((f: any) => f.userId === seedUser.id)
      expect(userFeedbacks).toHaveLength(1)
      expect(userFeedbacks[0].rating).toBe('positive')
    })

    it('400 — rating inválido', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/feedback')
        .set('Authorization', `Bearer ${token}`)
        .send({ messageId: seedMessage.id, rating: 'excelente' })
      expect(res.status).toBe(400)
    })

    it('403 — mensaje de conversación ajena', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/feedback')
        .set('Authorization', `Bearer ${userBToken}`)
        .send({ messageId: seedMessage.id, rating: 'positive' })
      expect(res.status).toBe(403)
    })

    it('404 — messageId inexistente', async () => { ... })
    it('401 — sin token', async () => { ... })
  })

  // GET /api/feedback/me
  describe('GET /api/feedback/me', () => {
    it('200 — usuario ve solo su propio feedback', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/feedback/me')
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(200)
      res.body.data.forEach((f: any) => expect(f.userId).toBe(seedUser.id))
    })

    it('200 — lista vacía si usuario no ha dado feedback', async () => { ... })
  })

  // GET /api/feedback (admin only)
  describe('GET /api/feedback — admin', () => {
    it('200 — admin puede ver todo el feedback', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/feedback')
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.status).toBe(200)
    })

    it('403 — usuario normal no puede ver feedback de otros', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/feedback')
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(403)
    })

    it('200 — filtra por rating=negative', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/feedback?rating=negative')
        .set('Authorization', `Bearer ${adminToken}`)
      res.body.data.forEach((f: any) => expect(f.rating).toBe('negative'))
    })

    it('200 — filtra por messageId', async () => { ... })
    it('200 — filtra por rango de fechas', async () => { ... })
  })

  // GET /api/reports/satisfaction
  describe('GET /api/reports/satisfaction — admin', () => {
    it('200 — retorna métricas de satisfacción', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/reports/satisfaction?from=2026-01-01&to=2026-12-31')
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.status).toBe(200)
      expect(res.body.data).toHaveProperty('positive')
      expect(res.body.data).toHaveProperty('negative')
      expect(res.body.data).toHaveProperty('total')
      expect(res.body.data).toHaveProperty('satisfactionRate')
    })

    it('200 — reporte no incluye emails ni userIds', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/reports/satisfaction')
        .set('Authorization', `Bearer ${adminToken}`)
      expect(JSON.stringify(res.body.data)).not.toMatch(/@/)
      expect(res.body.data).not.toHaveProperty('userIds')
    })

    it('403 — usuario sin rol admin no accede', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/reports/satisfaction')
        .set('Authorization', `Bearer ${token}`)
      expect(res.status).toBe(403)
    })

    it('200 — reporte vacío si no hay feedback en el rango', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/reports/satisfaction?from=2000-01-01&to=2000-01-02')
        .set('Authorization', `Bearer ${adminToken}`)
      expect(res.body.data.total).toBe(0)
    })
  })
})
```

### `feedback.idempotency.spec.ts` — Idempotencia

```typescript
describe('Feedback — Idempotencia', () => {
  it('enviar el mismo feedback 3 veces no crea duplicados', async () => {
    for (let i = 0; i < 3; i++) {
      await request(app.getHttpServer())
        .post('/api/feedback')
        .set('Authorization', `Bearer ${token}`)
        .send({ messageId: seedMessage.id, rating: 'positive' })
    }
    const list = await request(app.getHttpServer())
      .get(`/api/feedback?messageId=${seedMessage.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
    const userFeedbacks = list.body.data.filter((f: any) => f.userId === seedUser.id)
    expect(userFeedbacks).toHaveLength(1)
  })

  it('cambiar rating no duplica — solo actualiza el existente', async () => {
    await request(app.getHttpServer())
      .post('/api/feedback').set('Authorization', `Bearer ${token}`)
      .send({ messageId: seedMessage.id, rating: 'negative' })
    await request(app.getHttpServer())
      .post('/api/feedback').set('Authorization', `Bearer ${token}`)
      .send({ messageId: seedMessage.id, rating: 'positive' })

    const list = await request(app.getHttpServer())
      .get('/api/feedback/me').set('Authorization', `Bearer ${token}`)
    const forMessage = list.body.data.filter((f: any) => f.messageId === seedMessage.id)
    expect(forMessage).toHaveLength(1)
    expect(forMessage[0].rating).toBe('positive')
  })
})
```

---

## Pruebas de Flujo (E2E)

### `feedback.e2e.spec.ts`

```typescript
describe('Flujo completo — Feedback sobre respuesta de IA', () => {
  it('Usuario tiene conversación → mensaje de IA → da feedback → cambia feedback → aparece en reportes', async () => {
    // 1. Obtener mensaje de IA de la conversación seed
    const msgs = await request(app.getHttpServer())
      .get(`/api/conversations/${seedConvId}/messages`)
      .set('Authorization', `Bearer ${token}`)
    const aiMsg = msgs.body.data.find((m: any) => m.senderType === 'ai')

    // 2. Dar feedback negativo
    await request(app.getHttpServer())
      .post('/api/feedback')
      .set('Authorization', `Bearer ${token}`)
      .send({ messageId: aiMsg.id, rating: 'negative', comment: 'No fue útil' })

    // 3. Verificar feedback en /me
    const myFeedback = await request(app.getHttpServer())
      .get('/api/feedback/me').set('Authorization', `Bearer ${token}`)
    expect(myFeedback.body.data.some((f: any) => f.messageId === aiMsg.id && f.rating === 'negative')).toBe(true)

    // 4. Cambiar a positivo
    await request(app.getHttpServer())
      .post('/api/feedback')
      .set('Authorization', `Bearer ${token}`)
      .send({ messageId: aiMsg.id, rating: 'positive', comment: 'Reconsideré' })

    // 5. Verificar actualización (no duplicado)
    const updated = await request(app.getHttpServer())
      .get('/api/feedback/me').set('Authorization', `Bearer ${token}`)
    const forMsg = updated.body.data.filter((f: any) => f.messageId === aiMsg.id)
    expect(forMsg).toHaveLength(1)
    expect(forMsg[0].rating).toBe('positive')

    // 6. Verificar que aparece en el reporte de admin
    const report = await request(app.getHttpServer())
      .get('/api/reports/satisfaction')
      .set('Authorization', `Bearer ${adminToken}`)
    expect(report.body.data.positive).toBeGreaterThan(0)
  })
})
```

---

## Criterios de Aceptación

| Nivel | Cobertura mínima | Foco especial |
|-------|-----------------|---------------|
| Unitaria | 80% use-cases | Upsert, privacidad en reportes |
| Integración | 100% endpoints | Control admin vs. usuario |
| Idempotencia | 2 tests explícitos | No duplicados tras N envíos |
| Flujo | 1 E2E completo | Feedback → actualización → reporte |

---

## Tareas

1. [ ] Unitarias para `SubmitFeedbackUseCase`, `GetFeedbackUseCase`, `GenerateReportUseCase`.
2. [ ] Prueba unitaria: reporte no contiene datos identificables de usuarios.
3. [ ] Integración: POST /feedback con todos los casos (201, 400, 403, 404).
4. [ ] Integración: upsert — mismo usuario mismo mensaje no duplica.
5. [ ] Integración: GET /feedback/me — aislación de datos.
6. [ ] Integración: GET /reports/satisfaction — acceso admin, filtros, reporte vacío.
7. [ ] Suite de idempotencia: 3 envíos consecutivos = 1 registro.
8. [ ] E2E: ciclo completo feedback → cambio → reporte.
9. [ ] Cobertura ≥ 80%.

---

## Recomendaciones

- **Idempotencia como constraint de DB**: la unicidad de feedback por `(userId, messageId)` debe estar garantizada a nivel de DB con un unique constraint, no solo en la lógica de aplicación. Agregar un test que intente insertar el duplicado directamente en la DB para verificar que el constraint existe.
- **Privacidad en reportes**: los reportes de admin deben exponer métricas agregadas (conteos, porcentajes) nunca listas de usuarios o sus comentarios individuales. Verificar con `toHaveProperty` y con inspección del string JSON completo de la respuesta.
- **Feedback sobre mensajes de usuario vs. IA**: el feedback normalmente aplica solo a mensajes generados por IA. Si el módulo restringe esto, verificar con un test que intentar dar feedback sobre un mensaje de tipo `user` retorna 400 o 422.
- **Comentarios como opcionales**: el campo `comment` nunca debe ser requerido. Un usuario debe poder dar thumbs down sin escribir nada. Verificar explícitamente.
- **Reporte con rango de fechas**: la query del reporte debe usar `sentAt` del mensaje o `createdAt` del feedback (definir cuál y ser consistente). Probar que el filtro de fechas realmente excluye datos fuera del rango.

## Prioridad

**Media-Alta** — Feedback alimenta el ciclo de mejora de los modelos de IA. Datos de feedback corruptos (duplicados, rating incorrecto) degradan la calidad del fine-tuning en HU-038/039.
