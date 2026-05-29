# HU 103 - Panel de Auditoría — Snapshots y Revertir Cambios

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-101

---

## HU-103: Listar snapshots de auditoría y revertir cambios desde el panel admin

**Como** administrador del sistema,
**quiero** ver los snapshots de cambios en la base de datos y poder revertir uno específico,
**para** restaurar el estado anterior de un registro cuando se realizó un cambio incorrecto.

### Criterios de Aceptación
- El sistema debe mostrar una pestaña "Snapshots" dentro del panel de auditoría (junto a "Logs")
- El sistema debe llamar a `GET /audits` con paginación y filtros (tableName, action, userId, reverted) al cargar la pestaña
- El sistema debe mostrar una tabla con columnas: Tabla, ID Registro, Acción, Usuario, Revertido, Fecha
- El sistema debe mostrar visualmente diferenciado los snapshots ya revertidos (`reverted: true`) — por ejemplo con badge o fila tachada
- El sistema debe mostrar un botón "Revertir" en cada fila NO revertida
- El sistema debe mostrar un diálogo de confirmación antes de revertir ("¿Revertir este cambio? Se restaurará el estado anterior del registro")
- El sistema debe llamar a `POST /audits/:id/revert` al confirmar
- El sistema debe actualizar la fila a "Revertido" inmediatamente tras respuesta exitosa
- El sistema debe mostrar error 409 si el snapshot ya fue revertido previamente

### Notas
- `dataOld` y `dataNew` del snapshot se muestran en un modal de detalle (igual que en HU-102)
- Depende de HU-101 (panel admin ya disponible)
