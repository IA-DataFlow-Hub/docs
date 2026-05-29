# HU 075 - Crear Cliente HTTP Base con Interceptores JWT

> **Prioridad:** 🟠 High / Alta — Crítica

> **Tamaño:** M — Estándar — un día completo (4–8h) (4–8h)

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)

---

## HU-075: Crear cliente HTTP base con interceptores JWT

**Como** desarrollador del frontend,
**quiero** tener un cliente HTTP centralizado con interceptores para adjuntar el access token y manejar errores 401,
**para** que todas las llamadas a la API sean consistentes sin duplicar lógica de autenticación.

### Criterios de Aceptación
- El sistema debe crear una instancia de `axios` (o `fetch` wrapper) configurada con `baseURL` apuntando a `VITE_API_URL`
- El sistema debe adjuntar el header `Authorization: Bearer <token>` automáticamente en cada petición si existe token en `localStorage`/`sessionStorage`
- El sistema debe interceptar respuestas con código `401` y redirigir al usuario a `/login` limpiando los tokens almacenados
- El sistema debe exportar el cliente como módulo reutilizable en `src/app/lib/apiClient.ts`
- El sistema debe manejar errores de red (no conexión) con un error tipado que el resto del código pueda identificar

### Notas
- Prerequisito obligatorio para todas las HUs de integración (HU-076 en adelante)
- El refresh automático de token se implementa en HU-079; esta HU solo cubre la intercepción básica de 401
- La URL base debe leerse de variable de entorno: `VITE_API_URL=http://localhost:3001`
