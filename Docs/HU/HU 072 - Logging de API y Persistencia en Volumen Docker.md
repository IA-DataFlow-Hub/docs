# HU-072 — Logging de API y Persistencia en Volumen Docker

> **Asignado:** @juandiegows — Juan Diego Mejía Maestre
> **Prioridad:** 🟠 High / Alta — Crítica

## Asignación

**Responsable:** Juan Diego Mejia Maestre  
**Prioridad:** Alta  
**Dependencias:** HU-036 (Estructura Base NestJS), HU-040 (Auth)

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar un sistema centralizado de logging estructurado para el API NestJS que capture toda actividad de requests con trazabilidad completa del usuario y persista los logs en un volumen Docker dedicado,  
**Para** poder rastrear con exactitud quién hizo qué, cuándo, desde dónde y con qué resultado, sin perder información al reiniciar o recrear los contenedores.

---

## Formato Canónico de Log

Cada entrada de log es una línea JSON con la siguiente estructura. **Todos los campos son obligatorios**; usar `null` cuando no aplique.

```json
{
  "timestamp":      "2026-05-27T14:32:05.123Z",
  "level":          "info",
  "correlationId":  "550e8400-e29b-41d4-a716-446655440000",
  "method":         "POST",
  "url":            "/api/tasks",
  "statusCode":     201,
  "responseTimeMs": 87,
  "userId":         "usr_abc123",
  "userEmail":      "juan@example.com",
  "ip":             "192.168.1.10",
  "browser":        "Chrome 124.0",
  "os":             "Windows 11",
  "userAgent":      "Mozilla/5.0 (Windows NT 10.0; Win64; x64)...",
  "referer":        "https://app.iadataflow.com/tasks",
  "contentLength":  342,
  "message":        "POST /api/tasks 201 87ms"
}
```

> `userId` y `userEmail` se extraen del JWT del request (payload `sub` y `email`). En rutas públicas ambos son `null`.  
> `browser` y `os` se parsean del `User-Agent` usando la librería `ua-parser-js`.  
> `correlationId` es un UUID v4 generado al inicio del request y devuelto al cliente como header `X-Correlation-Id`.

---

## Criterios de Aceptación

### Escenario 1 — Logging centralizado de todos los requests

**Dado** que el API recibe cualquier request HTTP  
**Cuando** el request pasa por el pipeline de NestJS  
**Entonces:**
- Un `LoggingInterceptor` global captura **todos** los requests sin excepción de módulo o controlador
- Cada request genera exactamente **una entrada de log** al finalizar (no al entrar), con el formato canónico definido arriba
- El `correlationId` se genera como UUID v4 al inicio del request y se adjunta como header `X-Correlation-Id` en la respuesta
- Rutas de health-check (`/health`, `/__health`, `/`) quedan excluidas para evitar ruido operacional
- El sistema no require modificar ningún controlador existente; la cobertura es automática y global

### Escenario 2 — Extracción de identidad del usuario desde JWT

**Dado** que el request incluye un Bearer token válido  
**Cuando** el `LoggingInterceptor` procesa el request  
**Entonces:**
- Extrae `userId` del campo `sub` del payload JWT
- Extrae `userEmail` del campo `email` del payload JWT
- Ambos campos quedan registrados en el log **sin necesidad de consultar la base de datos**
- Si el token es inválido, expirado o ausente: `userId = null`, `userEmail = null` (no lanza error)

### Escenario 3 — Datos de cliente y dispositivo

**Dado** que el request incluye headers estándar HTTP  
**Cuando** el interceptor procesa el request  
**Entonces:**
- Se registran los siguientes campos de trazabilidad del cliente:
  - `ip`: IP real del cliente (soporta `X-Forwarded-For` para requests tras proxy/nginx)
  - `userAgent`: header `User-Agent` completo
  - `browser`: nombre y versión del navegador parseado (ej. `"Chrome 124.0"`)
  - `os`: sistema operativo parseado (ej. `"Windows 11"`, `"Android 14"`)
  - `referer`: header `Referer` si está presente, `null` si no
  - `contentLength`: tamaño del body del request en bytes (`0` si no tiene body)

### Escenario 4 — Logging de errores con trazabilidad completa

**Dado** que ocurre una excepción en cualquier capa del API  
**Cuando** el `HttpExceptionFilter` global captura el error  
**Entonces:**
- Genera una entrada de log que **extiende** el formato canónico con campos adicionales:
  ```json
  {
    "...": "todos los campos del formato canónico",
    "errorMessage": "Task not found",
    "errorCode":    "TASK_NOT_FOUND",
    "stack":        "Error: Task not found\n    at ..." 
  }
  ```
- `stack` solo se incluye en `NODE_ENV !== production`
- Niveles de log según código HTTP: `2xx/3xx → info`, `4xx → warn`, `5xx → error`
- El `correlationId` del request original se mantiene en el log de error para correlación

### Escenario 5 — Persistencia en volumen Docker dedicado

**Dado** que el servicio `api` corre en Docker  
**Cuando** se monta el volumen `api_logs`  
**Entonces:**
- El volumen `api_logs` se declara como **named volume** en `docker-compose.yml` y se monta en `/app/logs` del contenedor
- Los archivos se generan en `/app/logs/`:
  - `access-YYYY-MM-DD.log` — requests 2xx y 3xx
  - `warn-YYYY-MM-DD.log` — errores 4xx
  - `error-YYYY-MM-DD.log` — errores 5xx y excepciones no capturadas
  - `combined-YYYY-MM-DD.log` — todos los niveles (usado para búsqueda por `correlationId`)
- Los logs persisten tras `docker compose down` (sin flag `-v`) y `docker compose restart`

### Escenario 6 — Rotación y retención automática

**Dado** que el sistema genera logs continuamente  
**Cuando** un archivo de log supera 10 MB o cambia el día  
**Entonces:**
- Se rota automáticamente con `winston-daily-rotate-file`:
  - Un archivo nuevo por día por tipo (`access`, `warn`, `error`, `combined`)
  - Retención máxima: **14 días**
  - Archivos rotados se comprimen en `.gz` automáticamente
- La rotación no interrumpe el servicio ni pierde logs en tránsito

### Escenario 7 — Niveles configurables por entorno

**Dado** que el API corre en diferentes entornos  
**Cuando** se inicia el contenedor  
**Entonces:**
- `LOG_LEVEL` controla el nivel mínimo registrado (`debug` | `info` | `warn` | `error`)
- `NODE_ENV=production`: nivel por defecto `info`, sin `stack` en logs
- `NODE_ENV=development`: nivel por defecto `debug`, con `stack` completo + salida colorizada a `stdout`

### Escenario 8 — Body del request en errores con sanitización

**Dado** que un request `POST`, `PUT` o `PATCH` falla con código 4xx o 5xx  
**Cuando** el `HttpExceptionFilter` genera la entrada de log  
**Entonces:**
- Se agrega el campo `requestBody` al log con el body parseado del request
- Antes de persistir, se aplica sanitización recursiva: cualquier campo cuyo nombre coincida con la lista negra se reemplaza por `"***REDACTED***"`
- Lista negra de campos sensibles (case-insensitive):
  `password`, `confirmPassword`, `currentPassword`, `newPassword`,
  `token`, `accessToken`, `refreshToken`, `apiKey`, `secret`,
  `creditCard`, `cardNumber`, `cvv`, `pin`
- `email` **no** es campo sensible — se permite en claro en el body; si se necesita identificar al usuario se cruza por `userId` que ya está en el log
- Si el body supera **10 KB** se trunca y se agrega `"requestBodyTruncated": true`
- En requests exitosos (2xx/3xx) **no se guarda el body** — el dato ya persiste en BD vía HU-051
- Métodos `GET` y `DELETE` no tienen body; el campo se omite (`null`)

Ejemplo de entrada de log con body sanitizado:

```json
{
  "timestamp": "2026-05-27T15:10:44.321Z",
  "level": "warn",
  "correlationId": "9f8e7d6c-5b4a-3210-fedc-ba9876543210",
  "method": "PUT",
  "url": "/api/auth/change-password",
  "statusCode": 400,
  "responseTimeMs": 23,
  "userId": "usr_abc123",
  "userEmail": "juan.mejia@iadataflow.com",
  "ip": "192.168.1.10",
  "browser": "Chrome 124.0",
  "os": "Windows 11",
  "userAgent": "Mozilla/5.0 ...",
  "referer": null,
  "contentLength": 89,
  "errorMessage": "New password does not meet complexity requirements",
  "errorCode": "WEAK_PASSWORD",
  "requestBody": {
    "currentPassword": "***REDACTED***",
    "newPassword": "***REDACTED***",
    "confirmPassword": "***REDACTED***"
  },
  "requestBodyTruncated": false,
  "message": "PUT /api/auth/change-password 400 23ms"
}
```

---

## Estructura de Archivos a Entregar

```
apps/api/src/
├── common/
│   ├── interceptors/
│   │   └── logging.interceptor.ts    # Interceptor global — captura request completo
│   ├── filters/
│   │   └── http-exception.filter.ts  # Filtro global — extiende log con datos de error
│   └── logger/
│       ├── logger.module.ts          # Módulo global (isGlobal: true)
│       ├── logger.service.ts         # Wrapper tipado de Winston
│       └── logger.config.ts         # Transports, rotación, formato JSON
└── main.ts                           # Registrar APP_INTERCEPTOR y APP_FILTER globalmente
```

```
docker-compose.yml    # + volumen api_logs declarado y montado en servicio api
.env.example          # + LOG_LEVEL=info, LOG_DIR=/app/logs
```

---

## Rutas HTTP Esperadas

> Este módulo **no expone endpoints propios**. Es infraestructura transversal.  
> El header `X-Correlation-Id` se inyecta en **todas** las respuestas del API automáticamente.

---

## Notas Técnicas

- **Winston** como motor de logging; integrar con `nest-winston` para reemplazar el `Logger` nativo de NestJS globalmente.
- `correlationId` propagado con `AsyncLocalStorage` (Node.js built-in) para disponibilidad en todas las capas sin pasar por parámetros.
- `ua-parser-js` para parsear `browser` y `os` desde el `User-Agent`; es liviano y sin dependencias nativas.
- El `LoggingInterceptor` se registra en `AppModule` como `APP_INTERCEPTOR`; el `HttpExceptionFilter` como `APP_FILTER`. Sin tocar controladores existentes.
- El volumen `api_logs` es **named volume** (no bind mount) para portabilidad entre Windows/Mac/Linux del equipo. Inspeccionar con `docker volume inspect iadataflow_api_logs`.
- **No solapar con HU-051 (Auditoría):** HU-072 = logs operacionales de infraestructura (trazabilidad de requests). HU-051 = logs de negocio (cambios en entidades, reversiones). Coexisten con propósitos distintos.
- El `correlationId` es el vínculo entre un log de acceso (HU-072) y un audit log (HU-051) para un mismo request.
