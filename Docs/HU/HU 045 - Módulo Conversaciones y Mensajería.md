# HU-045 — Módulo de Conversaciones y Mensajería

## Asignación de Tablas

`conversations` · `messages` · `message_sender_types`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Conversaciones siguiendo Clean Architecture,  
**Para** gestionar chats entre usuarios y motores de IA dentro de proyectos, registrar mensajes con su tipo de emisor (usuario, IA local, IA cloud, sistema) y mantener el historial paginado con soporte de soft-delete.

**Dependencia:** Requiere HU-043 (Projects) para validar membresía al proyecto.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/conversations/
├── conversations.module.ts
├── domain/
│   ├── entities/
│   │   ├── conversation.entity.ts
│   │   └── message.entity.ts
│   └── repositories/
│       ├── conversation.repository.interface.ts
│       └── message.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── create-conversation.dto.ts
│   │   ├── send-message.dto.ts
│   │   ├── conversation-response.dto.ts
│   │   └── message-response.dto.ts
│   ├── use-cases/
│   │   ├── create-conversation.use-case.ts
│   │   ├── send-user-message.use-case.ts
│   │   ├── send-ai-message.use-case.ts
│   │   ├── get-conversation-history.use-case.ts
│   │   └── soft-delete-conversation.use-case.ts
│   └── facades/
│       └── conversations.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── conversations.controller.ts
    └── persistence/
        ├── prisma-conversation.repository.ts
        ├── prisma-message.repository.ts
        └── mappers/
            ├── conversation.mapper.ts
            └── message.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Registro de mensaje de usuario

**Dado** que se recibe `SendMessageDto` con `id_conversation`, texto de `message` y `id_user` del contexto JWT  
**Cuando** `SendUserMessageUseCase` ejecuta  
**Entonces:**
- Verifica que la conversación pertenezca al proyecto del usuario (consulta `ConversationRepository`).
- Persiste en `messages` con `id_message_sender_type = 1` (user), `id_user` del usuario autenticado e `id_engine = null`.
- Actualiza `conversations.updated_at` para reflejar actividad reciente.
- Retorna `MessageResponseDto` con `sent_at`, el texto y el `sender_type` resuelto desde el catálogo.

### Escenario 2 — Registro de respuesta de motor de IA

**Dado** que el módulo AI Jobs (HU-047) necesita persistir la respuesta generada por un motor  
**Cuando** `SendAiMessageUseCase` es invocado internamente con `id_engine` y `id_message_sender_type = 2` (ai_local) o `3` (ai_cloud)  
**Entonces:**
- Persiste en `messages` con `id_user = null` e `id_engine` referenciando el motor de IA que respondió.
- El mapper resuelve el `type_name` del catálogo `message_sender_types` para incluirlo en el DTO de respuesta.
- Este caso de uso es interno (no expone endpoint HTTP); es invocado desde `ConversationsFacade`.

### Escenario 3 — Paginación de historial de conversación

**Dado** que el frontend solicita el historial con `page = 2` y `limit = 20`  
**Cuando** `GetConversationHistoryUseCase` ejecuta  
**Entonces:**
- El repositorio retorna mensajes con `WHERE deleted_at IS NULL` ordenados por `sent_at ASC`.
- Aplica `SKIP = (page - 1) * limit` y `TAKE = limit` usando Prisma.
- La respuesta incluye `pagination.total`, `pagination.totalPages` y el array `data` de `MessageResponseDto`.

### Escenario 4 — Soft-delete en cascada de conversación

**Dado** que `SoftDeleteConversationUseCase` recibe `id_conversation`  
**Cuando** ejecuta  
**Entonces:**
- Actualiza `conversations.deleted_at` y `conversations.deleted_by`.
- Los `messages` asociados **no se eliminan** (quedan en BD con su `deleted_at` intacto); la conversación simplemente desaparece del listado del usuario.
- Lanza `ConversationNotFoundException` si ya fue eliminada o no pertenece al usuario.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/projects/:projectId/conversations` | Crear conversación |
| GET | `/projects/:projectId/conversations` | Listar conversaciones del proyecto |
| GET | `/conversations/:id` | Detalle de conversación |
| DELETE | `/conversations/:id` | Soft-delete de conversación |
| POST | `/conversations/:id/messages` | Enviar mensaje de usuario |
| GET | `/conversations/:id/messages` | Historial paginado de mensajes |

---

## Notas Técnicas

- `ConversationsFacade` exporta `createAiMessage(dto)` para ser invocado desde HU-047 (AI Jobs) al recibir la respuesta del motor de IA.
- `MessageRepositoryInterface` es exportada y consumida por HU-049 (Feedback & Reports) para vincular feedback a mensajes.
- El catálogo `message_sender_types` es de solo lectura (sembrado en migración). El mapper resuelve el `type_name` usando el `id_message_sender_type` almacenado en la BD.
