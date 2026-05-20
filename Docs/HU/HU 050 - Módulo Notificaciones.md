# HU-050 — Módulo de Notificaciones

## Asignación de Tablas

`notifications` · `notification_recipients` · `notification_groups` · `notification_group_members`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Notificaciones siguiendo Clean Architecture,  
**Para** crear y distribuir notificaciones dirigidas a usuarios individuales o grupos, gestionar el estado de entrega (pending → sent → delivered → read), permitir notificaciones globales del sistema y agrupar destinatarios en grupos vinculados a equipos o proyectos.

**Dependencia:** Requiere HU-042 (Teams) y HU-043 (Projects) para las relaciones de FK con equipos y proyectos.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/notifications/
├── notifications.module.ts
├── domain/
│   ├── entities/
│   │   ├── notification.entity.ts
│   │   ├── notification-recipient.entity.ts
│   │   └── notification-group.entity.ts
│   └── repositories/
│       ├── notification.repository.interface.ts
│       └── notification-group.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── create-notification.dto.ts
│   │   ├── dispatch-to-group.dto.ts
│   │   ├── mark-read.dto.ts
│   │   ├── notification-response.dto.ts
│   │   └── notification-group-response.dto.ts
│   ├── use-cases/
│   │   ├── create-notification.use-case.ts
│   │   ├── dispatch-notification-to-group.use-case.ts
│   │   ├── mark-notification-read.use-case.ts
│   │   ├── get-user-inbox.use-case.ts
│   │   ├── create-notification-group.use-case.ts
│   │   └── add-member-to-group.use-case.ts
│   └── facades/
│       └── notifications.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── notifications.controller.ts
    └── persistence/
        ├── prisma-notification.repository.ts
        ├── prisma-notification-group.repository.ts
        └── mappers/
            ├── notification.mapper.ts
            └── notification-group.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Creación y despacho de notificación a destinatarios individuales

**Dado** que se recibe `CreateNotificationDto` con `title`, `message`, `notification_type` y un array `recipient_ids`  
**Cuando** `CreateNotificationUseCase` ejecuta  
**Entonces:**
- Inserta el registro en `notifications` con `is_global = false` y los FK opcionales (`id_project`, `id_team`, `source_entity_type`, `source_entity_id`).
- Dentro de una transacción `$transaction`:
  1. Por cada `id_user` en `recipient_ids`, inserta en `notification_recipients` con `delivery_status = 'pending'` e `is_read = false`.
  2. La constraint `uq_notification_recipient (id_notification, id_user)` evita duplicados; en caso de conflicto, el repositorio omite el duplicado (`upsert` con `skipDuplicates`).
- Retorna `NotificationResponseDto` con el total de destinatarios registrados.

### Escenario 2 — Despacho a grupo de notificación

**Dado** que `DispatchToGroupDto` incluye `id_notification` e `id_group_notification`  
**Cuando** `DispatchNotificationToGroupUseCase` ejecuta  
**Entonces:**
- Consulta todos los miembros activos del grupo desde `notification_group_members`.
- Inserta en `notification_recipients` un registro por cada miembro (ignorando duplicados si alguno ya era destinatario individual).
- Actualiza `sent_at = now()` en los nuevos recipients.
- Lanza `NotificationGroupNotFoundException` si el grupo no existe o tiene `deleted_at IS NOT NULL`.

### Escenario 3 — Marcar notificación como leída

**Dado** que el usuario autenticado solicita marcar una notificación como leída  
**Cuando** `MarkNotificationReadUseCase` recibe `id_notification`  
**Entonces:**
- Localiza el registro en `notification_recipients` con `id_notification` + `id_user` del JWT.
- Si `is_read = true`, retorna sin modificar (idempotente).
- Si `is_read = false`: actualiza `is_read = true`, `read_at = now()` y `delivery_status = 'read'`.
- Lanza `RecipientNotFoundException` si el usuario no es destinatario de esa notificación.

### Escenario 4 — Bandeja de entrada paginada del usuario

**Dado** que el frontend solicita la bandeja con filtro `?is_read=false&page=1&limit=20`  
**Cuando** `GetUserInboxUseCase` ejecuta  
**Entonces:**
- Consulta `notification_recipients` filtrando por `id_user` del JWT y el `is_read` recibido.
- Hace join con `notifications` excluyendo las que tienen `deleted_at IS NOT NULL`.
- Ordena por `notifications.created_at DESC` (más recientes primero).
- Aplica paginación estándar y retorna `{ data: NotificationResponseDto[], pagination: { total, totalPages } }`.
- Incluye contador `unread_count` con el total de `is_read = false` del usuario (calculado en query separada).

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/notifications` | Crear y despachar notificación |
| GET | `/notifications/inbox` | Bandeja de entrada del usuario autenticado |
| PATCH | `/notifications/:id/read` | Marcar como leída |
| PATCH | `/notifications/read-all` | Marcar todas como leídas |
| DELETE | `/notifications/:id` | Soft-delete de notificación (admin) |
| POST | `/notification-groups` | Crear grupo de notificación |
| GET | `/notification-groups` | Listar grupos (filtros: `id_team`, `id_project`) |
| POST | `/notification-groups/:id/members` | Agregar miembro al grupo |
| DELETE | `/notification-groups/:id/members/:userId` | Remover miembro del grupo |

---

## Notas Técnicas

- `NotificationsFacade` exporta `sendSystemNotification(userId, title, message)` para ser invocado desde otros módulos (AI Jobs al completar, ETL al fallar, etc.) sin acoplamiento directo.
- Las notificaciones con `is_global = true` se muestran a todos los usuarios; en este caso `notification_recipients` queda vacío y el inbox las resuelve con una query adicional.
- Los grupos de notificación con `id_team` o `id_project` se actualizan automáticamente cuando se agrega un miembro al equipo/proyecto (responsabilidad de HU-042 y HU-043 invocar `AddMemberToGroupUseCase`).
- `delivery_status` sigue la secuencia: `pending` → `sent` → `delivered` → `read`. Los canales de entrega externos (email, push) son responsabilidad de adaptadores externos inyectados vía interfaz.
