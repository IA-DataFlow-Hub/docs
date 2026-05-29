# HU 082 - Conectar Formulario de Edición de Perfil con la API

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-081

---

## HU-082: Conectar formulario de edición de perfil con la API

**Como** usuario autenticado,
**quiero** poder actualizar mi nombre y datos de perfil desde la pantalla de configuración,
**para** mantener mi información actualizada en el sistema.

### Criterios de Aceptación
- El sistema debe llamar a `PATCH /users/me` al guardar cambios en la sección de perfil del Dashboard (vista `settings` o `profile`)
- El sistema debe pre-rellenar el formulario con los datos actuales del usuario (obtenidos en HU-081)
- El sistema debe mostrar un mensaje de éxito al guardar correctamente
- El sistema debe mostrar el error de la API si falla (ej: email duplicado)
- El sistema debe actualizar el `AuthContext` local con los nuevos datos tras una respuesta exitosa

### Notas
- Hay una vista `profile` y una vista `settings` en `Dashboard.tsx` — identificar cuál tiene el formulario de datos del usuario
- Depende de HU-081
