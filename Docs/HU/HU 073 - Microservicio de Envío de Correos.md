# HU 073 - Microservicio de Envío de Correos

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)

---

## HU-073: Microservicio de envío de correos electrónicos

**Como** desarrollador o sistema interno del proyecto IA-DataFlow-Hub,
**quiero** contar con un microservicio independiente que exponga una API REST para el envío de correos electrónicos (simple y por plantilla),
**para** centralizar y desacoplar la lógica de envío de comunicaciones externas del resto de los módulos del monorepo.

---

### Criterios de Aceptación

#### Estructura y arquitectura
- El sistema debe existir como microservicio NestJS independiente dentro del monorepo (ej: `apps/mailer-service`)
- El sistema debe seguir Clean Architecture (domain / application / infrastructure)
- El sistema debe exponer una API REST documentada con Swagger
- El sistema debe autenticar las peticiones entrantes (API Key o JWT Bearer según convención del proyecto)

#### Endpoint: correo simple
- El sistema debe exponer `POST /mail/send` que reciba: `to` (string o array), `subject`, `body` (texto plano o HTML), y opcionalmente `cc`, `bcc`
- El sistema debe validar que `to` y `subject` no estén vacíos
- El sistema debe retornar `201` con un objeto `{ messageId, status: "queued" | "sent" }` ante envío exitoso
- El sistema debe retornar `400` con detalle de validación ante datos inválidos
- El sistema debe retornar `502` si el proveedor de correo falla y el error no es recuperable

#### Endpoint: correo por plantilla
- El sistema debe exponer `POST /mail/send-template` que reciba: `to`, `subject`, `templateId` (string), y `data` (objeto con los valores a reemplazar)
- El sistema debe resolver la plantilla referenciada por `templateId` desde almacenamiento interno (archivos `.hbs`, `.mjml`, o similar)
- El sistema debe reemplazar todas las variables `{{ variable }}` de la plantilla con los valores de `data`
- El sistema debe fallar con `404` si `templateId` no existe
- El sistema debe fallar con `422` si faltan variables requeridas por la plantilla en `data`
- El sistema debe retornar `201` con el mismo esquema de respuesta que el endpoint simple

#### Canales y configuración
- El sistema debe usar un proveedor SMTP configurable vía variables de entorno (`MAIL_HOST`, `MAIL_PORT`, `MAIL_USER`, `MAIL_PASS`, `MAIL_FROM`)
- El sistema debe incluir soporte opcional para proveedores alternativos (Resend, SendGrid) como adaptadores intercambiables en infraestructura, aunque solo SMTP se active por defecto
- Los canales SMS y WhatsApp deben estar definidos en la interfaz de dominio (`NotificationChannel`) pero **no implementados** en este sprint (retornan `501 Not Implemented`)

#### Observabilidad
- El sistema debe registrar en logs: destinatario (ofuscado), `templateId` si aplica, `messageId` del proveedor, y resultado (`sent` / `failed`)
- El sistema debe exponer `/health` con estado del servicio y conectividad SMTP

---

### Notas
- Dependencia: requiere credenciales SMTP en `.env` del microservicio
- Los canales SMS y WhatsApp se implementan en HU-074; su interfaz de dominio debe diseñarse aquí para no romper contrato futuro
- Plantillas iniciales sugeridas: `welcome`, `reset-password`, `notification-generic`; el sistema debe ser extensible sin modificar código (solo agregar archivos de plantilla)
- No duplica el módulo HU-050 (notificaciones internas in-app): este microservicio es la capa de entrega a canales externos reales
- Proveedor SMTP recomendado para desarrollo: Mailhog o Mailtrap
