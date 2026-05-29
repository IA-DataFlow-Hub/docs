# HU 093 - Conectar Editar y Eliminar Proyecto con la API

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-091, HU-092

---

## HU-093: Conectar editar y eliminar proyecto con la API

**Como** usuario autenticado,
**quiero** que editar y eliminar proyectos en el `ProjectManager` persista los cambios en la API,
**para** que las modificaciones sean permanentes.

### Criterios de Aceptación
- El sistema debe llamar a `PATCH /projects/:id` con los campos modificados al guardar edición
- El sistema debe llamar a `DELETE /projects/:id` al confirmar eliminación
- El sistema debe actualizar/eliminar el proyecto en el contexto local tras respuesta exitosa de la API
- El sistema debe mostrar error si la API falla (ej: proyecto no encontrado 404, sin permisos 403)
- El sistema debe mantener el diálogo de confirmación existente antes de eliminar

### Notas
- Depende de HU-091, HU-092
