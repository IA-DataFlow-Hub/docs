# HU 076 - Conectar Formulario de Login con la API

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-075

---

## HU-076: Conectar formulario de Login con la API

**Como** usuario,
**quiero** que al enviar el formulario de Login se llame a `POST /auth/login` con mis credenciales,
**para** obtener un token real y acceder al dashboard con mi sesión autenticada.

### Criterios de Aceptación
- El sistema debe leer los valores de email y contraseña del formulario en `Login.tsx`
- El sistema debe llamar a `POST /auth/login` con `{ email, password }`
- El sistema debe guardar el `access_token` y `refresh_token` recibidos (localStorage o cookie httpOnly si aplica)
- El sistema debe redirigir a `/dashboard` tras login exitoso
- El sistema debe mostrar un mensaje de error bajo el formulario si la API retorna `401` (credenciales inválidas)
- El sistema debe mostrar un indicador de carga (`loading`) en el botón mientras la petición está en vuelo
- El sistema debe deshabilitar el botón de submit durante la petición para evitar doble envío

### Notas
- Actualmente `handleLogin` en `Login.tsx` solo navega sin validar — reemplazar esa lógica
- Depende de HU-075 (cliente HTTP)
