# HU 079 - Implementar Refresh Automático de Access Token

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075

---

## HU-079: Implementar refresh automático de access token

**Como** usuario autenticado,
**quiero** que cuando mi access token expire la aplicación lo renueve automáticamente usando el refresh token,
**para** no ser expulsado de mi sesión mientras sigo usando la aplicación.

### Criterios de Aceptación
- El sistema debe interceptar respuestas `401` en el cliente HTTP e intentar llamar a `POST /auth/refresh` con el `refresh_token`
- El sistema debe reintentar la petición original con el nuevo `access_token` si el refresh fue exitoso
- El sistema debe redirigir a `/login` limpiando todos los tokens si el refresh también retorna `401` (refresh token expirado)
- El sistema debe evitar múltiples llamadas paralelas a `/auth/refresh` (usar un flag o cola de espera)

### Notas
- Extensión del interceptor creado en HU-075
- Este comportamiento es transparente para el usuario — no ve ningún cambio en la UI
- Depende de HU-075
