# HU 100 - Asignar Rol de Equipo a Usuario en Proyecto

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-088, HU-092

---

## HU-100: Asignar rol de equipo a un usuario dentro de un proyecto

**Como** propietario o administrador de un proyecto,
**quiero** poder asignar un rol específico de equipo a un usuario dentro del contexto de un proyecto,
**para** controlar qué puede hacer cada miembro del equipo en ese proyecto particular.

### Criterios de Aceptación
- El sistema debe mostrar una sección de "Miembros del Proyecto" en la vista de detalle del proyecto
- El sistema debe listar los miembros actuales del equipo al que pertenece el proyecto
- El sistema debe permitir seleccionar un usuario y un rol de equipo disponible para asignarlo al proyecto
- El sistema debe llamar a `POST /projects/:id/roles` con `{ idUser, idTeamRole }` al confirmar
- El sistema debe mostrar confirmación de éxito y actualizar la lista de miembros con sus roles
- El sistema debe mostrar error 400 si los datos son inválidos y 403 si el usuario no tiene permisos

### Notas
- Depende de HU-088 (ver miembros y roles de equipo disponibles) y HU-092 (proyecto cargado desde API)
- Los roles disponibles se obtienen de `GET /teams/:id/roles` (ya disponible en módulo Teams)
