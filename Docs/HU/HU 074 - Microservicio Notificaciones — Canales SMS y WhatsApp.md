# HU 074 - Microservicio Notificaciones — Canales SMS y WhatsApp

> Generado el 29 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)
> **Depende de:** HU-073 (microservicio base + interfaz `NotificationChannel`)

---

## HU-074: Extensión del microservicio de notificaciones con canales SMS y WhatsApp

**Como** desarrollador o sistema interno del proyecto IA-DataFlow-Hub,
**quiero** extender el microservicio de notificaciones para soportar envío de mensajes por SMS y WhatsApp,
**para** cubrir canales de comunicación adicionales sin duplicar infraestructura ni romper el contrato existente de la API.

---

### Criterios de Aceptación

#### Canal SMS
- El sistema debe exponer `POST /sms/send` que reciba: `to` (número E.164, ej: `+521XXXXXXXXXX`), `body` (texto plano, máx 1600 chars)
- El sistema debe validar formato E.164 en `to`; retornar `400` si inválido
- El sistema debe integrarse con un proveedor SMS configurable vía env vars (`SMS_PROVIDER`, `SMS_API_KEY`, `SMS_FROM`)
- El sistema debe soportar al menos un proveedor concreto (Twilio recomendado) como adaptador de infraestructura
- El sistema debe retornar `201` con `{ messageId, status: "queued" | "sent" }` ante éxito
- El sistema debe retornar `502` si el proveedor falla con error no recuperable

#### Canal WhatsApp
- El sistema debe exponer `POST /whatsapp/send` que reciba: `to` (número E.164), `body` (texto) o `templateId` + `data` para mensajes de plantilla aprobados por Meta
- El sistema debe integrarse con la API de WhatsApp Business (Cloud API de Meta) o Twilio WhatsApp como adaptador de infraestructura
- El sistema debe retornar `201` con el mismo esquema de respuesta que SMS
- El sistema debe retornar `422` si se usa `templateId` y la plantilla no está aprobada en el proveedor

#### Plantillas multi-canal
- El sistema debe permitir que una misma `templateId` tenga variantes por canal (`email`, `sms`, `whatsapp`) resolviendo la correcta según el endpoint invocado
- El sistema debe fallar con `404` si no existe variante para el canal solicitado

#### Arquitectura
- Los adaptadores SMS y WhatsApp deben implementar la misma interfaz `NotificationChannel` definida en HU-073
- El sistema debe permitir activar/desactivar canales vía env var (`CHANNEL_SMS_ENABLED=true`, `CHANNEL_WHATSAPP_ENABLED=true`)
- Canales desactivados deben retornar `503 Service Unavailable` con mensaje descriptivo

#### Observabilidad
- El sistema debe registrar en logs: canal, destinatario ofuscado, `templateId` si aplica, `messageId` del proveedor, resultado
- `/health` debe reportar el estado de conectividad de cada canal habilitado por separado

---

### Notas
- Prerequisito: HU-073 debe estar completada y el microservicio base funcionando
- WhatsApp Business requiere cuenta Meta aprobada y plantillas de mensaje validadas antes de producción; en desarrollo se puede usar la sandbox de Twilio
- Para SMS, Twilio tiene SDK oficial para NestJS; evaluar también Vonage (Nexmo) como alternativa
- El número `from` de WhatsApp debe estar registrado en la cuenta Meta Business; no es configurable arbitrariamente
- Considerar rate limits de cada proveedor al diseñar la capa de infraestructura (backoff/retry)
