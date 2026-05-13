# Diagrama 4 — Flujo de Autenticación

**Qué muestra:** Cómo un usuario inicia sesión (credenciales o Google OAuth), obtiene tokens JWT y cómo el API los valida en cada petición protegida.

**Última actualización:** 2026-05-12

---

## 4a — Login y emisión de tokens

```mermaid
sequenceDiagram
    actor U as 👤 Usuario
    participant FE as React Frontend
    participant API as NestJS API
    participant DB as MySQL
    participant G as Google OAuth

    alt Login con email + contraseña
        U->>FE: Ingresa email y contraseña
        FE->>API: POST /auth/login
        API->>DB: Busca user por email
        DB-->>API: Registro del usuario
        API->>API: Valida bcrypt(password, hash)
        alt Credenciales incorrectas
            API-->>FE: 401 Unauthorized
            FE-->>U: Credenciales inválidas
        end
    else Login con Google OAuth
        U->>FE: Click en Continuar con Google
        FE->>G: Redirige a Google OAuth consent
        G-->>FE: Código de autorización
        FE->>API: POST /auth/google con code
        API->>G: Intercambia code por id_token
        G-->>API: Perfil del usuario
        API->>DB: Busca o crea usuario por email
        DB-->>API: Registro del usuario
    end

    API->>API: Genera access_token JWT con exp 15 min
    API->>API: Genera refresh_token opaco con exp 7 días
    API->>DB: Guarda refresh_token_hash en sessions
    API-->>FE: 200 OK con access_token y refresh_token
    FE->>FE: Guarda tokens en memoria o localStorage
    FE-->>U: Redirige al Dashboard
```

---

## 4b — Petición autenticada con JWT

```mermaid
sequenceDiagram
    actor U as 👤 Usuario
    participant FE as React Frontend
    participant API as NestJS API
    participant DB as MySQL

    U->>FE: Navega a una sección protegida
    FE->>API: GET /api/projects — Authorization: Bearer access_token
    API->>API: JwtGuard valida firma y expiración
    alt Token válido
        API->>DB: Consulta datos del recurso
        DB-->>API: Datos
        API-->>FE: 200 OK
        FE-->>U: Muestra el contenido
    else Token expirado
        API-->>FE: 401 Unauthorized
        FE->>API: POST /auth/refresh con refresh_token
        API->>DB: Busca sesión por refresh_token_hash
        alt Refresh token válido
            API->>API: Genera nuevo access_token
            API-->>FE: 200 OK con nuevo access_token
            FE->>API: Reintenta la petición original
            API-->>FE: 200 OK
            FE-->>U: Muestra el contenido
        else Refresh token expirado
            API-->>FE: 401 Unauthorized
            API->>DB: Elimina sesión
            FE-->>U: Redirige al Login
        end
    end
```

---

## Resumen de tokens

| Token | Tipo | Duración | Almacenamiento | Uso |
|---|---|---|---|---|
| `access_token` | JWT firmado HS256 | 15 minutos | Memoria del frontend | Cada petición a la API |
| `refresh_token` | Opaco — hash en DB | 7 días | `sessions` table | Renovar el access_token |

## Notas

- El `JWT_SECRET` se define en `.env` y nunca se expone en logs ni respuestas.
- Cada sesión activa tiene una fila en `sessions`; el logout la elimina, invalidando el refresh_token.
- El guard `JwtGuard` de NestJS intercepta todas las rutas marcadas con `@UseGuards(JwtGuard)`.
- Si el usuario tiene múltiples dispositivos, cada uno tiene su propia fila en `sessions` (HU-024).
