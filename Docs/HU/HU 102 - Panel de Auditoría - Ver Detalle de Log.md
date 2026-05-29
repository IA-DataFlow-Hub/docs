# HU 102 - Panel de Auditoría — Ver Detalle de Log

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-101

---

## HU-102: Ver detalle de un log de auditoría

**Como** administrador del sistema,
**quiero** ver el detalle completo de un log de auditoría al hacer clic en él,
**para** inspeccionar los valores anteriores y nuevos de la acción registrada.

### Criterios de Aceptación
- El sistema debe abrir un modal o panel lateral al hacer clic en una fila de la tabla de logs
- El sistema debe llamar a `GET /audit-logs/:id` para obtener el detalle completo
- El sistema debe mostrar en el modal: ID del log, usuario, proyecto, acción, entidad, IP, fecha y los campos `oldValue` / `newValue` formateados como JSON legible
- El sistema debe mostrar `oldValue` y `newValue` en un diff visual side-by-side si ambos existen
- El sistema debe mostrar un spinner mientras carga y un mensaje de error si la API retorna 404

### Notas
- Depende de HU-101 (lista de logs con tabla)
