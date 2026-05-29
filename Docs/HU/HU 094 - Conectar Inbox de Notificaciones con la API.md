# HU 094 - Conectar Inbox de Notificaciones con la API

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075, HU-080

---

## HU-094: Conectar inbox de notificaciones con la API

**Como** usuario autenticado,
**quiero** que el `NotificationCenter` cargue mis notificaciones reales desde la API,
**para** ver avisos relevantes en lugar de notificaciones de ejemplo hardcodeadas.

### Criterios de Aceptación
- El sistema debe llamar a `GET /notifications/inbox` al abrir el `NotificationCenter` (o al montar el Dashboard)
- El sistema debe mostrar la lista paginada de notificaciones reales del usuario
- El sistema debe mostrar el conteo de notificaciones no leídas en el ícono de la campana del header
- El sistema debe actualizar el conteo en tiempo real al marcar notificaciones como leídas
- El sistema debe mostrar un estado vacío si no hay notificaciones

### Notas
- `NotificationCenter.tsx` actualmente usa `useNotifications()` del `NotificationContext` local — agregar carga desde API manteniendo las notificaciones locales de UX (loading, éxito, error de operaciones)
- Depende de HU-075, HU-080
