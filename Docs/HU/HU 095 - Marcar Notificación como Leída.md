# HU 095 - Marcar Notificación como Leída

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-094

---

## HU-095: Marcar notificación como leída

**Como** usuario autenticado,
**quiero** poder marcar una notificación como leída,
**para** limpiar mi inbox y saber cuáles he atendido.

### Criterios de Aceptación
- El sistema debe llamar a `PATCH /notifications/:id/read` al hacer clic en una notificación o en el botón "Marcar como leída"
- El sistema debe actualizar el estado visual de la notificación a "leída" inmediatamente en la UI (optimistic update)
- El sistema debe decrementar el contador de no leídas en el ícono de la campana
- El sistema debe llamar a `PATCH /notifications/read-all` al hacer clic en "Marcar todas como leídas"
- El sistema debe revertir el estado optimista si la API retorna error

### Notas
- Depende de HU-094
