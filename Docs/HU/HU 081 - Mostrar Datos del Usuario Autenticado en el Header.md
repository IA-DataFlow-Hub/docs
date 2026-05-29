# HU 081 - Mostrar Datos del Usuario Autenticado en el Header

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075, HU-076

---

## HU-081: Mostrar datos del usuario autenticado en el header

**Como** usuario autenticado,
**quiero** ver mi nombre y avatar en el header del dashboard,
**para** confirmar visualmente que mi sesión está activa con mi cuenta correcta.

### Criterios de Aceptación
- El sistema debe llamar a `GET /users/me` al cargar el Dashboard por primera vez
- El sistema debe mostrar el nombre del usuario en el dropdown del header (actualmente tiene texto hardcodeado)
- El sistema debe mostrar las iniciales del usuario en el avatar si no hay foto de perfil
- El sistema debe guardar los datos del usuario en un contexto global (`AuthContext` o similar) para no repetir la llamada
- El sistema debe manejar el error 401 redirigiendo a login (cubierto por el interceptor de HU-079)

### Notas
- El avatar y nombre están en el `DropdownMenuTrigger` del header en `Dashboard.tsx` alrededor de línea 599+
- Depende de HU-075, HU-076
