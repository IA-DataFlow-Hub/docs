# HU 083 - Conectar Formulario de Cambio de Contraseña

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075, HU-076

---

## HU-083: Conectar formulario de cambio de contraseña

**Como** usuario autenticado,
**quiero** poder cambiar mi contraseña desde la pantalla de configuración de seguridad,
**para** mantener mi cuenta segura.

### Criterios de Aceptación
- El sistema debe exponer un formulario con campos: "Contraseña actual", "Nueva contraseña", "Confirmar nueva contraseña" en la sección Seguridad del Dashboard
- El sistema debe validar en cliente que nueva contraseña y confirmación coincidan
- El sistema debe llamar a `POST /auth/change-password` con `{ currentPassword, newPassword }`
- El sistema debe mostrar un mensaje de éxito y limpiar los campos del formulario tras respuesta exitosa
- El sistema debe mostrar el error de la API si la contraseña actual es incorrecta (`400` o `401`)
- El sistema debe mostrar indicador de carga mientras la petición está en vuelo

### Notas
- Depende de HU-075, HU-076
