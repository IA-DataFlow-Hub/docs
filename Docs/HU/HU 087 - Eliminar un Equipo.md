# HU 087 - Eliminar un Equipo

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-084

---

## HU-087: Eliminar un equipo

**Como** propietario de un equipo,
**quiero** poder eliminar un equipo que ya no necesito,
**para** mantener mi lista de equipos limpia.

### Criterios de Aceptación
- El sistema debe mostrar un diálogo de confirmación antes de eliminar ("¿Eliminar este equipo? Esta acción no se puede deshacer")
- El sistema debe llamar a `DELETE /teams/:id` tras confirmar
- El sistema debe eliminar el equipo de la lista local tras respuesta exitosa
- El sistema debe mostrar error si el usuario no tiene permisos (403)
- El sistema debe seleccionar automáticamente otro equipo si se elimina el equipo activo actualmente

### Notas
- Depende de HU-084
