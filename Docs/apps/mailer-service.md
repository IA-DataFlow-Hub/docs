# Mailer Service — Microservicio de Notificaciones Externas

Microservicio NestJS independiente para el envío de correos electrónicos (y en el futuro SMS y WhatsApp).  
Ubicación: `apps/mailer-service/`  
Puerto: **3002**  
Swagger: `http://localhost:3002/docs`

---

## Arquitectura

```
apps/mailer-service/src/
├── domain/ports/
│   └── notification-channel.port.ts   ← interfaz NotificationChannelPort
├── application/
│   ├── dtos/                           ← request/response DTOs con validación
│   └── use-cases/
│       ├── send-mail.use-case.ts       ← correo simple
│       └── send-template-mail.use-case.ts ← correo con plantilla Handlebars
├── infrastructure/
│   ├── controllers/
│   │   ├── mail.controller.ts          ← POST /mail/send, POST /mail/send-template
│   │   ├── sms.controller.ts           ← POST /sms/send (501 — HU-074)
│   │   ├── whatsapp.controller.ts      ← POST /whatsapp/send (501 — HU-074)
│   │   └── health.controller.ts        ← GET /health
│   ├── providers/
│   │   └── smtp.provider.ts            ← nodemailer, implementa NotificationChannelPort
│   └── templates/                      ← archivos .hbs (Handlebars)
└── common/
    ├── guards/api-key.guard.ts         ← autenticación x-api-key
    ├── logger/app-logger.service.ts    ← Winston centralizado (DI)
    └── middleware/http-logging.middleware.ts ← log de cada request
```

**Canales disponibles:**

| Canal | Estado | Proveedor |
|-------|--------|-----------|
| Email (SMTP) | ✅ Activo | Hostinger / Mailhog (dev) |
| SMS | 🔲 HU-074 | Twilio (pendiente) |
| WhatsApp | 🔲 HU-074 | Meta Cloud API (pendiente) |

---

## Autenticación

Todos los endpoints (excepto `/health`) requieren el header:

```
x-api-key: <valor de MAILER_API_KEY>
```

Si `MAILER_API_KEY` no está configurado, el modo desarrollo acepta cualquier petición.

---

## Endpoints

### `POST /mail/send` — Correo simple

Envía un correo con cuerpo HTML o texto plano.

**Request:**
```json
{
  "to": "usuario@ejemplo.com",
  "subject": "Asunto del correo",
  "body": "<h1>Hola</h1><p>Mensaje aquí.</p>",
  "cc": "copia@ejemplo.com",
  "bcc": "copia-oculta@ejemplo.com"
}
```

- `to`: string o array de strings
- `cc`, `bcc`: opcionales, string o array
- `body`: acepta HTML completo o texto plano

**Response `201`:**
```json
{
  "messageId": "<abc123@mailer.local>",
  "status": "sent"
}
```

**Errores:**
| HTTP | Cuándo |
|------|--------|
| 400 | `to` o `subject` vacíos |
| 401 | API Key inválida o ausente |
| 502 | SMTP rechazó el mensaje o no hay conexión |

---

### `POST /mail/send-template` — Correo con plantilla

Renderiza una plantilla Handlebars (`.hbs`) y la envía.

**Request:**
```json
{
  "to": "usuario@ejemplo.com",
  "subject": "Asunto del correo",
  "templateId": "welcome",
  "data": {
    "name": "Juan Diego",
    "actionUrl": "https://app.ia-dataflow.com/dashboard"
  }
}
```

- `templateId`: nombre del archivo `.hbs` sin extensión
- `data`: objeto con las variables que usa la plantilla
- `to`, `cc`, `bcc`: igual que en `/mail/send`

**Response `201`:** igual que `/mail/send`

**Errores:**
| HTTP | Cuándo |
|------|--------|
| 400 | Campos requeridos vacíos |
| 401 | API Key inválida |
| 404 | `templateId` no existe en `infrastructure/templates/` |
| 422 | Faltan variables requeridas por la plantilla en `data` |
| 502 | Error SMTP |

---

### `GET /health` — Estado del servicio

No requiere autenticación.

**Response `200`:**
```json
{
  "status": "ok",
  "channels": {
    "smtp": "up",
    "sms": "not_implemented",
    "whatsapp": "not_implemented"
  },
  "timestamp": "2026-05-29T22:00:00.000Z"
}
```

Si SMTP no responde: `"status": "degraded"`, `"smtp": "down"`.

---

## Plantillas disponibles

Las plantillas están en `apps/mailer-service/src/infrastructure/templates/`.  
Formato: Handlebars (`.hbs`). Se agregan nuevas plantillas solo añadiendo el archivo — sin cambiar código.

### Variables globales (automáticas)

Estas variables se inyectan en **toda** plantilla sin necesidad de pasarlas en `data`:

| Variable | Valor | Ejemplo en .hbs |
|----------|-------|-----------------|
| `{{year}}` | Año actual (`new Date().getFullYear()`) | `© {{year}} IA-DataFlow Hub` |
| `{{appUrl}}` | `APP_URL` del `.env` | `<a href="{{appUrl}}/dashboard">` |
| `{{supportUrl}}` | `SUPPORT_URL` del `.env` | `<a href="{{supportUrl}}">Soporte</a>` |

El caller puede override una variable global pasándola en `data`.

---

### `welcome` — Bienvenida post-registro

**Cuándo:** Al completar `POST /auth/register` (HU-112).

**Variables requeridas en `data`:**

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `name` | Nombre completo del usuario | `Juan Diego` |
| `actionUrl` | URL del dashboard | `https://app.ia-dataflow.com/dashboard` |

**Body de prueba:**
```json
{
  "to": "usuario@ejemplo.com",
  "subject": "¡Bienvenido a IA-DataFlow Hub!",
  "templateId": "welcome",
  "data": {
    "name": "Juan Diego",
    "actionUrl": "http://localhost:5173/dashboard"
  }
}
```

---

### `reset-password` — Restablecimiento de contraseña

**Cuándo:** Al llamar `POST /auth/forgot-password` (HU-113).

**Variables requeridas en `data`:**

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `name` | Nombre del usuario | `Juan Diego` |
| `resetUrl` | URL del formulario de nueva contraseña con token | `https://app.ia-dataflow.com/reset?token=abc123` |
| `expiresIn` | Tiempo de expiración legible | `24 horas` |

**Body de prueba:**
```json
{
  "to": "usuario@ejemplo.com",
  "subject": "Restablece tu contraseña de IA-DataFlow Hub",
  "templateId": "reset-password",
  "data": {
    "name": "Juan Diego",
    "resetUrl": "http://localhost:5173/reset-password?token=abc123xyz",
    "expiresIn": "24 horas"
  }
}
```

---

### `notification-generic` — Notificación genérica del sistema

**Cuándo:** Para cualquier notificación de sistema que no tenga plantilla dedicada.

**Variables requeridas en `data`:**

| Variable | Descripción | Requerida | Notas |
|----------|-------------|-----------|-------|
| `title` | Título del mensaje | ✓ | También se usa como `<title>` del HTML |
| `message` | Cuerpo del mensaje | ✓ | **Acepta HTML** (`<p>`, `<b>`, `<ul>`, `<a>`, etc.) gracias al triple brace `{{{message}}}` |
| `actionUrl` | URL del botón CTA | ✗ | Si se omite, no se muestra el botón ni el enlace de respaldo |
| `actionLabel` | Texto del botón | ✗ | Requerido si se pasa `actionUrl` |

> **`message` acepta HTML:** el template usa `{{{message}}}` (triple brace Handlebars) lo que permite inyectar HTML completo. Para texto plano funciona igual.

**Body de prueba — con botón:**
```json
{
  "to": "usuario@ejemplo.com",
  "subject": "Tu AI Job ha finalizado",
  "templateId": "notification-generic",
  "data": {
    "title": "Tu AI Job ha finalizado",
    "message": "El análisis de tu dataset <strong>ventas_2026.xlsx</strong> fue completado exitosamente. Puedes ver los resultados en el dashboard.",
    "actionUrl": "http://localhost:5173/dashboard",
    "actionLabel": "Ver resultados"
  }
}
```

**Body de prueba — sin botón:**
```json
{
  "to": "usuario@ejemplo.com",
  "subject": "Aviso del sistema",
  "templateId": "notification-generic",
  "data": {
    "title": "Mantenimiento programado",
    "message": "El sistema estará en mantenimiento el <strong>domingo 1 de junio</strong> de 2:00 a 4:00 AM."
  }
}
```

**Body de prueba — message con lista HTML:**
```json
{
  "to": "usuario@ejemplo.com",
  "subject": "Resumen de cambios",
  "templateId": "notification-generic",
  "data": {
    "title": "Tu proyecto fue actualizado",
    "message": "<p>Se realizaron los siguientes cambios:</p><ul><li>Fase avanzada a EJECUTAR</li><li>3 tareas completadas</li><li>2 miembros agregados</li></ul>",
    "actionUrl": "http://localhost:5173/dashboard",
    "actionLabel": "Ver proyecto"
  }
}
```

---

## Cómo agregar una plantilla nueva

1. Crear `apps/mailer-service/src/infrastructure/templates/<nombre>.hbs`
2. Usar variables Handlebars con `{{variable}}`
3. Las variables `{{year}}`, `{{appUrl}}`, `{{supportUrl}}` están disponibles sin declararlas
4. Llamar `POST /mail/send-template` con `"templateId": "<nombre>"` y las variables en `data`
5. No se requiere ningún cambio de código

**Ejemplo mínimo de plantilla:**
```html
<!DOCTYPE html>
<html lang="es">
<body style="font-family: Arial, sans-serif; padding: 40px;">
  <h1>Hola, {{name}}</h1>
  <p>{{message}}</p>
  <p style="font-size: 12px; color: #888;">
    © {{year}} IA-DataFlow Hub · <a href="{{supportUrl}}">Soporte</a>
  </p>
</body>
</html>
```

---

## Variables de entorno

```env
# Puerto
MAILER_PORT=3002

# Autenticación
MAILER_API_KEY=clave-secreta

# SMTP
MAIL_HOST=smtp.hostinger.com
MAIL_PORT=465
MAIL_USER=notifications@tudominio.com
MAIL_PASS=tu-contraseña
MAIL_FROM=IA-DataFlow Hub <notifications@tudominio.com>
MAIL_SECURE=true          # true para puerto 465 (SSL), false para 587 (TLS)

# URLs globales para plantillas
APP_URL=https://app.ia-dataflow.com
SUPPORT_URL=https://ia-dataflow.com/soporte

# Logs
LOG_LEVEL=info
LOG_DIR=/app/logs
```

**Para desarrollo local con Mailhog** (ver correos en `http://localhost:8025`):
```env
MAIL_HOST=localhost
MAIL_PORT=1025
MAIL_SECURE=false
# MAIL_USER y MAIL_PASS vacíos — Mailhog no requiere auth
```

---

## Logs

Cada acción genera una línea en consola y en archivo rotado diario (`/app/logs/mailer-YYYY-MM-DD.log`):

```
2026-05-29 22:45:01 [INFO ] POST /mail/send 201 142ms [key=***key4]
2026-05-29 22:45:01 [INFO ] mail:sent | to=j***@ejemplo.com | messageId=<abc@mailer> | status=sent

2026-05-29 22:45:10 [INFO ] POST /mail/send-template 201 89ms [key=***key4]
2026-05-29 22:45:10 [INFO ] mail:template | to=j***@ejemplo.com | templateId=welcome | messageId=<xyz@mailer> | status=sent

2026-05-29 22:45:20 [WARN ] POST /sms/send 501 2ms [key=***key4]

2026-05-29 22:45:50 [ERROR] POST /mail/send 502 210ms [key=***key4]
2026-05-29 22:45:50 [ERROR] smtp:error | Connection refused
```

Los destinatarios se **ofuscan** en los logs: `j***@ejemplo.com`.  
Rotación: diaria, comprimido, máximo 30 días.

---

## Levantar el servicio

```bash
# Desarrollo local
cd apps/mailer-service
npm install
npm run start:dev

# Con Docker (incluye Mailhog)
docker-compose up mailer mailhog

# Solo el mailer (SMTP externo configurado en .env)
docker-compose up mailer
```

**URLs con Docker:**
- Mailer API: `http://localhost:3002`
- Swagger: `http://localhost:3002/docs`
- Mailhog (bandeja dev): `http://localhost:8025`


---

## Documentos relacionados

**Backend:** [[api]] · [[DOCKERIZACION]] · [[ARQUITECTURA]]
**HUs:** [[HU 073 - Microservicio de Envío de Correos|HU-073]] · [[HU 074 - Microservicio Notificaciones — Canales SMS y WhatsApp|HU-074]] · [[HU 112 - Plantilla de Correo — Registro Exitoso|HU-112]] · [[HU 113 - Plantilla de Correo — Restablecer Contraseña|HU-113]] · [[HU 114 - Plantilla de Correo — Invitación a Equipo|HU-114]]
