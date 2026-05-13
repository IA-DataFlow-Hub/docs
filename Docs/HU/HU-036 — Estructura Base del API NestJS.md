# HU-036 — Estructura Base del API (NestJS)

## Historia de Usuario

**Como** equipo de desarrollo del backend,  
**Quiero** tener la estructura de módulos, guards, interceptors y respuestas estandarizadas del API lista,  
**Para** que cada módulo de negocio (auth, proyectos, archivos, etc.) se pueda desarrollar de forma consistente sin tomar decisiones arquitectónicas cada vez.

---

## Contexto

El backend actual es solo el boilerplate de NestJS con un "Hello World". Esta HU construye el esqueleto del API — todo lo que es transversal y que los demás módulos van a reutilizar.

**No depende de la base de datos:** se puede construir completo y después conectar Prisma cuando el schema esté listo.

---

## Criterios de Aceptación

- [ ] Estructura de carpetas definida y aplicada.
- [ ] Respuesta estandarizada para todos los endpoints (éxito y error).
- [ ] Guard JWT funcional (rechaza peticiones sin token válido).
- [ ] Interceptor de logging que registra cada petición con método, ruta y tiempo de respuesta.
- [ ] Pipe de validación global con `class-validator`.
- [ ] Manejo global de excepciones con mensajes claros al cliente.
- [ ] Endpoint `GET /health` que confirma que el API está vivo.
- [ ] Variables de entorno cargadas y tipadas con `@nestjs/config`.
- [ ] El API corre en Docker sin errores.

---

## Estructura de Carpetas

```
apps/api/src/
├── main.ts
├── app.module.ts
├── common/
│   ├── decorators/          ← @CurrentUser(), @Public(), @Roles()
│   ├── filters/             ← GlobalExceptionFilter
│   ├── guards/              ← JwtAuthGuard, RolesGuard
│   ├── interceptors/        ← LoggingInterceptor, ResponseInterceptor
│   ├── pipes/               ← ValidationPipe global
│   └── dto/
│       └── pagination.dto.ts
├── config/
│   └── config.module.ts     ← variables de entorno tipadas
├── health/
│   └── health.controller.ts ← GET /health
└── modules/                 ← aquí van los módulos de negocio (auth, users, etc.)
```

---

## Formato de Respuesta Estandarizado

Todas las respuestas del API siguen el mismo formato:

**Éxito:**
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "timestamp": "2026-05-10T14:30:00Z",
    "path": "/api/projects"
  }
}
```

**Error:**
```json
{
  "success": false,
  "error": {
    "code": "RESOURCE_NOT_FOUND",
    "message": "El proyecto no existe.",
    "statusCode": 404
  },
  "meta": {
    "timestamp": "2026-05-10T14:30:00Z",
    "path": "/api/projects/abc-123"
  }
}
```

**Paginación:**
```json
{
  "success": true,
  "data": [ ... ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 143,
    "totalPages": 8
  }
}
```

---

## Tareas

1. [ ] Definir estructura de carpetas y crear archivos vacíos.
2. [ ] Crear `ResponseInterceptor` que envuelve todas las respuestas exitosas en el formato estándar.
3. [ ] Crear `GlobalExceptionFilter` que convierte excepciones en respuestas de error estandarizadas.
4. [ ] Crear `LoggingInterceptor` que registra método, ruta, status y tiempo de respuesta.
5. [ ] Configurar `ValidationPipe` global con `transform: true` y `whitelist: true`.
6. [ ] Crear `JwtAuthGuard` y decorador `@Public()` para rutas abiertas.
7. [ ] Crear decorador `@CurrentUser()` para extraer el usuario autenticado del request.
8. [ ] Crear `config.module.ts` con las variables de entorno tipadas (`DATABASE_URL`, `JWT_SECRET`, etc.).
9. [ ] Crear `GET /health` que devuelve `{ status: "ok", uptime: ... }`.
10. [ ] Verificar que todo corre en Docker con `docker-compose up api`.

---

## Variables de Entorno Requeridas

```bash
PORT=3000
NODE_ENV=development
DATABASE_URL=mysql://...
JWT_SECRET=...
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=...
JWT_REFRESH_EXPIRES_IN=7d
OLLAMA_URL=http://ollama:11434
GEMINI_API_KEY=...
N8N_WEBHOOK_URL=http://n8n:5678/webhook
```

## Prioridad

**Alta** — todos los módulos de negocio dependen de esta base. Debe completarse antes que Auth, Users, Projects, etc.
