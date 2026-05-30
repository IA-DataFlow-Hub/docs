# HU 114 - Plantilla de Correo — Invitación a Equipo

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-073, HU-089

---

## HU-114: Enviar correo de invitación cuando un usuario es agregado a un equipo

**Como** usuario invitado a un equipo,
**quiero** recibir un correo notificándome que fui agregado a un equipo en IA-DataFlow Hub,
**para** saber quién me invitó, en qué equipo y poder acceder directamente.

### Criterios de Aceptación

#### Plantilla (nueva: `team-invitation.hbs`)
- El sistema debe crear la plantilla `team-invitation.hbs` en `apps/mailer-service/src/infrastructure/templates/` con:
  - Header con logo
  - Título: "Te han invitado a un equipo"
  - Mensaje: "{{inviterName}} te ha agregado al equipo **{{teamName}}** con el rol de **{{roleName}}**"
  - Botón CTA: "Ver el equipo" → `{{teamUrl}}`
  - Sección de información del equipo: nombre, descripción (si existe), número de miembros
  - Footer con © y enlace para gestionar notificaciones

#### Variables requeridas de la plantilla

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `inviteeName` | Nombre del invitado | `María García` |
| `inviterName` | Nombre de quien invitó | `Juan Diego` |
| `teamName` | Nombre del equipo | `Data Science Team` |
| `teamDescription` | Descripción del equipo (opcional) | `Equipo de análisis de datos` |
| `roleName` | Rol asignado | `Member` |
| `teamUrl` | URL del equipo en la plataforma | `https://app.ia-dataflow.com/teams/uuid` |

#### Integración con módulo Teams
- El sistema debe llamar al mailer-service con `templateId: "team-invitation"` al completar exitosamente `POST /teams/:id/members` (HU-089)
- La llamada debe hacerse de forma **asíncrona** (fire-and-forget)
- El sistema debe obtener el email del usuario invitado desde el módulo Users

### Notas
- Crear archivo `team-invitation.hbs` desde cero (no existe aún)
- Asunto sugerido: "{{inviterName}} te invitó a unirse a {{teamName}} en IA-DataFlow Hub"
- El correo solo se envía si el usuario invitado tiene email verificado
