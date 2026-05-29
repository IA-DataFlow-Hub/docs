# HU 085 - Crear Equipo desde el Frontend

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-084

---

## HU-085: Crear equipo desde el frontend

**Como** usuario autenticado,
**quiero** poder crear un nuevo equipo desde el Dashboard,
**para** organizar mi trabajo con otros colaboradores.

### Criterios de Aceptación
- El sistema debe mostrar un formulario/modal con campo nombre y descripción del equipo
- El sistema debe llamar a `POST /teams` con `{ name, description }` al confirmar
- El sistema debe agregar el nuevo equipo a la lista local inmediatamente tras respuesta exitosa (optimistic o post-fetch)
- El sistema debe mostrar el error de la API si el nombre ya existe u otro conflicto
- El sistema debe cerrar el modal y mostrar el nuevo equipo seleccionado como activo

### Notas
- Depende de HU-084
