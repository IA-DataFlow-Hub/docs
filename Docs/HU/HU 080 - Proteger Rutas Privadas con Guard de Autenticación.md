# HU 080 - Proteger Rutas Privadas con Guard de Autenticación

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-076

---

## HU-080: Proteger rutas privadas con guard de autenticación

**Como** usuario no autenticado,
**quiero** que al intentar acceder a `/dashboard` o cualquier ruta protegida sea redirigido a `/login`,
**para** que no pueda usar la aplicación sin haber iniciado sesión.

### Criterios de Aceptación
- El sistema debe crear un componente `PrivateRoute` (o `AuthGuard`) que verifique la existencia de un token válido
- El sistema debe redirigir a `/login` si no hay token presente al intentar acceder a `/dashboard`
- El sistema debe aplicar `PrivateRoute` a la ruta `/dashboard` en `routes.tsx`
- El sistema debe preservar la URL solicitada y redirigir al usuario a ella tras un login exitoso (ej: intentó ir a `/dashboard`, fue a `/login`, después del login vuelve a `/dashboard`)
- Las rutas públicas (`/`, `/login`, `/register`, `/nuestro-equipo`) no deben verse afectadas

### Notas
- Depende de HU-076 (tokens disponibles tras login)
