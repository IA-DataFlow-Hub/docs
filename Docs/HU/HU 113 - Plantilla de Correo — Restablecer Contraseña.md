# HU 113 - Plantilla de Correo — Restablecer Contraseña

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-073

---

## HU-113: Enviar correo de restablecimiento de contraseña

**Como** usuario registrado que olvidó su contraseña,
**quiero** recibir un correo con un enlace seguro para crear una nueva contraseña,
**para** recuperar el acceso a mi cuenta sin contactar soporte.

### Criterios de Aceptación

#### Plantilla (`reset-password.hbs`)
- El sistema debe mejorar la plantilla `reset-password.hbs` existente con:
  - Header con logo y título "Restablece tu contraseña"
  - Saludo personalizado: "Hola, {{name}}"
  - Mensaje explicando que se solicitó restablecer la contraseña
  - Botón CTA rojo/naranja: "Restablecer contraseña" → `{{resetUrl}}`
  - Aviso de expiración: "Este enlace expira en {{expiresIn}}"
  - Aviso de seguridad: "Si no solicitaste este cambio, ignora este correo"
  - Footer con © y nota de seguridad

#### Variables requeridas de la plantilla

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `name` | Nombre del usuario | `Juan Diego` |
| `resetUrl` | URL del formulario de nueva contraseña con token | `https://app.ia-dataflow.com/reset?token=abc123` |
| `expiresIn` | Tiempo de expiración legible | `24 horas` |

#### Backend requerido (nuevo endpoint)
- El sistema debe exponer `POST /auth/forgot-password` en el API principal que reciba `{ email }`
- El sistema debe generar un token seguro (`crypto.randomBytes(32).toString('hex')`) con expiración de 24h
- El sistema debe guardar el token hasheado en DB (nueva tabla `password_reset_tokens` o campo en `users`)
- El sistema debe llamar al mailer-service con `templateId: "reset-password"` de forma **asíncrona**
- El sistema debe retornar siempre `200` con el mismo mensaje genérico, independientemente de si el email existe ("Si el correo está registrado, recibirás un enlace") — para no revelar qué emails existen
- El sistema debe exponer `POST /auth/reset-password` que reciba `{ token, newPassword }` y aplique el cambio

#### Seguridad
- El token debe ser de un solo uso — invalidarlo tras usarse
- El token debe expirar a las 24 horas de generación
- El endpoint no debe revelar si el email existe o no (siempre 200 con mensaje genérico)

### Notas
- La plantilla `reset-password.hbs` ya existe — mejorar diseño
- Asunto sugerido: "Restablece tu contraseña de IA-DataFlow Hub"
