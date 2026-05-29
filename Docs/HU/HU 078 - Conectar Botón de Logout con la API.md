# HU 078 - Conectar Botón de Logout con la API

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075

---

## HU-078: Conectar botón de Logout con la API

**Como** usuario autenticado,
**quiero** que al hacer clic en "Cerrar Sesión" se llame a `POST /auth/logout` y se limpie mi sesión,
**para** que mi cuenta quede segura al cerrar la aplicación.

### Criterios de Aceptación
- El sistema debe llamar a `POST /auth/logout` al hacer clic en "Cerrar Sesión" en el dropdown del header (`Dashboard.tsx`)
- El sistema debe eliminar el `access_token` y `refresh_token` del almacenamiento local independientemente del resultado de la API
- El sistema debe redirigir a `/login` tras completar el logout
- El sistema debe manejar el caso en que la API devuelva error (limpiar tokens de todas formas y redirigir)

### Notas
- El item de logout está en el `DropdownMenu` del avatar en `Dashboard.tsx` con label `profile.logout`
- Depende de HU-075
