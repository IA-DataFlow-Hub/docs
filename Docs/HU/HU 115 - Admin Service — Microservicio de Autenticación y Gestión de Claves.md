# Historias de Usuario — Admin Service

> Generado el 30 de mayo de 2026
> **Asignado a:** JuanDiegoWS (keitem99+claude@gmail.com)

---

## Contexto

El `mailer-service` (y futuros microservicios) necesitan un sistema de autenticación centralizado.
Hoy usan una API key estática en `.env`. El **Admin Service** es un microservicio NestJS independiente
que gestiona API Keys y OAuth 2.0 clients, emite JWT, y permite a cualquier microservicio del monorepo
validar tokens de forma stateless (solo necesitan `JWT_SECRET` compartido, sin llamadas al admin-service en cada request).

**Arquitectura objetivo:**

```
apps/
├── admin-service/     ← HU-115 a HU-118: este microservicio
│   └── SQLite propio (api_keys, oauth_clients)
├── mailer-service/    ← valida JWT con JWT_SECRET (stateless)
└── api/               ← valida JWT con JWT_SECRET (stateless)
```

---

## HU-115: Estructura Base del Admin Service

**Como** desarrollador del equipo,
**quiero** tener un microservicio NestJS independiente en `apps/admin-service/`
con su propia base de datos SQLite, Swagger, logger Winston y Docker,
**para** centralizar la gestión de autenticación de todos los microservicios del monorepo
sin acoplarla al mailer-service ni al API principal.

### Criterios de Aceptación

- El servicio debe levantarse en el puerto `3003` (configurable vía `ADMIN_PORT`)
- Debe tener su propia base de datos SQLite en `/app/data/admin.sqlite` dentro del contenedor
- El volumen Docker `admin_data` debe persistir la base de datos entre reinicios
- Debe exponer `GET /health` sin autenticación que retorne `{ status: "ok", timestamp }`
- Debe tener Swagger en `GET /docs` (desactivable con `SWAGGER_ENABLED=false`)
- Debe tener logger Winston con rotación diaria en `/app/logs/` (volumen `admin_logs`)
- El `docker-compose.yml` debe incluir el servicio `admin` con healthcheck
- Debe tener un `Dockerfile` multistage igual al del mailer-service (deps → builder → runtime)
- El usuario en el contenedor debe ser no-root (`nestjs`, uid 1001)
- El `.env.example` debe documentar todas las variables requeridas

### Variables de entorno requeridas

| Variable | Descripción | Ejemplo |
|---|---|---|
| `ADMIN_PORT` | Puerto del servicio | `3003` |
| `ADMIN_KEY` | Clave maestra para endpoints `/admin/*` | `change-me` |
| `JWT_SECRET` | Secret compartido para firmar JWT | `change-jwt-secret` |
| `JWT_EXPIRES_IN` | TTL de los JWT emitidos | `3600` (segundos) |
| `DB_PATH` | Ruta del SQLite | `./data/admin.sqlite` |
| `CORS_ORIGINS` | Origins CORS permitidos | `*` |
| `LOG_LEVEL` | Nivel de log | `info` |
| `SWAGGER_ENABLED` | Activar Swagger | `true` |

### Notas

- Depende de: [[✅ HU 036 - Estructura Base del API NestJS|HU-036]] (patrón NestJS Clean Architecture)
- Depende de: [[✅ HU 013 - Configuración de Infraestructura de Datos (Docker)|HU-013]] (Docker compose)
- El `JWT_SECRET` debe ser el mismo valor que usen `mailer-service` y `apps/api` para validar tokens
- TypeORM con SQLite (`synchronize: true` en desarrollo, migraciones en producción)

---

## HU-116: Gestión de API Keys

**Como** administrador del sistema,
**quiero** poder crear, listar, activar, desactivar y eliminar API Keys desde el Admin Service,
**para** controlar qué servicios o aplicaciones tienen acceso a los microservicios del monorepo
sin exponer las claves reales tras la creación.

### Criterios de Aceptación

- `POST /admin/api-keys` debe crear una API Key con nombre y scopes opcionales
  - La respuesta incluye el campo `key` (valor completo con prefijo `ak_`) **solo en la creación**
  - El sistema debe almacenar solo el hash SHA-256 de la clave, nunca el valor plano
  - Si no se envían `scopes`, el default es `["mail:send"]`
- `GET /admin/api-keys` debe listar todas las API Keys **sin exponer** el valor real
  - Cada item incluye: `id`, `name`, `scopes`, `isActive`, `createdAt`, `lastUsedAt`, `expiresAt`
- `PATCH /admin/api-keys/:id/activate` debe activar una API Key desactivada
- `PATCH /admin/api-keys/:id/deactivate` debe desactivar una API Key activa
- `DELETE /admin/api-keys/:id` debe eliminar una API Key (responde `204 No Content`)
- Todos los endpoints requieren header `x-admin-key` con el valor de `ADMIN_KEY`
- Responde `401` si `x-admin-key` es inválido o ausente
- Responde `404` si el id no existe

### Esquema de la entidad `ApiKey`

```
id          UUID (PK)
name        VARCHAR(100)
keyHash     VARCHAR(64)   ← SHA-256 del valor plano
scopes      TEXT          ← JSON array serializado
isActive    BOOLEAN       default true
expiresAt   DATETIME      nullable
lastUsedAt  DATETIME      nullable
createdAt   DATETIME      default now
```

### Notas

- Depende de: [[HU 115 - Admin Service — Microservicio de Autenticación y Gestión de Claves|HU-115]]
- La API Key completa (`ak_<hex>`) debe ser 48 bytes hexadecimales con prefijo (`ak_` + 48 chars = 51 chars total)
- El `lastUsedAt` se actualiza cuando otro microservicio valida la clave vía endpoint de verificación (HU-118)

---

## HU-117: Gestión de OAuth 2.0 Clients

**Como** administrador del sistema,
**quiero** poder registrar, listar, activar, desactivar y eliminar OAuth 2.0 clients,
**para** que servicios machine-to-machine obtengan JWT de corta duración usando `client_credentials`
en lugar de API keys estáticas.

### Criterios de Aceptación

- `POST /admin/oauth/clients` debe crear un OAuth client con nombre y scopes opcionales
  - La respuesta incluye `clientSecret` (valor completo con prefijo `sk_`) **solo en la creación**
  - El sistema almacena solo el hash bcrypt del secret, nunca el valor plano
  - Si no se envían `scopes`, el default es `["mail:send"]`
- `GET /admin/oauth/clients` debe listar todos los clients **sin exponer** el secret
  - Cada item incluye: `id`, `name`, `scopes`, `isActive`, `createdAt`
- `PATCH /admin/oauth/clients/:id/activate` debe activar un client desactivado
- `PATCH /admin/oauth/clients/:id/deactivate` debe desactivar un client activo
- `DELETE /admin/oauth/clients/:id` debe eliminar el client (responde `204 No Content`)
- Todos los endpoints requieren header `x-admin-key`
- Responde `401` si `x-admin-key` es inválido o ausente
- Responde `404` si el id no existe

### Esquema de la entidad `OAuthClient`

```
id                UUID (PK)
name              VARCHAR(100)
clientSecretHash  VARCHAR(60)   ← bcrypt hash
scopes            TEXT          ← JSON array serializado
isActive          BOOLEAN       default true
createdAt         DATETIME      default now
```

### Notas

- Depende de: [[HU 115 - Admin Service — Microservicio de Autenticación y Gestión de Claves|HU-115]]
- El `client_id` es el campo `id` (UUID) retornado en la creación
- El `clientSecret` completo es `sk_` + 48 bytes hex

---

## HU-118: Emisión y Verificación de Tokens JWT

**Como** microservicio del monorepo (mailer-service, api, futuros servicios),
**quiero** poder obtener un JWT de acceso presentando `client_id` + `client_secret`,
y verificarlo de forma stateless usando el `JWT_SECRET` compartido,
**para** autenticar requests machine-to-machine sin depender de una llamada al Admin Service en cada petición.

### Criterios de Aceptación

#### Emisión (`POST /auth/token`)

- El endpoint es **público** (no requiere `x-admin-key`)
- Acepta `Content-Type: application/json` y `application/x-www-form-urlencoded`
- Body requerido: `{ grant_type: "client_credentials", client_id, client_secret }`
- El sistema debe validar que:
  - El `client_id` existe en la BD
  - El `client_secret` coincide con el hash almacenado (bcrypt compare)
  - El client está activo (`isActive: true`)
- Respuesta exitosa `201`:
  ```json
  {
    "access_token": "<JWT>",
    "token_type": "Bearer",
    "expires_in": 3600
  }
  ```
- El JWT debe incluir en el payload: `sub` (client_id), `scopes`, `iss` ("admin-service")
- Responde `401` si las credenciales son inválidas o el client está desactivado

#### Verificación de API Key (`POST /auth/verify-key`) — opcional para microservicios sin JWT

- El endpoint es **público**
- Body: `{ key: "ak_..." }`
- Valida la clave contra los hashes almacenados y retorna `{ valid: true, scopes: [...] }`
- Actualiza `lastUsedAt` de la API Key si la validación es exitosa
- Responde `{ valid: false }` si la clave no existe, está desactivada o expirada
- Responde `200` siempre (nunca `401`) para no revelar existencia de claves

#### Validación stateless en microservicios

- Los microservicios (`mailer-service`, `apps/api`) validan JWT localmente usando `JWT_SECRET`
- No necesitan llamar al Admin Service en cada request (stateless)
- Solo usan `POST /auth/verify-key` para API Keys (con estado en BD)

### Notas

- Depende de: [[HU 116 - Admin Service — Microservicio de Autenticación y Gestión de Claves|HU-116]], [[HU 117 - Admin Service — Microservicio de Autenticación y Gestión de Claves|HU-117]]
- `JWT_SECRET` debe configurarse idéntico en `admin-service`, `mailer-service` y `apps/api`
- El JWT tiene `expiresIn` configurable via `JWT_EXPIRES_IN` (default: `3600` segundos)
- Implementar con `@nestjs/jwt`
- El `grant_type` por ahora solo soporta `client_credentials`; otros flujos son futura expansión

---

## Resumen de HUs

| # | Título | Tamaño | Depende de |
|---|--------|--------|-----------|
| HU-115 | Estructura base Admin Service | L | HU-036, HU-013 |
| HU-116 | Gestión de API Keys | M | HU-115 |
| HU-117 | Gestión de OAuth Clients | M | HU-115 |
| HU-118 | Emisión y verificación de JWT | M | HU-116, HU-117 |

**Orden de implementación:** HU-115 → HU-116 + HU-117 (paralelo) → HU-118

## Documentos relacionados

**Arquitectura:** [[ARQUITECTURA]] · [[DOCKERIZACION]]
**Mailer (consumidor):** [[HU 073 - Microservicio de Envío de Correos|HU-073]] · [[mailer-service]]
**Base:** [[✅ HU 036 - Estructura Base del API NestJS|HU-036]] · [[✅ HU 013 - Configuración de Infraestructura de Datos (Docker)|HU-013]]
**Auth existente:** [[✅ HU 040 - Módulo Auth y Gestión de Sesiones|HU-040]]
