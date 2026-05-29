# HU 086 - Editar Nombre y Descripción de un Equipo

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-084, HU-085

---

## HU-086: Editar nombre y descripción de un equipo

**Como** propietario de un equipo,
**quiero** poder editar el nombre y descripción de mi equipo,
**para** mantener la información del equipo actualizada.

### Criterios de Aceptación
- El sistema debe mostrar un formulario pre-rellenado con los datos actuales del equipo al hacer clic en "Editar"
- El sistema debe llamar a `PATCH /teams/:id` con los campos modificados
- El sistema debe actualizar el equipo en la lista local tras respuesta exitosa
- El sistema debe mostrar error si el usuario no tiene permisos para editar (403)
- El sistema debe mostrar indicador de carga durante la petición

### Notas
- Depende de HU-084, HU-085
