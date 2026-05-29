# HU 096 - Eliminar Notificación

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-094

---

## HU-096: Eliminar notificación

**Como** usuario autenticado,
**quiero** poder eliminar notificaciones de mi inbox,
**para** mantener mi bandeja limpia.

### Criterios de Aceptación
- El sistema debe mostrar un botón o icono de eliminar en cada notificación del `NotificationCenter`
- El sistema debe llamar a `DELETE /notifications/:id` al hacer clic en eliminar
- El sistema debe remover la notificación de la lista local inmediatamente (optimistic update)
- El sistema debe actualizar el contador de no leídas si la notificación eliminada no había sido leída
- El sistema debe revertir la eliminación optimista si la API retorna error

### Notas
- Depende de HU-094
