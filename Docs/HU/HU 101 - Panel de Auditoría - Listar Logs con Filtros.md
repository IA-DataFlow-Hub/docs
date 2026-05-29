# HU 101 - Panel de Auditoría — Listar Logs con Filtros

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075, HU-080

---

## HU-101: Crear panel de auditoría para administradores — listar logs

**Como** administrador del sistema,
**quiero** tener una vista dedicada en el Dashboard que muestre los logs de auditoría con filtros,
**para** monitorear las acciones realizadas por usuarios en el sistema.

### Criterios de Aceptación
- El sistema debe mostrar una ruta o sección `/admin/audit` accesible solo para usuarios con rol `admin`
- El sistema debe redirigir a `/dashboard` con mensaje de error si el usuario no es admin
- El sistema debe llamar a `GET /audit-logs` con paginación (page, limit) al cargar la vista
- El sistema debe mostrar una tabla con columnas: Usuario, Proyecto, Acción, Entidad, IP, Fecha
- El sistema debe exponer filtros por: idUser (input), idProject (input), action (input), entityType (select), from/to (date pickers)
- El sistema debe aplicar los filtros al llamar de nuevo a `GET /audit-logs` con los query params correspondientes
- El sistema debe implementar paginación con botones Anterior/Siguiente y mostrar el total de registros
- El sistema debe mostrar un spinner durante la carga y un estado vacío si no hay logs

### Notas
- Acceso solo admin — verificar con `GET /users/me` que el usuario tiene `role: "admin"` antes de renderizar
- Depende de HU-075 (cliente HTTP), HU-080 (rutas protegidas)
