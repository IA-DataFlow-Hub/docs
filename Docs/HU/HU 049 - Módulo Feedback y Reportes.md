# HU-049 — Módulo de Feedback y Reportes

## Asignación de Tablas

`message_feedback` · `reports`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Feedback y Reportes siguiendo Clean Architecture,  
**Para** registrar reacciones (like/dislike) sobre mensajes de IA, gestionar reportes de abuso o incidencias vinculados a mensajes, conversaciones o proyectos, y permitir la resolución de reportes con trazabilidad de estado.

**Dependencia:** Requiere HU-043 (Projects), HU-044 (Files), HU-045 (Conversations) y HU-047 (AI Jobs).

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/feedback/
├── feedback.module.ts
├── domain/
│   ├── entities/
│   │   ├── message-feedback.entity.ts
│   │   └── report.entity.ts
│   └── repositories/
│       ├── message-feedback.repository.interface.ts
│       └── report.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── submit-feedback.dto.ts
│   │   ├── create-report.dto.ts
│   │   ├── resolve-report.dto.ts
│   │   ├── feedback-response.dto.ts
│   │   └── report-response.dto.ts
│   ├── use-cases/
│   │   ├── submit-message-feedback.use-case.ts
│   │   ├── toggle-feedback.use-case.ts
│   │   ├── create-report.use-case.ts
│   │   ├── resolve-report.use-case.ts
│   │   └── list-reports.use-case.ts
│   └── facades/
│       └── feedback.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── feedback.controller.ts
    └── persistence/
        ├── prisma-message-feedback.repository.ts
        ├── prisma-report.repository.ts
        └── mappers/
            ├── message-feedback.mapper.ts
            └── report.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Feedback único por usuario y mensaje

**Dado** que se recibe `SubmitFeedbackDto` con `id_message` y `feedback_type` (`like` | `dislike`)  
**Cuando** `SubmitMessageFeedbackUseCase` ejecuta  
**Entonces:**
- Verifica que el mensaje exista y no haya sido eliminado.
- La constraint `uq_feedback_unique (id_message, id_user)` garantiza un único feedback por combinación; si ya existe, lanza `FeedbackAlreadySubmittedException`.
- Persiste en `message_feedback` con `id_user` del contexto JWT.
- Retorna `FeedbackResponseDto` con `id_feedback`, `feedback_type`, `id_message` y `created_at`.

### Escenario 2 — Toggle de feedback (cambiar o retirar reacción)

**Dado** que el usuario ya tiene un feedback previo sobre el mismo mensaje  
**Cuando** `ToggleFeedbackUseCase` recibe el mismo `id_message` con un `feedback_type` diferente  
**Entonces:**
- Si el nuevo `feedback_type` es igual al existente: elimina el registro (retira la reacción). Retorna `null` con HTTP 204.
- Si el nuevo `feedback_type` es distinto: actualiza `feedback_type` y `updated_at`. Retorna el `FeedbackResponseDto` actualizado.
- La operación se realiza dentro de una transacción para evitar race conditions.

### Escenario 3 — Creación de reporte con validación de referencia

**Dado** que se recibe `CreateReportDto` con `report_type` (`message` | `conversation` | `application`) y el FK correspondiente  
**Cuando** `CreateReportUseCase` evalúa la constraint de referencia  
**Entonces:**
- Si `report_type = 'message'`: requiere `id_message NOT NULL`; lanza `ReportReferenceMissingException` si falta.
- Si `report_type = 'conversation'`: requiere `id_conversation NOT NULL`.
- Si `report_type = 'application'`: `id_message` e `id_conversation` deben ser `null`.
- Persiste en `reports` con `status = 'pending'`, `category` (default `'other'`) y `priority` (default `'medium'`).
- Retorna `ReportResponseDto` con el `id_report` asignado.

### Escenario 4 — Resolución de reporte con auditoría de estado

**Dado** que un administrador envía `ResolveReportDto` con `id_report` y `status` (`resolved` | `dismissed`)  
**Cuando** `ResolveReportUseCase` ejecuta  
**Entonces:**
- La entidad `Report` define transiciones válidas: `pending` → `in_review` → `resolved` | `dismissed`.
- Si la transición no es válida, lanza `InvalidReportTransitionException`.
- Actualiza `status`, `resolved_at = now()` y `updated_by` del usuario autenticado.
- Los reportes con `deleted_at IS NOT NULL` no son accesibles; lanza `ReportNotFoundException`.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/messages/:messageId/feedback` | Enviar feedback sobre un mensaje |
| PUT | `/messages/:messageId/feedback` | Cambiar o retirar feedback |
| GET | `/messages/:messageId/feedback` | Feedback del usuario autenticado en ese mensaje |
| POST | `/reports` | Crear reporte de abuso/incidencia |
| GET | `/reports` | Listar reportes (filtros: `status`, `report_type`, `priority`) |
| GET | `/reports/:id` | Detalle del reporte |
| PATCH | `/reports/:id/status` | Cambiar estado del reporte |
| DELETE | `/reports/:id` | Soft-delete del reporte |

---

## Notas Técnicas

- `MessageRepositoryInterface` (HU-045) es consumida para verificar existencia del mensaje antes de persistir feedback.
- `FeedbackFacade` exporta `getFeedbackSummary(id_message)` retornando `{ likes: number, dislikes: number }` para ser consumido por el módulo de conversaciones en el DTO de mensaje enriquecido.
- Los reportes de tipo `application` no vinculan ninguna entidad específica; se usan para reportar bugs generales de la plataforma.
- La constraint `chk_reports_reference` en la BD sirve como segunda línea de defensa; la validación principal ocurre en el caso de uso.
