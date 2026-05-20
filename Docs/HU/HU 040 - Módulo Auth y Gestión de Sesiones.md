# HU-040 — Módulo de Autenticación y Gestión de Sesiones

## Asignación de Tablas

`users` (creación inicial) · `credentials` · `password_history` · `identity_providers` · `auth_methods` · `sessions`

---

## Historia de Usuario

**Como** desarrollador del equipo,  
**Quiero** implementar el módulo vertical de Autenticación siguiendo Clean Architecture,  
**Para** gestionar el registro, login local y OAuth, renovación de tokens JWT, historial de contraseñas y el ciclo de vida completo de sesiones por dispositivo.

**Dependencia:** Requiere HU-036 (estructura base del API) completada.

---

## Estructura de Archivos a Entregar

```
apps/api/src/modules/auth/
├── auth.module.ts
├── domain/
│   ├── entities/
│   │   ├── credential.entity.ts
│   │   └── session.entity.ts
│   └── repositories/
│       ├── credential.repository.interface.ts
│       └── session.repository.interface.ts
├── application/
│   ├── dtos/
│   │   ├── register.dto.ts
│   │   ├── login.dto.ts
│   │   ├── oauth-callback.dto.ts
│   │   ├── refresh-token.dto.ts
│   │   ├── change-password.dto.ts
│   │   └── auth-response.dto.ts
│   ├── use-cases/
│   │   ├── register-user.use-case.ts
│   │   ├── login-user.use-case.ts
│   │   ├── oauth-login.use-case.ts
│   │   ├── refresh-token.use-case.ts
│   │   ├── change-password.use-case.ts
│   │   ├── revoke-session.use-case.ts
│   │   └── logout.use-case.ts
│   └── facades/
│       └── auth.facade.ts
└── infrastructure/
    ├── controllers/
    │   └── auth.controller.ts
    └── persistence/
        ├── prisma-credential.repository.ts
        ├── prisma-session.repository.ts
        └── mappers/
            ├── credential.mapper.ts
            └── session.mapper.ts
```

---

## Criterios de Aceptación Técnicos

### Escenario 1 — Registro local con contraseña

**Dado** que se recibe un `RegisterDto` con `email` único y `password` que cumple mínimo 8 caracteres  
**Cuando** `RegisterUserUseCase` ejecuta  
**Entonces:**
- La entidad `Credential` valida la longitud del password antes de llegar a persistencia; si falla, lanza `WeakPasswordException`.
- Se crea el `User` con `id_user_status = 1` (active) a través del módulo Users (inyectado vía interfaz).
- Se inserta en `credentials` con `id_auth_method = 1` (password) y el hash + salt.
- Se registra la contraseña en `password_history` (historial de últimas 5).
- Se retorna un `AuthResponseDto` con `access_token`, `refresh_token` y perfil básico del usuario.

### Escenario 2 — Login OAuth Google

**Dado** que se recibe un `OAuthCallbackDto` con token de Google válido  
**Cuando** `OAuthLoginUseCase` verifica el token con el proveedor (`id_provider = 1`)  
**Entonces:**
- Busca en `credentials` por `provider_user_id`. Si no existe, crea el `User` y el registro en `credentials` con `provider_id = 1` e `id_auth_method = 2` (google).
- Si el email ya existe vinculado a un método diferente (password), lanza `DuplicateProviderException` con código `AUTH_PROVIDER_CONFLICT`.
- Registra una nueva `Session` con `browser_name`, `device_type`, `ip_address` y `login_at = now()`.
- Retorna JWT + `refresh_token`.

### Escenario 3 — Revocación remota de sesión

**Dado** que un usuario autenticado solicita revocar una sesión activa (propia o de otro dispositivo)  
**Cuando** `RevokeSessionUseCase` recibe el `id_session`  
**Entonces:**
- Verifica que la sesión pertenezca al usuario autenticado; si no, lanza `SessionOwnershipException`.
- Actualiza `revoked_at = now()`, `revoke_reason`, `status = 'revoked'` e `is_current = false`.
- El registro de sesión **no se elimina físicamente** (soft pattern para auditoría).
- Si se revoca la sesión actual (`is_current = true`), el `access_token` en circulación queda inválido en el siguiente ciclo de validación del `JwtAuthGuard`.

### Escenario 4 — Cambio de contraseña con validación de historial

**Dado** que `ChangePasswordDto` contiene la contraseña actual y la nueva  
**Cuando** `ChangePasswordUseCase` ejecuta  
**Entonces:**
- Verifica que la contraseña actual sea correcta comparando el hash.
- Consulta `password_history` y lanza `PasswordReusedException` si el hash de la nueva contraseña coincide con alguna de las últimas 5.
- Actualiza `credentials.password_hash`, `credentials.last_password_change` e inserta en `password_history`.

---

## Rutas HTTP Esperadas

| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/auth/register` | Registro con contraseña |
| POST | `/auth/login` | Login local |
| POST | `/auth/oauth/google` | Login con Google |
| POST | `/auth/refresh` | Renovar access_token |
| POST | `/auth/logout` | Cierra sesión actual |
| POST | `/auth/change-password` | Cambia contraseña |
| GET | `/auth/sessions` | Lista sesiones activas del usuario |
| DELETE | `/auth/sessions/:id` | Revoca sesión específica |

---

## Notas Técnicas

- Los tokens JWT se firman con `JWT_SECRET` y tienen expiración de `JWT_EXPIRES_IN` (15m por defecto).
- El `refresh_token` se almacena hasheado en `sessions.refresh_token` con expiración `JWT_REFRESH_EXPIRES_IN` (7d).
- El `JwtAuthGuard` (definido en HU-036) debe verificar que la sesión no esté `revoked` ni `expired`.
- Las rutas `/auth/register` y `/auth/login` son públicas (`@Public()`).
