# HU 112 - Plantilla de Correo — Registro Exitoso

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-073, HU-077

---

## HU-112: Enviar correo de bienvenida al completar el registro

**Como** usuario nuevo,
**quiero** recibir un correo de bienvenida cuando creo mi cuenta en IA-DataFlow Hub,
**para** confirmar que mi registro fue exitoso y tener acceso rápido a la plataforma.

### Criterios de Aceptación

#### Plantilla (`welcome.hbs`)
- El sistema debe mejorar la plantilla `welcome.hbs` existente con el siguiente contenido:
  - Logo y nombre de la plataforma en el header
  - Saludo personalizado: "¡Bienvenido, {{name}}!"
  - Resumen de qué puede hacer en la plataforma (ETL, IA, colaboración)
  - Botón CTA: "Acceder a la plataforma" → `{{actionUrl}}`
  - Footer con © y enlace de soporte

#### Variables requeridas de la plantilla

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `name` | Nombre completo del usuario | `Juan Diego` |
| `email` | Email registrado | `juan@ejemplo.com` |
| `actionUrl` | URL del dashboard | `https://app.ia-dataflow.com/dashboard` |

#### Integración con el módulo Auth
- El sistema debe llamar a `POST /mail/send-template` del mailer-service al completar exitosamente `POST /auth/register`
- La llamada debe hacerse de forma **asíncrona** (fire-and-forget) — si el correo falla, el registro igual es exitoso
- El sistema debe usar `templateId: "welcome"` con las variables del usuario recién creado

#### Configuración de la llamada desde el API principal
- La URL del mailer-service debe leerse de la variable de entorno `MAILER_SERVICE_URL` (ej: `http://mailer:3002`)
- La API Key debe leerse de `MAILER_API_KEY`
- Timeout máximo de la llamada: 5 segundos

### Notas
- La plantilla `welcome.hbs` ya existe en `apps/mailer-service/src/infrastructure/templates/` — mejorar su diseño
- No bloquear el response del registro si el correo falla — loguear el error y continuar
- Asunto sugerido: "¡Bienvenido a IA-DataFlow Hub, {{name}}!"
